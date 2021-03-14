
String feedIdToString(int feedId) {
  String feedIdStr = feedId.toString();
  final zerosNeeded = 6 - feedIdStr.length;
  return 'FeedItems${"0" * zerosNeeded}$feedIdStr';
}