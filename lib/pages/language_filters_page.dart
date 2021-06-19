
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/language_filter_service.dart';

class LanguageFiltersPage extends StatefulWidget {
  Logger _logger;
  
  LanguageFiltersPage() {
    _logger = Logger('LanguageFiltersPage');
  }

  @override
  _LanguageFiltersPageState createState() => _LanguageFiltersPageState();
}

class _LanguageFiltersPageState extends State<LanguageFiltersPage> {
  TextEditingController _queryStringController = TextEditingController();
  LanguageFilterService _languageFilterService;
  ScrollController _controller;
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  List<String> _filteredWords;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _newFilteredWord;
  
  @override
  void initState() {
    _filteredWords = [];
    _newFilteredWord = '';
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
        child: _buildFilterList(context),
      ),
    );
  }

  Widget _buildFilterList(BuildContext context) {
    _controller = ScrollController(initialScrollOffset: _previousScrollPosition);

    return SizedBox(
      width: 300.0,
      child: Column(
        children: [
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1
                  )
                ),
                child: ListView.builder(
                itemCount: _filteredWords.length,
                controller: _controller,
                itemBuilder: (BuildContext context, int index) {
                  return _buildFilterRow(context, index);
            }),
              ),
          ),
          SizedBox(height: 30.0),
          _buildNewFilteredWordWidget(context)
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, int index) {
    String filteredWord = _filteredWords[index];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(filteredWord)),
          IconButton(
            onPressed: () async {
              print('Deleting filtered word $filteredWord');
              final success = await _languageFilterService.deleteFilteredWord(filteredWord);
              if (success) {
                setState(() {
                  _filteredWords.removeAt(index);
                });
              } else {
                widget._logger.severe('Deleting filtered word $filteredWord unsuccessful');
              }
            },
            icon: Icon(Icons.delete)
          )
        ],
      ),
    );
  }

  Widget _buildNewFilteredWordWidget(BuildContext context) {
    return Form(
        key: _formKey,
        child: Row(children: [
        Expanded(
          child: TextFormField(
            controller: _queryStringController,
            decoration: InputDecoration(labelText: 'Word to be filtered'),
            onChanged: (String value) async {
              _newFilteredWord = value;
            },
          ),
        ),
        TextButton(onPressed: () async {
          final filteredWord = _newFilteredWord;

          try {
            final success = await _languageFilterService.addNewFilteredWord(filteredWord);

            if (!success) {
              widget._logger.severe('Adding filtered word $filteredWord unsuccessful');
            } else {
              setState(() {
                _filteredWords.add(_newFilteredWord);
              });

              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
            }

            _queryStringController.text = '';
          } catch (e) {
            widget._logger.severe('Error adding filtered word $filteredWord: ${e.message}');
          }
        }, child: Text('Add'))
      ],),
    );
  }

  void _scrollToEnd() {
    _controller.animateTo(_controller.position.maxScrollExtent,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
  }
}