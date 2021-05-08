import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';

class FeedListWidget extends StatefulWidget {
  FeedService feedService;
  NotificationService notificationService;

  FeedListWidget(this.feedService, this.notificationService);

  @override
  _FeedListWidgetState createState() => _FeedListWidgetState();
}


class _FeedListWidgetState extends State<FeedListWidget> {
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  List<Feed> _feeds;
  Map<int, int> _unreadCount;
  
  @override
  void initState() {
    super.initState();

    _feeds = [];
    _unreadCount = {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchFeeds(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              return _buildAll(context, _feeds, widget.feedService, widget.notificationService);

            default:
              return Center(child: Text(''));
          }
      },
    ); 
  }

  Future<void> _fetchFeeds() async {
    _feeds = await widget.feedService.getFeeds();

    _unreadCount = {};

    for (final feed in _feeds) {
      final count = await widget.feedService.numberOfUnreadFeedItems(feed.id);
      _unreadCount[feed.id] = count;
    }
  }

  Widget _buildAll(BuildContext context, List<Feed> feeds, FeedService feedService, NotificationService notificationService) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor))
            ),
      child: Scrollbar(
        isAlwaysShown: true,
        thickness: 12.0,
        controller: _controller,
        child: Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: ListView.builder(
            itemCount: feeds.length,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              return _buildFeedRow(context, feeds[index], feedService, notificationService);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeedRow(BuildContext context, Feed feed, FeedService feedService, NotificationService notificationService) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: _backgroundColor(feed, feedService),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            _previousScrollPosition = _controller.position.pixels;
            notificationService.setStatusMessage('${feed.name} selected', timeout: 1);
            widget.feedService.selectFeed(feed.id);
            setState(() { });
          },
          onSecondaryTapUp: (TapUpDetails details) async {
            // notificationService.setStatusMessage('Feed ${feed.name}, ID: ${feed.id}');
            // TODO: Want to show a pop-up menu here with various actions, including an item to
            //  update the feed.  Unfortunately, like most things in flutter, doing this simple
            //  thing is a mini-research project.  Figure this stuff out later.
            // final menuRect = RelativeRect.fromLTRB(details.localPosition, top, right, bottom)
            // final selection = await showMenu(context: context, position: details.localPosition, items: items)
            // await feedService.fetchFeed(feed.id);
          },
          child: Row(
            children: <Widget>[
              feedService.getFeedIconWidget(feed.id),
              SizedBox(width: 5.0),
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

  int _feedUnread(int feedId) {
    return _unreadCount.containsKey(feedId) ? _unreadCount[feedId] : 0;
  }

  Widget _feedRowText(BuildContext context, Feed feed, FeedService feedService) {
    final _unreadForFeed = _feedUnread(feed.id);
    final label = _unreadForFeed > 0 ? '${feed.name} ($_unreadForFeed)' : feed.name;

    return Text(label, overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _textColor(feed, feedService),
                        fontWeight: _unreadForFeed > 0 ? FontWeight.bold : FontWeight.normal),
    );
  }
}