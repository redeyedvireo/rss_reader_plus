import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
}