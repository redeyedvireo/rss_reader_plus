
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/feed_item_filter.dart';
import 'package:rss_reader_plus/services/filter_service.dart';

class GlobalFiltersPage extends StatefulWidget {
  @override
  _GlobalFiltersPageState createState() => _GlobalFiltersPageState();
}

class _GlobalFiltersPageState extends State<GlobalFiltersPage> {
  FilterService _filterService;
  List<FeedItemFilter> _feedItemFilters;
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page

@override
  void initState() {
    super.initState();
    _feedItemFilters = [];
  }

  @override
  Widget build(BuildContext context) {
    _filterService = Provider.of<FilterService>(context);

    return FutureBuilder(
      future: _getFeedItemFilters(_filterService),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
          case ConnectionState.done:
            return _buildAll(context);

          default:
            return Center(child: Text(''));
        }
      });
  }

  Future<void> _getFeedItemFilters(FilterService filterService) async {
    _feedItemFilters = await filterService.getFeedItemFilters();
  }

  Widget _buildAll(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Global Filters'),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Container(
        child: _buildFilterList(context),
      ),
    );
  }

  Widget _buildFilterList(BuildContext context) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    return SizedBox(
      width: 600.0,
      child: ListView.builder(
        itemCount: _feedItemFilters.length,
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          return _buildFilterRow(context, index);
      }),
    );
  }

  Widget _buildFilterRow(BuildContext context, int index) {
    FeedItemFilter feedItemFilter = _feedItemFilters[index];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(_constructFilterString(feedItemFilter))),
          IconButton(
            onPressed: () {
              print('Editing filter ID ${feedItemFilter.filterId}');
            },
            icon: Icon(Icons.edit)),
          IconButton(
            onPressed: () {
              print('Deleting filter ID ${feedItemFilter.filterId}');
            },
            icon: Icon(Icons.delete)
          )
        ],
      ),
    );
  }

  String _constructFilterString(FeedItemFilter feedItemFilter) {
    return 'When the ${feedItemFilter.fieldString()} ${feedItemFilter.filterQuery()} ${feedItemFilter.queryStr}, ${feedItemFilter.filterAction()}';
  }
}