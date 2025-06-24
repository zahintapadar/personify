import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _lastNotificationKey = 'last_notification_date';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Eye-catching notification messages
  static const List<String> _notificationTitles = [
    '🧠 Ready to discover yourself?',
    '✨ Who are you really?',
    '🎯 Time for self-discovery!',
    '🌟 Unlock your personality!',
    '💫 Your inner self awaits!',
    '🚀 Personality adventure time!',
    '🎭 What\'s your true nature?',
    '🔍 Ready to explore your mind?',
  ];

  static const List<String> _notificationBodies = [
    'Take a quick personality test and discover amazing insights about yourself!',
    'Uncover your hidden traits with our AI-powered personality analysis.',
    'Just 5 minutes to learn something new about yourself. Ready?',
    'Your personality holds secrets. Let\'s unlock them together!',
    'Discover your strengths, traits, and what makes you unique.',
    'Ready for a journey of self-discovery? Take the test now!',
    'Find out what your personality says about your future success.',
    'Curious about your MBTI type? Take the test and find out!',
  ];

  /// Initialize the notification service
  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for both Android and iOS
    await _requestPermissions();

    debugPrint('Notification service initialized');
  }

  /// Request notification permissions for both Android and iOS
  static Future<bool> _requestPermissions() async {
    bool permissionGranted = false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Request notification permission for Android 13+ (API level 33+)
      final status = await Permission.notification.request();
      permissionGranted = status.isGranted;

      if (!permissionGranted) {
        debugPrint('Notification permission denied for Android');
      } else {
        debugPrint('Notification permission granted for Android');
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      permissionGranted = result ?? false;

      if (!permissionGranted) {
        debugPrint('Notification permission denied for iOS');
      } else {
        debugPrint('Notification permission granted for iOS');
      }
    }

    return permissionGranted;
  }

  /// Check if notification permissions are granted
  static Future<bool> arePermissionsGranted() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.notification.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // For iOS, we'll assume permission is granted if notifications are enabled in settings
      return await areNotificationsEnabled();
    }
    return false;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Note: Navigation logic would need to be handled through a callback
    // since we don't have access to BuildContext here
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default enabled
  }

  /// Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (!enabled) {
      await cancelAllNotifications();
    } else {
      await schedulePeriodicNotifications();
    }

    debugPrint('Notifications ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Schedule periodic notifications - one random notification per day
  static Future<void> schedulePeriodicNotifications() async {
    if (!await areNotificationsEnabled()) return;

    // Check if permissions are granted
    if (!await arePermissionsGranted()) {
      debugPrint(
        'Notification permissions not granted. Cannot schedule notifications.',
      );
      return;
    }

    // Cancel existing notifications first
    await _flutterLocalNotificationsPlugin.cancelAll();

    // Schedule one notification per day for the next 7 days at random times
    final now = DateTime.now();
    final random = Random();
    int scheduledCount = 0;

    for (int day = 1; day <= 7; day++) {
      // Check if we should schedule a notification today (skip some days randomly)
      // This ensures not every day has a notification, making it feel more organic
      if (random.nextBool() || day == 1) {
        // Always schedule for first day
        final notificationDate = now.add(Duration(days: day));

        // Random time between 10 AM and 8 PM
        final hour = 10 + random.nextInt(11); // 10-20 (8 PM)
        final minute = random.nextInt(60);

        final scheduledDate = DateTime(
          notificationDate.year,
          notificationDate.month,
          notificationDate.day,
          hour,
          minute,
        );

        // Only schedule if the time is in the future
        if (scheduledDate.isAfter(now)) {
          await _scheduleNotification(
            id: day,
            title:
                _notificationTitles[random.nextInt(_notificationTitles.length)],
            body:
                _notificationBodies[random.nextInt(_notificationBodies.length)],
            scheduledDate: scheduledDate,
          );
          scheduledCount++;
        }
      }
    }

    debugPrint(
      'Scheduled $scheduledCount random notifications over the next 7 days',
    );
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'personality_reminders',
          'Personality Test Reminders',
          channelDescription:
              'Notifications to remind users to take personality tests',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF6C63FF),
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // For now, we'll use immediate notifications
    // In production, you could implement proper scheduling with a background task
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'personality_test_reminder',
    );
  }

  /// Schedule immediate notification (for testing)
  static Future<void> showImmediateNotification({
    String? title,
    String? body,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final random = Random();
    final notificationTitle =
        title ??
        _notificationTitles[random.nextInt(_notificationTitles.length)];
    final notificationBody =
        body ?? _notificationBodies[random.nextInt(_notificationBodies.length)];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'personality_reminders',
          'Personality Test Reminders',
          channelDescription:
              'Notifications to remind users to take personality tests',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF6C63FF),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
      payload: 'personality_test_reminder',
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled');
  }

  /// Get pending notifications count
  static Future<int> getPendingNotificationsCount() async {
    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    return pendingNotifications.length;
  }

  /// Check if it's time to show a notification (daily check)
  static Future<bool> shouldShowDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationDate = prefs.getString(_lastNotificationKey);

    if (lastNotificationDate == null) return true;

    final lastDate = DateTime.parse(lastNotificationDate);
    final now = DateTime.now();

    // Show notification if more than 3 days have passed
    return now.difference(lastDate).inDays >= 3;
  }

  /// Show welcome notification on first app launch
  static Future<void> showWelcomeNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownWelcome =
        prefs.getBool('has_shown_welcome_notification') ?? false;

    if (!hasShownWelcome) {
      await showImmediateNotification(
        title: '🎉 Welcome to Personify!',
        body:
            'Discover your true personality with AI-powered insights. Take your first test now!',
      );

      await prefs.setBool('has_shown_welcome_notification', true);
      debugPrint('Welcome notification shown');
    }
  }

  /// Update last notification date
  static Future<void> updateLastNotificationDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastNotificationKey,
      DateTime.now().toIso8601String(),
    );
  }
}
