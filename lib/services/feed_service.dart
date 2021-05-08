import 'package:dart_rss/domain/rss1_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/parser/feed_identifier.dart';
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
  final BehaviorSubject feedUpdated$ = BehaviorSubject<int>();

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
    feedItemList.sort((a, b) => a.publicationDatetime.compareTo(b.publicationDatetime));
    return feedItemList;
  }

  Widget getFeedIconWidget(int feedId) {
    final feed = _findFeed(feedId);
    if (feed.favicon != null) {
      return Image.memory(
        feed.favicon,
        height: 20.0,
      );
    } else {
      return Icon(Icons.rss_feed_rounded);
    }
  }

  Feed _findFeed(int feedId) {
    return _feeds.firstWhere((feed) => feed.id == feedId, orElse: () => Feed(),);
  }

  /// Sets the read flag for the given feed item
  Future<void> setFeedItemReadFlag(String feedItemId, bool read) async {
    final count = await db.setFeedItemReadFlag(feedItemId, _selectedFeedId, read);

    if (count > 0) {
      final feedItem = _feedItems[feedItemId];
      feedItem.read = read;
    } else {
      print('[FeedService.setFeedItemReadFlag] Did not update feed item');
    }
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

        // Store new feed items
        await db.writeFeedItems(feedId, newFeedItems);

        if (feedId == _selectedFeedId) {
          // Invalidate feed item cache
          _feedItemsLoaded = false;
        }

        this.feedUpdated$.add(feedId);
      } catch (e) {
        print('[FeedService.fetchFeed] $e');
      }
    }
  }
}