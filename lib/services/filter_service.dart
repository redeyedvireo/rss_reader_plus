import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
}