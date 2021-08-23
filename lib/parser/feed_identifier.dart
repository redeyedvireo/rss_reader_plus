import 'package:rss_reader_plus/services/network_service.dart';

import './feed_parser.dart';
import 'package:rss_reader_plus/parser/atom_parser.dart';
import 'package:rss_reader_plus/parser/rss_v1_parser.dart';
import 'package:rss_reader_plus/parser/rss_v2_parser.dart';

enum FeedType { RSS_V1_FEED, RSS_V2_FEED, ATOM_FEED }

class ParserEntry {
  int numFeedItems;
  FeedParser parser;
  ParserEntry(this.numFeedItems, this.parser);
}

class FeedIdentifier {
  static FeedParser getFeedParser(String rawFeedData, NetworkService networkService) {
    final rssV1Parser = RssV1Parser(rawFeedData, networkService);
    final rssV2Parser = RssV2Parser(rawFeedData, networkService);
    final atomParser = AtomParser(rawFeedData, networkService);

    List<ParserEntry> potentialParsers = [];

    if (rssV1Parser.parse()) {
      potentialParsers.add(ParserEntry(rssV1Parser.numberOfFeedItems(), rssV1Parser));
    }

    if (rssV2Parser.parse()) {
      potentialParsers.add(ParserEntry(rssV2Parser.numberOfFeedItems(), rssV2Parser));
    }

    if (atomParser.parse()) {
      potentialParsers.add(ParserEntry(atomParser.numberOfFeedItems(), atomParser));
    }

    if (potentialParsers.length == 0) {
      // None of the parsers can parse this.  Probably indicates corrupted data, or
      // data that is not a feed.
      throw 'Not a valid feed';
    } else {
      potentialParsers.sort((a, b) => a.numFeedItems.compareTo(b.numFeedItems));

      return potentialParsers.first.parser;
    }
  }
}