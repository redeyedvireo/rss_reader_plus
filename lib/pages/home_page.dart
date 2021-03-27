import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import '../widgets/feed_list_widget.dart';
import '../widgets/feed_item_list_widget.dart';
import '../widgets/feed_item_view_widget.dart';

// Pane size constraints
const feedPaneWidth = 200.0;
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
    // AppState appState = Provider.of<AppState>(context);
    
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
            return _buildAll(context);

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

  Widget _buildAll(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RssReader Plus'),
        actions: [
          ElevatedButton(onPressed: _addFeed, child: Text('Add Feed')),
          ElevatedButton(onPressed: _updateFeeds, child: Text('Update Feeds')),
          ElevatedButton(onPressed: _purgeOldNews, child: Text('Purge Old News')),
          ElevatedButton(onPressed: _manageGlobalFilters, child: Text('Manage Global Filters')),
          ElevatedButton(onPressed: _editLanguageFilter, child: Text('Edit Language Filter')),
          ElevatedButton(onPressed: _editAdFilter, child: Text('Edit Ad Filter')),
          ElevatedButton(onPressed: _preferences, child: Text('Preferences')),
        ],
      ),
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              width: feedPaneWidth,
              child: FeedListWidget(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: feedItemPaneHeight,
                    child: FeedItemListWidget()
                  ),
                  Expanded(
                    child: FeedItemViewWidget()
                  )
                ],
              ),
            )
            
          ],
        ),
      ),
    );
  }

  void _addFeed() {
    print('Add Feed tapped');
  }

  void _updateFeeds() {
    print('Update Feeds tapped');
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
