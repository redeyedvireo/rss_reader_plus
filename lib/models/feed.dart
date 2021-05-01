import 'dart:typed_data';

class Feed {
  int id;
  int parentId;     // TODO: Not sure what this is used for.  Delete?

  String name;
  String url;

  // Tracking info
  DateTime dateAdded;
  DateTime lastUpdated;
  DateTime lastPurged;

  // Data from feed XML
  String title;           // Actual title, given by the feed data
  String language;        // TODO: Is this needed?
  String description;
  String webPageLink;     // URL to the host's web page for this feed

  // TODO: Figure out what data types these need to be.
  Uint8List favicon;  // Icon for the feed's main web site (for display in the feed tree)
  // image    // Image from the feed itself.  This is generally not an icon

  Feed({this.id,
        this.parentId,
        this.name,
        this.url,
        this.dateAdded,
        this.lastUpdated,
        this.lastPurged,
        this.title,
        this.language,
        this.description,
        this.webPageLink,
        this.favicon
      });
}
