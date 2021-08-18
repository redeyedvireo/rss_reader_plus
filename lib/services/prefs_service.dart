import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class PrefsService {
  static const PREFS_FILE = 'shared_preferences.json';
  static const FEED_UPDATE_RATE = 'feed_update_rate';         // Update rate, in minutes
  Logger _logger;
  
  SharedPreferences prefs;

  PrefsService() {
    _logger = Logger('PrefsService');
  }

  Future<void> initPrefsService() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  Future<String> getPrefFilePath() async {
    final PathProviderWindows provider = PathProviderWindows();
    String path = '';

    try {
      final directory = await provider.getApplicationSupportPath();
      path = join(directory, PREFS_FILE);
    } catch (exception) {
      _logger.severe('Failed to get app support directory: $exception');
    }

    return path;
  }

  int getFeedUpdateRate() {
    return prefs != null ? prefs.getInt(FEED_UPDATE_RATE) ?? 30 : 30;
  }

  Future<void> setFeedUpdateRate(int updateRate) async {
    if (prefs != null) {
      _logger.info('Setting feed update rate at $updateRate');
      await prefs.setInt(FEED_UPDATE_RATE, updateRate);
    }
  }
}