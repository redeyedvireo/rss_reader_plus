import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:rss_reader_plus/dialogs/ok_cancel_dialog.dart';
import 'package:rss_reader_plus/dialogs/feed_purge_dialog.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/services/purge_service.dart';

enum FeedMenuAction { Refresh, Purge, Delete }

class FeedItemHeaderWidget extends StatefulWidget {
  FeedService feedService;  
  NotificationService notificationService;
  PurgeService purgeService;

  FeedItemHeaderWidget(this.feedService, this.notificationService, this.purgeService);

  @override
  _FeedItemHeaderWidgetState createState() => _FeedItemHeaderWidgetState();
}

class _FeedItemHeaderWidgetState extends State<FeedItemHeaderWidget> {
  @override
  void initState() {
    super.initState();

    widget.feedService.feedSelected$.listen((feedId) {
      if (mounted) {
        setState(() { });
      }
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
            PopupMenuButton<FeedMenuAction>(
              onSelected: (FeedMenuAction result) async {
                switch (result) {
                  case FeedMenuAction.Refresh:
                    widget.notificationService.setStatusMessage('Updating ${widget.feedService.selectedFeed.name}...');
                    await widget.feedService.fetchFeed(widget.feedService.selectedFeed.id);
                    break;

                  case FeedMenuAction.Purge:
                    final feedPurgeConfig = await PurgeFeedDialog.showFeedPurgeDialog(context);
                    if (!feedPurgeConfig.wasCanceled) {
                      print('Days: ${feedPurgeConfig.targetDate}, include unread: ${feedPurgeConfig.deleteUnreadItems}');
                      await widget.feedService.purgeFeed(widget.feedService.selectedFeedId,
                                                         feedPurgeConfig.targetDate,
                                                         feedPurgeConfig.deleteUnreadItems);
                    }
                    break;

                  case FeedMenuAction.Delete:
                    final okToDelete = await showOkCancelDialog(context,
                    'Delete Feed?',
                    'Delete ${widget.feedService.selectedFeed.name}',
                    okButtonText: 'Yes',
                    cancelButtonText: 'No');

                    if (okToDelete) {
                      await widget.feedService.deleteFeed(widget.feedService.selectedFeed.id);
                    }
                    break;

                  default:
                    print('Unknown menu item selected: $result');
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<FeedMenuAction>>[
              PopupMenuItem(
                value: FeedMenuAction.Refresh,
                child: Text('Refresh'),),
              PopupMenuItem(
                value: FeedMenuAction.Purge,
                child: Text('Purge')),
              PopupMenuDivider(),
              PopupMenuItem(
                value: FeedMenuAction.Delete,
                child: Text('Delete Feed',
                  style: TextStyle(color: Colors.red),
                ),)
            ])
          ],
        ),),
    );
  }
}