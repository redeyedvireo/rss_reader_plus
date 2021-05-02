
import 'package:rss_reader_plus/models/feed_item.dart';

abstract class FeedParser {

  /// Returns the number of feed items contained in this feed.
  int numberOfFeedItems();

  List<FeedItem> getNewFeedItems(List<String> existingGuids);
}