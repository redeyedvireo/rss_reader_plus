
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/ad_filter_service.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';
import 'package:rss_reader_plus/services/update_service.dart';
import 'package:path/path.dart';

class InitializationService {
  static const LOG_FILE = 'rss_reader_plus.log';
  PrefsService _prefsService;
  FeedDatabase _feedDb;
  UpdateService _updateService;
  LanguageFilterService _languageFilterService;
  AdFilterService _adFilterService;
  bool _initialized;
  String _logFilePath;
  Logger _logger;
  File _logFile;
  IOSink _logFileSink;

  InitializationService(BuildContext context) {
    _initialized = false;
    _logFilePath = '';
    _logger = Logger('InitializationService');

    _prefsService = Provider.of<PrefsService>(context, listen: false);
    _feedDb = Provider.of<FeedDatabase>(context, listen: false);
    _updateService = Provider.of<UpdateService>(context, listen: false);
    _languageFilterService = Provider.of<LanguageFilterService>(context, listen: false);
    _adFilterService = Provider.of<AdFilterService>(context, listen: false);
  }

  Future<void> initialize() async {
    if (!_initialized) {
      await _initLogging();

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

  String get logFilePath => _logFilePath;

  Future<void> _initLogging() async {
    final PathProviderWindows provider = PathProviderWindows();
    String appSupportDirectory;

    try {
      appSupportDirectory = await provider.getApplicationSupportPath();
      _logFilePath = join(appSupportDirectory, LOG_FILE);

      _logFile = File(_logFilePath);
      _logFileSink = _logFile.openWrite(mode: FileMode.append);
    } catch (exception) {
      appSupportDirectory = 'Failed to get app support directory: $exception';
    }

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) async {
      final logMsg = '[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}';
      print(logMsg);

      if (_logFileSink != null) {
        _logFileSink.write('$logMsg\n');
      }
    });
  }
}