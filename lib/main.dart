import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/pages/app_info_page.dart';
import 'package:rss_reader_plus/pages/edit_ad_filters_page.dart';
import 'package:rss_reader_plus/pages/feed_item_list_page.dart';
import 'package:rss_reader_plus/pages/feed_list_page.dart';
import 'package:rss_reader_plus/pages/feed_view_page.dart';
import 'package:rss_reader_plus/pages/global_filters_page.dart';
import 'package:rss_reader_plus/pages/language_filters_page.dart';
import 'package:rss_reader_plus/pages/preferences_page.dart';
import 'package:rss_reader_plus/services/ad_filter_service.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/filter_service.dart';
import 'package:rss_reader_plus/services/initialization_service.dart';
import 'package:rss_reader_plus/services/keystore_service.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';
import 'package:rss_reader_plus/services/network_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';
import 'package:rss_reader_plus/services/purge_service.dart';
import 'package:rss_reader_plus/services/update_service.dart';

import './pages/home_page.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<AppState>(create: (_) => AppState()),
      Provider<PrefsService>(create: (context) => PrefsService()),
      Provider<NetworkService>(create: (context) => NetworkService(context)),
      Provider<NotificationService>(create: (context) => NotificationService()),
      Provider<FeedDatabase>(create: (context) => FeedDatabase()),
      Provider<KeystoreService>(create: (context) => KeystoreService(context)),
      Provider<FilterService>(create: (context) => FilterService(context)),
      Provider<LanguageFilterService>(create: (context) => LanguageFilterService(context)),
      Provider<AdFilterService>(create: (context) => AdFilterService(context)),
      Provider<FeedService>(create: (context) => FeedService(context)),
      Provider<AppState>(create: (context) => AppState()),
      Provider<UpdateService>(create: (context) => UpdateService(context)),
      Provider<PurgeService>(create: (context) => PurgeService(context)),
      Provider<InitializationService>(create: (context) => InitializationService(context)),
    ],
    child: MaterialApp(
      title: 'RssReader Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: Platform.isWindows ? 'homewindows' : 'homeandroid',
      initialRoute: 'homeandroid',      // For debugging
      routes: {
        'homewindows': (BuildContext context) => MyHomePage(),
        'homeandroid': (BuildContext context) => FeedListPage(),
        'feeditemlist': (BuildContext context) => FeedItemListPage(),
        'feedview': (BuildContext context) => FeedViewPage(),
        'globalfilters': (BuildContext context) => GlobalFiltersPage(),
        'languagefilters': (BuildContext context) => LanguageFiltersPage(),
        'adfilters': (BuildContext context) => AdFiltersPage(),
        'preferences': (BuildContext context) => PreferencesPage(),
        'app_info': (BuildContext context) => AppInfoPage(),
      },
    ));
  }
}
