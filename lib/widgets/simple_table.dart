import 'package:flutter/material.dart';

class SimpleTableRow {
  String left;
  String right;

  SimpleTableRow(this.left, this.right);
}

class SimpleTable extends StatelessWidget {
  List<SimpleTableRow> rows = [];
  Map<int, TableColumnWidth> columnWidths = {};
  double verticalPadding;

  SimpleTable({this.rows, this.columnWidths, this.verticalPadding = 8.0});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: _tableRows(),
      columnWidths: columnWidths,
    );
  }

  List<TableRow> _tableRows() {
    return List.generate(rows.length, (int index) {
      return TableRow(
          children: <Widget>[
            _cell(rows[index].left, TextAlign.left),
            _cell(rows[index].right, TextAlign.end),
          ]
      );
    });
  }

  Widget _cell(String text, TextAlign alignment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: verticalPadding),
      child: Text(text, textAlign: alignment,),
    );
  }
}
