class FeedItem {
  String title;
  String author;
  String link;
  String description;
  String encodedContent;          // <content: encoded> tag sometimes contains the article
  List<String> categories;
  DateTime publicationDatetime;   // datetime (stored in database as a Julian Day, (eg, a Unix timestamp)
  String thumbnailLink;           // TODO: Remove this field from the database
  int thumbnailWidth;             // TODO: Remove this field from the database
  int thumbnailHeight;            // TODO: Remove this field from the database
  String guid;                    // Used as feed item ID
  String feedburnerOrigLink;      // TODO: Remove this field from the database

  String enclosureLink;         // Link to media enclosure
  int enclosureLength;          // Length of enclosure item
  String enclosureType;         // MIME type of enclosure (for example: 'media/mpeg')

  int parentFeedId;             // Feed ID that owns this feed item
   
  bool read;                    // true if the feed item has been read

  FeedItem({
    this.title,
    this.author,
    this.link,
    this.description,
    this.encodedContent,
    this.categories,
    this.publicationDatetime,
    this.thumbnailLink,
    this.thumbnailWidth,
    this.thumbnailHeight,
    this.guid,
    this.feedburnerOrigLink,
    this.enclosureLink,
    this.enclosureLength,
    this.enclosureType,
    this.parentFeedId,
    this.read
  });

  get hasEnclosure => enclosureLink.length > 0;

  get isValid => guid != null && guid.length > 0;
}
