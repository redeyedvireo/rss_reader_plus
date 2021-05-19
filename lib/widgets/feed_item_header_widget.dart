import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';

class FeedItemHeaderWidget extends StatefulWidget {
  FeedService feedService;  
  NotificationService notificationService;

  FeedItemHeaderWidget(this.feedService, this.notificationService);

  @override
  _FeedItemHeaderWidgetState createState() => _FeedItemHeaderWidgetState();
}

class _FeedItemHeaderWidgetState extends State<FeedItemHeaderWidget> {
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
    final feedTitle = widget.feedService.selectedFeed.title != null ?
                        widget.feedService.selectedFeed.title :
                        '<No feed title>';
    List<Widget> children = [];

    children.add(widget.feedService.getFeedIconWidget(widget.feedService.selectedFeedId));
    children.add(SizedBox(width: 10.0));

    children.add(Text(feedTitle));

    final feedTitleGroup = Row(
      children: children,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      color: Colors.grey[100],
      child: SizedBox(
        height: 40.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            feedTitleGroup,
            PopupMenuButton<String>(
              onSelected: (String result) async {
                switch (result) {
                  case 'refresh':
                    widget.notificationService.setStatusMessage('Updating ${widget.feedService.selectedFeed.name}...');
                    await widget.feedService.fetchFeed(widget.feedService.selectedFeed.id);
                    break;

                  default:
                    print('Unknown menu item selected: $result');
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh'),),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Feed'),)
            ])
          ],
        ),),
    );
  }
}