import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../helpers/translate_helper.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'reminder_channel';
  static const String _channelName = 'Podsetnici';
  static const String _channelDesc = 'Podsetnici za aplikaciju Ljubav i Zvezde';

  static Future<void> init() async {
    // Timezone init (bez ovoga zonedSchedule često bude “tišina”)
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Belgrade'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);

    // Android 13+ permission
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }
static NotificationDetails _details() {
  return const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
  );
}
static Future<void> testNow(BuildContext context) async {
  await _notifications.show(
    1001,
    t(context, "Test", listen: false),
    t(context, "Ako vidiš ovo, notifikacije rade ✅", listen: false),
    _details(),
  );
}


  static List<String> _messages(BuildContext context) => [
        t(context, "Zvezde su se pomerile! Proveri svoj ljubavni status. ✨", listen: false),
        t(context, "Da li je danas tvoj srećan dan? Saznaj u aplikaciji. 💖", listen: false),
        t(context, "Tvoj kineski znak ima novu poruku za tebe... 🐉", listen: false),
        t(context, "Neko misli na tebe? Proveri procente odmah! 😍", listen: false),
      ];

  /// Primer: notifikacija za 3 dana (tvoja postojeća logika)
  static Future<void> scheduleTripleDayNotification(BuildContext context) async {
    final randomMsg = _messages(context)[Random().nextInt(_messages(context).length)];

    final when = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));

    await _notifications.zonedSchedule(
      1,
      t(context, "Ljubav i Zvezde", listen: false),
      randomMsg,
      when,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ne traži “exact alarm” dramu
    );
  }

  /// Ako želiš i “test za 5 sekundi” da proveriš da radi
  static Future<void> testIn5Seconds(BuildContext context) async {
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    await _notifications.zonedSchedule(
      999,
      t(context, "Test", listen: false),
      t(context, "Notifikacije rade ✅", listen: false),
      when,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }


  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
