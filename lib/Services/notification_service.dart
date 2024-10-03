import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
class NotificationService {
  // The Firebase Cloud Messaging (FCM) service
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // The local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // A timer that is used to send targeted notifications at a regular interval
  Timer? _notificationTimer;

  // Boolean values that determine whether to send targeted notifications of a particular type
  bool _newUpdates = false;
  bool _promotions = false;
  bool _offers = false;

  // Lists of messages that are used for targeted notifications
  final List<String> _updateMessages = [
    "Check out our latest app update!",
    "New features available now",
    "We've improved our app performance"
  ];

  final List<String> _promotionMessages = [
    "Limited time promotion: 50% off!",
    "Special offer for our valued customers",
    "Don't miss out on our biggest sale of the year"
  ];

  final List<String> _offerMessages = [
    "Exclusive offer just for you",
    "Buy one, get one free",
    "Flash sale: Next 24 hours only!"
  ];

  // Initializes the FCM service and sets up the local notifications plugin
  Future<void> init() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      await _initializeLocalNotifications();

      String? token = await _fcm.getToken();
      print('FCM Token: $token');

      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToFirestore);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          _showNotification(message);
        }

        _storeNotification(message);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await _loadPreferences();
      await updateNotificationFrequency('1 min');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Initializes the local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Saves the FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'token': token}, SetOptions(merge: true));
  }

  // Shows a local notification
  Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  // Stores a notification in Firestore
  Future<void> _storeNotification(RemoteMessage message) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Loads the user's notification preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _newUpdates = prefs.getBool('newUpdates') ?? false;
    _promotions = prefs.getBool('promotions') ?? false;
    _offers = prefs.getBool('offers') ?? false;
  }

  // Updates the user's notification preferences
  Future<void> updateNotificationPreferences(String frequency, bool newUpdates, bool promotions, bool offers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newUpdates', newUpdates);
    await prefs.setBool('promotions', promotions);
    await prefs.setBool('offers', offers);

    _newUpdates = newUpdates;
    _promotions = promotions;
    _offers = offers;
    await updateNotificationFrequency(frequency);
  }

  // Updates the frequency of targeted notifications
  Future<void> updateNotificationFrequency(String frequency) async {
    _notificationTimer?.cancel();

    int seconds;
    switch (frequency) {
      case '5 sec':
        seconds = 5;
        break;
      case '10 sec':
        seconds = 10;
        break;
      case '1 min':
        seconds = 60;
        break;
      case 'daily':
        seconds = 86400;
        break;
      case 'weekly':
        seconds = 604800;
        break;
      default:
        seconds = 60;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationFrequency', frequency);

    if (_newUpdates || _promotions || _offers) {
      _notificationTimer = Timer.periodic(Duration(seconds: seconds), (timer) {
        sendTargetedNotification();
      });
    }
  }

  // Sends a targeted notification
  Future<void> sendTargetedNotification() async {
    String? title;
    String? body;

    if (_newUpdates && _promotions && _offers) {
      final random = Random().nextInt(3);
      if (random == 0) {
        title = "New Update";
        body = _updateMessages[Random().nextInt(_updateMessages.length)];
      } else if (random == 1) {
        title = "Promotion";
        body = _promotionMessages[Random().nextInt(_promotionMessages.length)];
      } else {
        title = "Special Offer";
        body = _offerMessages[Random().nextInt(_offerMessages.length)];
      }
    } else if (_newUpdates) {
      title = "New Update";
      body = _updateMessages[Random().nextInt(_updateMessages.length)];
    } else if (_promotions) {
      title = "Promotion";
      body = _promotionMessages[Random().nextInt(_promotionMessages.length)];
    } else if (_offers) {
      title = "Special Offer";
      body = _offerMessages[Random().nextInt(_offerMessages.length)];
    }

    if (title != null && body != null) {
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'targeted_channel',
            'Targeted Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );

      // Store the notification in Firestore
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Gets the user's recent notifications
  Future<List<Map<String, dynamic>>> getRecentNotifications() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return querySnapshot.docs
        .map((doc) => {
              'title': doc['title'],
              'body': doc['body'],
              'timestamp': doc['timestamp'],
            })
        .toList();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // You can process the message here, but be careful not to perform long-running tasks
  // as this handler runs in the background with limited execution time.
}
