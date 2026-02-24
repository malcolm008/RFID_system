import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool notificationsEnabled = true;
  bool showWeekends = true;
  ThemeMode themeMode = ThemeMode.system;
  int reminderMinutes = 10;
  int startHour = 8;
  int endHour = 20;

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void toggleWeekends(bool value) {
    showWeekends = value;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setReminderMinutes(int minutes) {
    reminderMinutes = minutes;
    notifyListeners();
  }

   void setStartHour(int hour) {
    startHour = hour;
    notifyListeners();
   }

   void setEndHour(int hour) {
    endHour = hour;
    notifyListeners();
   }
}