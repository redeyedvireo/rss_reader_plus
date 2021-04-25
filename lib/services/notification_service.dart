

import 'dart:async';

import 'package:rxdart/subjects.dart';

class NotificationService {
  String _statusMessage = '';
  Timer messageTimer;

  final BehaviorSubject statusBarNotification$ = BehaviorSubject<String>();

  NotificationService();

  String get statusMessage => _statusMessage;

  /// Sets a message to appear in the status bar.
  /// @param message Message to appear
  /// @param timeout Number of seconds until the message disappears (set to 0 for no timeout)
  void setStatusMessage(String message, {int timeout = 10}) {
    _statusMessage = message;
    statusBarNotification$.add(message);

    if (timeout > 0) {
      messageTimer = Timer(Duration(seconds: timeout), () {
        setStatusMessage('');
        messageTimer.cancel();
      });
    }

  }
}