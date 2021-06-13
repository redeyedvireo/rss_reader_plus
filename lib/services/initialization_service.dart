
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';

class InitializationService {
  PrefsService _prefsService;
  FeedDatabase _feedDb;
  bool _initialized;

  InitializationService(BuildContext context) {
    _initialized = false;
    _prefsService = Provider.of<PrefsService>(context, listen: false);
    _feedDb = Provider.of<FeedDatabase>(context, listen: false);
  }

  Future<void> initialize() async {
    if (!_initialized) {
      _prefsService.initPrefsService();
      final sqlfliteDb = await FeedDatabase.init();
      _feedDb.setSqlfliteDb(sqlfliteDb);

      _initialized = true;
    } else {
      print('InitializationService.initialize() called after already initialized');
    }
  }
}