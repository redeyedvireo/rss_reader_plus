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
              return _buildAll(context, widget.feedService, snapshot.data);

            default:
              return Center(child: Text(''));
          }
      },
    );
  }

  // TODO: The list view could probably be refactored into a "SelectableList" widget.

  Widget _buildAll(BuildContext context, FeedService feedService, List<FeedItem> feedItems) {
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
              return _buildFeedItemRow(context, feedItems[index], feedService);
            },
          )
        )
      );
    }
  }

  Widget _buildFeedItemRow(BuildContext context, FeedItem feedItem, FeedService feedService) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      color: _backgroundColor(feedItem, feedService),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            print("Tapped on feed item ${feedItem.guid}");
            widget.feedService.selectFeedItem(feedItem.guid);
            _previousScrollPosition = _controller.position.pixels;
          },
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: _rowText(feedItem.title, feedItem, feedService),
              ),
              Expanded(
                flex: 1,
                child: _rowText(DateFormat('M/d/y h:mm a').format(feedItem.publicationDatetime), feedItem, feedService),
              ),
              Expanded(
                flex: 1,
                child: _rowText(feedItem.author, feedItem, feedService),
              ),
              Expanded(
                flex: 1,
                child: _rowText(feedItem.categories.join(' '), feedItem, feedService),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _isSelected(FeedItem feedItem, FeedService feedService) {
    return feedService.selectedFeedItemId == feedItem.guid;
  }

    Color _backgroundColor(FeedItem feedItem, FeedService feedService) {
    // TODO: Use theme colors here
    return _isSelected(feedItem, feedService) ? Colors.blue : Colors.white;
  }

  Color _textColor(FeedItem feedItem, FeedService feedService) {
    // TODO: Use theme colors here
    return _isSelected(feedItem, feedService) ? Colors.white : Colors.black;
  }

  Widget _rowText(String text, FeedItem feedItem, FeedService feedService) {
    return Text(text, overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _textColor(feedItem, feedService)),
    );
  }
}
