
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/ad_filter_service.dart';
import 'package:rss_reader_plus/widgets/string_list_edit_widget.dart';

class AdFiltersPage extends StatefulWidget {
  Logger _logger;
  
  AdFiltersPage() {
    _logger = Logger('AdFiltersPage');
  }

  @override
  _AdFiltersPageState createState() => _AdFiltersPageState();
}

class _AdFiltersPageState extends State<AdFiltersPage> {
  AdFilterService _adFilterService;
  List<String> _adFilters = [];

  @override
  Widget build(BuildContext context) {
    _adFilterService = Provider.of<AdFilterService>(context, listen: false);
    
    return FutureBuilder(
      future: _getAdFilters(),
      builder:(BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(child: Text(''),);

          case ConnectionState.done:
            return _buildAll(context);

          default:
            return Center(child: Text(''));
        }
      });
  }

  Future<void> _getAdFilters() async {
    _adFilters = await _adFilterService.getAdFilters();
  }

  Widget _buildAll(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Filters'),
      ),
      body: _buildContent(context),
    );    
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 40.0, bottom: 60.0),
        child: SizedBox(
          width: 900,
          child: StringListEditWidget(
            stringList: _adFilters,
            textEditHint: 'Enter new ad URL',
            onDeleteFn: onDelete,
            onAddFn: onAdd
          ),
        ),
      ),
    );    
  }

  Future<bool> onDelete(String wordToDelete) async {
    final success = await _adFilterService.deleteAdFilter(wordToDelete);
    if (!success) {
      widget._logger.severe('Deleting ad filter $wordToDelete unsuccessful');
    }

    return success;
  }

  Future<bool> onAdd(String wordToAdd) async {
    final success = await _adFilterService.addNewAdFilter(wordToAdd);

    if (!success) {
      widget._logger.severe('Adding ad filter $wordToAdd unsuccessful');
    }

    return success;          
  }
}