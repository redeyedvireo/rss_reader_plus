
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/services/purge_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_header_widget.dart';
import 'package:rss_reader_plus/widgets/feed_item_list_widget.dart';

class FeedItemListPage extends StatefulWidget {
  const FeedItemListPage();

  @override
  _FeedItemListPageState createState() => _FeedItemListPageState();
}

class _FeedItemListPageState extends State<FeedItemListPage> {
  @override
  Widget build(BuildContext context) {
    FeedService _feedService = Provider.of<FeedService>(context);
    NotificationService _notificationService = Provider.of<NotificationService>(context);
    PurgeService _purgeService = Provider.of<PurgeService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('RssReader Plus'),
      ),
      body: _buildContent(context, _feedService, _notificationService, _purgeService),
    );
  }

  Widget _buildContent(BuildContext context,
                    FeedService feedService,
                    NotificationService notificationService,
                    PurgeService purgeService) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeedItemHeaderWidget(feedService, notificationService, purgeService),
        Expanded(child: FeedItemListWidget(feedService, onFeedItemSelected: (guid) async {
          await Navigator.pushNamed(context, 'feedview');
        })),
      ],
    );
  }
}