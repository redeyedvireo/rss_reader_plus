class FeedItem {
  String title;
  String author;
  String link;
  String description;
  String encodedContent; // <content: encoded> tag sometimes contains the article
  List<String> categories;
  String thumbnailLink;
  int thumbnailWidth;
  int thumbnailHeight;
  String guid; // Used as feed item ID
  String feedburnerOrigLink;

  String enclosureLink;     // Link to media enclosure
  int enclosureLength;      // Length of enclosure item
  String enclosureType;     // MIME type of enclosure (for example: 'media/mpeg')

  int parentFeedId;         // Feed ID that owns this feed item
  String webPageLink;       // URL of the feed item's web page.  This is not part
                            //  of the feed item's XML, but is taken from the feed.
  
  bool read;                // true if the feed item has been read

  get hasEnclosure => enclosureLink.length > 0;
}
