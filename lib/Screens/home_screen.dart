import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app_name/Services/auth_service.dart';
import 'package:your_app_name/Services/notification_service.dart';
import 'package:your_app_name/Screens/preferences_screen.dart';
import 'package:your_app_name/Screens/notification_history_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;  // Controls the current tab.
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.init();  // Set up notifications.
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.purple.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar with title and sign out button.
              _buildAppBar(authService),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,  // Switch between tabs.
                  children: [
                    _buildDashboard(authService),
                    _buildNotificationCenter(),
                    _buildProfile(authService),
                  ],
                ),
              ),
              // Bottom navigation bar to switch between screens.
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  // Custom app bar with sign-out functionality.
  Widget _buildAppBar(AuthService authService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Home',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Sign-out button
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await authService.signOut(context);  // Call the sign out function.
              Navigator.of(context).pushReplacementNamed('/auth');  // Navigate back to login.
            },
          ),
        ],
      ),
    );
  }

  // Main dashboard with stats and quick actions.
  Widget _buildDashboard(AuthService authService) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greet the user by their name.
            Text(
              'Welcome, ${authService.currentUser?.displayName ?? "User"}!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _buildNotificationStatsCard(),  // Chart for notification stats.
            SizedBox(height: 20),
            _buildQuickActionsCard(),  // Quick action buttons.
            SizedBox(height: 20),
            _buildRecentActivityCard(),  // Show recent notifications.
          ],
        ),
      ),
    );
  }

  // Card displaying a line chart with notification stats.
  Widget _buildNotificationStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Stats',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Displaying the line chart using fl_chart package.
              Container(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),  
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),  
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),  
                      ),
                    ),
                    borderData: FlBorderData(show: false),  // Hide chart borders.
                    minX: 0, maxX: 6,  // X-axis range for notification counts.
                    minY: 0, maxY: 6,  // Y-axis range for notification counts.
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 3),  // Data points for the chart.
                          FlSpot(1, 1),
                          FlSpot(2, 4),
                          FlSpot(3, 2),
                          FlSpot(4, 5),
                          FlSpot(5, 1),
                          FlSpot(6, 4),                        ],
                        isCurved: true,  // Curved line for smooth transition.
                        color: Colors.white,  
                        barWidth: 4,  
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withOpacity(0.3),  
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick actions like Preferences, History, and Test Notification.
  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.teal.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Preferences button.
                  _buildQuickActionButton(
                    icon: Icons.settings,
                    label: 'Preferences',
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PreferencesScreen()),
                      );
                    },
                  ),
                  // Notification history button.
                  _buildQuickActionButton(
                    icon: Icons.history,
                    label: 'History',
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationHistoryScreen()),
                      );
                    },
                  ),
                  // Test notification button.
                  _buildQuickActionButton(
                    icon: Icons.notifications_active,
                    label: 'Test',
                    color: Colors.white,
                    onPressed: () {
                      _notificationService.sendTargetedNotification();  // Trigger a test notification.
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create quick action buttons.
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Icon(icon, size: 30, color: Colors.teal.shade700),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  // Recent activity card showing recent notifications.
  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.deepOrange.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Display recent notifications using FutureBuilder.
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _notificationService.getRecentNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();  // Show loading indicator.
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No recent notifications');
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final notification = snapshot.data![index];
                        return ListTile(
                          leading: Icon(Icons.notifications, color: Colors.white),
                          title: Text(
                            notification['title'] ?? 'No title',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            notification['body'] ?? 'No body',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            _formatTimestamp(notification['timestamp']),
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format the notification timestamp.
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
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

  // Notification center screen (placeholder).
  Widget _buildNotificationCenter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications,
            size: 100,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Notification Center',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'You have no new notifications',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // User profile screen.
  Widget _buildProfile(AuthService authService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              authService.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(fontSize: 40, color: Colors.blue.shade700),
            ),
          ),
          SizedBox(height: 20),
          Text(
            authService.currentUser?.displayName ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            authService.currentUser?.email ?? '',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Implement edit profile functionality (placeholder).
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Edit Profile'),
                  content: Text('This feature is not implemented yet.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom navigation bar for switching between dashboard, notifications, and profile.
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.purple.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,  // Current selected tab.
        onTap: (index) {
          setState(() {
            _selectedIndex = index;  // Switch tabs.
          });
        },
        backgroundColor: Colors.transparent,  
        selectedItemColor: Colors.white,  
        unselectedItemColor: Colors.white60,  
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
