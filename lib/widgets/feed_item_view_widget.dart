import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

class FeedItemViewWidget extends StatefulWidget {
  @override
  _FeedItemViewWidgetState createState() => _FeedItemViewWidgetState();
}

class _FeedItemViewWidgetState extends State<FeedItemViewWidget> {
  FeedItem  feedItem;

  @override
  Widget build(BuildContext context) {
    FeedService _feedService = Provider.of<FeedService>(context);

    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.selectedFeedItem != null) {
          return _buildAll(context, appState.selectedFeedItem);
        } else {
          return Center(child: Text("No news item selected"),);
        }
      }
    );
  }

  Widget _buildAll(BuildContext context, FeedItem feedItem) {
    return Scrollbar(
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Html(
          data: feedItem.encodedContent),
      ),
    );
  }
}
