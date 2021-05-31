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
}