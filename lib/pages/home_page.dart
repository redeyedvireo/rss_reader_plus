import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/dialogs/new_feed_dialog.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_header_widget.dart';
import 'package:rss_reader_plus/widgets/status_bar_widget.dart';
import '../widgets/feed_list_widget.dart';
import '../widgets/feed_item_list_widget.dart';
import '../widgets/feed_item_view_widget.dart';
import '../services/feed_service.dart';

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
    FeedDatabase feedDb = Provider.of<FeedDatabase>(context, listen: false);
    FeedService _feedService = Provider.of<FeedService>(context);
    NotificationService _notificationService = Provider.of<NotificationService>(context);
    
    return FutureBuilder(
      future: _mainInit(feedDb),
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

  Future<void> _mainInit(FeedDatabase feedDb) async {
    final sqlfliteDb = await FeedDatabase.init();
    feedDb.setSqlfliteDb(sqlfliteDb);
  }

  Widget _buildAll(BuildContext context, FeedService feedService, NotificationService notificationService) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RssReader Plus'),
        actions: [
          ElevatedButton(onPressed: () async {
            _addFeed(context, feedService, notificationService);
          }, child: Text('Add Feed')),
          ElevatedButton(onPressed: () {
            _updateFeeds(feedService);
          }, child: Text('Update Feeds')),
          ElevatedButton(onPressed: _purgeOldNews, child: Text('Purge Old News')),
          ElevatedButton(onPressed: _manageGlobalFilters, child: Text('Manage Global Filters')),
          ElevatedButton(onPressed: _editLanguageFilter, child: Text('Edit Language Filter')),
          ElevatedButton(onPressed: _editAdFilter, child: Text('Edit Ad Filter')),
          ElevatedButton(onPressed: _preferences, child: Text('Preferences')),
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
    );
  }

  void _addFeed(BuildContext context, FeedService feedService, NotificationService notificationService) async {
    final url = await NewFeedDialog.showNewFeedDialog(context);
    if (url.isNotEmpty) {
      print('Feed URL: $url');

      try {
        final feedId = await feedService.newFeed(url);

        if (feedId > 0) {
          // TODO: Consider popping up a dialog asking if the user would like to switch to the new feed.
          //  (or, maybe just go ahead and switch to it.)
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

  void _updateFeeds(FeedService feedService) async {
    await feedService.updateFeeds();
  }

  void _purgeOldNews() {
    print('Purge Old News tapped');
  }

  void _manageGlobalFilters() {
    print('Manage Global Filters tapped');
  }

  void _editLanguageFilter() {
    print('Edit Language Filter tapped');
  }

  void _editAdFilter() {
    print('Edit Ad Filter tapped');
  }

  void _preferences() {
    print('Preferences tapped');
  }
}
