
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_database.dart';

class LanguageFilterService {
  FeedDatabase _db;
  List<String> _filteredWords;
  bool _filteredWordsLoaded;
  Logger _logger;
  
  LanguageFilterService(BuildContext context) {
    _db = Provider.of<FeedDatabase>(context, listen: false);
    _logger = Logger('LanguageFilterService');
    _filteredWords = [];
    _filteredWordsLoaded = false;
  }

  Future<List<String>> getLanguageFilters() async {
    if (!_filteredWordsLoaded) {
      try {
        _filteredWords = await _db.readLanguageFilters();
      } catch (e) {
        _logger.severe('[getLanguageFilters] ${e.message}');
      }
    }

    return _filteredWords;
  }

  Future<bool> addNewFilteredWord(String filteredWord) async {
    final id = await _db.addLanguageFilter(filteredWord);
    return id > 0;
  }

  Future<bool> deleteFilteredWord(String filteredWord) async {
    final numDeletions = await _db.deleteLanguageFilter(filteredWord);
    return numDeletions >= 1;
  }
}