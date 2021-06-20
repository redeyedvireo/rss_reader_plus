
import 'package:flutter/material.dart';

class StringListEditWidget extends StatefulWidget {
  _StringListEditWidgetState  state;
  final String textEditHint;
  final List<String> stringList;
  final Future<bool> Function(String wordToDelete) onDeleteFn;
  final Future<bool> Function(String wordToAdd) onAddFn;

  StringListEditWidget({this.stringList,
                        this.textEditHint,
                        @required this.onDeleteFn,
                        @required this.onAddFn});

  @override
  _StringListEditWidgetState createState() {
    state = _StringListEditWidgetState(stringList);
    return state;
  }
}

class _StringListEditWidgetState extends State<StringListEditWidget> {
  List<String> _stringList;
  ScrollController _scrollController;
  TextEditingController _textEditController = TextEditingController();
  double _previousScrollPosition = 0;      // Used to set scroll position after returning from another page
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _newString;

  _StringListEditWidgetState(List<String> inStrings) {
    _stringList = inStrings;
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController(initialScrollOffset: _previousScrollPosition);

    return Column(
      children: [
        Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                  width: 1
                )
              ),
              child: ListView.builder(
              itemCount: _stringList.length,
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                    return _buildStringRow(context, index);
              }),
          ),
        ),
        SizedBox(height: 30.0),
        _buildTextEditWidget(context)
      ],
    );
  }

  Widget _buildStringRow(BuildContext context, int index) {
    String curString = _stringList[index];

    return Container(
      padding: EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(curString)),
          IconButton(
            onPressed: () async {
              final success = await widget.onDeleteFn(curString);
              if (success) {
                setState(() {
                  _stringList.removeAt(index);
                });
              }
            },
            icon: Icon(Icons.delete)
          )
        ],
      ),
    );
  }

  Widget _buildTextEditWidget(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(children: [
      Expanded(
        child: TextFormField(
          controller: _textEditController,
          decoration: InputDecoration(labelText: widget.textEditHint),
          onChanged: (String value) async {
            _newString = value;
          },
        ),
      ),
      TextButton(onPressed: () async {
        final newString = _newString;

        try {
          final success = await widget.onAddFn(newString);

          if (success) {
            setState(() {
              _stringList.add(newString);
            });

            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
          }

          _textEditController.text = '';
        } catch (e) {
          // widget._logger.severe('Error adding filtered word $filteredWord: ${e.message}');
          print('${e.message}');
        }
        }, child: Text('Add'))
      ],),
    );
  }

  void _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
  }
}