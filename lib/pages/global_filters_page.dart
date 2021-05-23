
import 'package:flutter/material.dart';

class GlobalFiltersPage extends StatefulWidget {
  @override
  _GlobalFiltersPageState createState() => _GlobalFiltersPageState();
}

class _GlobalFiltersPageState extends State<GlobalFiltersPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Text('Global Filters Page'),
        TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text('Back'))
      ]),
    );
  }
}