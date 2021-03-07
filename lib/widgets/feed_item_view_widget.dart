import 'package:flutter/material.dart';

class FeedItemViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black, width: 1.0, style: BorderStyle.solid)),
      child: Center(
        child: Text('Feed Item View Widget'),
      ),
    );
  }
}
