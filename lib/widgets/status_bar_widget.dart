import 'package:flutter/material.dart';
import 'package:rss_reader_plus/services/notification_service.dart';

class StatusBarWidget extends StatefulWidget {
  NotificationService notificationService;

  StatusBarWidget(this.notificationService);

  @override
  _StatusBarWidgetState createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> {
  @override
  void initState() {
    super.initState();
    
    widget.notificationService.statusBarNotification$.listen((value) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.0,
      child: Container(
        color: Colors.grey[300],
        child: Text(widget.notificationService.statusMessage, textAlign: TextAlign.left,)
    ));
  }
}