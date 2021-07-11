import 'package:flutter/material.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';
import 'package:intl/intl.dart';
import 'package:rss_reader_plus/util/utils.dart';

class FeedPurgeConfig {
  DateTime  targetDate;         // Purge feed items on and before this date
  bool      deleteUnreadItems;
  bool      cancel;

  FeedPurgeConfig(this.targetDate, this.deleteUnreadItems) {
    cancel = false;
  }

  bool get wasCanceled => cancel;
}

class PurgeFeedDialog extends AlertDialog {
  static Future<FeedPurgeConfig> showFeedPurgeDialog(BuildContext context) async {
    bool _deleteUnreadItems = false;
    int _daysBefore = 10;

    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Purge Feed'),
        content: SizedBox(
          width: 400.0,
          height: 100.0,
          child: DialogContent((value) {
            _daysBefore = value;
          },
          (value) {
            _deleteUnreadItems = value;
          }, _daysBefore, _deleteUnreadItems)),
          actions: <Widget>[
            ElevatedButton(onPressed: () {
              final feedPurgeConfig = FeedPurgeConfig(daysBeforeNow(_daysBefore), _deleteUnreadItems);
              feedPurgeConfig.cancel = true;
              
              Navigator.of(context).pop(feedPurgeConfig);
            }, child: Text('Cancel')),
            ElevatedButton(onPressed: () {
              final feedPurgeConfig = FeedPurgeConfig(daysBeforeNow(_daysBefore), _deleteUnreadItems);

              Navigator.of(context).pop(feedPurgeConfig);
            }, child: Text('Ok'))
        ],
      );
    });
  }
}

class DialogContent extends StatefulWidget {
  Function daysChanged;
  Function deleteUnreadChanged;
  int initialDaysBefore;
  bool initialDeleteUnreadItems;

  DialogContent(this.daysChanged, this.deleteUnreadChanged,
                this.initialDaysBefore, this.initialDeleteUnreadItems);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  bool _deleteUnreadItems;
  int _daysBefore;

  @override
  void initState() {
    _daysBefore = widget.initialDaysBefore;
    _deleteUnreadItems = widget.initialDeleteUnreadItems;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Delete older than '),
            TouchSpin(
              min: 1,
              max: 10000,
              value: 10,
              displayFormat: NumberFormat('#####'),
              onChanged: (value) {
                widget.daysChanged(value.toInt());

                setState(() {
                  _daysBefore = value.toInt();
                });
              }),
            Text(' days')
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: _deleteUnreadItems,
              onChanged: (bool value) {
                widget.deleteUnreadChanged(value);

                setState(() {
                  _deleteUnreadItems = value;
                });
              },
            ),
            Text('Include unread items')
          ],
        )
      ],
    );
  }
}