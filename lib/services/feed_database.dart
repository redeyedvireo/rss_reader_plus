
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/util/utils.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FeedDatabase {
  static const DB_FILE = 'Feeds.db';
  static const DB_VERSION = 1;
  Database sqlfliteDb;

  static final feedsTable = 'feeds';

  FeedDatabase();

  /// Returns the Sqlflite database.
  static Future<Database> init() async {
    final databaseDir = await getDatabaseDirectory();

    final path = join(databaseDir, DB_FILE);

    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;
    return await databaseFactory.openDatabase(path);

    // return await openDatabase(path, version: DB_VERSION, onCreate: FeedDatabase.onCreate);
  }

  static Future<String> getDatabaseDirectory() async {
    String tempDirectory;
    String downloadsDirectory;
    String appSupportDirectory;
    String documentsDirectory;
    final PathProviderWindows provider = PathProviderWindows();

    try {
      tempDirectory = await provider.getTemporaryPath();
    } catch (exception) {
      tempDirectory = 'Failed to get temp directory: $exception';
    }
    try {
      downloadsDirectory = await provider.getDownloadsPath();
    } catch (exception) {
      downloadsDirectory = 'Failed to get downloads directory: $exception';
    }

    try {
      documentsDirectory = await provider.getApplicationDocumentsPath();
    } catch (exception) {
      documentsDirectory = 'Failed to get documents directory: $exception';
    }

    try {
      appSupportDirectory = await provider.getApplicationSupportPath();
    } catch (exception) {
      appSupportDirectory = 'Failed to get app support directory: $exception';
    }

    print('temp dir: $tempDirectory');
    print('downloads dir: $downloadsDirectory');
    print('documents dir: $documentsDirectory');
    print('appSupport dir: $appSupportDirectory');

    // TODO: Use the downloads directory as the temporary place for the feeds database
    return downloadsDirectory;
  }

  static Future<void> onCreate(Database db, int version) async {
    createTables(db);
  }

  static Future<void> createTables(Database db) async {
    // String sql = 'CREATE TABLE $fillupsTable( ' +
    //       '$columnTimestamp INTEGER UNIQUE NOT NULL, ' +
    //       '$columnPricePerVolume REAL, ' +
    //       '$columnVolume REAL, ' +
    //       '$columnOdometer REAL, ' +
    //       '$columnPreviousOdometer REAL, ' +
    //       '$columnTripOdometer REAL, ' +
    //       '$columnDistance REAL,' +
    //       '$columnDistanceDetermination INTEGER,' +
    //       '$columnOctane INTEGER, ' +
    //       '$columnDistVolRatio REAL, ' +
    //       '$columnLat REAL, ' +
    //       '$columnLon REAL '
    //     ')';

    // await db.execute(sql);
  }

  Future<void> createFeedItemTable(int feedId) async {
    final tableName = feedIdToString(feedId);

    String sql = 'CREATE TABLE $tableName( ' +
          'title text, ' +
          'author text, ' +
          'link text, ' +
          'description text, ' +
          'categories text, ' +
          'pubdatetime integer, ' +
          'thumbnaillink text, ' +
          'thumbnailwidth integer, ' +
          'thumbnailheight integer, ' +
          'guid text UNIQUE, ' +
          'feedburneroriglink text, ' +
          'readflag integer, ' +
          'enclosurelink text, ' +
          'enclosurelength integer, ' +
          'enclosuretype text, ' +
          'contentencoded text ' +
        ')';

    await sqlfliteDb.execute(sql);
  }

  void setSqlfliteDb(Database database) {
    sqlfliteDb = database;
  }

  Future<List<Feed>> readFeeds() async {
    final feedMapList = await sqlfliteDb.rawQuery('SELECT * FROM $feedsTable');

    List<Feed> feeds = [];

    // feedMapList is an array of maps
    for (var feedMap in feedMapList) {
      Uint8List favicon = feedMap['favicon'];
      Uint8List feedImage = feedMap['image'];
      
      final feed = Feed(
        id: feedMap['feedid'],
        name: feedMap['name'],
        url: feedMap['url'],
        dateAdded: DateTime.fromMillisecondsSinceEpoch(feedMap['added']),
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(feedMap['lastupdated']),
        lastPurged: DateTime.fromMillisecondsSinceEpoch(feedMap['lastpurged']),
        title: feedMap['title'],
        language: feedMap['language'],
        description: feedMap['description'],
        webPageLink: feedMap['webpagelink'],
        favicon: favicon != null ? favicon : feedImage
      );

      feeds.add(feed);
    }

    return feeds;
  }

  Future<Map<String, FeedItem>> readFeedItems(int feedId) async {
    String tableName = feedIdToString(feedId);
    Map<String, FeedItem> feedItems = {};

    try {
      final feedItemMapList = await sqlfliteDb.rawQuery('select * from $tableName');

      for (final feedItemMap in feedItemMapList) {
        int timestampRaw = feedItemMap['pubdatetime'];
        int timestamp = timestampRaw * 1000;

        final feedItem = FeedItem(
          title: feedItemMap['title'],
          author: feedItemMap['author'],
          link: feedItemMap['link'],
          description: feedItemMap['description'],
          encodedContent: feedItemMap['contentencoded'],
          categories: _splitCategories(feedItemMap['categories']),
          publicationDatetime: DateTime.fromMillisecondsSinceEpoch(timestamp),
          thumbnailLink: feedItemMap['thumbnaillink'],
          thumbnailWidth: feedItemMap['thumbnailwidth'],
          thumbnailHeight: feedItemMap['thumnailheight'],
          guid: feedItemMap['guid'],
          feedburnerOrigLink: feedItemMap['feedburneroriglink'],
          enclosureLink: feedItemMap['enclosurelink'],
          enclosureLength: feedItemMap['enclosurelength'],
          enclosureType: feedItemMap['enclosuretype'],
          parentFeedId: -1,
          read: feedItemMap['readflag'] == 1 ? true : false
        );

        feedItems[feedItem.guid] = feedItem;
      }
    } catch (e) {
      print('[FeedDatabase.readFeedItems] Error: $e');
    }

    return feedItems;
  }

  /// Reads the guids of all feed items for the given feed.
  Future<List<String>> readGuids(int feedId) async {
    final resultList = await sqlfliteDb.query('${feedIdToString(feedId)}', columns: ['guid']);

    List<String> guids = [];

    resultList.forEach((item) {
      guids.add(item['guid']);
    });

    return guids;
  }

  List<String> _splitCategories(String categoryString) {
    return categoryString.split(',');
  }

  String _joinCategories(List<String> categoryList) {
    return categoryList.join(',');
  }

  /// Writes a list of feed items to the database.
  /// TODO: Return an error code?
  Future<void> writeFeedItems(int feedId, List<FeedItem> feedItems) async {
    final tableName = feedIdToString(feedId);

    for (var feedItem in feedItems) {
      await sqlfliteDb.insert(tableName, {
        'title': feedItem.title,
        'author': feedItem.author,
        'link': feedItem.link,
        'description': feedItem.description,
        'categories': _joinCategories(feedItem.categories),
        'pubdatetime': feedItem.publicationDatetime.millisecondsSinceEpoch ~/ 1000,
        'thumbnaillink': feedItem.thumbnailLink,
        'thumbnailwidth': feedItem.thumbnailWidth,
        'thumbnailheight': feedItem.thumbnailHeight,
        'guid': feedItem.guid,
        'feedburneroriglink': feedItem.feedburnerOrigLink,
        'readflag': feedItem.read ? 1 : 0,
        'enclosurelink': feedItem.enclosureLink,
        'enclosurelength': feedItem.enclosureLength,
        'enclosuretype': feedItem.enclosureType,
        'contentencoded': feedItem.encodedContent,
      });
    }
  }

  Future<int> setFeedItemReadFlag(String feedItemId, int feedId, bool readFlag) async {
    final tableName = feedIdToString(feedId);

    final count = await sqlfliteDb.rawUpdate('update $tableName set readflag = ? where guid = ?',
                                             [readFlag ? 1 : 0, feedItemId]);

    return count;
  }

  Future<int> getNumberOfUnreadFeedItems(int feedId) async {
    final tableName = feedIdToString(feedId);

    final result = await sqlfliteDb.rawQuery('select count(*) from $tableName where readFlag = 0');
    int count = 0;

    if (result.length > 0) {
      count = result.first['count(*)'];
    }

    return count;
  }

  /// Note: this may throw an exception
  Future<int> writeFeed(Feed feed) async {
    await sqlfliteDb.insert(feedsTable, {
      'name': feed.name,
      'url': feed.url,
      'parentid': feed.parentId,
      'added': feed.dateAdded.millisecondsSinceEpoch ~/ 1000,
      'lastupdated': feed.lastUpdated.millisecondsSinceEpoch ~/ 1000,
      'title': feed.title,
      'language': feed.language,
      'description': feed.description,
      'webpagelink': feed.webPageLink,
      'favicon': feed.favicon,
      'image': feed.image,
      'lastpurged': feed.lastPurged.millisecondsSinceEpoch ~/ 1000
    });
    
    // Retrieve the newly-inserted item, so that its ID can be obtained
    final queryResult = await sqlfliteDb.query(feedsTable,
                                                columns: ['feedid'],
                                                where: 'url = ?',
                                                whereArgs: [feed.url]);

    if (queryResult.isNotEmpty) {
      int feedId = queryResult.first['feedid'];
      return feedId;
    } else {
      return 0;
    }
  }
}