import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationsProvider extends ChangeNotifier {
  static const _key = 'notifications_enabled';
  bool _enabled;

  bool get enabled => _enabled;

  NotificationsProvider({bool initialEnabled = true}) : _enabled = initialEnabled;

  static Future<bool> loadInitialValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> setEnabled(bool value, BuildContext context) async {
    _enabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);

    if (value) {
      // kad uključiš, zakaži nešto (primer: tvoja 3-dana notifikacija)
      await NotificationService.scheduleTripleDayNotification(context);
    } else {
      await NotificationService.cancelAll();
    }
  }
}
