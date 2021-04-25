

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss_reader_plus/models/feed_item.dart';

class AppState {
  FeedItem selectedFeedItem;
  String statusMessage;
  Timer messageTimer;

  // TODO Eventually, many of these items will be stored in preferences, and reloaded
  // when the app starts.
  AppState() {
    statusMessage = '';
  }

  void selectFeedItem(FeedItem feedItem) {
    selectedFeedItem = feedItem;
    // notifyListeners();
  }

  /// Sets a message to appear in the status bar.
  /// @param message Message to appear
  /// @param timeout Number of seconds until the message disappears (set to 0 for no timeout)
  void setStatusMessage(String message, {int timeout = 10}) {
    statusMessage = message;
    if (timeout > 0) {
      messageTimer = Timer(Duration(seconds: timeout), () {
        setStatusMessage('');
        messageTimer.cancel();
      });
    }

    // notifyListeners();
  }
}