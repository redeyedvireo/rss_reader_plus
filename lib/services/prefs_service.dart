import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final FEED_UPDATE_RATE = 'feed_update_rate';         // Update rate, in minutes

  SharedPreferences prefs;

  PrefsService();

  Future<void> initPrefsService() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  int getFeedUpdateRate() {
    return prefs != null ? prefs.getInt(FEED_UPDATE_RATE) ?? 30 : 30;
  }

  Future<void> setFeedUpdateRate(int updateRate) async {
    if (prefs != null) {
      await prefs.setInt(FEED_UPDATE_RATE, updateRate);
    }
  }
}