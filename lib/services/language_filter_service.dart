
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:html/dom.dart' as dom;
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

  Future<void> init() async {
    await getLanguageFilters();
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

  void filterContent(dom.Document document) {
    final documentParent = document.documentElement;
    final childNodes = documentParent.nodes;
    final firstChildNode = documentParent.firstChild;

    processNodes(childNodes);
  }

  void processNodes(dom.NodeList nodes) {
    for (final node in nodes) {
      processNode(node);
      
      if (node.nodes.length > 0) {
        processNodes(node.nodes);
      }
    }
  }

  void processNode(dom.Node node) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      final filteredString = performLanguageFilteringOnString(node.text);

      node.text = filteredString;
    }
  }

  String performLanguageFilteringOnString(String inString) {
    String filteredString = inString;
    for (String filteredWord in _filteredWords) {
      // It would be great to use replaceAllMapped, but it chokes on strings that contain a single apostrophe.
      // Hence, replaceAll must be used.

      // filteredString = filteredString.replaceAllMapped(RegExp('(\\W)$filteredWord(\\W)', caseSensitive: false),
      //                                                         (Match m) => '${m[1]}****${m[2]}');
      
      filteredString = filteredString.replaceAll(RegExp(filteredWord, caseSensitive: false), '****');
    }

    return filteredString;
  }
}