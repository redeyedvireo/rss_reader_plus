import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:clipboard/clipboard.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/feed_service.dart';

class FeedItemViewWidget extends StatefulWidget {
  BehaviorSubject feedItemSelected$;

  FeedItemViewWidget(this.feedItemSelected$);

  @override
  _FeedItemViewWidgetState createState() => _FeedItemViewWidgetState();
}

class _FeedItemViewWidgetState extends State<FeedItemViewWidget> {
  FeedItem  _feedItem;

  @override
  void initState() {
    super.initState();

    widget.feedItemSelected$.listen((feedItem) {
      setState(() {
        _feedItem = feedItem;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FeedService _feedService = Provider.of<FeedService>(context);
    AppState _appState = Provider.of<AppState>(context);

    if (_feedItem != null) {
      return _buildAll(context, _feedItem, _appState);
    } else {
      return Center(child: Text(""),);
    }

  }

  Widget _buildAll(BuildContext context, FeedItem feedItem, AppState appState) {
    String content;

    content = feedItem.encodedContent.length > 0 ? feedItem.encodedContent : feedItem.description;

    return Column(
      children: [
        Text(feedItem.title,
          style: TextStyle(fontSize: 24)),
        Flexible(
          child: Scrollbar(
            isAlwaysShown: true,
            thickness: 12.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 15.0),
              child: SingleChildScrollView(
                child: Html(
                  onLinkTap: (url) async {
                    print('Link tapped: $url');
                    appState.setStatusMessage(url, timeout: 5);
                    await canLaunch(url) ? await launch(url) : appState.setStatusMessage('Cannot launch $url', timeout: 5);
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
