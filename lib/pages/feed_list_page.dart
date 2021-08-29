
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/dialogs/new_feed_dialog.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/initialization_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/services/purge_service.dart';
import 'package:rss_reader_plus/widgets/feed_list_widget.dart';

class FeedListPage extends StatefulWidget {
  const FeedListPage();

  @override
  _FeedListPageState createState() => _FeedListPageState();
}

class _FeedListPageState extends State<FeedListPage> {
  @override
  Widget build(BuildContext context) {
    InitializationService _initializationService = Provider.of<InitializationService>(context, listen: false);
    FeedService _feedService = Provider.of<FeedService>(context);
    NotificationService _notificationService = Provider.of<NotificationService>(context);
    PurgeService _purgeService = Provider.of<PurgeService>(context, listen: false);
    
    // _feedService.feedSelected$.listen((feedId) async {
    //   await Navigator.pushNamed(context, 'feeditemlist');
    // });

    return FutureBuilder(
      future: _mainInit(_initializationService),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return _buildAll(context, _feedService, _notificationService, _purgeService);

          default:
            return Center(child: Text(''));
        }
      }
    );
  }

  Future<void> _mainInit(InitializationService initializationService) async {
    if (!initializationService.isInitialized) {
      await initializationService.initialize();
    }
  }

  Widget _buildAll(BuildContext context,
                   FeedService feedService,
                   NotificationService notificationService,
                   PurgeService purgeService) {
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
      body: _buildContent(context, feedService, notificationService, purgeService),
      drawer: _createDrawer(),
    );
  }

  Widget _buildContent(BuildContext context,
                       FeedService feedService,
                       NotificationService notificationService,
                       PurgeService purgeService) {
    return _buildFeedListWidget(context, feedService, notificationService, purgeService);
  }

  Widget _buildFeedListWidget(BuildContext context,
                              FeedService feedService,
                              NotificationService notificationService,
                              PurgeService purgeService) {
    return Container(
      // child: Consumer<AppState>(
      //   builder: (context, appState, child) {
      //     return FeedListWidget(feedService, notificationService, onFeedSelectedFn: (feedId) async {
      //       await Navigator.pushNamed(context, 'feeditemlist');
      //     },);
      //   }
      // )
      child: FeedListWidget(feedService, notificationService, onFeedSelectedFn: (feedId) async {
        await Navigator.pushNamed(context, 'feeditemlist');
      }),
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
          leading: Icon(Icons.info),
          title: Text('App info'),
          onTap: () async {
            Navigator.pop(context);
            await _appInfo();
          },
        ),
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
    await Navigator.pushNamed(context, 'adfilters');
  }

  Future<void> _preferences() async {
    await Navigator.pushNamed(context, 'preferences');
  }

  Future<void> _appInfo() async {
    await Navigator.pushNamed(context, 'app_info');
  }
}