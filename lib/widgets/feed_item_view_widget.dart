import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:clipboard/clipboard.dart';
import 'package:rss_reader_plus/services/ad_filter_service.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';
import 'package:rss_reader_plus/services/notification_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_view_header_widget.dart';
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
  LanguageFilterService _languageFilterService;
  AdFilterService _adFilterService;
  String _feedContent;

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
    _languageFilterService = Provider.of<LanguageFilterService>(context, listen: false);
    _adFilterService = Provider.of<AdFilterService>(context, listen: false);
    FeedItem feedItem = widget.feedService.selectedFeedItem;

    if (feedItem.isValid) {
      _feedContent = feedItem.encodedContent.length > 0 ? feedItem.encodedContent : feedItem.description;

      return _buildAll(context, feedItem, widget.notificationService);
    } else {
      return Center(child: Text(""),);
    }

  }

  Widget _buildAll(BuildContext context, FeedItem feedItem, NotificationService notificationService) {
    dom.Document document = htmlparser.parse(_feedContent);

    _languageFilterService.filterContent(document);
    _adFilterService.filterContent(document);

    final feedItemTitle = _languageFilterService.performLanguageFilteringOnString(feedItem.title);

    return Column(
      children: [
        FeedItemViewHeaderWidget(feedItemTitle, copyFeedText),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 0),
            child: SingleChildScrollView(
              child: Html.fromDom(
                onLinkTap: (String url, RenderContext context, Map<String, String> attributes, dom.Element element) async {
                  print('Link tapped: $url');
                  notificationService.setStatusMessage(url, timeout: 5);
                  await canLaunch(url) ? await launch(url) : notificationService.setStatusMessage('Cannot launch $url', timeout: 5);
                },
                onImageTap: (String url, RenderContext context, Map<String, String> attributes, dom.Element element) {
                  print('Image tapped: $url');
                },
                onImageError: (Object exception, StackTrace stackTrace) {
                  print('Image error');
                },
                document: document),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> copyFeedText() async {
    await FlutterClipboard.copy(_feedContent);
  }
}
