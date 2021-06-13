import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

// A service for updating feeds on a regular interval.

class UpdateService {
  Timer _feedUpdateTimer;
  int _updateRateInMinutes;
  FeedService _feedService;
  Logger _logger;

  UpdateService(BuildContext context) {
    _updateRateInMinutes = 30;
    _feedService = Provider.of<FeedService>(context, listen: false);
    _logger = Logger('UpdateService');
  }

  void setUpdateRate(int updateRate) {
    if (updateRate > 0) {
      if (_feedUpdateTimer != null && _feedUpdateTimer.isActive) {
        _feedUpdateTimer.cancel();
      }

      start(updateRate);
    }
  }

  /// Starts, or restarts, the service
  void start(int updateRate) {
    if (updateRate > 0) {
      _logger.info('Starting update service at rate $updateRate');
      
      _updateRateInMinutes = updateRate;
      _feedUpdateTimer = Timer.periodic(Duration(minutes: _updateRateInMinutes), (timer) async {
        _logger.info('Updating feeds...');
        await _feedService.updateFeeds();
      });
    }
  }

  /// Stops the service
  void stop() {
    _feedUpdateTimer.cancel();
  }
}