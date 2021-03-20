import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

class FeedListWidget extends StatefulWidget {
  FeedListWidget();

  @override
  _FeedListWidgetState createState() => _FeedListWidgetState();
}


class _FeedListWidgetState extends State<FeedListWidget> {
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  List<Feed> _feeds;

  @override
  Widget build(BuildContext context) {
    FeedService _feedService = Provider.of<FeedService>(context);
    AppState appState = Provider.of<AppState>(context);

    return FutureBuilder(
      future: _loadFeeds(_feedService),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: Text(''));

            case ConnectionState.active:
              return Center(child: Text(''),);

            case ConnectionState.done:
              return _buildAll(context, _feeds, appState);

            default:
              return Center(child: Text(''));
          }
      },
    ); 
  }

  Future<void> _loadFeeds(FeedService feedService) async {
    _feeds = await feedService.getFeeds();
  }

  Widget _buildAll(BuildContext context, List<Feed> feeds, AppState appState) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.black, width: 1.0, style: BorderStyle.solid)),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _controller,
        child: ListView.separated(
          itemCount: feeds.length,
          controller: _controller,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int index) {
            return _buildFeedRow(context, feeds[index], appState);
          },
        ),
      ),
    );
  }

  Widget _buildFeedRow(BuildContext context, Feed feed, AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: GestureDetector(
        onTap: () async {
          print("Tapped on feed ${feed.name}");
          _previousScrollPosition = _controller.position.pixels;
          appState.selectFeed(feed.id);
        },
        child: Row(
          children: <Widget>[
            Flexible(child: Text(feed.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}