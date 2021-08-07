
class SqlTableField<T> {
  String name;
  String fieldType;
  bool isPrimaryKey = false;
  T defaultValue;

  SqlTableField(this.name, this.fieldType, {this.isPrimaryKey, this.defaultValue});

  String sqlText() {
    String sql = '$name $fieldType';

    if (isPrimaryKey) {
      sql = '$sql primary key';
    }

    if (defaultValue != null) {
      sql = '$sql default $defaultValue';
    }

    return sql;
  }
}

class SqlTableBuilder {
  List<SqlTableField> fields = [];
  String tableName;

  SqlTableBuilder(this.tableName);

  addField(SqlTableField field) {
    fields.add(field);
    return this;
  }

  String build() {
    final fieldStr = fields.join(', ');
    return 'CREATE TABLE ( $fieldStr );';
  }
}