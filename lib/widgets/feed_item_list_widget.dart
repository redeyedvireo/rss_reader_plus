import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rxdart/rxdart.dart';

class FeedItemListWidget extends StatefulWidget {
  FeedService feedService;

  FeedItemListWidget(this.feedService);

  @override
  _FeedItemListWidgetState createState() => _FeedItemListWidgetState();
}

class _FeedItemListWidgetState extends State<FeedItemListWidget> {
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page

  @override
  void initState() {
    super.initState();
    widget.feedService.feedSelected$.listen((feedId) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AppState _appState = Provider.of<AppState>(context);
    
    return FutureBuilder(
      future: widget.feedService.getFeedItems(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: Text(''));

            case ConnectionState.active:
              return Center(child: Text(''),);

            case ConnectionState.done:
              return _buildAll(context, _appState, snapshot.data);

            default:
              return Center(child: Text(''));
          }
      },
    );
  }

  // TODO: The list view could probably be refactored into a "SelectableList" widget.

  Widget _buildAll(BuildContext context, AppState appState, List<FeedItem> feedItems) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    if (feedItems.length == 0) {
      return Center(child: Text('No feed items'));
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
        child: Scrollbar(
          isAlwaysShown: true,
          thickness: 12.0,
          controller: _controller,
          child:ListView.builder(
            itemCount: feedItems.length,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              return _buildFeedItemRow(context, feedItems[index], appState);
            },
          )
        )
      );
    }
  }

  Widget _buildFeedItemRow(BuildContext context, FeedItem feedItem, AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      color: _backgroundColor(feedItem, appState),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            print("Tapped on feed item ${feedItem.guid}");
            widget.feedService.feedItemSelected$.add(feedItem);
            appState.selectFeedItem(feedItem);
            _previousScrollPosition = _controller.position.pixels;
          },
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: _rowText(feedItem.title, feedItem, appState),
              ),
              Expanded(
                flex: 1,
                child: _rowText(DateFormat('M/d/y h:mm a').format(feedItem.publicationDatetime), feedItem, appState),
              ),
              Expanded(
                flex: 1,
                child: _rowText(feedItem.author, feedItem, appState),
              ),
              Expanded(
                flex: 1,
                child: _rowText(feedItem.categories.join(' '), feedItem, appState),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _isSelected(FeedItem feedItem, AppState appState) {
    return appState.selectedFeedItem != null && appState.selectedFeedItem.guid == feedItem.guid;
  }

    Color _backgroundColor(FeedItem feedItem, AppState appState) {
    // TODO: Use theme colors here
    return _isSelected(feedItem, appState) ? Colors.blue : Colors.white;
  }

  Color _textColor(FeedItem feedItem, AppState appState) {
    // TODO: Use theme colors here
    return _isSelected(feedItem, appState) ? Colors.white : Colors.black;
  }

  Widget _rowText(String text, FeedItem feedItem, AppState appState) {
    return Text(text, overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _textColor(feedItem, appState)),
    );
  }
}
