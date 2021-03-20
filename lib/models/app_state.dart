

import 'package:flutter/material.dart';
import 'package:rss_reader_plus/models/feed_item.dart';

class AppState extends ChangeNotifier{
  int selectedFeed;
  FeedItem selectedFeedItem;

  // TODO Eventually, many of these items will be stored in preferences, and reloaded
  // when the app starts.
  AppState() {
    selectedFeed = 0;             // Indicate no feed selected.
    selectedFeedItem;             // Selected feed item
  }

  void selectFeed(int feedId) {
    selectedFeed = feedId;
    notifyListeners();
  }

  void selectFeedItem(FeedItem feedItem) {
    selectedFeedItem = feedItem;
    notifyListeners();
  }
}