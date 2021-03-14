import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import '../models/feed.dart';
import 'package:rss_reader_plus/services/feed_database.dart';


class FeedService {
  FeedDatabase db;
  List<Feed> _feeds;
  
  FeedService(BuildContext context) {
    db = Provider.of<FeedDatabase>(context, listen: false);
    _feeds = [];
  }

  Future<List<Feed>> getFeeds() async {
    if (_feeds.length == 0) {
      _feeds = await db.readFeeds();
    }
    
    return _feeds;
  }

  Future<List<FeedItem>> getFeedItems(int feedId) async {
    // TODO: Does it make sense to cache feed items for the current feed?
    return await db.readFeedItems(feedId);
  }
}