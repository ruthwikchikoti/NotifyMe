import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:your_app_name/Services/auth_service.dart';

/// Screen for displaying the notification history of the current user.
class NotificationHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user from the AuthService
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Notification History')),
      body: StreamBuilder<QuerySnapshot>(
        // Stream of notifications for the current user
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true) // Sort by timestamp, newest first
            .snapshots(),
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Building the list of notifications
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // Geting the data from the document snapshot
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              // Build a ListTile for each notification
              return ListTile(
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text(data['body'] ?? 'No body'),
                trailing: Text(data['timestamp'].toDate().toString()),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
