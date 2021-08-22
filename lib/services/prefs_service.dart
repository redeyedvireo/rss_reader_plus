import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import '../util/utils.dart';

class PrefsService {
  static const PREFS_FILE = 'shared_preferences.json';
  static const ENCRYPTION_KEY = 'd9l@zP01A';

  static const FEED_UPDATE_RATE = 'feed_update_rate';         // Update rate, in minutes
  static const USE_NETWORK_PROXY = 'use_network_proxy';
  static const NETWORK_PROXY_USERNAME = 'network_proxy_username';
  static const NETWORK_PROXY_PASSWORD = 'network_proxy_password';

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

  bool getUseNetworkProxy() {
    return prefs != null ? prefs.getBool(USE_NETWORK_PROXY) ?? false : false;
  }

  Future<void> setUseNetworkProxy(bool useProxy) async {
    if (prefs != null) {
      _logger.info('Setting use network proxy to $useProxy');
      await prefs.setBool(USE_NETWORK_PROXY, useProxy);
    }
  }

  String getNetworkProxyUsername() {
    return prefs != null ? prefs.getString(NETWORK_PROXY_USERNAME) ?? '' : '';
  }

  Future<void> setNetworkProxyUsername(String username) async {
    if (prefs != null) {
      _logger.info('Setting network proxy username to $username');
      await prefs.setString(NETWORK_PROXY_USERNAME, username);
    }
  }

  String getNetworkProxyPassword() {
    final encryptedPassword = prefs != null ? prefs.getString(NETWORK_PROXY_PASSWORD) ?? '' : '';
    if (encryptedPassword.length > 0) {
      try {
        return decrypt(encryptedPassword, ENCRYPTION_KEY);
      } catch (e) {
        _logger.severe('[getNetworkProxyPassword] $e');
      }
    } else {
      return '';
    }
  }

  Future<void> setNetworkProxyPassword(String password) async {
    if (prefs != null) {
      _logger.info('Setting network proxy password to $password');    // TODO: Delete this once this feature works

      // Encrypt this before saving to prefs
      try {
        final encryptedPassword = encrypt(password, ENCRYPTION_KEY);
        await prefs.setString(NETWORK_PROXY_PASSWORD, encryptedPassword);        
      } catch (e) {
        _logger.severe('[setNetworkProxyPassword] $e');
      }
    }
  }
}