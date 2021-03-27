import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

class FeedItemListWidget extends StatefulWidget {
  @override
  _FeedItemListWidgetState createState() => _FeedItemListWidgetState();
}

class _FeedItemListWidgetState extends State<FeedItemListWidget> {
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  List<FeedItem> _feedItems = [];

  @override
  Widget build(BuildContext context) {
    FeedService _feedService = Provider.of<FeedService>(context);

    
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return FutureBuilder(
          future: _loadFeedItems(_feedService, appState.selectedFeed),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(child: Text(''));

                case ConnectionState.active:
                  return Center(child: Text(''),);

                case ConnectionState.done:
                  return _buildAll(context, appState);

                default:
                  return Center(child: Text(''));
              }
          },
        ); 
      },
    );
  }

  Future<void> _loadFeedItems(FeedService feedService, int feedId) async {
    if (feedId <= 0) {
      // Invalid feed ID
      _feedItems = [];
    } else {
      _feedItems = await feedService.getFeedItems(feedId);
    }
  }

  Widget _buildAll(BuildContext context, AppState appState) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    if (_feedItems.length == 0) {
      return Center(child: Text('No feed items'));
    } else {
      return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: _controller,
          child:ListView.builder(
            itemCount: _feedItems.length,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              return _buildFeedItemRow(context, _feedItems[index], appState);
            },
          )
        )
      );
    }
  }

  Widget _buildFeedItemRow(BuildContext context, FeedItem feedItem, AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: GestureDetector(
        onTap: () async {
          print("Tapped on feed item ${feedItem.guid}");
          appState.selectFeedItem(feedItem);
          _previousScrollPosition = _controller.position.pixels;
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(feedItem.title, overflow: TextOverflow.ellipsis,),
            ),
            Expanded(
              flex: 1,
              child: Text(DateFormat('M/d/y h:mm a').format(feedItem.publicationDatetime), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 1,
              child: Text(feedItem.author, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 1,
              child: Text(feedItem.categories.join(' '), overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      ),
    );
  }
}
