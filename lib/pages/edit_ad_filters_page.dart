
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
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
  List<String> _adFilters = [];

  @override
  Widget build(BuildContext context) {
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
    return;
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
          width: 300,
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
    // final success = await _languageFilterService.deleteFilteredWord(wordToDelete);
    // if (!success) {
    //   widget._logger.severe('Deleting filtered word $wordToDelete unsuccessful');
    // }

    // return success;
    return true;
  }

  Future<bool> onAdd(String wordToAdd) async {
    // final success = await _languageFilterService.addNewFilteredWord(wordToAdd);

    // if (!success) {
    //   widget._logger.severe('Adding filtered word $wordToAdd unsuccessful');
    // }

    // return success;          
    return true;
  }
}