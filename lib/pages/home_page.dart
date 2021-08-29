import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/dialogs/new_feed_dialog.dart';
import 'package:rss_reader_plus/services/initialization_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/services/purge_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_header_widget.dart';
import 'package:rss_reader_plus/widgets/status_bar_widget.dart';
import 'package:split_view/split_view.dart';
import '../widgets/feed_list_widget.dart';
import '../widgets/feed_item_list_widget.dart';
import '../widgets/feed_item_view_widget.dart';
import '../services/feed_service.dart';

enum ConfigAction { ManageGlobalFilters, EditAdFilter }

// In mobile mode (ie, for a mobile phone), indicates which view
// is currently being shown.
enum ViewMode { FeedList, FeedItemList, FeedView}

// Pane size constraints
const feedPaneWidth = 250.0;
const feedItemPaneHeight = 300.0;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ViewMode _viewMode;
  bool _isDesktop;


  @override
  void initState() {
    _viewMode = ViewMode.FeedList;
    _isDesktop = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    InitializationService _initializationService = Provider.of<InitializationService>(context, listen: false);
    FeedService _feedService = Provider.of<FeedService>(context);
    NotificationService _notificationService = Provider.of<NotificationService>(context);
    PurgeService _purgeService = Provider.of<PurgeService>(context, listen: false);
    
    _isDesktop = MediaQuery.of(context).size.width > 500;


    // _feedService.feedSelected$.listen((feedId) {
    //   if (!_isDesktop) {
    //     ViewMode nextState;

    //     switch (_viewMode) {
    //       case ViewMode.FeedList:
    //         nextState = ViewMode.FeedItemList;    
    //         break;

    //       case ViewMode.FeedItemList:
    //         nextState = ViewMode.FeedView;
    //         break;

    //       case ViewMode.FeedView:
    //         nextState = ViewMode.FeedList;
    //         break;
    //     }

    //     _viewMode = nextState;

    //     // if (mounted) {
    //     //   setState(() {
    //     //     _viewMode = nextState;
    //     //   });
    //     // }
    //   }
    // });

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
            return _buildAll(context, _feedService, _notificationService, _purgeService);

          default:
            return Center(child: Text(''));
        }
      }
    );
  }

  newFeedSelected() {
    print('[HomePage] New Feed Selected!');
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
    if (_isDesktop) {
      return _buildForDesktop(context, feedService, notificationService, purgeService);
    } else {
      return _buildForMobile(context, feedService, notificationService, purgeService);
    }
  }

  Widget _buildForDesktop(BuildContext context,
                          FeedService feedService,
                          NotificationService notificationService,
                          PurgeService purgeService) {
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SplitView(
                viewMode: SplitViewMode.Horizontal,
                gripSize: 8.0,
                gripColor: Colors.blue.shade100,
                gripColorActive: Colors.blue.shade600,
                indicator: SplitIndicator(viewMode: SplitViewMode.Horizontal,),
                activeIndicator: SplitIndicator(
                  viewMode: SplitViewMode.Horizontal,
                  isActive: true,
                ),
                controller: SplitViewController(
                  weights: [.2, .8],
                  limits: [WeightLimit(min: .1, max: .3), null]),
                children: <Widget>[
                  FeedListWidget(feedService, notificationService),
                  SplitView(
                    viewMode: SplitViewMode.Vertical,
                    gripSize: 8.0,
                    gripColorActive: Colors.blue.shade600,
                    gripColor: Colors.blue.shade100,
                    indicator: SplitIndicator(viewMode: SplitViewMode.Vertical,),
                    activeIndicator: SplitIndicator(
                      viewMode: SplitViewMode.Vertical,
                      isActive: true,),
                    controller: SplitViewController(
                      weights: [.5, .5],
                      limits: [WeightLimit(min: .1, max: .9)]
                    ),
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FeedItemHeaderWidget(feedService, notificationService, purgeService),
                          Expanded(child: FeedItemListWidget(feedService)),
                        ],
                      ),
                      FeedItemViewWidget(feedService, notificationService)
                    ],
                  )
                ],
              ),
            ),
            StatusBarWidget(notificationService)
          ],
        ),
      );
  }

  Widget _buildForMobile(BuildContext context,
                         FeedService feedService,
                         NotificationService notificationService,
                         PurgeService purgeService) {
    switch (_viewMode) {
      case ViewMode.FeedList:
        return _buildFeedListWidget(context, feedService, notificationService, purgeService);
      
      case ViewMode.FeedItemList:
        return _buildFeedItemListWidget(context, feedService, notificationService, purgeService);

      case ViewMode.FeedView:
        return _buildFeedViewWidget(context, feedService, notificationService, purgeService);
    }

    return Center(child: Text(''),);    // Should never get here
  }

  Widget _buildFeedListWidget(BuildContext context,
                              FeedService feedService,
                              NotificationService notificationService,
                              PurgeService purgeService) {
    return Container(
      child: FeedListWidget(feedService, notificationService),
    );
  }

  Widget _buildFeedItemListWidget(BuildContext context,
                                  FeedService feedService,
                                  NotificationService notificationService,
                                  PurgeService purgeService) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeedItemHeaderWidget(feedService, notificationService, purgeService),
        Expanded(child: FeedItemListWidget(feedService)),
      ],
    );
  }

  Widget _buildFeedViewWidget(BuildContext context,
                              FeedService feedService,
                              NotificationService notificationService,
                              PurgeService purgeService) {
    return FeedItemViewWidget(feedService, notificationService);
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
