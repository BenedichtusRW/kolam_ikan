import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report.dart';

class ReportsAdminScreen extends StatefulWidget {
  @override
  _ReportsAdminScreenState createState() => _ReportsAdminScreenState();
}

class _ReportsAdminScreenState extends State<ReportsAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchRecentReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan User'),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.reports.isEmpty) {
            return Center(child: Text('Belum ada laporan'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: provider.reports.length,
            itemBuilder: (context, i) {
              final Report r = provider.reports[i];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(r.userName ?? r.userId),
                  subtitle: Text(
                    'Kolam: ${r.pondId} • ${r.timestamp.toLocal()}',
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Suhu: ${r.temperature.toStringAsFixed(1)}°C'),
                      Text('pH: ${r.ph.toStringAsFixed(2)}'),
                      Text('Oksigen: ${r.oxygen.toStringAsFixed(2)} ppm'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
