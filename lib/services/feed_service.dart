import 'package:dart_rss/domain/rss1_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/network_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/feed.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:dart_rss/domain/rss1_feed.dart';

import 'feed_database.dart';


class FeedService {
  FeedDatabase db;
  List<Feed> _feeds;                  // TODO: Make this a map
  Map<String, FeedItem> _feedItems;
  int _selectedFeedId;
  String _selectedFeedItem;
  bool _feedItemsLoaded;
  
  final BehaviorSubject feedSelected$ = BehaviorSubject<int>();
  final BehaviorSubject feedItemSelected$ = BehaviorSubject<String>();

  FeedService(BuildContext context) {
    db = Provider.of<FeedDatabase>(context, listen: false);
    _feeds = [];
    _feedItems = {};
    _selectedFeedId = 0;
    _selectedFeedItem = '';
    _feedItemsLoaded = false;
  }

  int get selectedFeedId => _selectedFeedId;

  String get selectedFeedItemId => _selectedFeedItem;

  Feed get selectedFeed {
    // TODO: _feeds should be a map
    final index = _feeds.indexWhere((feed) => feed.id == _selectedFeedId);

    if (index != -1) {
      return _feeds[index];
    } else {
      return Feed();
    }
  }

  FeedItem get selectedFeedItem {
    if (_feedItemsLoaded) {
      if (_feedItems.containsKey(_selectedFeedItem)) {
        return _feedItems[_selectedFeedItem];
      }
    }

    return FeedItem();
  }

  void selectFeed(int feedId) {
    if (_selectedFeedId != feedId) {
      _selectedFeedId = feedId;
      feedSelected$.add(feedId);
      _feedItems = {};
      _feedItemsLoaded = false;
    }
  }

  Future<List<Feed>> getFeeds() async {
    if (_feeds.length == 0) {
      _feeds = await db.readFeeds();
    }
    
    return _feeds;
  }

  void selectFeedItem(String feedItemId) {
    if (_feedItemsLoaded) {
      _selectedFeedItem = feedItemId;
      feedItemSelected$.add(feedItemId);
    }
  }

  Future<List<FeedItem>> getFeedItems() async {
    if (!_feedItemsLoaded) {
      if (_selectedFeedId > 0) {
      _feedItems = await db.readFeedItems(_selectedFeedId);
      _feedItemsLoaded = true;
      }
    }

    List<FeedItem> feedItemList = _feedItems.values.toList();
    return feedItemList;
  }

  /// Fetch feed from the internet.
  /// @param feedId - ID of feed in the database
  Future<void> fetchFeed(int feedId) async {
    await getFeeds();
    final feedIndex = _feeds.indexWhere((element) => element.id == feedId);
    if (feedIndex != -1) {
      final feed = _feeds[feedIndex];
      final feedUrl = feed.url;
      final feedData = await NetworkService.getFeed(feedUrl);
      final rssFeedVer2 = RssFeed.parse(feedData);
      final rssFeedVer1 = Rss1Feed.parse(feedData);
      final numberOfVer2Items = rssFeedVer2.items.length;
      final numberOfVer1Items = rssFeedVer1.items.length;
      
      if (numberOfVer2Items > numberOfVer1Items) {
        // This is an RSS 2.0 feed
        await storeNewFeedItemsVersion2(feedId, rssFeedVer2);
      } else {
        // This is an RSS 1.0 feed
        await storeNewFeedItemsVersion1(feedId, rssFeedVer1);
      }
      
      return feedData;
    } else {
      return '';
    }
  }

  /// Stores new feed items for a version 2.0 RSS feed.
  Future<void> storeNewFeedItemsVersion2(int feedId, RssFeed rssFeed) async {
    final existingGuids = await db.readGuids(feedId);

    final newRssFeedItems = rssFeed.items.where((item) => !existingGuids.contains(item.guid)).toList();
    final feedItems = newRssFeedItems.map((rssItem) => createFromParsedVersion2(rssItem)).toList();

    // Store new feed items
    await db.writeFeedItems(feedId, feedItems);
  }

  FeedItem createFromParsedVersion2(RssItem rssItem) {
    return FeedItem(title: rssItem.title,
                    author: parseFeedItemAuthorVersion2(rssItem),
                    link: rssItem.link,
                    description: rssItem.description,
                    encodedContent: rssItem.content.value,
                    categories: rssItem.categories.map((category) => category.value).toList(),
                    publicationDatetime: parseRssItemDate(rssItem.pubDate),
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

  /// Stores new feed items for a version 1.0 RSS feed.
  Future<void> storeNewFeedItemsVersion1(int feedId, Rss1Feed rssFeed) async {
    final existingGuids = await db.readGuids(feedId);

    final newRssFeedItems = rssFeed.items.where((item) {
      String guid = guidFromVersion1FeedItem(item);
      return guid.length > 0 && !existingGuids.contains(guid);
    }).toList();

    final feedItems = newRssFeedItems.map((rssItem) => createFromParsedVersion1(rssItem)).toList();

    // Store new feed items
    await db.writeFeedItems(feedId, feedItems);
  }

  FeedItem createFromParsedVersion1(Rss1Item rssItem) {
    String guid = guidFromVersion1FeedItem(rssItem);

    if (guid.length > 0) {
      return FeedItem(title: rssItem.title,
                      author: parseFeedItemAuthorVersion1(rssItem),
                      link: rssItem.link,
                      description: rssItem.description,
                      encodedContent: contentFromVersion1FeedItem(rssItem),
                      categories: categoriesFromVersion1FeedItem(rssItem),         // RSS 1.0 does not support categories
                      publicationDatetime: parseRssItemDateVersion1(rssItem),
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
      return null;
    }
  }

  /// Attempts to parse a date/time.  Tries several formats before giving up.
  DateTime parseRssItemDate(String pubDateTime) {
    List<String> possibleDateTimeFormats = [
      'EEE, d MMM yyyy hh:mm:s Z',
      'yyyy-MM-ddThh:mm:s Z'
    ];

    // possibleDateTimeFormats.forEach((possibleDateTimeFormat) {
    //   try {
    //     print('Attempting to parse: $pubDateTime');
    //     final jiffyDate = Jiffy(pubDateTime, possibleDateTimeFormat);
    //     print('Successfully parsed $pubDateTime');
    //     return jiffyDate.dateTime;
    //   } catch (e) {
    //     print('Error parsing $pubDateTime: ${e.toString()}');
    //   }
    // });

    try {
      print('Attempting to parse: $pubDateTime');
      final jiffyDate = Jiffy(pubDateTime);
      print('Successfully parsed $pubDateTime');
      return jiffyDate.dateTime;
    } catch (e) {
      print('Error parsing $pubDateTime: ${e.toString()}');
    }

    return DateTime.now();
  }

  DateTime parseRssItemDateVersion1(Rss1Item rssItem) {
    if (rssItem.dc != null && rssItem.dc.date != null) {
      return parseRssItemDate(rssItem.dc.date);
    } else {
      return DateTime.now();
    }
  }

  String guidFromVersion1FeedItem(Rss1Item rssItem) {
    if (rssItem.dc != null && rssItem.dc.identifier != null) {
      return rssItem.dc.identifier;
    } else {
      if (rssItem.link != null) {
        return rssItem.link;
      } else {
        if (rssItem.title != null) {
          return rssItem.title;     // TODO: Remove spaces
        } else {
          return '';        // There is no simple way to identify the feed item
        }
      }
    }
  }

  List<String> categoriesFromVersion1FeedItem(Rss1Item rssItem) {
    if (rssItem.dc != null) {
      return rssItem.dc.subjects;
    } else {
      return [];
    }
  }

  String contentFromVersion1FeedItem(Rss1Item rssItem) {
    return rssItem.content != null ? rssItem.content : rssItem.description;
  }

  String parseFeedItemAuthorVersion2(RssItem rssItem) {
    if (rssItem.author != null) {
      return rssItem.author;
    } else if (rssItem.dc.creator != null) {
      return rssItem.dc.creator;
    } else if (rssItem.dc.contributor != null) {
      return rssItem.dc.contributor;
    } else {
      return '';
    }
  }

  String parseFeedItemAuthorVersion1(Rss1Item rssItem) {
    if (rssItem.dc != null) {
      if (rssItem.dc.creator != null) {
        return rssItem.dc.creator;
      } else if (rssItem.dc.contributor != null) {
        return rssItem.dc.contributor;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}