import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

import 'feed_database.dart';

class PurgeService {
  FeedDatabase _db;
  FeedService _feedService;
  Logger _logger;
  
  PurgeService(BuildContext context) {
    _db = Provider.of<FeedDatabase>(context, listen: false);
    _feedService = Provider.of<FeedService>(context, listen: false);
    _logger = Logger('PurgeService');    
  }


}