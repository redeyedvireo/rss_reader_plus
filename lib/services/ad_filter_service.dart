
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_database.dart';

class AdFilterService {
  FeedDatabase _db;
  List<String> _adFilters;
  bool _filtersLoaded;
  Logger _logger;

  AdFilterService(BuildContext context) {
    _db = Provider.of<FeedDatabase>(context, listen: false);
    _logger = Logger('AdFilterService');
    _adFilters = [];
    _filtersLoaded = false;
  }

  Future<List<String>> getAdFilters() async {
    if (!_filtersLoaded) {
      try {
        _adFilters = await _db.readAdFilters();
      } catch (e) {
        _logger.severe('[getAdFilters] ${e.message}');
      }
    }

    return _adFilters;
  }

  Future<bool> addNewAdFilter(String adFilter) async {
    final id = await _db.addAdFilter(adFilter);
    return id > 0;
  }

  Future<bool> deleteAdFilter(String adFilter) async {
    final numDeletions = await _db.deleteAdFilter(adFilter);
    return numDeletions > 0;
  }
}