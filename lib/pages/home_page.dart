import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import '../widgets/feed_list_widget.dart';
import '../widgets/feed_item_list_widget.dart';
import '../widgets/feed_item_view_widget.dart';

// Pane size constraints
const feedPaneWidth = 200.0;
const feedItemPaneHeight = 300.0;
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    FeedDatabase feedDb = Provider.of<FeedDatabase>(context, listen: false);
    
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
        title: Text(this.title),
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
}
