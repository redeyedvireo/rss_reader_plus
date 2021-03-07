import 'package:flutter/material.dart';

class FeedListWidget extends StatelessWidget {
  FeedListWidget({this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black, width: 1.0, style: BorderStyle.solid)),
      child: Center(
        child: Text('Feed List!'),
      ),
    );
  }
}
