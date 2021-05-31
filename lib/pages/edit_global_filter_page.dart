
import 'package:flutter/material.dart';
import 'package:rss_reader_plus/models/feed_item_filter.dart';


class EditGlobalFilterPage extends StatefulWidget {
  FeedItemFilter feedItemFilter;

  EditGlobalFilterPage(this.feedItemFilter);

  @override
  _EditGlobalFilterPageState createState() => _EditGlobalFilterPageState();
}

class _EditGlobalFilterPageState extends State<EditGlobalFilterPage> {
  TextEditingController _queryStringController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FeedItemFilter _feedItemFilter;

@override
  void initState() {
    super.initState();
    _feedItemFilter = widget.feedItemFilter;
    _queryStringController.text = _feedItemFilter.queryStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Global Filter'),
      ),
      body: _buildContent(context, _feedItemFilter),
    );
  }

  Widget _buildContent(BuildContext context, FeedItemFilter feedItemFilter) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 800.0,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('When...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),),
                Row(
                  children: [
                    Flexible(child: _fieldWidget()),
                    SizedBox(width: 20,),
                    Expanded(child: _queryWidget()),
                    SizedBox(width: 20,),
                    Flexible(child: _queryStringWidget()),
                  ],
                ),
                SizedBox(height: 20.0,),
                Text('then...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                  )),
                _actionWidget(),
                SizedBox(height: 50,),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(onPressed: () {
                    print('Saving feed item filter...');
                    Navigator.pop(context, _feedItemFilter);
                  }, child: Text('Save')),
                )
              ],
            ),
          ),
        )),
    );
  }

  Widget _fieldWidget() {
    return DropdownButtonFormField<FilterField>(
      value: _feedItemFilter.fieldId,
      items: [
        DropdownMenuItem<FilterField>(
          value: FilterField.TITLE,
          child: Text('Title'),
        ),
        DropdownMenuItem<FilterField>(
          value: FilterField.AUTHOR,
          child: Text('Author'),
        ),
        DropdownMenuItem<FilterField>(
          value: FilterField.DESCRIPTION,
          child: Text('Description'),
        ),
        DropdownMenuItem<FilterField>(
          value: FilterField.CATEGORIES,
          child: Text('Categories'),
        ),
      ],
      onChanged: (FilterField newValue) {
        setState(() {
          _feedItemFilter.fieldId = newValue;
        });
      },);
  }

  Widget _queryWidget() {
    return DropdownButtonFormField<FilterQuery>(
      value: _feedItemFilter.verb,
      items: [
        DropdownMenuItem<FilterQuery>(
          value: FilterQuery.CONTAINS,
          child: Text('contains'),
        ),
        DropdownMenuItem<FilterQuery>(
          value: FilterQuery.DOES_NOT_CONTAIN,
          child: Text('does not contain'),
        ),
        DropdownMenuItem<FilterQuery>(
          value: FilterQuery.EQUALS,
          child: Text('equals'),
        ),
        DropdownMenuItem<FilterQuery>(
          value: FilterQuery.REGULAR_EXPRESSION_MATCH,
          child: Text('matches by regular expression'),
        ),
      ],
      onChanged: (FilterQuery newValue) {
        setState(() {
          _feedItemFilter.verb = newValue;
        });
      },);
  }

  Widget _queryStringWidget() {
    return TextFormField(
      controller: _queryStringController,
      decoration: InputDecoration(labelText: 'Query string'),
      onChanged: (String value) {
        setState(() {
          _feedItemFilter.queryStr = value;
        });
      },
    );
  }

  Widget _actionWidget() {
    return DropdownButtonFormField<FilterAction>(
      value: _feedItemFilter.action,
      items: [
        DropdownMenuItem<FilterAction>(
          value: FilterAction.COPY_TO_INTEREST_FEED,
          child: Text('Copy to Items of Interest'),
        ),
        DropdownMenuItem<FilterAction>(
          value: FilterAction.MARK_AS_READ,
          child: Text('Mark as read'),
        ),
        DropdownMenuItem<FilterAction>(
          value: FilterAction.DELETE,
          child: Text('Delete item'),
        ),
      ],
      onChanged: (FilterAction newValue) {
        setState(() {
          _feedItemFilter.action = newValue;
        });
      },);
  }
}