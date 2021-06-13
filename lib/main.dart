import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/pages/global_filters_page.dart';
import 'package:rss_reader_plus/pages/preferences_page.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/filter_service.dart';
import 'package:rss_reader_plus/services/initialization_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';

import './pages/home_page.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider<PrefsService>(create: (context) => PrefsService()),
      Provider<NotificationService>(create: (context) => NotificationService()),
      Provider<FeedDatabase>(create: (context) => FeedDatabase()),
      Provider<FilterService>(create: (context) => FilterService(context)),
      Provider<FeedService>(create: (context) => FeedService(context)),
      Provider<AppState>(create: (context) => AppState()),
      Provider<InitializationService>(create: (context) => InitializationService(context)),
    ],
    child: MaterialApp(
      title: 'RssReader Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => MyHomePage(),
        'globalfilters': (BuildContext context) => GlobalFiltersPage(),
        'preferences': (BuildContext context) => PreferencesPage(),
      },
    ));
  }
}
