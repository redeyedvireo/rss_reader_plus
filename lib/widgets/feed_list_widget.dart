import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rxdart/rxdart.dart';

class FeedListWidget extends StatefulWidget {
  FeedService feedService;

  FeedListWidget(this.feedService);

  @override
  _FeedListWidgetState createState() => _FeedListWidgetState();
}


class _FeedListWidgetState extends State<FeedListWidget> {
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  
  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder(
      future: widget.feedService.getFeeds(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: Text(''));

            case ConnectionState.active:
              return Center(child: Text(''),);

            case ConnectionState.done:
              return _buildAll(context, snapshot.data, appState, widget.feedService);

            default:
              return Center(child: Text(''));
          }
      },
    ); 
  }

  Widget _buildAll(BuildContext context, List<Feed> feeds, AppState appState, FeedService feedService) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor))
            ),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _controller,
        child: ListView.builder(
          itemCount: feeds.length,
          controller: _controller,
          itemBuilder: (BuildContext context, int index) {
            return _buildFeedRow(context, feeds[index], appState, feedService);
          },
        ),
      ),
    );
  }

  Widget _buildFeedRow(BuildContext context, Feed feed, AppState appState, FeedService feedService) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: _backgroundColor(feed, feedService),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            _previousScrollPosition = _controller.position.pixels;
            appState.setStatusMessage('${feed.name} selected', timeout: 1);
            widget.feedService.selectFeed(feed.id);
          },
          onSecondaryTapUp: (TapUpDetails details) async {
            appState.setStatusMessage('Feed ${feed.name}, ID: ${feed.id}');
            // TODO: Want to show a pop-up menu here with various actions, including an item to
            //  update the feed.  Unfortunately, like most things in flutter, doing this simple
            //  thing is a mini-research project.  Figure this stuff out later.
            // final menuRect = RelativeRect.fromLTRB(details.localPosition, top, right, bottom)
            // final selection = await showMenu(context: context, position: details.localPosition, items: items)
            await feedService.fetchFeed(feed.id);
          },
          child: Row(
            children: <Widget>[
              Expanded(child: _feedRowText(context, feed, feedService)),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSelected(Feed feed, FeedService feedService) {
    return feed.id == feedService.selectedFeedId;
  }

  Color _backgroundColor(Feed feed, FeedService feedService) {
    // TODO: Use theme colors here
    return _isSelected(feed, feedService) ? Colors.blue : Colors.white;
  }

  Color _textColor(Feed feed, FeedService feedService) {
    // TODO: Use theme colors here
    return _isSelected(feed, feedService) ? Colors.white : Colors.black;
  }

  Widget _feedRowText(BuildContext context, Feed feed, FeedService feedService) {
    return Text(feed.name, overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _textColor(feed, feedService)),
    );
  }
}