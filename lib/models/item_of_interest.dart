
import 'feed_item.dart';

class ItemOfInterest {
  int feedId;
  String guid;

  ItemOfInterest(this.feedId, this.guid);

  static ItemOfInterest fromFeedItem(FeedItem feedItem, int feedId) {
    return ItemOfInterest(feedId, feedItem.guid);
  }
}