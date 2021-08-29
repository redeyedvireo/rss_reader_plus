// A class to store ephemeral app state, such as the active feed, and feed item
// currently being displayed.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss_reader_plus/models/feed_item.dart';

class AppState with ChangeNotifier {
  int activeFeedId = 0;
  String currentFeedItemId = '';

  AppState();

  setActiveFeed(int feedId) {
    if (activeFeedId != feedId) {
      activeFeedId = feedId;
      notifyListeners();
    }
  }

  setCurrentFeedItem(String guid) {
    if (currentFeedItemId != guid) {
      this.currentFeedItemId = guid;
      notifyListeners();
    }
  }
}