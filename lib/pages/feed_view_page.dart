
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_view_widget.dart';

class FeedViewPage extends StatefulWidget {
  const FeedViewPage();

  @override
  _FeedViewPageState createState() => _FeedViewPageState();
}

class _FeedViewPageState extends State<FeedViewPage> {
  @override
  Widget build(BuildContext context) {
    FeedService _feedService = Provider.of<FeedService>(context);
    NotificationService _notificationService = Provider.of<NotificationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('RssReader Plus'),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return FeedItemViewWidget(Provider.of<FeedService>(context, listen: false),
                              Provider.of<NotificationService>(context, listen: false));
  }
}