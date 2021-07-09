
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:html/dom.dart' as dom;
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

  void filterContent(dom.Document document) {
    final documentParent = document.documentElement;
    final childNodes = documentParent.nodes;
    final firstChildNode = documentParent.firstChild;

    final nodeList = processNodes(childNodes);

    nodeList.forEach((node) {
      final elt = node as dom.Element;
      print('Deleting node: ${elt.outerHtml}');
      node.remove();    // Delete the node!
    });
  }

  List<dom.Node> processNodes(dom.NodeList nodes) {
    List<dom.Node> nodeList = [];

    for (final node in nodes) {
      if (nodeShouldBeDeleted(node)) {
        nodeList.add(node);
      }
      
      if (node.nodes.length > 0) {
        final newList = processNodes(node.nodes);
        nodeList.addAll(newList);
      }
    }

    return nodeList;
  }

  bool nodeShouldBeDeleted(dom.Node node) {
    bool shouldDelete = false;

    if (node.nodeType == dom.Node.ELEMENT_NODE) {
      final elt = node as dom.Element;
      final targetAttributes = [ 'src', 'href' ];

      // final tagName = elt.localName;
      // print('Local name: $tagName');

      final attrs = elt.attributes;
      String url = '';

      for (int i = 0; i < targetAttributes.length; i++) {
        String attribute = targetAttributes[i];
        if (attrs.containsKey(attribute)) {
          url = attrs[attribute];
          break;
        }
      }

      if (url.isNotEmpty) {
        for (String adFilter in _adFilters) {
          if (url.contains(RegExp(adFilter, caseSensitive: false))) {
            shouldDelete = true;
            break;
          }    
        }
      }

      // if (tagName == 'a' || tagName == 'img') {
      //   print('Outer HTML: ${elt.outerHtml}');
      //   // print('Attributes: $attrs');
      //   if (attrs.containsKey('src')) {
      //     print('src: ${attrs['src']}');
      //   }

      //   if (attrs.containsKey('href')) {
      //     print('href: ${attrs['href']}');
      //   }
      // }
    }

    return shouldDelete;
  }
}