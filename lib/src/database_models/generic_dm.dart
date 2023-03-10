enum AttributeType {
  integer('INTEGER'),
  text('TEXT'),
  blob('BLOB'),
  real('REAL'),
  double('DOUBLE'),
  boolean('BOOLEAN'),
  date('DATE'),
  time('TIME'),
  datetime('DATETIME'),
  timestamp('TIMESTAMP');

  final String type;
  const AttributeType(this.type);

  get sqlType => type;
}

class Attribute {
  final String name;
  final AttributeType type;
  final bool isNulable;
  final bool isForeignKey;
  final String? foreignTable;
  final String? foreignColumn;

  Attribute(
      {required this.name,
      required this.type,
      this.isNulable = false,
      this.isForeignKey = false,
      this.foreignTable,
      this.foreignColumn = 'id'});
}

abstract class GenericDM {
  late final String _tableName;
  late final List<Attribute> _attributes;

  GenericDM({
    required String tableName,
    required List<Attribute> attributes,
  })  : _tableName = tableName,
        _attributes = attributes;

  String _getAtributesDefinitionScript() {
    return _attributes
        .map((attribute) =>
            ',${attribute.name} ${attribute.type.sqlType} ${!attribute.isNulable ? 'NOT ' : ''}NULL')
        .join('\n');
  }

  String _getForeignKeysDefinitionScript() {
    final fkAttributes =
        _attributes.where((attribute) => attribute.isForeignKey);

    if (fkAttributes.isEmpty) {
      return '';
    }

    return ',${fkAttributes.map((attribute) => 'FOREIGN KEY (${attribute.name}) REFERENCES ${attribute.foreignTable}(${attribute.foreignColumn})').join('\n')}';
  }

  String getTableName() {
    return _tableName;
  }

  String getCreateTableScript() {
    return '''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT
        ${_getAtributesDefinitionScript()}
        ,created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ,updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ,deleted_at TIMESTAMP
        ${_getForeignKeysDefinitionScript()}
      );
    ''';
  }
}
