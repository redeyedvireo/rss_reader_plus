import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/dialogs/new_feed_dialog.dart';
import 'package:rss_reader_plus/services/initialization_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_header_widget.dart';
import 'package:rss_reader_plus/widgets/status_bar_widget.dart';
import '../widgets/feed_list_widget.dart';
import '../widgets/feed_item_list_widget.dart';
import '../widgets/feed_item_view_widget.dart';
import '../services/feed_service.dart';

enum ConfigAction { ManageGlobalFilters, EditAdFilter }

// Pane size constraints
const feedPaneWidth = 250.0;
const feedItemPaneHeight = 300.0;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    InitializationService _initializationService = Provider.of<InitializationService>(context, listen: false);
    FeedService _feedService = Provider.of<FeedService>(context);
    NotificationService _notificationService = Provider.of<NotificationService>(context);
    
    return FutureBuilder(
      future: _mainInit(_initializationService),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: Text(''));

          case ConnectionState.active:
            return Center(child: Text(''),);

          case ConnectionState.done:
            return _buildAll(context, _feedService, _notificationService);

          default:
            return Center(child: Text(''));
        }
      }
    );
  }

  Future<void> _mainInit(InitializationService initializationService) async {
    await initializationService.initialize();
  }

  Widget _buildAll(BuildContext context, FeedService feedService, NotificationService notificationService) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RssReader Plus'),
        actions: [
          ElevatedButton(onPressed: () async {
            await _addFeed(context, feedService, notificationService);
          }, child: Text('Add Feed')),
          ElevatedButton(onPressed: _purgeOldNews, child: Text('Purge Old News')),
          IconButton(onPressed: () async {
            await _updateFeeds(feedService);
          }, icon: Icon(Icons.refresh),),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: feedPaneWidth,
                    child: FeedListWidget(feedService, notificationService),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FeedItemHeaderWidget(feedService, notificationService),
                        SizedBox(
                          height: feedItemPaneHeight,
                          child: FeedItemListWidget(feedService)
                        ),
                        Expanded(
                          child: FeedItemViewWidget(feedService, notificationService)
                        )
                      ],
                    ),
                  )
                  
                ],
              ),
            ),
            StatusBarWidget(notificationService)
          ],
        ),
      ),
      drawer: _createDrawer(),
    );
  }

  Widget _createDrawer() {
    return Drawer(child: ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue
          ),
          child: Text('RssReader Plus',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24),)),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Manage Global Filters'),
          onTap: () async {
            Navigator.pop(context);
            await _manageGlobalFilters();
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Edit Language Filters'),
          onTap: () async {
            Navigator.pop(context);
            await _editLanguageFilter();
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Edit Ad Filters'),
          onTap: () async {
            Navigator.pop(context);
            await _editAdFilter();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () async {
            Navigator.pop(context);
            await _preferences();
          },
        )
      ],
    ),);
  }

  Future<void> _addFeed(BuildContext context, FeedService feedService, NotificationService notificationService) async {
    final url = await NewFeedDialog.showNewFeedDialog(context);
    if (url.isNotEmpty) {
      print('Feed URL: $url');

      try {
        final feedId = await feedService.newFeed(url);

        if (feedId > 0) {
          final feed = feedService.getFeed(feedId);
          notificationService.setStatusMessage('Feed ${feed.title} added');

          feedService.selectFeed(feedId);
        } else {
          print('[_addFeed] Error adding feed');
          // TODO: Need error dialog
        }
      } catch (e) {
        print('[_addFeed] ${e.message}');
        // TODO: Need error dialog
      }
    }
  }

  Future<void> _updateFeeds(FeedService feedService) async {
    await feedService.updateFeeds();
  }

  void _purgeOldNews() {
    print('Purge Old News tapped');
  }

  Future<void> _manageGlobalFilters() async {
    await Navigator.pushNamed(context, 'globalfilters');
  }

  Future<void> _editLanguageFilter() async {
    await Navigator.pushNamed(context, 'languagefilters');
  }

  Future<void> _editAdFilter() async {
    print('Edit Ad Filter tapped');
  }

  Future<void> _preferences() async {
    await Navigator.pushNamed(context, 'preferences');
  }
}
