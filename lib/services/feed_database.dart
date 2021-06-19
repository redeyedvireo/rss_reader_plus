
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/models/feed_item_filter.dart';
import 'package:rss_reader_plus/models/item_of_interest.dart';
import 'package:rss_reader_plus/util/utils.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FeedDatabase {
  static const DB_FILE = 'Feeds.db';
  static const DB_VERSION = 1;
  Database sqlfliteDb;

  static final feedsTable = 'feeds';
  static final itemsOfInterestTable = 'itemsofinterest';
  static final feedItemFilterTable = 'feeditemfilters';
  static final filteredWordsTable = 'filteredwords';

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
        final feedItem = feedItemFromDbResult(feedItemMap, feedId);
        feedItems[feedItem.guid] = feedItem;
      }
    } catch (e) {
      print('[FeedDatabase.readFeedItems] Error: $e');
    }

    return feedItems;
  }

  /// Reads a single feed item.
  Future<FeedItem> readFeedItem(int feedId, String guid) async {
    String tableName = feedIdToString(feedId);

    final queryResult = await sqlfliteDb.query(tableName,
                                               where: 'guid = ?',
                                               whereArgs: [guid]);

    return feedItemFromDbResult(queryResult.first, feedId);
  }

  FeedItem feedItemFromDbResult(dynamic dbResult, int feedId) {
    int timestampRaw = dbResult['pubdatetime'];
    int timestamp = timestampRaw * 1000;

    return FeedItem(
      title: dbResult['title'],
      author: dbResult['author'],
      link: dbResult['link'],
      description: dbResult['description'],
      encodedContent: dbResult['contentencoded'],
      categories: _splitCategories(dbResult['categories']),
      publicationDatetime: DateTime.fromMillisecondsSinceEpoch(timestamp),
      thumbnailLink: dbResult['thumbnaillink'],
      thumbnailWidth: dbResult['thumbnailwidth'],
      thumbnailHeight: dbResult['thumnailheight'],
      guid: dbResult['guid'],
      feedburnerOrigLink: dbResult['feedburneroriglink'],
      enclosureLink: dbResult['enclosurelink'],
      enclosureLength: dbResult['enclosurelength'],
      enclosureType: dbResult['enclosuretype'],
      parentFeedId: feedId,
      read: dbResult['readflag'] == 1 ? true : false
    );
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

  Future<List<ItemOfInterest>> readItemsOfInterest() async {
    final queryResult = await sqlfliteDb.query(itemsOfInterestTable,
                                                columns: ['feedid', 'guid']);

    if (queryResult.isNotEmpty) {
      List<ItemOfInterest> itemsOfInterest = [];

      queryResult.forEach((row) {
        itemsOfInterest.add(ItemOfInterest(row['feedid'], row['guid']));
      });
      return itemsOfInterest;
    } else {
      return [];
    }
  }

  Future<bool> writeItemsOfInterest(List<ItemOfInterest> itemsOfInterest) async {
    final batch = sqlfliteDb.batch();

    for (var itemOfInterest in itemsOfInterest) {
      batch.insert(itemsOfInterestTable, {
        'feedid': itemOfInterest.feedId,
        'guid': itemOfInterest.guid
      });
    }

    final result = await batch.commit();
    return result.isNotEmpty;     // TODO: To be more thorough, go check each item in the result
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

  Future<bool> isFeedItemRead(int feedId, String guid) async {
    final tableName = feedIdToString(feedId);

    final queryResult = await sqlfliteDb.query(tableName,
                                               columns: ['readflag'],
                                               where: 'guid = ?',
                                               whereArgs: [guid]);

    if (queryResult.isNotEmpty) {
      return queryResult.first['readflag'] == 1;
    } else {
      return false;
    }
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

  /// Deletes a feed item table
  Future<void> deleteFeedItemTable(int feedId) async {
    final tableName = feedIdToString(feedId);

    await sqlfliteDb.execute('drop table $tableName');
  }

  /// Removes a feed from the feeds table.
  Future<bool> removeFeed(int feedId) async {
    final numRowsRemoved = await sqlfliteDb.delete(feedsTable,
                                                   where: 'feedid = ?',
                                                   whereArgs: [feedId]);
    return numRowsRemoved > 0;
  }

  Future<List<FeedItemFilter>> readFeedItemFilters() async {
    List<FeedItemFilter> feedItemFilters = [];

    final queryResult = await sqlfliteDb.query(feedItemFilterTable,
                                                columns: ['filterid',
                                                          'feedid',
                                                          'field',
                                                          'verb',
                                                          'querystring',
                                                          'action']);
    
    queryResult.forEach((row) {
      final feedItemFilter = FeedItemFilter(filterId: row['filterid'],
                                            feedId: row['feedid'],
                                            fieldId: FilterField.values[row['field']],
                                            verb: FilterQuery.values[row['verb']],
                                            queryStr: row['querystring'],
                                            action: FilterAction.values[row['action']]);

      feedItemFilters.add(feedItemFilter);
    });

    return feedItemFilters;
  }

  Future<int> updateFeedItemFilter(FeedItemFilter feedItemFilter) async {
    return await sqlfliteDb.update(feedItemFilterTable, {
      'field': feedItemFilter.fieldId.index,
      'verb': feedItemFilter.verb.index,
      'querystring': feedItemFilter.queryStr,
      'action': feedItemFilter.action.index
    },
    where: 'filterid = ?',
    whereArgs: [feedItemFilter.filterId]);
  }

  Future<int> deleteFeedItemFilter(FeedItemFilter feedItemFilter) async {
    return await sqlfliteDb.delete(feedItemFilterTable,
                                   where: 'filterid = ?',
                                   whereArgs: [feedItemFilter.filterId]);
  }

  Future<int> createFeedItemFilter(FeedItemFilter feedItemFilter) async {
    return await sqlfliteDb.insert(feedItemFilterTable, {
      'feedid': feedItemFilter.feedId,
      'field': feedItemFilter.fieldId.index,
      'verb': feedItemFilter.verb.index,
      'querystring': feedItemFilter.queryStr,
      'action': feedItemFilter.action.index
    });
  }
  
  Future<List<String>> readLanguageFilters() async {
    List<String> filters = [];

    final queryResult = await sqlfliteDb.query(filteredWordsTable, columns: [ 'word' ]);

    queryResult.forEach((row) {
      filters.add(row['word']);
    });

    return filters;
  }

  Future<int> addLanguageFilter(String filteredWord) async {
    return await sqlfliteDb.insert(filteredWordsTable, {
      'word': filteredWord
    });
  }

  Future<int> deleteLanguageFilter(String filteredWord) async {
    return await sqlfliteDb.delete(filteredWordsTable,
                                                 where: 'word = ?',
                                                 whereArgs: [filteredWord]);
  }
}