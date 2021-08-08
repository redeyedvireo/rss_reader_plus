
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'feed_database.dart';

class KeystoreService {
  FeedDatabase _db;
  Logger _logger;

  KeystoreService(BuildContext context) {
    _db = Provider.of<FeedDatabase>(context, listen: false);
    _logger = Logger('KeystoreService');
  }

  Future<bool> writeString(String key, String value) async {
    try {
      final result = await _db.writeKeystoreItem(key, value);
      return result > 0;
    } catch (e) {
      _logger.severe('[writeString] ${e.message}');
      return false;
    }
  }

  Future<bool> updateString(String key, String value) async {
    try {
      return await _db.updateKeystoreItem(key, value);
    } catch (e) {
      _logger.severe('[updateString] ${e.message}');
      return false;
    }
  }

  Future<String> readString(String key) async {
    try {
      return await _db.readKeystoreItem(key);
    } catch (e) {
      _logger.severe('[readString] ${e.message}');
      return '';
    }
  }

  Future<bool> writeInt(String key, int value) async {
    try {
      final result = await _db.writeKeystoreItem(key, value.toString());
      return result > 0;
    } catch (e) {
      _logger.severe('[writeInt] ${e.message}');
      return false;
    }
  }

  Future<bool> updateInt(String key, int value) async {
    try {
      return await _db.updateKeystoreItem(key, value.toString());
    } catch (e) {
      _logger.severe('[updateInt] ${e.message}');
      return false;
    }
  }

  Future<int> readInt(String key) async {
    try {
      final result = await _db.readKeystoreItem(key);
      return int.parse(result);
    } catch (e) {
      _logger.severe('[readInt] ${e.message}');
      return 0;
    }
  }

  Future<bool> keyExists(String key) async {
    try {
      return await _db.keyExistsInKeystore(key);
    } catch (e) {
      _logger.severe('[keyExists] Error checking if key $key exists in the keystore');
      return false;
    }
  }
}