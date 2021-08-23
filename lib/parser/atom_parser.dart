
import 'dart:typed_data';

import 'package:dart_rss/dart_rss.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/parser/feed_parser.dart';
import 'package:rss_reader_plus/services/network_service.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';
import 'package:rss_reader_plus/util/utils.dart';

class AtomParser extends FeedParser {
  String rawFeedData;
  AtomFeed parsedFeed;
  NetworkService networkService;
  bool validFeed = false;

  AtomParser(this.rawFeedData, networkService);

  bool parse() {
    try {
      parsedFeed = AtomFeed.parse(rawFeedData);
      validFeed =  true;
    } catch (e) {
      // print('[AtomParser.parse] Is not an Atom feed: $e');
      validFeed =  false;
    }

    return validFeed;
  }

  Future<Feed> getFeedMetaData(String feedUrl) async {
    final link = getFirstNonNull(parsedFeed.links);
    final iconPath = getNullableItem(parsedFeed.icon, '');
    Uint8List faviconData = Uint8List(0);
    
    if (iconPath.isNotEmpty) {
      faviconData = await networkService.getIcon('feedUrl/$iconPath');
    }
    
    return Feed(title: getNullableItem(parsedFeed.title, 'Untitled feed'),
                name: getNullableItem(parsedFeed.title, ''),
                url: feedUrl,
                dateAdded: DateTime.now(),
                lastUpdated: DateTime.now(),
                lastPurged: DateTime.now(),
                language: link?.hreflang != null ? link.hreflang : '',
                description: getNullableItem(parsedFeed.subtitle, ''),
                webPageLink: link?.href != null ? link.href : '',
                favicon: faviconData,
                image: null
    );
  }
  
  int numberOfFeedItems() {
    return validFeed ? parsedFeed.items.length : -1;
  }

  List<FeedItem> getNewFeedItems(List<String> existingGuids) {
    final newRssFeedItems = parsedFeed.items.where((item) {
      String guid = getGuidFromParsed(item);
      return guid.length > 0 && existingGuids.contains(guid);
    }).toList();

    return newRssFeedItems.map((rssItem) => _createFromParsed(rssItem)).toList();
  }

  String getGuidFromParsed(AtomItem rssItem) {
    return getFirstNonNull([
      rssItem.id,
      rssItem.links?.first?.href,
      rssItem.title,
      ''            // No simple way to identify the feed item
    ]);
  }

  FeedItem _createFromParsed(AtomItem rssItem) {
    String guid = getGuidFromParsed(rssItem);

    if (guid.length > 0) {
      return FeedItem(title: getNullableItem(rssItem.title, ''),
                      author: _getAuthorFromParsed(rssItem),
                      link: _getLinkFromParsed(rssItem),
                      description: _getDescriptionFromParsed(rssItem),
                      encodedContent: _getContentFromParsed(rssItem),
                      categories: _getCategoriesFromParsed(rssItem),
                      publicationDatetime: _getDateFromParsed(rssItem),
                      thumbnailLink: '',
                      thumbnailWidth: 0,
                      thumbnailHeight: 0,
                      guid: guid,
                      feedburnerOrigLink: '',
                      enclosureLink: '',          // TODO: where to get this?
                      enclosureLength: 0,         // TODO: where to get this?
                      enclosureType: '',          // TODO: where to get this?
                      parentFeedId: 0,
                      read: false
                    );
    } else {
      return FeedItem();
    }
  }

  String _getAuthorFromParsed(AtomItem rssItem) {
    if (rssItem.authors.length > 0) {
      return rssItem.authors.first.name;
    } else if (rssItem.contributors.length > 0) {
      return getNullableItem(rssItem.contributors.first.name, '');
    } else {
      return '';
    }
  }

  String _getLinkFromParsed(AtomItem rssItem) {
    if (rssItem.links.length > 0) {
      return getNullableItem(rssItem.links.first.href, '');
    } else {
      return '';
    }
  }

  String _getDescriptionFromParsed(AtomItem rssItem) {
    return getFirstNonNull([
      rssItem.summary,
      rssItem.title,
      ''
    ]);
  }

  String _getContentFromParsed(AtomItem rssItem) {
    return getFirstNonNull([
      rssItem.content,
      rssItem.summary,
      ''
    ]);
  }

  List<String> _getCategoriesFromParsed(AtomItem rssItem) {
    rssItem.categories.map((atomCategory) => getNullableItem(atomCategory.label, ''))
                      .where((label) => label.length > 0).toList();
  }

  DateTime _getDateFromParsed(AtomItem rssItem) {
    final dateTimeString = getFirstNonNull([
      rssItem.published,
      rssItem.updated,
      ''
    ]);

    if (dateTimeString.length == 0) {
      return DateTime.now();
    } else {
      return parseDate(dateTimeString);
    }
  }
}