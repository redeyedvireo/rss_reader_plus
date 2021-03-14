

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier{
  int selectedFeed;
  String selectedFeedItem;

  // TODO Eventually, many of these items will be stored in preferences, and reloaded
  // when the app starts.
  AppState() {
    selectedFeed = 0;    // Indicate no feed selected.
    selectedFeedItem = '';    // GUID of selected feed item
  }

  void selectFeed(int feedId) {
    selectedFeed = feedId;
    notifyListeners();
  }

  void selectFeedItem(String feedItem) {
    selectedFeedItem = feedItem;
    notifyListeners();
  }
}