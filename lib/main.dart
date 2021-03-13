import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/database.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

import './pages/home_page.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider<Database>(create: (context) => Database()),
      Provider<FeedService>(create: (context) => FeedService(context))
    ],
    child: MaterialApp(
      title: 'RssReader Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Rss Reader Plus'),
    ));
  }
}
