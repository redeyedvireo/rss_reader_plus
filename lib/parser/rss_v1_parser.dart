
import 'package:dart_rss/domain/rss1_feed.dart';
import 'package:dart_rss/domain/rss1_item.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/parser/feed_parser.dart';
import 'package:rss_reader_plus/util/utils.dart';

class RssV1Parser extends FeedParser{
  String rawFeedData;
  Rss1Feed parsedFeed;
  bool validFeed = false;

  RssV1Parser(this.rawFeedData);

  bool parse() {
    try {
      parsedFeed = Rss1Feed.parse(rawFeedData);
      validFeed = true;
    } catch (e) {
      print('[RssV1Parser.parse] Is not an RSS 1.0 feed: $e');
      validFeed = false;
    }

    return validFeed;
  }

  int numberOfFeedItems() {
    return validFeed ? parsedFeed.items.length : -1;
  }

  List<FeedItem> getNewFeedItems(List<String> existingGuids) {
    final newRssFeedItems = parsedFeed.items.where((item) {
      String guid = getGuidFromParsed(item);
      return guid.length > 0 && !existingGuids.contains(guid);
    }).toList();

    return newRssFeedItems.map((rssItem) => _createFromParsed(rssItem)).toList();
  }

  String getGuidFromParsed(Rss1Item rssItem) {
    if (rssItem.dc != null && rssItem.dc.identifier != null) {
      return rssItem.dc.identifier;
    } else {
      if (rssItem.link != null) {
        return rssItem.link;
      } else {
        if (rssItem.title != null) {
          return rssItem.title;     // TODO: Remove spaces
        } else {
          return '';        // There is no simple way to identify the feed item
        }
      }
    }
  }

  FeedItem _createFromParsed(Rss1Item rssItem) {
    String guid = getGuidFromParsed(rssItem);

    if (guid.length > 0) {
      return FeedItem(title: getNullableItem(rssItem.title, ''),
                      author: _getAuthorFromParsed(rssItem),
                      link: getNullableItem(rssItem.link, ''),
                      description: getNullableItem(rssItem.description, ''),
                      encodedContent: _getContentFromParsed(rssItem),
                      categories: _getCategoriesFromParsed(rssItem),         // RSS 1.0 does not support categories
                      publicationDatetime: _getDateFromParsed(rssItem),
                      thumbnailLink: '',
                      thumbnailWidth: 0,
                      thumbnailHeight: 0,
                      guid: guid,
                      feedburnerOrigLink: '',
                      enclosureLink: '',          // TODO: where to get this?
                      enclosureLength: 0,         // TODO: where to get this?
                      enclosureType: '',          // TODO: where to get this?
                      parentFeedId: 0,
                      read: false
                    );
    } else {
      return FeedItem();
    }
  }

  String _getAuthorFromParsed(Rss1Item rssItem) {
    return getFirstNonNull([
      rssItem.dc?.creator,
      rssItem.dc?.contributor,
      ''
    ]);
  }

  String _getContentFromParsed(Rss1Item rssItem) {
    return getFirstNonNull([
      rssItem.content,
      rssItem.description,
      ''
    ]);
  }

  List<String> _getCategoriesFromParsed(Rss1Item rssItem) {
    return getFirstNonNull([
      rssItem.dc?.subjects,
      []
    ]);
  }

  DateTime _getDateFromParsed(Rss1Item rssItem) {
    if (rssItem.dc != null && rssItem.dc.date != null) {
      return parseDate(rssItem.dc.date);
    } else {
      return DateTime.now();
    }
  }
}