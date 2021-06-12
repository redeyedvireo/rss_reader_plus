import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/models/feed_item_filter.dart';
import 'package:rss_reader_plus/services/feed_database.dart';

class FilterService {
  FeedDatabase db;
  List<FeedItemFilter> _feedItemFilters;
  bool _feedItemFiltersLoaded;

  FilterService(BuildContext context) {
    db = Provider.of<FeedDatabase>(context, listen: false);
    _feedItemFilters = [];
    _feedItemFiltersLoaded = false;
  }

  Future<List<FeedItemFilter>> getFeedItemFilters() async {
    if (!_feedItemFiltersLoaded) {
      try {
        _feedItemFilters = await db.readFeedItemFilters();
      } catch (e) {
        print('[getFeedItemFilters] ${e.message}');
      }
    }

    return _feedItemFilters;
  }

  Future<bool> updateFeedItemFilter(FeedItemFilter feedItemFilter) async {
    final numItemsUpdated = await db.updateFeedItemFilter(feedItemFilter);

    return numItemsUpdated == 1;
  }

  Future<bool> deleteFeedItemFilter(FeedItemFilter feedItemFilter) async {
    final numItemsDeleted = await db.deleteFeedItemFilter(feedItemFilter);

    return numItemsDeleted == 1;
  }

  Future<bool> createFeedItemFilter(FeedItemFilter feedItemFilter) async {
    final numItemsCreated = await db.createFeedItemFilter(feedItemFilter);

    return numItemsCreated == 1;
  }

  /// Filters the given list of feed items.
  List<FeedItem> filterFeedItems(List<FeedItem> feedItems) {
    return feedItems.map((feedItem) => _filterFeedItem(feedItem))
                    .where((feedItem) => feedItem.isValid)
                    .toList();
  }

  /// Runs the given feedItem through all the known filters.  If the feed item
  /// is to be deleted, an invalid feedItem is returned.
  FeedItem _filterFeedItem(FeedItem feedItem) {
    FeedItem filteredFeedItem = feedItem;

    for (var i = 0; i < _feedItemFilters.length && filteredFeedItem.isValid; i++) {
      final filter = _feedItemFilters[i];

      filteredFeedItem = filter.filterFeedItem(filteredFeedItem);
    }

    return filteredFeedItem;
  }

  /// Returns a list of feed items which should be copied to the Items of Interest feed.
  List<FeedItem> findItemsOfInterest(List<FeedItem> feedItems) {
    return feedItems.where((feedItem) => isItemOfInterest(feedItem)).toList();
  }

  bool isItemOfInterest(FeedItem feedItem) {
    bool isIoI = false;
    bool wouldBeDeleted = false;

    for (var i = 0; i < _feedItemFilters.length && !wouldBeDeleted; i++) {
      final filter = _feedItemFilters[i];

      isIoI = isIoI || filter.isItemOfInterest(feedItem);
      wouldBeDeleted = wouldBeDeleted || filter.wouldBeDeleted(feedItem);
    }

    // If the feed item would be deleted by any filter, return false
    return isIoI && !wouldBeDeleted;
  }
}