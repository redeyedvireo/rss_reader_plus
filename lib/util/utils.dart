
import 'package:jiffy/jiffy.dart';

String feedIdToString(int feedId) {
  String feedIdStr = feedId.toString();
  final zerosNeeded = 6 - feedIdStr.length;
  return 'FeedItems${"0" * zerosNeeded}$feedIdStr';
}

/// Attempts to parse a date/time.  Tries several formats before giving up.
DateTime parseDate(String inDateTime) {
  List<String> possibleDateTimeFormats = [
    'EEE, d MMM yyyy hh:mm:s Z',
    'yyyy-MM-ddThh:mm:s Z'
  ];

  DateTime result = DateTime.now();

  // print('[parseDate] Attempting to parse: $inDateTime');

  // First, try to parse without a format string
  try {
    final jiffyDate = Jiffy(inDateTime);
    print('Successfully parsed $inDateTime: ${jiffyDate.dateTime}');
    result = jiffyDate.dateTime;
  } catch (e) {
    // print('[parseDate] First attempt - parsing $inDateTime: ${e.toString()}');
  }

  possibleDateTimeFormats.forEach((possibleDateTimeFormat) {
    try {
      final jiffyDate = Jiffy(inDateTime, possibleDateTimeFormat);
      print('Successfully parsed $inDateTime: ${jiffyDate.dateTime}');
      result = jiffyDate.dateTime;
    } catch (e) {
      // print('[parseDate] With format - parsing $inDateTime: ${e.toString()}');
    }
  });

  return result;
}

/// Retrieves an item which might be null.  If the item is null,
/// the default value is returned instead.
/// This is generally used to retrieve member items from an object that originates
/// from an untrusted source, such as the internet.
T getNullableItem<T>(dynamic item, T defaultValue) {
  return item != null ? item : defaultValue;
}

/// Returns the first non-null item in a list.  If all items are null,
/// null will be returned.  It is up to the caller to ensure that one
/// item (usually the last item) is non-null.
dynamic getFirstNonNull(List<dynamic> items) {
  dynamic result;

  for (var element in items) {
    if (element != null) {
      result = element;
      break;
    }    
  }

  return result;
}