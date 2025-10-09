import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import 'user_dashboard_view_screen.dart';
import '../../services/export_service.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        title: Text(
          'Daftar User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onExportSemua(context),
        label: Text('Export Semua'),
        icon: Icon(Icons.download_rounded),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Kelola dan Pantau Semua User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pilih user untuk melihat dashboard mereka',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            
            // User List
            _buildUserList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    // Sample users - in real app, this would come from Firebase
    final sampleUsers = [
      UserProfile(
        uid: 'user1',
        email: 'petani1@gmail.com',
        name: 'Petani A - Kolam Lele',
        role: 'user',
        pondId: 'pond1',
      ),
      UserProfile(
        uid: 'user2',
        email: 'petani2@gmail.com',
        name: 'Petani B - Kolam Nila',
        role: 'user',
        pondId: 'pond2',
      ),
      UserProfile(
        uid: 'user3',
        email: 'petani3@gmail.com',
        name: 'Petani C - Kolam Gurame',
        role: 'user',
        pondId: 'pond3',
      ),
      UserProfile(
        uid: 'user4',
        email: 'farmer@example.com',
        name: 'Farmer D - Kolam Mujair',
        role: 'user',
        pondId: 'pond4',
      ),
    ];

    return Column(
      children: sampleUsers.map((user) => _buildUserCard(context, user)).toList(),
    );
  }

  void _onExportSemua(BuildContext context) async {
    // Gather pondIds from sample users for now
    final sampleUsers = [
      'pond1', 'pond2', 'pond3', 'pond4'
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Export Semua User'),
          content: Text('Pilih format file untuk mengekspor seluruh data user (mock).'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final saved = await ExportService.exportPDF(context: context, pondIds: sampleUsers, date: DateTime.now());
                if (saved != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF disimpan: $saved')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan PDF')));
                }
              },
              child: Text('PDF'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final saved = await ExportService.exportExcel(context: context, pondIds: sampleUsers, date: DateTime.now());
                if (saved != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel disimpan: $saved')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan Excel')));
                }
              },
              child: Text('Excel'),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Batal')),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfile user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboardViewScreen(
                userId: user.uid,
                userName: user.name,
                pondId: 'pond1', // Default pond ID
                pondName: 'Kolam Utama', // Default pond name
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // User Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 57, 73, 171).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: const Color.fromARGB(255, 57, 73, 171),
                ),
              ),
              SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.water,
                          size: 16,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pond ID: ${user.pondId ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status & Arrow
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}