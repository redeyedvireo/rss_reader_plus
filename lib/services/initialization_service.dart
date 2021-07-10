
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/ad_filter_service.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';
import 'package:rss_reader_plus/services/update_service.dart';

class InitializationService {
  PrefsService _prefsService;
  FeedDatabase _feedDb;
  UpdateService _updateService;
  LanguageFilterService _languageFilterService;
  AdFilterService _adFilterService;
  bool _initialized;
  Logger _logger;

  InitializationService(BuildContext context) {
    _initialized = false;
    _logger = Logger('InitializationService');

    _prefsService = Provider.of<PrefsService>(context, listen: false);
    _feedDb = Provider.of<FeedDatabase>(context, listen: false);
    _updateService = Provider.of<UpdateService>(context, listen: false);
    _languageFilterService = Provider.of<LanguageFilterService>(context, listen: false);
    _adFilterService = Provider.of<AdFilterService>(context, listen: false);
  }

  Future<void> initialize() async {
    if (!_initialized) {
      _initLogging();

      _prefsService.initPrefsService();
      final sqlfliteDb = await FeedDatabase.init();
      _feedDb.setSqlfliteDb(sqlfliteDb);

      await _languageFilterService.init();
      await _adFilterService.init();

      _updateService.start(_prefsService.getFeedUpdateRate());

      _logger.info('App initialization complete');
      _initialized = true;
    } else {
      _logger.warning('InitializationService.initialize() called after already initialized');
    }
  }

  void _initLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}