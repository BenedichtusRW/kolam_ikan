import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  // Local cache for demo/testing if Firestore unavailable
  final List<Report> _localReports = [];

  List<Report> get reports => List.unmodifiable(_localReports);

  // Submit a report; enforce once-per-hour per user (by timestamp check)
  Future<bool> submitReport(Report report) async {
    isLoading = true;
    notifyListeners();

    try {
      // Check last report time locally for throttle (for demo)
      Report? last;
      try {
        last = _localReports.reversed.firstWhere(
          (r) => r.userId == report.userId,
        );
      } catch (_) {
        last = null;
      }
      if (last != null) {
        final diff = report.timestamp.difference(last.timestamp).inMinutes;
        if (diff < 60) {
          errorMessage = 'Anda hanya dapat melaporkan setiap 1 jam sekali.';
          isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Try write to Firestore; if fails, store locally
      try {
        final docRef = await _firestore
            .collection('reports')
            .add(report.toMap());
        // Optionally add to local cache
        _localReports.add(
          Report(
            id: docRef.id,
            userId: report.userId,
            userName: report.userName,
            pondId: report.pondId,
            timestamp: report.timestamp,
            temperature: report.temperature,
            ph: report.ph,
            oxygen: report.oxygen,
            note: report.note,
          ),
        );
      } catch (e) {
        // Firestore write failed; fallback to local cache
        _localReports.add(report);
      }

      errorMessage = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Admin: fetch recent reports (from Firestore if available)
  Future<void> fetchRecentReports({int limit = 100}) async {
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      _localReports.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        try {
          _localReports.add(Report.fromMap(data, id: doc.id));
        } catch (_) {}
      }
      errorMessage = null;
    } catch (e) {
      // keep any local cache
      errorMessage = 'Gagal memuat laporan: ${e.toString()}';
    }
    isLoading = false;
    notifyListeners();
  }

  // Return the most recent report timestamp for a given userId (Firestore first, fallback local)
  Future<DateTime?> getLastReportTimeForUser(String userId) async {
    try {
      // Try Firestore query
      final snapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final ts = data['timestamp'];
        if (ts is Timestamp) return ts.toDate();
        if (ts is DateTime) return ts;
      }
    } catch (_) {
      // ignore and fallback to local cache
    }

    // Fallback: local cache
    try {
      final last = _localReports.reversed.firstWhere((r) => r.userId == userId);
      return last.timestamp.toLocal();
    } catch (_) {
      return null;
    }
  }

  // Check whether user must submit a new report (true if none or last >= 60 minutes)
  Future<bool> isReportDue(String userId) async {
    final last = await getLastReportTimeForUser(userId);
    if (last == null) return true;
    final diff = DateTime.now().toUtc().difference(last.toUtc()).inMinutes;
    return diff >= 60;
  }
}
