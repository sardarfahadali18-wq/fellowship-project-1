// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khata_sync_op.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetKhataSyncOpRowCollection on Isar {
  IsarCollection<KhataSyncOpRow> get khataSyncOpRows => this.collection();
}

const KhataSyncOpRowSchema = CollectionSchema(
  name: r'KhataSyncOpRow',
  id: -2995894935872390282,
  properties: {
    r'attempts': PropertySchema(id: 0, name: r'attempts', type: IsarType.long),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'entity': PropertySchema(
      id: 2,
      name: r'entity',
      type: IsarType.byte,
      enumMap: _KhataSyncOpRowentityEnumValueMap,
    ),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'kind': PropertySchema(
      id: 4,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _KhataSyncOpRowkindEnumValueMap,
    ),
    r'lastError': PropertySchema(
      id: 5,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'localId': PropertySchema(id: 6, name: r'localId', type: IsarType.long),
    r'nextAt': PropertySchema(id: 7, name: r'nextAt', type: IsarType.dateTime),
    r'uuid': PropertySchema(id: 8, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _khataSyncOpRowEstimateSize,
  serialize: _khataSyncOpRowSerialize,
  deserialize: _khataSyncOpRowDeserialize,
  deserializeProp: _khataSyncOpRowDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'nextAt': IndexSchema(
      id: 1821179223098185982,
      name: r'nextAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nextAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _khataSyncOpRowGetId,
  getLinks: _khataSyncOpRowGetLinks,
  attach: _khataSyncOpRowAttach,
  version: '3.3.2',
);

int _khataSyncOpRowEstimateSize(
  KhataSyncOpRow object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _khataSyncOpRowSerialize(
  KhataSyncOpRow object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attempts);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeByte(offsets[2], object.entity.index);
  writer.writeString(offsets[3], object.key);
  writer.writeByte(offsets[4], object.kind.index);
  writer.writeString(offsets[5], object.lastError);
  writer.writeLong(offsets[6], object.localId);
  writer.writeDateTime(offsets[7], object.nextAt);
  writer.writeString(offsets[8], object.uuid);
}

KhataSyncOpRow _khataSyncOpRowDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = KhataSyncOpRow();
  object.attempts = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.entity =
      _KhataSyncOpRowentityValueEnumMap[reader.readByteOrNull(offsets[2])] ??
      KhataEntity.customers;
  object.id = id;
  object.key = reader.readString(offsets[3]);
  object.kind =
      _KhataSyncOpRowkindValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      KhataOpKind.upsert;
  object.lastError = reader.readStringOrNull(offsets[5]);
  object.localId = reader.readLong(offsets[6]);
  object.nextAt = reader.readDateTime(offsets[7]);
  object.uuid = reader.readString(offsets[8]);
  return object;
}

P _khataSyncOpRowDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (_KhataSyncOpRowentityValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              KhataEntity.customers)
          as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_KhataSyncOpRowkindValueEnumMap[reader.readByteOrNull(offset)] ??
              KhataOpKind.upsert)
          as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _KhataSyncOpRowentityEnumValueMap = {'customers': 0, 'transactions': 1};
const _KhataSyncOpRowentityValueEnumMap = {
  0: KhataEntity.customers,
  1: KhataEntity.transactions,
};
const _KhataSyncOpRowkindEnumValueMap = {'upsert': 0, 'delete': 1};
const _KhataSyncOpRowkindValueEnumMap = {
  0: KhataOpKind.upsert,
  1: KhataOpKind.delete,
};

Id _khataSyncOpRowGetId(KhataSyncOpRow object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _khataSyncOpRowGetLinks(KhataSyncOpRow object) {
  return [];
}

void _khataSyncOpRowAttach(
  IsarCollection<dynamic> col,
  Id id,
  KhataSyncOpRow object,
) {
  object.id = id;
}

extension KhataSyncOpRowByIndex on IsarCollection<KhataSyncOpRow> {
  Future<KhataSyncOpRow?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  KhataSyncOpRow? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<KhataSyncOpRow?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<KhataSyncOpRow?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(KhataSyncOpRow object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(KhataSyncOpRow object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<KhataSyncOpRow> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(
    List<KhataSyncOpRow> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension KhataSyncOpRowQueryWhereSort
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QWhere> {
  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhere> anyNextAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nextAt'),
      );
    });
  }
}

extension KhataSyncOpRowQueryWhere
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QWhereClause> {
  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> keyEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> keyNotEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> nextAtEqualTo(
    DateTime nextAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nextAt', value: [nextAt]),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause>
  nextAtNotEqualTo(DateTime nextAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextAt',
                lower: [],
                upper: [nextAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextAt',
                lower: [nextAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextAt',
                lower: [nextAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nextAt',
                lower: [],
                upper: [nextAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause>
  nextAtGreaterThan(DateTime nextAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextAt',
          lower: [nextAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause>
  nextAtLessThan(DateTime nextAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextAt',
          lower: [],
          upper: [nextAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterWhereClause> nextAtBetween(
    DateTime lowerNextAt,
    DateTime upperNextAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'nextAt',
          lower: [lowerNextAt],
          includeLower: includeLower,
          upper: [upperNextAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension KhataSyncOpRowQueryFilter
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QFilterCondition> {
  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  attemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attempts', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  attemptsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  attemptsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attempts',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attempts',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  entityEqualTo(KhataEntity value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entity', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  entityGreaterThan(KhataEntity value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  entityLessThan(KhataEntity value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  entityBetween(
    KhataEntity lower,
    KhataEntity upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  kindEqualTo(KhataOpKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  kindGreaterThan(KhataOpKind value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  kindLessThan(KhataOpKind value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  kindBetween(
    KhataOpKind lower,
    KhataOpKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  localIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localId', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  localIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  localIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  localIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  nextAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextAt', value: value),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  nextAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  nextAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  nextAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension KhataSyncOpRowQueryObject
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QFilterCondition> {}

extension KhataSyncOpRowQueryLinks
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QFilterCondition> {}

extension KhataSyncOpRowQuerySortBy
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QSortBy> {
  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  sortByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByNextAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAt', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  sortByNextAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAt', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension KhataSyncOpRowQuerySortThenBy
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QSortThenBy> {
  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  thenByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByNextAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAt', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy>
  thenByNextAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAt', Sort.desc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension KhataSyncOpRowQueryWhereDistinct
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> {
  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attempts');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByLastError({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByNextAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextAt');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension KhataSyncOpRowQueryProperty
    on QueryBuilder<KhataSyncOpRow, KhataSyncOpRow, QQueryProperty> {
  QueryBuilder<KhataSyncOpRow, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<KhataSyncOpRow, int, QQueryOperations> attemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attempts');
    });
  }

  QueryBuilder<KhataSyncOpRow, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataEntity, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<KhataSyncOpRow, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<KhataSyncOpRow, KhataOpKind, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<KhataSyncOpRow, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<KhataSyncOpRow, int, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<KhataSyncOpRow, DateTime, QQueryOperations> nextAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextAt');
    });
  }

  QueryBuilder<KhataSyncOpRow, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
