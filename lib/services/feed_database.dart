
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/models/feed_item_filter.dart';
import 'package:rss_reader_plus/models/item_of_interest.dart';
import 'package:rss_reader_plus/util/utils.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const DATABASE_VERSION = 1;

class FeedDatabase {
  static const DB_FILE = 'Feeds.db';
  static const DB_VERSION = 1;
  static String databasePath = '';
  Database sqlfliteDb;
  Logger _logger;

  static final feedsTable = 'feeds';
  static final itemsOfInterestTable = 'itemsofinterest';
  static final feedItemFilterTable = 'feeditemfilters';
  static final filteredWordsTable = 'filteredwords';
  static final adFiltersTable = 'adfilters';
  static final keystoreTable = 'keystore';

  FeedDatabase() {
    _logger = Logger('FeedDatabase');
  }

  /// Returns the Sqlflite database.
  static Future<Database> init() async {
    Logger _tempLogger = Logger('FeedDatabaseStatic');

    final databaseDir = await getDatabaseDirectory(_tempLogger);

    FeedDatabase.databasePath = join(databaseDir, DB_FILE);
    
    _tempLogger.info('[init] Opening database: $FeedDatabase.databasePath');

    try {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;

      return await databaseFactory.openDatabase(FeedDatabase.databasePath,
                                                  options: OpenDatabaseOptions(
                                                  version: DATABASE_VERSION,
                                                  onCreate: FeedDatabase.onCreate));      
    } catch (e) {
      _tempLogger.severe('[init] $e');
    }
  }

  static Future<String> getDatabaseDirectory(Logger logger) async {
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

    logger.info('temp dir: $tempDirectory');
    logger.info('downloads dir: $downloadsDirectory');
    logger.info('documents dir: $documentsDirectory');
    logger.info('appSupport dir: $appSupportDirectory');

    // TODO: Use the downloads directory as the temporary place for the feeds database
    return downloadsDirectory;
  }

  static Future<void> onCreate(Database db, int version) async {
    Logger _tempLogger = Logger('FeedDatabaseStatic');

    _tempLogger.info('[onCreate] Creating tables...');
    createTables(db);
  }

  static Future<void> createTables(Database db) async {
    await createFeedTable(db);
    await createItemsOfInterestTable(db);
    await createFilteredWordsTable(db);
    await createFeedItemFilters(db);
    await createAdFilters(db);
    await createKeystoreTable(db);
  }

  static Future<void> createFeedTable(Database db) async {
    final sql = 'CREATE TABLE $feedsTable ('
        'feedid integer primary key, '  // Unique Feed ID (must not be 0).  SQLite guarantees this field to be unique
        'name text, '                   // User - specified name of feed
        'url text, '                    // Feed URL
        'parentid integer, '            // Page's parent page (TODO: Figure out how to use this)
        'added integer, '               // Date and time the feed was added, as a time_t
        'lastupdated integer, '         // Date and time page was last updated, as a time_t
        'title text, '                  // Feed title
        'language text, '               // Feed language
        'description text, '            // Feed description
        'webpagelink text, '            // URL of web site that owns this feed
        'favicon blob, '                // Favicon for feed's main web site
        'image blob, '                  // Feed image(not a favicon)
        'lastpurged integer default 0'  // Date and time the feed was last purged
        ')';

    await db.execute(sql);
  }

  static Future<void> createItemsOfInterestTable(Database db) async {
    final sql = 'CREATE TABLE $itemsOfInterestTable ('
        'feedid integer, ' // Feed ID of this item
        'guid text '       //Item guid
        ')';

    await db.execute(sql);
  }

  static Future<void> createFilteredWordsTable(Database db) async {
    final sql = 'CREATE TABLE $filteredWordsTable ('
        'word text '  // Word to filter
        ')';

    await db.execute(sql);
  }

  static Future<void> createFeedItemFilters(Database db) async {
    final sql = 'create table $feedItemFilterTable ('
        'filterid integer primary key, '  // Filter ID
        'feedid integer, '                // Feed ID
        'field integer, '                 // ID of field to query
        'verb integer, '                  // Query action to perform
        'querystring text, '              // String to look for
        'action integer '                 // Action ID
        ')';

    await db.execute(sql);
  }

  static Future<void> createAdFilters(Database db) async {
    final sql = 'create table $adFiltersTable ('
        'word text '  // Word to filter
        ')';

    await db.execute(sql);
  }

  static Future<void> createKeystoreTable(Database db) async {
    final sql = 'create table $keystoreTable ('
        'key text, '
        'value text'
        ')';

    await db.execute(sql);
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

  DateTime timestampToDateTime(int timestamp) {
    DateTime tempDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    if (tempDateTime.year < 2000) {
      tempDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }

    return tempDateTime;
  }

  int dateTimeToTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
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
        dateAdded: timestampToDateTime(feedMap['added']),         // WARNING: This is stored as a Julian date
        lastUpdated: timestampToDateTime(feedMap['lastupdated']), // WARNING: This is stored as a Julian date
        lastPurged: timestampToDateTime(feedMap['lastpurged']),   // WARNING: This is stored as a Julian date
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

  /// Note: this may throw an exception
  Future<int> writeFeed(Feed feed) async {
    await sqlfliteDb.insert(feedsTable, {
      'name': feed.name,
      'url': feed.url,
      'parentid': feed.parentId,
      'added': dateTimeToTimestamp(feed.dateAdded),
      'lastupdated': dateTimeToTimestamp(feed.lastUpdated),
      'title': feed.title,
      'language': feed.language,
      'description': feed.description,
      'webpagelink': feed.webPageLink,
      'favicon': feed.favicon,
      'image': feed.image,
      'lastpurged': dateTimeToTimestamp(feed.lastPurged)
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

  Future<bool> writeLastPurged(int feedId, DateTime lastPurgedDateTime) async {
    final numRecordsUpdated = await sqlfliteDb.update(feedsTable, {
      'lastpurged': dateTimeToTimestamp(lastPurgedDateTime)
    },
    where: 'feedid = ?',
    whereArgs: [ feedId ]);

    return numRecordsUpdated == 1;
  }

  Future<void> vacuumDatabase() async {
    await sqlfliteDb.rawQuery('vacuum;');
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
    int timestamp = dbResult['pubdatetime'];

    return FeedItem(
      title: dbResult['title'],
      author: dbResult['author'],
      link: dbResult['link'],
      description: dbResult['description'],
      encodedContent: dbResult['contentencoded'],
      categories: _splitCategories(dbResult['categories']),
      publicationDatetime: timestampToDateTime(timestamp),
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

  Future<bool> deleteFeedItem(int feedId, String guid) async {
    String tableName = feedIdToString(feedId);

    final numRowsRemoved = await sqlfliteDb.delete(tableName,
                                                   where: 'guid = ?',
                                                   whereArgs: [guid]);

    return numRowsRemoved > 0;
  }

  Future<int> deleteFeedItemsByDate(int feedId, DateTime targetDate, bool deleteUnreadItems) async {
    String tableName = feedIdToString(feedId);
    String whereClause = '';
    List<int> args = [ dateTimeToTimestamp(targetDate) ];

    if (deleteUnreadItems) {
      whereClause = 'pubdatetime <= ?';
    } else {
      whereClause = 'pubdatetime <= ? and readflag = 1';
    }

    final numRowsRemoved = await sqlfliteDb.delete(tableName,
                                                    where: whereClause,
                                                    whereArgs: args);

    return numRowsRemoved;
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
        'pubdatetime': dateTimeToTimestamp(feedItem.publicationDatetime),
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

  Future<List<String>> readAdFilters() async {
    List<String> filters = [];

    final queryResult = await sqlfliteDb.query(adFiltersTable, columns: [ 'word' ]);

    queryResult.forEach((row) {
      filters.add(row['word']);
    });

    return filters;
  }

  Future<int> addAdFilter(String adFilter) async {
    return await sqlfliteDb.insert(adFiltersTable, { 'word': adFilter });
  }

  Future<int> deleteAdFilter(String adFilter) async {
    return await sqlfliteDb.delete(adFiltersTable,
                                    where: 'word = ?',
                                    whereArgs: [adFilter]);
  }

  Future<int> writeKeystoreItem(String key, String value) async {
    return await sqlfliteDb.insert(keystoreTable, {
      'key': key,
      'value': value
    });
  }

  Future<String> readKeystoreItem(String key) async {
    final queryResult = await sqlfliteDb.query(keystoreTable,
                                               columns: [ 'value' ],
                                               where: 'key = ?',
                                               whereArgs: [key]);
    if (queryResult.isNotEmpty) {
      return queryResult.first['value'];
    } else {
      return '';
    }                                               
  }

  Future<bool> updateKeystoreItem(String key, String value) async {
    final numRecordsUpdated = await sqlfliteDb.update(keystoreTable, {
      'value': value
    },
    where: 'key = ?',
    whereArgs: [ key ]);

    return numRecordsUpdated == 1;
  }

  /// Determines if the given key exists in the keystore.
  Future<bool> keyExistsInKeystore(String key) async {
    final queryResult = await sqlfliteDb.query(keystoreTable,
                                               columns: [ 'value' ],
                                               where: 'key = ?',
                                               whereArgs: [key]);
    return queryResult.isNotEmpty;
  }
}