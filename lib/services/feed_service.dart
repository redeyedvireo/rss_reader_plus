import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/network_service.dart';
import '../models/feed.dart';
import 'package:dart_rss/dart_rss.dart';

import 'feed_database.dart';


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

  /// Fetch feed from the internet.
  /// @param feedId - ID of feed in the database
  Future<void> fetchFeed(int feedId) async {
    await getFeeds();
    final feedIndex = _feeds.indexWhere((element) => element.id == feedId);
    if (feedIndex != -1) {
      final feed = _feeds[feedIndex];
      final feedUrl = feed.url;
      final feedData = await NetworkService.getFeed(feedUrl);
      final rssFeed = RssFeed.parse(feedData);
      
      await storeNewFeedItems(feedId, rssFeed);
      return feedData;
    } else {
      return '';
    }
  }

  Future<void> storeNewFeedItems(int feedId, RssFeed rssFeed) async {
    final existingGuids = await db.readGuids(feedId);

    final newRssFeedItems = rssFeed.items.where((item) => !existingGuids.contains(item.guid)).toList();
    final feedItems = newRssFeedItems.map((rssItem) => createFromParsed(rssItem)).toList();

    // Store new feed items
    await db.writeFeedItems(feedId, feedItems);
  }

  FeedItem createFromParsed(RssItem rssItem) {
    return FeedItem(title: rssItem.title,
                    author: parseFeedItemAuthor(rssItem),
                    link: rssItem.link,
                    description: rssItem.description,
                    encodedContent: rssItem.content.value,
                    categories: rssItem.categories.map((category) => category.value).toList(),
                    publicationDatetime: parseRssItemDate(rssItem.pubDate),
                    thumbnailLink: '',
                    thumbnailWidth: 0,
                    thumbnailHeight: 0,
                    guid: rssItem.guid,
                    feedburnerOrigLink: '',
                    enclosureLink: '',          // TODO: where to get this?
                    enclosureLength: 0,         // TODO: where to get this?
                    enclosureType: '',          // TODO: where to get this?
                    parentFeedId: 0,
                    read: false
                    );
  }

  DateTime parseRssItemDate(String pubDateTime) {
    DateTime result;

    try {
      print('Attempting to parse: $pubDateTime');
      final jiffyDate = Jiffy(pubDateTime, 'EEE, d MMM yyyy hh:mm:s Z');
      result = jiffyDate.dateTime;
    } catch (e) {
      print('Error parsing $pubDateTime: ${e.toString()}');
      result = DateTime.now();
    }

    return result;
  }

  String parseFeedItemAuthor(RssItem rssItem) {
    if (rssItem.author != null) {
      return rssItem.author;
    } else if (rssItem.dc.creator != null) {
      return rssItem.dc.creator;
    } else if (rssItem.dc.contributor != null) {
      return rssItem.dc.contributor;
    } else {
      return '';
    }
  }
}