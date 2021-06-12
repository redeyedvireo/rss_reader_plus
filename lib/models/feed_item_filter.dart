import 'feed_item.dart';

enum FilterField {
  NONE,
  TITLE,
  AUTHOR,
  DESCRIPTION,
  CATEGORIES
}

enum FilterQuery {
  IGNORE,
  CONTAINS,
  DOES_NOT_CONTAIN,
  EQUALS,
  REGULAR_EXPRESSION_MATCH
}

enum FilterAction {
  DO_NOTHING,
  COPY_TO_INTEREST_FEED,
  MARK_AS_READ,
  DELETE
}

class FeedItemFilter {
  int filterId = 0;
  int feedId = 0;                                 // Feed ID of filter( if 0, it is a global filter)
  FilterField fieldId = FilterField.NONE;         // ID of field in DB to be queried
  FilterQuery verb = FilterQuery.CONTAINS;        // Specifies how to query the item
  String queryStr = '';                           // Query string(ie, string to search for , etc.)
  FilterAction action = FilterAction.DO_NOTHING;  // Action ID(ie, what to do with selected feed items)

  final fieldStrings = {
    FilterField.NONE: "<invalid filter>",
    FilterField.TITLE: "title",
    FilterField.AUTHOR: "author",
    FilterField.DESCRIPTION: "description",
    FilterField.CATEGORIES: "categories"
  };

  final filterQueries = {
    FilterQuery.IGNORE: 'ignore',
    FilterQuery.CONTAINS: 'contains',
    FilterQuery.DOES_NOT_CONTAIN: 'does not contain',
    FilterQuery.EQUALS: 'equals',
    FilterQuery.REGULAR_EXPRESSION_MATCH: 'matches with regular expression'
  };

  final filterActions = {
    FilterAction.DO_NOTHING: 'do nothing',
    FilterAction.COPY_TO_INTEREST_FEED: 'mark it as an Item of Interest',
    FilterAction.MARK_AS_READ: 'mark it as read',
    FilterAction.DELETE: 'delete it'
  };

  FeedItemFilter({
    this.filterId,
    this.feedId,
    this.fieldId,
    this.verb,
    this.queryStr,
    this.action,
  });

  String fieldString() {
    return fieldStrings[fieldId];
  }

  String filterQuery() {
    return filterQueries[verb];
  }

  String filterAction() {
    return filterActions[action];
  }

  /// Returns true if the given feedItem would be selected by this filter.
  bool isSelected(FeedItem feedItem) {
    String subject = '';
    bool categoriesIsSubject = false;

    switch (fieldId) {
      case FilterField.NONE:
        return false;

      case FilterField.AUTHOR:
        subject = feedItem.author;
        break;

      case FilterField.TITLE:
        subject = feedItem.title;
        break;

      case FilterField.DESCRIPTION:
        subject = feedItem.description;
        break;

      case FilterField.CATEGORIES:
        categoriesIsSubject = true;
        break;
    }

    switch (verb) {
      case FilterQuery.IGNORE:
        return false;

      case FilterQuery.CONTAINS:
        if (categoriesIsSubject) {
          return feedItem.categories.contains(queryStr);
        } else {
          return subject.contains(queryStr);
        }
        break;

      case FilterQuery.DOES_NOT_CONTAIN:
        if (categoriesIsSubject) {
          return !feedItem.categories.contains(queryStr);
        } else {
          return !subject.contains(queryStr);
        }
        break;

      case FilterQuery.EQUALS:
        if (categoriesIsSubject) {
          return feedItem.categories.join(',') == queryStr;   // TODO: Maybe sort first, and do case-insensitive comparison
        } else {
          return subject == queryStr;   // TODO: Use equalsIgnoreAsciiCase(subject, queryStr);  (Need to install flutter collection package)
        }
        break;

      case FilterQuery.REGULAR_EXPRESSION_MATCH:
        if (categoriesIsSubject) {
          return false;
        } else {
          RegExp exp = RegExp(queryStr);
          return exp.hasMatch(subject);
        }
        break;
    }

    // Should not get this far, but if it does, return false
    print('[FeedItemFilter.isSelected] Query not handled.');
    return false;
  }

  /// Returns a filtered version of the given feed item.  If the filtering indicates
  /// that the feed item should be deleted, an invalid feed item is returned.
  FeedItem filterFeedItem(FeedItem feedItem) {
    FeedItem resultantFeedItem = feedItem;

    if (feedItem.isValid) {
      if (isSelected(feedItem)) {
        switch (action) {
          case FilterAction.DELETE:
            resultantFeedItem = FeedItem();
            break;

          case FilterAction.COPY_TO_INTEREST_FEED:
          case FilterAction.DO_NOTHING:
            break;

          case FilterAction.MARK_AS_READ:
            feedItem.read = true;
            break;
        }
      }
    }

    return resultantFeedItem;
  }

  /// Returns true if this feed item should be copied to the Items of Interest feed.
  bool isItemOfInterest(FeedItem feedItem) {
    return feedItem.isValid && isSelected(feedItem) && action == FilterAction.COPY_TO_INTEREST_FEED;
  }

  /// Returns true if this feed item would be deleted
  bool wouldBeDeleted(FeedItem feedItem) {
    return feedItem.isValid && isSelected(feedItem) && action == FilterAction.DELETE;
  }
}