
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/services/initialization_service.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';
import 'package:rss_reader_plus/util/file_reader.dart';
import 'package:rss_reader_plus/widgets/simple_table.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;


class AppInfoPage extends StatefulWidget {
  const AppInfoPage();

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  String _prefsFilePath = '';
  String _databaseFilePath = '';
  String _logFilePath = '';
  String _aboutString = '';

  @override
  Widget build(BuildContext context) {
    final _db = Provider.of<FeedDatabase>(context, listen: false);
    PrefsService _prefsService = Provider.of<PrefsService>(context, listen: false);
    InitializationService _initializationService = Provider.of<InitializationService>(context, listen: false);
    
    return FutureBuilder(
      future: _mainInit(_prefsService, _initializationService),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: Text(''));

          case ConnectionState.active:
            return Center(child: Text(''),);

          case ConnectionState.done:
            return _buildAll(context);

          default:
            return Center(child: Text(''));
        }
      }
    );
  }

  Future<void> _mainInit(PrefsService prefsService, InitializationService initializationService) async {
    _prefsFilePath = await prefsService.getPrefFilePath();
    _databaseFilePath = FeedDatabase.databasePath;
    _logFilePath = initializationService.logFilePath;
    _aboutString = await FileReader.readAboutFile();
  }

  Widget _buildAll(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Info'),
      ),
      body: _buildContent(context)
    );
  }

  Widget _buildContent(BuildContext context) {
    dom.Document document = htmlparser.parse(_aboutString);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: SizedBox(
          width: 800,
          child: Column(
            children: [
              Html.fromDom(
                onImageError: (Object exception, StackTrace stackTrace) {
                  print('Image error');
                },
                document: document),
              SizedBox(height: 70.0,),
              SimpleTable(
                verticalPadding: 3.0,
                boldLeftColumn: true,
                columnWidths: <int, TableColumnWidth> {
                  0: FixedColumnWidth(150.0),
                  1: FlexColumnWidth()
                },
                rows: [
                  SimpleTableRow('Database', _databaseFilePath, rightAlign: TextAlign.left),
                  SimpleTableRow('Preferences', _prefsFilePath, rightAlign: TextAlign.left),
                  SimpleTableRow('Logs', _logFilePath, rightAlign: TextAlign.left)
                ],
              )
            ],)
          ,),
      ),
    );
  }
}