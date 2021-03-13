
import 'package:path/path.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FeedDatabase {
  static const DB_FILE = 'Feeds.db';
  static const DB_VERSION = 1;
  Database sqlfliteDb;

  static final feedsTable = 'feeds';

  FeedDatabase();

  /**
   * Returns the Sqlflite database.
   */
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

  void setSqlfliteDb(Database database) {
    sqlfliteDb = database;
  }

  Future<List<Feed>> readFeeds() async {
    final feedMapList = await sqlfliteDb.rawQuery('SELECT * FROM $feedsTable');

    List<Feed> feeds = [];

    // feedMapList is an array of maps
    for (var feedMap in feedMapList) {
      final feed = Feed(name: feedMap['name'],
                        title: feedMap['title'],
                        description: feedMap['description']);
      feeds.add(feed);
    }

    return feeds;
  }
}