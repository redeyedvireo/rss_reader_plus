import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/models/item_of_interest.dart';
import 'package:rss_reader_plus/parser/feed_identifier.dart';
import 'package:rss_reader_plus/services/filter_service.dart';
import 'package:rss_reader_plus/services/keystore_service.dart';
import 'package:rss_reader_plus/services/network_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/feed.dart';
import 'feed_database.dart';


class FeedService {
  static const ItemsOfInterestFeedId = -1;
  static const String _feedOrderKey = 'feed-order';

  FeedDatabase db;
  NotificationService _notificationService;
  FilterService _filterService;
  KeystoreService _keystoreService;
  Logger _logger;
  List<Feed> _feeds;                  // Feeds, ordered by the feed-order field in the database
  Map<String, FeedItem> _feedItems;
  int _selectedFeedId;
  String _selectedFeedItem;
  bool _feedItemsLoaded;
  bool _feedsLoaded;
  
  final BehaviorSubject feedSelected$ = BehaviorSubject<int>();
  final BehaviorSubject feedItemSelected$ = BehaviorSubject<String>();
  final BehaviorSubject feedUpdated$ = BehaviorSubject<int>();
  final BehaviorSubject feedUnreadCountChanged$ = BehaviorSubject<int>();
  final BehaviorSubject feedsUpdated$ = BehaviorSubject<int>();             // Emitted when a feed has been added or deleted

  FeedService(BuildContext context) {
    db = Provider.of<FeedDatabase>(context, listen: false);
    _notificationService = Provider.of<NotificationService>(context, listen: false);
    _filterService = Provider.of<FilterService>(context, listen: false);
    _keystoreService = Provider.of<KeystoreService>(context, listen: false);
    _logger = Logger('FeedService');

    _feeds = [];
    _feedItems = {};
    _selectedFeedId = ItemsOfInterestFeedId;
    _selectedFeedItem = '';
    _feedItemsLoaded = false;
    _feedsLoaded = false;
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
      _selectedFeedItem = '';
      _selectedFeedId = feedId;
      feedSelected$.add(feedId);
      _feedItems = {};
      _feedItemsLoaded = false;
    }
  }

  Future<List<Feed>> getFeeds() async {
    if (!_feedsLoaded) {
      try {
        List<Feed> allFeeds = await db.readFeeds();

        final feedOrderStr = await _keystoreService.readString(_feedOrderKey);
        final orderedFeedIds = feedOrderStr.split(',').map((feedStr) => int.parse(feedStr)).toList();

        _feeds = [];

        orderedFeedIds.forEach((feedId) {
          final feed = allFeeds.where((f) => f.id == feedId);
          if (feed.isNotEmpty) {
            _feeds.add(feed.first);
          }
        });

        // In case there are any feeds that were not included in the feed order string, add them at the end.
        allFeeds.forEach((feed) {
          if (!orderedFeedIds.contains(feed.id)) {
            _logger.warning('Feed ID ${feed.id} (${feed.name}) was not included in the feed order');
            _feeds.add(feed);
          }
        });

        // Prepend Item of Interest feed
        final ioiFeed = Feed(id: ItemsOfInterestFeedId,
                              name: 'Items of Interest',
                              title: 'Items of Interest',
                              description: 'Items of Interest');
        _feeds.insert(0, ioiFeed);

        _feedsLoaded = true;
      } catch (e) {
        print('[getFeeds] ${e.message}');
      }
    }
    
    return _feeds;
  }

  /// Moves the position of a feed in the feed order
  Future<void> moveFeed(int oldPosition, int newPosition) async {
    if (_feedsLoaded) {
      if (newPosition > oldPosition) {
        newPosition--;
      }

      final feed = _feeds.removeAt(oldPosition);

      _feeds.insert(newPosition, feed);

      // Write new feed order
      final feedOrderString = generateFeedOrderString;
      print('Feed order string: $feedOrderString');

      await _keystoreService.updateString(_feedOrderKey, feedOrderString);
    }
  }

  String get generateFeedOrderString {
    return _feeds.map((feed) => feed.id.toString())
                    .toList()
                    .slice(1)    // Remove Items of Interest feed
                    .join(',');
  }

  void selectFeedItem(String feedItemId) {
    if (_feedItemsLoaded) {
      _selectedFeedItem = feedItemId;
      feedItemSelected$.add(feedItemId);
    }
  }

  Future<List<FeedItem>> getFeedItems() async {
    if (!_feedItemsLoaded) {
      if (_selectedFeedId == ItemsOfInterestFeedId) {
        final itemsOfInterest = await db.readItemsOfInterest();

        _feedItems = {};
        for (var i = 0; i < itemsOfInterest.length; i++) {
          final itemOfInterest = itemsOfInterest[i];
          try {
            final feedItem = await db.readFeedItem(itemOfInterest.feedId, itemOfInterest.guid);
            _feedItems[feedItem.guid] = feedItem;            
          } catch (e) {
            print('[getFeedItems] Item of Interest error: ${e.message}');
          }
        }

        _feedItemsLoaded = true;
      } else {
        if (_selectedFeedId > 0) {
          _feedItems = await db.readFeedItems(_selectedFeedId);
          _feedItemsLoaded = true;
        }
      }
    }

    List<FeedItem> feedItemList = _feedItems.values.toList();
    feedItemList.sort((a, b) => a.publicationDatetime.compareTo(b.publicationDatetime));
    return feedItemList;
  }

  Widget getFeedIconWidget(int feedId, {bool makeSquare = false}) {
    final feed = _findFeed(feedId);
    if (feed.favicon != null) {
      if (makeSquare) {
        return Image.memory(
          feed.favicon,
          height: 20.0,
          width: 20.0,
          fit: BoxFit.fitHeight
        );
      } else {
        return Image.memory(
          feed.favicon,
          height: 20.0
        );
      }
    } else {
      return Icon(Icons.rss_feed_rounded);
    }
  }

  Feed _findFeed(int feedId) {
    return _feeds.firstWhere((feed) => feed.id == feedId, orElse: () => Feed());
  }

  Feed getFeed(int feedId) {
    return _findFeed(feedId);
  }

  /// Sets the read flag for the given feed item
  Future<void> setFeedItemReadFlag(String feedItemId, int feedId, bool read) async {
    final count = await db.setFeedItemReadFlag(feedItemId, feedId, read);

    if (count > 0) {
      final feedItem = _feedItems[feedItemId];
      feedItem.read = read;

      final newUnreadCount = await numberOfUnreadFeedItems(feedId);
      feedUnreadCountChanged$.add(newUnreadCount);
    } else {
      print('[FeedService.setFeedItemReadFlag] Did not update feed item');
    }
  }

  /// Updates all feeds.
  Future<void> updateFeeds() async {
    for (var i = 0; i < _feeds.length; i++) {
      final feed = _feeds[i];

      if (feed.id > 0) {
        _notificationService.setStatusMessage('Updating ${feed.name}...');
        await fetchFeed(feed.id);
      }
    }

    _notificationService.setStatusMessage('Feeds updated.');
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

      try {
        final feedParser = FeedIdentifier.getFeedParser(feedData);

        final existingGuids = await db.readGuids(feedId);

        final newFeedItems = feedParser.getNewFeedItems(existingGuids);

        // Remove feed items whose publication date is older than either the last updated date
        // or the last purged date of the feed

        final earliestAllowableDate = feed.lastPurged.isAfter(feed.lastUpdated) ? feed.lastPurged : feed.lastUpdated;

        final dateFilteredFeedItems = newFeedItems.where((feedItem) => !feedItem.publicationDatetime.isBefore(earliestAllowableDate)).toList();

        // Perform filtering
        final filteredFeedItems = _filterService.filterFeedItems(dateFilteredFeedItems);

        // Store new feed items
        await db.writeFeedItems(feedId, filteredFeedItems);

        if (feedId == _selectedFeedId) {
          // Invalidate feed item cache
          _feedItemsLoaded = false;
        }

        // Copy desired feed items to the Items of Interest feed
        final itemsOfInterestFeedItems = _filterService.findItemsOfInterest(filteredFeedItems);
        final itemsOfInterest = itemsOfInterestFeedItems.map((feedItem) => ItemOfInterest.fromFeedItem(feedItem, feedId)).toList();

        if (itemsOfInterest.length > 0) {
          final result = await db.writeItemsOfInterest(itemsOfInterest);

          if (!result) {
            print('[FeedService.fetchFeed] Error writing items of interest');
          }
        }

        feedUpdated$.add(feedId);
      } catch (e) {
        print('[FeedService.fetchFeed] $e');
      }
    }
  }

  /// Returns the number of unread feed items for the given feed.
  Future<int> numberOfUnreadFeedItems(int feedId) async {
    if (feedId == ItemsOfInterestFeedId) {
      final itemsOfInterest = await db.readItemsOfInterest();
      int unreadCount = 0;

      for (var i = 0; i < itemsOfInterest.length; i++) {
        final itemOfInterest = itemsOfInterest[i];
        try {
          final isRead = await db.isFeedItemRead(itemOfInterest.feedId, itemOfInterest.guid);
          if (!isRead) {
            unreadCount++;
          }
        } catch (e) {
          print('[numberOfUnreadFeedItems] Item of Interest error: ${e.message}');
        }
      }

      return unreadCount;
    } else {
      return await db.getNumberOfUnreadFeedItems(feedId);
    }
  }

  /// Note - this may throw an exception
  Future<int> newFeed(String url) async {
    // TODO: Should throw an error if necessary; the contents of the exception
    //  will be the error message.
    final feedContents = await NetworkService.getFeed(url);
    final feedParser = FeedIdentifier.getFeedParser(feedContents);

    if (feedParser == null) {
      throw FormatException('Error parsing feed');
    }

    final feed = await feedParser.getFeedMetaData(url);

    final feedId = await db.writeFeed(feed);

    if (feedId > 0) {
      feed.id = feedId;
      _feeds.add(feed);
      feedsUpdated$.add(feedId);

      await db.createFeedItemTable(feedId);
      
      // Write feed items
      final newFeedItems = feedParser.getNewFeedItems([]);

      // Store new feed items
      await db.writeFeedItems(feedId, newFeedItems);

      // No need to emit feedUpdated$ here, since this feed won't be displayed (because it is new)
    } else {
      // This should not happen, since database errors are handled by catching an exception
      print('[newFeed] Error: feed not written to the database');
      throw FileSystemException('Error: feed not written to the database');
    }

    return feedId;
  }

  Future<void> deleteFeed(int feedId) async {
    try {
      await db.deleteFeedItemTable(feedId);
      final success = await db.removeFeed(feedId);
      if (!success) {
        print('[deleteFeed] Failed to delete feed');
      }

      _feeds.removeWhere((element) => element.id == feedId);

      // If the feed was the selected feed (and it likely will be), select a new feed.
      if (_selectedFeedId == feedId) {
        final newFeedId = _feeds.first.id;
        selectFeed(newFeedId);
      }

      feedsUpdated$.add(_selectedFeedId);
    } catch (e) {
      print('[deleteFeed] ${e.message}');
    }
  }

  /// Purges all feeds.
  Future<void> purgeFeeds(DateTime olderThanDate, bool deleteUnreadItems) async {
    for (var i = 0; i < _feeds.length; i++) {
      final feed = _feeds[i];

      if (feed.id > 0) {
        _notificationService.setStatusMessage('Purging ${feed.name}...');
        await purgeFeed(feed.id, olderThanDate, deleteUnreadItems);
      }
    }

    _notificationService.setStatusMessage('Feeds purged.');
  }

  Future<bool> purgeFeed(int feedId, DateTime targetDate, bool deleteUnreadItems) async {
    Feed feed = getFeed(feedId);
    bool success = false;

    try {
      final feedItemsPurged = await db.deleteFeedItemsByDate(feedId, targetDate, deleteUnreadItems);

      _logger.info('$feedItemsPurged feed items purged from ${feed.name} ($feedId) purged.');

      success = await db.writeLastPurged(feedId, DateTime.now());

      if (feedId == _selectedFeedId) {
        // Invalidate feed item cache
        _feedItemsLoaded = false;
      }

      if (!success) {
        _logger.info('[purgeFeed] Failed to update last purged date');
      }

      feedUpdated$.add(feedId);
    } catch (e) {
      _logger.severe('[purgeFeed] ${e.message}');
    }
  
    return success;
  }
}