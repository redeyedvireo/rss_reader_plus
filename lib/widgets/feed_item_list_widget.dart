import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item.dart';
import 'package:rss_reader_plus/services/feed_service.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';
import 'package:rss_reader_plus/widgets/feed_item_header_widget.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class FeedItemListWidget extends StatefulWidget {
  FeedService feedService;

  FeedItemListWidget(this.feedService);

  @override
  _FeedItemListWidgetState createState() => _FeedItemListWidgetState();
}

class _FeedItemListWidgetState extends State<FeedItemListWidget> {
  Logger _logger;
  LanguageFilterService _languageFilterService;
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  List<FeedItem> _feedItems;
  final _columnTitles = [
    'Title',
    'Date',
    'Author',
    'Categories'
  ];

  @override
  void initState() {
    super.initState();
    _feedItems = [];
    _logger = Logger('FeedItemListWidget');

    widget.feedService.feedSelected$.listen((feedId) {
      if (mounted) {
        setState(() { });
      }
    });

    widget.feedService.feedUpdated$.listen((feedId) {
      // If the feed that was updated is the one being displayed, then refresh contents
      if (feedId == widget.feedService.selectedFeedId) {
        setState(() {
          _feedItems = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _languageFilterService = Provider.of<LanguageFilterService>(context, listen: false);
    
    return FutureBuilder(
      future: _getFeedItems(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              return _buildAll(context, widget.feedService, _feedItems);

            default:
              return Center(child: Text(''));
          }
      },
    );
  }

  Future<void> _getFeedItems() async {
    _feedItems = await widget.feedService.getFeedItems();
  }

  // TODO: The list view could probably be refactored into a "SelectableList" widget.

  Widget _buildAll(BuildContext context, FeedService feedService, List<FeedItem> feedItems) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    if (feedItems.length == 0) {
      return Center(child: Text('No feed items'));
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 0),
          child: StickyHeadersTable(
            columnsLength: 4,
            rowsLength: feedItems.length,
            cellAlignments: CellAlignments.uniform(Alignment.centerLeft),
            cellDimensions: CellDimensions.variableColumnWidth(
              columnWidths: [450.0, 150.0, 200.0, 300.0],
              contentCellHeight: 25.0,
              stickyLegendWidth: null,
              stickyLegendHeight: null),
            columnsTitleBuilder: _tableTitleBuilder,
            rowsTitleBuilder: (i) => null,
            contentCellBuilder: _tableContentBuilder,
            onContentCellPressed: _onTableCellPressed,
          ),
          // child: ListView.builder(
          //   itemCount: feedItems.length,
          //   controller: _controller,
          //   itemBuilder: (BuildContext context, int index) {
          //     return _buildFeedItemRow(context, index, feedItems[index], feedService);
          //   },
          // ),
        )
      );
    }
  }

  Widget _tableTitleBuilder(int pos) => Text(_columnTitles[pos]);

  Widget _tableContentBuilder(int col, int row) {
    final feedItem = _feedItems[row];

        // Perform language filtering on the title
    final filteredTitle = _languageFilterService.performLanguageFilteringOnString(feedItem.title);

    switch (col) {
      case 0:
        return _rowText(filteredTitle, feedItem, widget.feedService);
        // return _testRowText(filteredTitle, feedItem, widget.feedService);
      
      case 1:
        return _rowText(DateFormat('M/d/y h:mm a').format(feedItem.publicationDatetime), feedItem, widget.feedService);

      case 2:
        return _rowText(feedItem.author, feedItem, widget.feedService);

      case 3:
        return _rowText(feedItem.categories.join(' '), feedItem, widget.feedService);

      default:
        _logger.severe('Invalid table column: $col');
        return Text('');
    }
  }

  Future<void> _onTableCellPressed(int col, int row) async {
    final feedItem = _feedItems[row];

    print("Tapped on feed item ${feedItem.guid}");
    widget.feedService.selectFeedItem(feedItem.guid);
    await widget.feedService.setFeedItemReadFlag(feedItem.guid, feedItem.parentFeedId, true);
    setState(() {
      feedItem.read = true;
    });
  }

  Widget _buildFeedItemRow(BuildContext context, int index, FeedItem feedItem, FeedService feedService) {
    // Perform language filtering on the title
    final filteredTitle = _languageFilterService.performLanguageFilteringOnString(feedItem.title);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      color: _backgroundColor(feedItem, feedService),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            print("Tapped on feed item ${feedItem.guid}");
            widget.feedService.selectFeedItem(feedItem.guid);
            await widget.feedService.setFeedItemReadFlag(feedItem.guid, feedItem.parentFeedId, true);
            _previousScrollPosition = _controller.position.pixels;
            setState(() {
              _feedItems[index].read = true;
            });
          },
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: _rowText(filteredTitle, feedItem, feedService),
              ),
              Expanded(
                flex: 1,
                child: _rowText(DateFormat('M/d/y h:mm a').format(feedItem.publicationDatetime), feedItem, feedService),
              ),
              Expanded(
                flex: 1,
                child: _rowText(feedItem.author, feedItem, feedService),
              ),
              Expanded(
                flex: 1,
                child: _rowText(feedItem.categories.join(' '), feedItem, feedService),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _isSelected(FeedItem feedItem, FeedService feedService) {
    return feedService.selectedFeedItemId == feedItem.guid;
  }

    Color _backgroundColor(FeedItem feedItem, FeedService feedService) {
    // TODO: Use theme colors here
    return _isSelected(feedItem, feedService) ? Colors.blue : Colors.white;
  }

  Color _textColor(FeedItem feedItem, FeedService feedService) {
    // TODO: Use theme colors here
    return _isSelected(feedItem, feedService) ? Colors.white : Colors.black;
  }

  Widget _rowText(String text, FeedItem feedItem, FeedService feedService) {
    return Container(
      color: _backgroundColor(feedItem, feedService),
      alignment: Alignment.centerLeft,
      constraints: BoxConstraints.expand(),
      child: Text(text, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: _textColor(feedItem, feedService),
                         fontWeight: feedItem.read ? FontWeight.normal : FontWeight.bold),
      ),
    );
  }

  Widget _testRowText(String text, FeedItem feedItem, FeedService feedService) {
    return Container(
      alignment: Alignment.centerLeft,
      constraints: BoxConstraints.expand(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.amber,
    );
  }
}
