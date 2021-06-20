
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';
import 'package:rss_reader_plus/widgets/string_list_edit_widget.dart';

class LanguageFiltersPage extends StatefulWidget {
  Logger _logger;
  
  LanguageFiltersPage() {
    _logger = Logger('LanguageFiltersPage');
  }

  @override
  _LanguageFiltersPageState createState() => _LanguageFiltersPageState();
}

class _LanguageFiltersPageState extends State<LanguageFiltersPage> {
  LanguageFilterService _languageFilterService;
  List<String> _filteredWords;
  
  @override
  void initState() {
    _filteredWords = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _languageFilterService = Provider.of<LanguageFilterService>(context, listen: false);

    return FutureBuilder(
      future: _getLanguageFilters(_languageFilterService),
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

  Future<void> _getLanguageFilters(LanguageFilterService languageFilterService) async {
    _filteredWords = await languageFilterService.getLanguageFilters();
  }

  Widget _buildAll(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Filters'),
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
            stringList: _filteredWords,
            textEditHint: 'Enter new filtered word',
            onDeleteFn: onDelete,
            onAddFn: onAdd
          ),
        ),
      ),
    );
  }

  Future<bool> onDelete(String wordToDelete) async {
    print('Deleting filtered word $wordToDelete');
    final success = await _languageFilterService.deleteFilteredWord(wordToDelete);
    if (!success) {
      widget._logger.severe('Deleting filtered word $wordToDelete unsuccessful');
    }

    return success;
  }

  Future<bool> onAdd(String wordToAdd) async {
    final success = await _languageFilterService.addNewFilteredWord(wordToAdd);

    if (!success) {
      widget._logger.severe('Adding filtered word $wordToAdd unsuccessful');
    }

    return success;          
  }
}