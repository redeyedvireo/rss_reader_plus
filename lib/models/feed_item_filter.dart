
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

  FeedItemFilter({
    this.filterId,
    this.feedId,
    this.fieldId,
    this.verb,
    this.queryStr,
    this.action,
  });

  String fieldString() {
    switch (fieldId) {
      case FilterField.NONE:
        return "<invalid filter>";

      case FilterField.TITLE:
        return "title";

      case FilterField.AUTHOR:
        return "author";

      case FilterField.DESCRIPTION:
        return "description";

      case FilterField.CATEGORIES:
        return "categories";
    }
  }

  String filterQuery() {
    switch (verb) {
      case FilterQuery.IGNORE:
        return 'ignore';

      case FilterQuery.CONTAINS:
        return 'contains';

      case FilterQuery.DOES_NOT_CONTAIN:
        return 'does not contain';

      case FilterQuery.EQUALS:
        return 'equals';

      case FilterQuery.REGULAR_EXPRESSION_MATCH:
        return 'matches with regular expression';
    }
  }

  String filterAction() {
    switch (action) {
      case FilterAction.DO_NOTHING:
        return 'do nothing';

      case FilterAction.COPY_TO_INTEREST_FEED:
        return 'mark it as an Item of Interest';

      case FilterAction.MARK_AS_READ:
        return 'mark it as read';

      case FilterAction.DELETE:
        return 'delete it';
    }
  }
}