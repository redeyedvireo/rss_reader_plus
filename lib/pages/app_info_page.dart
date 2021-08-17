
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/feed_database.dart';
import 'package:rss_reader_plus/widgets/simple_table.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage();

  @override
  Widget build(BuildContext context) {
    final _db = Provider.of<FeedDatabase>(context);
    
    return Scaffold(
      appBar: AppBar(
          title: Text('App Info'),
        ),
        body: _buildContent(context, _db)
    );
  }

  Widget _buildContent(BuildContext context, FeedDatabase db) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: SizedBox(
          width: 500,
          child: Column(
            children: [
              Text('App Info'),
              SizedBox(height: 20.0,),
              SimpleTable(
                verticalPadding: 6.0,
                columnWidths: <int, TableColumnWidth> {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth()
                },
                rows: [
                  SimpleTableRow('Database', '${FeedDatabase.databasePath}'),
                  SimpleTableRow('Preferences', 'Prefs file path'),
                  SimpleTableRow('Logs', 'Log file path')
                ],
              )
            ],)
          ,),
      ),
    );
  }
}