import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/models/app_state.dart';

class StatusBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context);
    return SizedBox(
      height: 20.0,
      child: Container(
        color: Colors.grey[300],
        child: Text(appState.statusMessage, textAlign: TextAlign.left,)
    ));
  }
}