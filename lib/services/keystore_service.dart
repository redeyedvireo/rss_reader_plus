
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

  Future<int> readInt(String key) async {
    try {
      final result = await _db.readKeystoreItem(key);
      return int.parse(result);
    } catch (e) {
      _logger.severe('[readInt] ${e.message}');
      return 0;
    }
  }
}