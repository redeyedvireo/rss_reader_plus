
import 'package:flutter/material.dart';

enum FeedItemViewMenuAction { CopyFeedText }

class FeedItemViewHeaderWidget extends StatelessWidget {
  String title;
  Function copyContentFn;

  FeedItemViewHeaderWidget(this.title, this.copyContentFn);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(width: 1, color: Colors.grey.shade400))
      ),
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 24)),
          PopupMenuButton<FeedItemViewMenuAction>(
            onSelected: (FeedItemViewMenuAction result) async {
              switch (result) {
                case FeedItemViewMenuAction.CopyFeedText:
                  await copyContentFn();
                break;

                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FeedItemViewMenuAction>>[
              PopupMenuItem(
                value: FeedItemViewMenuAction.CopyFeedText,
                child: Text('Copy feed text')),
            ])
        ],
      )
    );
  }
}