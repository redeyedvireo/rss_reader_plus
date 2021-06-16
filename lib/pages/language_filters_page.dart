
import 'package:flutter/material.dart';

class LanguageFiltersPage extends StatefulWidget {
  @override
  _LanguageFiltersPageState createState() => _LanguageFiltersPageState();
}

class _LanguageFiltersPageState extends State<LanguageFiltersPage> {
  @override
  Widget build(BuildContext context) {
    return _buildAll(context);
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
        child: Text('Language filter'),
      ),
    );
  }
}