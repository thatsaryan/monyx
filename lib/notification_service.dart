import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    print('Timezone initialized: ${tz.local.name}');

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'reminder_channel',
        'Reminders',
        description: 'Channel for reminder notifications',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      print('Notification channel created: reminder_channel');
    }

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );

    print('NotificationService initialized');
  }

  Future<bool> _hasExactAlarmPermission() async {
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 31) {
      final status = await Permission.scheduleExactAlarm.status;
      print('Exact alarm permission status: $status');
      return status.isGranted;
    }
    return true;
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        print('Android SDK version: ${androidInfo.version.sdkInt}');
        return androidInfo.version.sdkInt;
      } catch (e) {
        print('Error getting Android version: $e');
        return 0;
      }
    }
    return 0;
  }

  Future<void> openExactAlarmPermissionSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
      print('Opened exact alarm permission settings');
    }
  }

  Future<void> requestDisableBatteryOptimization() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:com.example.monyx',
      );
      try {
        await intent.launch();
        print('Requested to disable battery optimization');
      } catch (e) {
        print('Error requesting battery optimization: $e');
      }
    }
  }

  Future<void> fetchAndScheduleReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dynamic rawDate = data['dateTime'];
      DateTime? scheduledTime;

      // Robust date parsing
      if (rawDate is Timestamp) {
        scheduledTime = rawDate.toDate();
      } else if (rawDate is String) {
        try {
          scheduledTime = DateTime.parse(rawDate);
        } catch (e) {
          print('Invalid date format: $rawDate');
          continue;
        }
      } else {
        print('Unsupported dateTime type: ${rawDate.runtimeType}');
        continue;
      }

      // Convert to TZ-aware datetime
      final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);
      final tzNow = tz.TZDateTime.now(tz.local);

      if (tzScheduled.isAfter(tzNow.add(Duration(seconds: 5)))) {
        final id = doc.id.hashCode;
        final title = data['title'] ?? 'Reminder';
        final amount = data['amount'] ?? '0.00';
        final category = data['category'] ?? 'General';

        await scheduleNotification(
          id: id,
          title: title,
          body: 'Reminder: ₹$amount for $category',
          scheduledTime: scheduledTime,
        );

        print('Reminder scheduled for $scheduledTime');
      } else {
        print('⏭ Skipped past or invalid reminder: $scheduledTime');
      }
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    if (scheduled.isBefore(now.add(Duration(seconds: 5)))) {
      print('Scheduled time must be in the future: $scheduled vs now: $now');
      throw Exception('Please add a future time and date');
    }

    if (!await _hasExactAlarmPermission()) {
      await openExactAlarmPermissionSettings();
      throw Exception('SCHEDULE_EXACT_ALARM permission not granted');
    }

    try {
      print('📅 Scheduling notification: id=$id | title=$title | time=$scheduled');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            channelDescription: 'Channel for reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      print('Notification scheduled at $scheduled');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }
}
