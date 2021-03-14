import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

import './pages/home_page.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider<FeedDatabase>(create: (context) => FeedDatabase()),
      Provider<FeedService>(create: (context) => FeedService(context)),
      ChangeNotifierProvider<AppState>(create: (context) => AppState())
    ],
    child: MaterialApp(
      title: 'RssReader Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    ));
  }
}
