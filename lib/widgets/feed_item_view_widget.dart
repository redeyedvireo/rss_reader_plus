import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:clipboard/clipboard.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

class FeedItemViewWidget extends StatefulWidget {
  FeedService feedService;
  NotificationService notificationService;

  FeedItemViewWidget(this.feedService, this.notificationService);

  @override
  _FeedItemViewWidgetState createState() => _FeedItemViewWidgetState();
}

class _FeedItemViewWidgetState extends State<FeedItemViewWidget> {
  @override
  void initState() {
    super.initState();

    widget.feedService.feedItemSelected$.listen((feedItemId) {
      setState(() {
      });
    });

    widget.feedService.feedSelected$.listen((feed) {
      if (mounted) {
        setState(() { });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FeedItem feedItem = widget.feedService.selectedFeedItem;

    if (feedItem.isValid) {
      return _buildAll(context, feedItem, widget.notificationService);
    } else {
      return Center(child: Text(""),);
    }

  }

  Widget _buildAll(BuildContext context, FeedItem feedItem, NotificationService notificationService) {
    String content;

    content = feedItem.encodedContent.length > 0 ? feedItem.encodedContent : feedItem.description;

    return Column(
      children: [
        Text(feedItem.title,
          style: TextStyle(fontSize: 24)),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 0),
            child: SingleChildScrollView(
              child: Html(
                onLinkTap: (url) async {
                  print('Link tapped: $url');
                  notificationService.setStatusMessage(url, timeout: 5);
                  await canLaunch(url) ? await launch(url) : notificationService.setStatusMessage('Cannot launch $url', timeout: 5);
                },
                onImageTap: (url) {
                  print('Image tapped: $url');
                },
                onImageError: (Object exception, StackTrace stackTrace) {
                  print('Image error');
                },
                data: content),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
          child: ButtonBar(
            buttonHeight: 16.0,
            buttonPadding: EdgeInsets.symmetric(vertical: 1.0),
            children: [
              TextButton(
                child: Text('Copy feed text'),
                onPressed: () async {
                  print('Copy feed pressed');
                  await FlutterClipboard.copy(content);
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
