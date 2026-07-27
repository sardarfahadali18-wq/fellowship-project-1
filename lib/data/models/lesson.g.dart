// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLessonCollection on Isar {
  IsarCollection<Lesson> get lessons => this.collection();
}

const LessonSchema = CollectionSchema(
  name: r'Lesson',
  id: 6343151657775798464,
  properties: {
    r'assetPaths': PropertySchema(
      id: 0,
      name: r'assetPaths',
      type: IsarType.stringList,
    ),
    r'contentMarkdown': PropertySchema(
      id: 1,
      name: r'contentMarkdown',
      type: IsarType.string,
    ),
    r'order': PropertySchema(id: 2, name: r'order', type: IsarType.long),
    r'packId': PropertySchema(id: 3, name: r'packId', type: IsarType.long),
    r'quizId': PropertySchema(id: 4, name: r'quizId', type: IsarType.long),
    r'title': PropertySchema(id: 5, name: r'title', type: IsarType.string),
  },

  estimateSize: _lessonEstimateSize,
  serialize: _lessonSerialize,
  deserialize: _lessonDeserialize,
  deserializeProp: _lessonDeserializeProp,
  idName: r'id',
  indexes: {
    r'packId': IndexSchema(
      id: 8730215967688696519,
      name: r'packId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'packId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _lessonGetId,
  getLinks: _lessonGetLinks,
  attach: _lessonAttach,
  version: '3.3.2',
);

int _lessonEstimateSize(
  Lesson object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.assetPaths.length * 3;
  {
    for (var i = 0; i < object.assetPaths.length; i++) {
      final value = object.assetPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.contentMarkdown.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _lessonSerialize(
  Lesson object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.assetPaths);
  writer.writeString(offsets[1], object.contentMarkdown);
  writer.writeLong(offsets[2], object.order);
  writer.writeLong(offsets[3], object.packId);
  writer.writeLong(offsets[4], object.quizId);
  writer.writeString(offsets[5], object.title);
}

Lesson _lessonDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Lesson();
  object.assetPaths = reader.readStringList(offsets[0]) ?? [];
  object.contentMarkdown = reader.readString(offsets[1]);
  object.id = id;
  object.order = reader.readLong(offsets[2]);
  object.packId = reader.readLong(offsets[3]);
  object.quizId = reader.readLongOrNull(offsets[4]);
  object.title = reader.readString(offsets[5]);
  return object;
}

P _lessonDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lessonGetId(Lesson object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lessonGetLinks(Lesson object) {
  return [];
}

void _lessonAttach(IsarCollection<dynamic> col, Id id, Lesson object) {
  object.id = id;
}

extension LessonQueryWhereSort on QueryBuilder<Lesson, Lesson, QWhere> {
  QueryBuilder<Lesson, Lesson, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhere> anyPackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'packId'),
      );
    });
  }
}

extension LessonQueryWhere on QueryBuilder<Lesson, Lesson, QWhereClause> {
  QueryBuilder<Lesson, Lesson, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> idBetween(
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

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> packIdEqualTo(int packId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'packId', value: [packId]),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> packIdNotEqualTo(int packId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packId',
                lower: [],
                upper: [packId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packId',
                lower: [packId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packId',
                lower: [packId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packId',
                lower: [],
                upper: [packId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> packIdGreaterThan(
    int packId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'packId',
          lower: [packId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> packIdLessThan(
    int packId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'packId',
          lower: [],
          upper: [packId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterWhereClause> packIdBetween(
    int lowerPackId,
    int upperPackId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'packId',
          lower: [lowerPackId],
          includeLower: includeLower,
          upper: [upperPackId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LessonQueryFilter on QueryBuilder<Lesson, Lesson, QFilterCondition> {
  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'assetPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  assetPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'assetPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'assetPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'assetPaths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  assetPathsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'assetPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'assetPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'assetPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'assetPaths',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  assetPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'assetPaths', value: ''),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  assetPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'assetPaths', value: ''),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'assetPaths', length, true, length, true);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'assetPaths', 0, true, 0, true);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'assetPaths', 0, false, 999999, true);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'assetPaths', 0, true, length, include);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  assetPathsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'assetPaths', length, include, 999999, true);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> assetPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assetPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentMarkdown',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  contentMarkdownGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentMarkdown',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentMarkdown',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentMarkdown',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentMarkdown',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentMarkdown',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentMarkdown',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentMarkdown',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> contentMarkdownIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentMarkdown', value: ''),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition>
  contentMarkdownIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentMarkdown', value: ''),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> packIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'packId', value: value),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> packIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> packIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> packIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> quizIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quizId'),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> quizIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quizId'),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> quizIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quizId', value: value),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> quizIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quizId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> quizIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quizId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> quizIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quizId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension LessonQueryObject on QueryBuilder<Lesson, Lesson, QFilterCondition> {}

extension LessonQueryLinks on QueryBuilder<Lesson, Lesson, QFilterCondition> {}

extension LessonQuerySortBy on QueryBuilder<Lesson, Lesson, QSortBy> {
  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByContentMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentMarkdown', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByContentMarkdownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentMarkdown', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByPackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packId', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByPackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packId', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByQuizId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizId', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByQuizIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizId', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension LessonQuerySortThenBy on QueryBuilder<Lesson, Lesson, QSortThenBy> {
  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByContentMarkdown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentMarkdown', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByContentMarkdownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentMarkdown', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByPackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packId', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByPackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packId', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByQuizId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizId', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByQuizIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizId', Sort.desc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Lesson, Lesson, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension LessonQueryWhereDistinct on QueryBuilder<Lesson, Lesson, QDistinct> {
  QueryBuilder<Lesson, Lesson, QDistinct> distinctByAssetPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetPaths');
    });
  }

  QueryBuilder<Lesson, Lesson, QDistinct> distinctByContentMarkdown({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'contentMarkdown',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Lesson, Lesson, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<Lesson, Lesson, QDistinct> distinctByPackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packId');
    });
  }

  QueryBuilder<Lesson, Lesson, QDistinct> distinctByQuizId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quizId');
    });
  }

  QueryBuilder<Lesson, Lesson, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension LessonQueryProperty on QueryBuilder<Lesson, Lesson, QQueryProperty> {
  QueryBuilder<Lesson, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Lesson, List<String>, QQueryOperations> assetPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetPaths');
    });
  }

  QueryBuilder<Lesson, String, QQueryOperations> contentMarkdownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentMarkdown');
    });
  }

  QueryBuilder<Lesson, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<Lesson, int, QQueryOperations> packIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packId');
    });
  }

  QueryBuilder<Lesson, int?, QQueryOperations> quizIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quizId');
    });
  }

  QueryBuilder<Lesson, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
