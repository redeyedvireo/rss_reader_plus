
import 'package:flutter/material.dart';

enum DialogState { ASK_URL, IDENTIFY_FEED, VERIFY_OK }


class NewFeedDialog extends AlertDialog {
  static Future<String> showNewFeedDialog(BuildContext context) async {
    final dialogContent = DialogContent();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String feedUrl = '';

    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Feed'),
        content: SizedBox(
          width: 400.0,
          child: Form(key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(labelText: 'FeedUrl'),
              onChanged: (String url) {
                feedUrl = url;
              },
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop('');
          }, child: Text('Cancel')),
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop(feedUrl);
          }, child: Text('Ok'))
        ],);
    });
  }

  static List<Widget> _getActions(DialogContent dialogContent, BuildContext context) {
    switch (dialogContent.dialogState) {
      case DialogState.ASK_URL:
        return <Widget>[
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop(false);
          }, child: Text('Cancel')),
          ElevatedButton(onPressed: () {
            // Navigator.of(context).pop(true);
            dialogContent.setDialogState(DialogState.IDENTIFY_FEED);
          }, child: Text('Go'))
        ];

      case DialogState.IDENTIFY_FEED:
        return <Widget>[
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop(false);
          }, child: Text('Stop'))
        ];

      case DialogState.VERIFY_OK:
        return <Widget>[
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop(false);
          }, child: Text('No')),
          ElevatedButton(onPressed: () {
            // TODO: Add feed to database, including feed items from this feed
            Navigator.of(context).pop(true);
          }, child: Text('Yes'))
        ];
    }
  }
}

class DialogContent extends StatefulWidget {
  _DialogContentState currentDialogState;
  
  void setDialogState(DialogState state) => currentDialogState.setDialogState(state);
  get dialogState => currentDialogState.dialogState;

  @override
  _DialogContentState createState() { 
    currentDialogState = _DialogContentState();
    return currentDialogState;
  }
}

class _DialogContentState extends State<DialogContent> {
  DialogState dialogState;
  String feedUrl;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void setDialogState(DialogState state) {
    setState(() {
      dialogState = state;
    });
  }

  @override
  void initState() {
    super.initState();

    dialogState = DialogState.ASK_URL;
  }

  @override
  Widget build(BuildContext context) {
    switch (dialogState) {
      case DialogState.ASK_URL:
        return _askUrl();

      case DialogState.IDENTIFY_FEED:
        return _identifyFeed();

      case DialogState.VERIFY_OK:
        return _verifyFeed();
    }
  }

  Widget _askUrl() {
    return SizedBox(
      width: 400.0,
      child: Form(key: _formKey,
        child: TextFormField(
          decoration: InputDecoration(labelText: 'FeedUrl'),
          onChanged: (String url) {
            feedUrl = url;
            // TODO: Initiate feed fetch
            dialogState = DialogState.IDENTIFY_FEED;
          },
        ),
      ),
    );
  }

  Widget _identifyFeed() {
    // Future builder?
    // Show progress spinner.
    return Text('Fetching feed...');
  }

  Widget _verifyFeed() {
    return Column(children: [
      Text('Feed: <feed name>'),
      Text('Add feed?')
    ],);
  }
}