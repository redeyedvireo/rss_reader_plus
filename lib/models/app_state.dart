

import 'package:flutter/material.dart';
import 'package:rss_reader_plus/models/feed_item.dart';

class AppState extends ChangeNotifier{
  int selectedFeed;
  FeedItem selectedFeedItem;

  // TODO Eventually, many of these items will be stored in preferences, and reloaded
  // when the app starts.
  AppState() {
    selectedFeed = 0;             // Indicate no feed selected.
  }

  void selectFeed(int feedId) {
    selectedFeed = feedId;

    // When switching feeds, set the selected feed item to null (for now).
    // TODO: Remember which feed item was selected per feed, and then reselect
    // that one, when feeds are switched.
    selectedFeedItem = null;
    notifyListeners();
  }

  void selectFeedItem(FeedItem feedItem) {
    selectedFeedItem = feedItem;
    notifyListeners();
  }
}