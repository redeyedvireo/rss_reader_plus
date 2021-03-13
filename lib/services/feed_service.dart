import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/services/database.dart';


class FeedService {
  Database db;
  
  FeedService(BuildContext context) {
    db = Provider.of<Database>(context, listen: false);
  }

  List<Feed> getFeeds() {
    List<Feed> someFeeds = [];

    // Dummy data
    someFeeds.add(Feed(id: 1, name: 'Food feed', description: 'A feed about food'));
    someFeeds.add(Feed(id: 1, name: 'Car feed', description: 'Read about cars here'));
    someFeeds.add(Feed(id: 1, name: 'Gadget feed', description: 'Learn about gadgets'));

    return someFeeds;
  }
}