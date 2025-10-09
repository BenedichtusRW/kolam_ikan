import 'package:flutter/material.dart';
import '../admin/user_dashboard_view_screen.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({Key? key}) : super(key: key);

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  String _selectedFilter = 'All Users';
  List<String> _filterOptions = ['All Users', 'Active Users', 'Inactive Users'];

  // Mock data untuk user reports
  List<Map<String, dynamic>> _userReports = [
    {
      'id': 'user_001',
      'name': 'Budi Santoso',
      'email': 'budi@example.com',
      'pondId': 'pond_001',
      'pondName': 'Kolam A',
      'status': 'active',
      'lastActivity': DateTime.now().subtract(Duration(hours: 2)),
      'sensorCount': 4,
      'alertCount': 2,
    },
    {
      'id': 'user_002',
      'name': 'Siti Nurhaliza',
      'email': 'siti@example.com',
      'pondId': 'pond_002',
      'pondName': 'Kolam B',
      'status': 'active',
      'lastActivity': DateTime.now().subtract(Duration(hours: 5)),
      'sensorCount': 4,
      'alertCount': 0,
    },
    {
      'id': 'user_003',
      'name': 'Ahmad Rahman',
      'email': 'ahmad@example.com',
      'pondId': 'pond_003',
      'pondName': 'Kolam C',
      'status': 'inactive',
      'lastActivity': DateTime.now().subtract(Duration(days: 2)),
      'sensorCount': 3,
      'alertCount': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Laporan User'),
        backgroundColor: const Color.fromARGB(255, 57, 73, 171),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Filter:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: _filterOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Summary Cards
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Users',
                    '${_userReports.length}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Active Users',
                    '${_userReports.where((u) => u['status'] == 'active').length}',
                    Icons.people_alt,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Alerts',
                    '${_userReports.fold<int>(0, (sum, u) => sum + (u['alertCount'] as int))}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getFilteredUsers().length,
              itemBuilder: (context, index) {
                final user = _getFilteredUsers()[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    switch (_selectedFilter) {
      case 'Active Users':
        return _userReports.where((u) => u['status'] == 'active').toList();
      case 'Inactive Users':
        return _userReports.where((u) => u['status'] == 'inactive').toList();
      default:
        return _userReports;
    }
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    bool isActive = user['status'] == 'active';
    DateTime lastActivity = user['lastActivity'];
    String timeAgo = _getTimeAgo(lastActivity);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  child: Text(
                    user['name'].toString().substring(0, 1).toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    _handleUserAction(value, user);
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'dashboard',
                      child: Row(
                        children: [
                          Icon(Icons.dashboard, size: 18),
                          SizedBox(width: 8),
                          Text('View Dashboard'),
                        ],
                      ),
                    ),
                    // Removed Edit User and Generate Report per request
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            // Info Grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Pond', user['pondName'], Icons.pool),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Sensors',
                    '${user['sensorCount']}',
                    Icons.sensors,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Alerts',
                    '${user['alertCount']}',
                    Icons.warning,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Last Active',
                    timeAgo,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'dashboard':
        _viewUserDashboard(user);
        break;
      default:
        break;
    }
  }

  void _viewUserDashboard(Map<String, dynamic> user) {
    // Navigate directly to the User Dashboard (no download dialog here)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDashboardViewScreen(
          userId: user['id'] ?? user['userId'] ?? 'unknown',
          userName: user['name'] ?? 'Unknown User',
          pondId: user['pondId'] ?? 'pond_001',
          pondName: user['pondName'] ?? 'Unknown Pond',
        ),
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', user['name']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('User ID', user['id']),
              _buildDetailRow('Pond ID', user['pondId']),
              _buildDetailRow('Pond Name', user['pondName']),
              _buildDetailRow('Status', user['status']),
              _buildDetailRow('Sensors', '${user['sensorCount']}'),
              _buildDetailRow('Alerts', '${user['alertCount']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
