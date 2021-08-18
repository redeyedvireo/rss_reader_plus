import 'package:flutter/material.dart';

class SimpleTableRow {
  String left;
  String right;
  TextAlign leftAlign;
  TextAlign rightAlign;

  SimpleTableRow(this.left,
                 this.right,
                 { this.leftAlign = TextAlign.left,
                   this.rightAlign = TextAlign.end});
}

class SimpleTable extends StatelessWidget {
  List<SimpleTableRow> rows = [];
  Map<int, TableColumnWidth> columnWidths = {};
  double verticalPadding;
  bool boldLeftColumn;
  bool boldRightColumn;

  SimpleTable({this.rows,
              this.columnWidths,
              this.verticalPadding = 8.0,
              this.boldLeftColumn = false,
              this.boldRightColumn = false});

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
            _cell(rows[index].left, rows[index].leftAlign, boldLeftColumn),
            _cell(rows[index].right, rows[index].rightAlign, boldRightColumn),
          ]
      );
    });
  }

  Widget _cell(String text, TextAlign alignment, bool bold) {
    if (bold) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: verticalPadding),
        child: Text(text, textAlign: alignment,
          style: TextStyle(
                      fontWeight: FontWeight.bold)),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: verticalPadding),
        child: Text(text, textAlign: alignment,),
      );
    }
  }
}
