
import 'dart:typed_data';

import 'package:dart_rss/dart_rss.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/parser/feed_parser.dart';
import 'package:rss_reader_plus/services/network_service.dart';
import 'package:rss_reader_plus/util/utils.dart';

class RssV2Parser extends FeedParser {
  String rawFeedData;
  RssFeed parsedFeed;
  NetworkService networkService;
  bool validFeed = false;

  RssV2Parser(this.rawFeedData, networkService);

  bool parse() {
    try {
      parsedFeed = RssFeed.parse(rawFeedData);
      validFeed =  true;
    } catch (e) {
      // print('[RssV2Parser.parse] Is not an RSS 2.0 feed: $e');
      validFeed =  false;
    }

    return validFeed;
  }

  Future<Feed> getFeedMetaData(String feedUrl) async {
    Uint8List faviconData = Uint8List(0);

    if (parsedFeed.image != null) {
      final imageUrl = getNullableItem(parsedFeed.image?.url, '');
      if (imageUrl.isNotEmpty) {
        faviconData = await networkService.getIcon(imageUrl);
      }
    }
    
    return Feed(title: getFirstNonNull([parsedFeed.title, parsedFeed?.dc?.title, 'Untitled feed']),
                name: getFirstNonNull([parsedFeed.title, parsedFeed?.dc?.title, 'Untitled feed']),
                url: feedUrl,
                dateAdded: DateTime.now(),
                lastUpdated: DateTime.now(),
                lastPurged: DateTime.now(),
                language: getFirstNonNull([parsedFeed.language, parsedFeed?.dc?.language, '']),
                description: getFirstNonNull([parsedFeed.description, parsedFeed?.dc?.description, '']),
                webPageLink: getNullableItem(parsedFeed.link, feedUrl),
                favicon: faviconData,
                image: null
    );
  }
      
  int numberOfFeedItems() {
    return validFeed ? parsedFeed.items.length : -1;
  }

  List<FeedItem> getNewFeedItems(List<String> existingGuids) {
    final newRssFeedItems = parsedFeed.items.where((item) => !existingGuids.contains(item.guid)).toList();
    return newRssFeedItems.map((rssItem) => _createFromParsed(rssItem)).toList();
  }
    
  FeedItem _createFromParsed(RssItem rssItem) {
    return FeedItem(title: getNullableItem(rssItem.title, ''),
                    author: getAuthorFromParsed(rssItem),
                    link: getNullableItem(rssItem.link, ''),
                    description: getNullableItem(rssItem.description, ''),
                    encodedContent: getContentFromParsed(rssItem),
                    categories: rssItem.categories.map((category) => category.value).toList(),
                    publicationDatetime: parseDate(rssItem.pubDate),
                    thumbnailLink: '',
                    thumbnailWidth: 0,
                    thumbnailHeight: 0,
                    guid: rssItem.guid,
                    feedburnerOrigLink: '',
                    enclosureLink: '',          // TODO: where to get this?
                    enclosureLength: 0,         // TODO: where to get this?
                    enclosureType: '',          // TODO: where to get this?
                    parentFeedId: 0,
                    read: false
                );
  }
    
  String getAuthorFromParsed(RssItem rssItem) {
    return getFirstNonNull([
      rssItem.author,
      rssItem.dc?.creator,
      rssItem.dc?.contributor,
      '']);
  }

  String getContentFromParsed(RssItem rssItem) {
    // TODO: See if there are other fields that should be checked.
    return getFirstNonNull([
      rssItem.content?.value,
      ''
    ]);
  }   
}