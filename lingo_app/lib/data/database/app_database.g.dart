// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _englishMeta = const VerificationMeta(
    'english',
  );
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
    'english',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chineseMeaningsMeta = const VerificationMeta(
    'chineseMeanings',
  );
  @override
  late final GeneratedColumn<String> chineseMeanings = GeneratedColumn<String>(
    'chinese_meanings',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  @override
  late final GeneratedColumn<String> pronunciation = GeneratedColumn<String>(
    'pronunciation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleSentenceMeta = const VerificationMeta(
    'exampleSentence',
  );
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
    'example_sentence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scenarioExampleMeta = const VerificationMeta(
    'scenarioExample',
  );
  @override
  late final GeneratedColumn<String> scenarioExample = GeneratedColumn<String>(
    'scenario_example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scenarioTranslationMeta =
      const VerificationMeta('scenarioTranslation');
  @override
  late final GeneratedColumn<String> scenarioTranslation =
      GeneratedColumn<String>(
        'scenario_translation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    english,
    chineseMeanings,
    pronunciation,
    exampleSentence,
    scenarioExample,
    scenarioTranslation,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('chinese_meanings')) {
      context.handle(
        _chineseMeaningsMeta,
        chineseMeanings.isAcceptableOrUnknown(
          data['chinese_meanings']!,
          _chineseMeaningsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chineseMeaningsMeta);
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
        _exampleSentenceMeta,
        exampleSentence.isAcceptableOrUnknown(
          data['example_sentence']!,
          _exampleSentenceMeta,
        ),
      );
    }
    if (data.containsKey('scenario_example')) {
      context.handle(
        _scenarioExampleMeta,
        scenarioExample.isAcceptableOrUnknown(
          data['scenario_example']!,
          _scenarioExampleMeta,
        ),
      );
    }
    if (data.containsKey('scenario_translation')) {
      context.handle(
        _scenarioTranslationMeta,
        scenarioTranslation.isAcceptableOrUnknown(
          data['scenario_translation']!,
          _scenarioTranslationMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      english: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english'],
      )!,
      chineseMeanings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chinese_meanings'],
      )!,
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronunciation'],
      ),
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      ),
      scenarioExample: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_example'],
      ),
      scenarioTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_translation'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String english;
  final String chineseMeanings;
  final String? pronunciation;
  final String? exampleSentence;
  final String? scenarioExample;
  final String? scenarioTranslation;
  final int createdAt;
  const Word({
    required this.id,
    required this.english,
    required this.chineseMeanings,
    this.pronunciation,
    this.exampleSentence,
    this.scenarioExample,
    this.scenarioTranslation,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['english'] = Variable<String>(english);
    map['chinese_meanings'] = Variable<String>(chineseMeanings);
    if (!nullToAbsent || pronunciation != null) {
      map['pronunciation'] = Variable<String>(pronunciation);
    }
    if (!nullToAbsent || exampleSentence != null) {
      map['example_sentence'] = Variable<String>(exampleSentence);
    }
    if (!nullToAbsent || scenarioExample != null) {
      map['scenario_example'] = Variable<String>(scenarioExample);
    }
    if (!nullToAbsent || scenarioTranslation != null) {
      map['scenario_translation'] = Variable<String>(scenarioTranslation);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      english: Value(english),
      chineseMeanings: Value(chineseMeanings),
      pronunciation: pronunciation == null && nullToAbsent
          ? const Value.absent()
          : Value(pronunciation),
      exampleSentence: exampleSentence == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleSentence),
      scenarioExample: scenarioExample == null && nullToAbsent
          ? const Value.absent()
          : Value(scenarioExample),
      scenarioTranslation: scenarioTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(scenarioTranslation),
      createdAt: Value(createdAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      english: serializer.fromJson<String>(json['english']),
      chineseMeanings: serializer.fromJson<String>(json['chineseMeanings']),
      pronunciation: serializer.fromJson<String?>(json['pronunciation']),
      exampleSentence: serializer.fromJson<String?>(json['exampleSentence']),
      scenarioExample: serializer.fromJson<String?>(json['scenarioExample']),
      scenarioTranslation: serializer.fromJson<String?>(
        json['scenarioTranslation'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'english': serializer.toJson<String>(english),
      'chineseMeanings': serializer.toJson<String>(chineseMeanings),
      'pronunciation': serializer.toJson<String?>(pronunciation),
      'exampleSentence': serializer.toJson<String?>(exampleSentence),
      'scenarioExample': serializer.toJson<String?>(scenarioExample),
      'scenarioTranslation': serializer.toJson<String?>(scenarioTranslation),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Word copyWith({
    int? id,
    String? english,
    String? chineseMeanings,
    Value<String?> pronunciation = const Value.absent(),
    Value<String?> exampleSentence = const Value.absent(),
    Value<String?> scenarioExample = const Value.absent(),
    Value<String?> scenarioTranslation = const Value.absent(),
    int? createdAt,
  }) => Word(
    id: id ?? this.id,
    english: english ?? this.english,
    chineseMeanings: chineseMeanings ?? this.chineseMeanings,
    pronunciation: pronunciation.present
        ? pronunciation.value
        : this.pronunciation,
    exampleSentence: exampleSentence.present
        ? exampleSentence.value
        : this.exampleSentence,
    scenarioExample: scenarioExample.present
        ? scenarioExample.value
        : this.scenarioExample,
    scenarioTranslation: scenarioTranslation.present
        ? scenarioTranslation.value
        : this.scenarioTranslation,
    createdAt: createdAt ?? this.createdAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      english: data.english.present ? data.english.value : this.english,
      chineseMeanings: data.chineseMeanings.present
          ? data.chineseMeanings.value
          : this.chineseMeanings,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      scenarioExample: data.scenarioExample.present
          ? data.scenarioExample.value
          : this.scenarioExample,
      scenarioTranslation: data.scenarioTranslation.present
          ? data.scenarioTranslation.value
          : this.scenarioTranslation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('english: $english, ')
          ..write('chineseMeanings: $chineseMeanings, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('scenarioExample: $scenarioExample, ')
          ..write('scenarioTranslation: $scenarioTranslation, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    english,
    chineseMeanings,
    pronunciation,
    exampleSentence,
    scenarioExample,
    scenarioTranslation,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.english == this.english &&
          other.chineseMeanings == this.chineseMeanings &&
          other.pronunciation == this.pronunciation &&
          other.exampleSentence == this.exampleSentence &&
          other.scenarioExample == this.scenarioExample &&
          other.scenarioTranslation == this.scenarioTranslation &&
          other.createdAt == this.createdAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> english;
  final Value<String> chineseMeanings;
  final Value<String?> pronunciation;
  final Value<String?> exampleSentence;
  final Value<String?> scenarioExample;
  final Value<String?> scenarioTranslation;
  final Value<int> createdAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.english = const Value.absent(),
    this.chineseMeanings = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.scenarioExample = const Value.absent(),
    this.scenarioTranslation = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String english,
    required String chineseMeanings,
    this.pronunciation = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.scenarioExample = const Value.absent(),
    this.scenarioTranslation = const Value.absent(),
    required int createdAt,
  }) : english = Value(english),
       chineseMeanings = Value(chineseMeanings),
       createdAt = Value(createdAt);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? english,
    Expression<String>? chineseMeanings,
    Expression<String>? pronunciation,
    Expression<String>? exampleSentence,
    Expression<String>? scenarioExample,
    Expression<String>? scenarioTranslation,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (english != null) 'english': english,
      if (chineseMeanings != null) 'chinese_meanings': chineseMeanings,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (scenarioExample != null) 'scenario_example': scenarioExample,
      if (scenarioTranslation != null)
        'scenario_translation': scenarioTranslation,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? english,
    Value<String>? chineseMeanings,
    Value<String?>? pronunciation,
    Value<String?>? exampleSentence,
    Value<String?>? scenarioExample,
    Value<String?>? scenarioTranslation,
    Value<int>? createdAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      english: english ?? this.english,
      chineseMeanings: chineseMeanings ?? this.chineseMeanings,
      pronunciation: pronunciation ?? this.pronunciation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      scenarioExample: scenarioExample ?? this.scenarioExample,
      scenarioTranslation: scenarioTranslation ?? this.scenarioTranslation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (chineseMeanings.present) {
      map['chinese_meanings'] = Variable<String>(chineseMeanings.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<String>(pronunciation.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (scenarioExample.present) {
      map['scenario_example'] = Variable<String>(scenarioExample.value);
    }
    if (scenarioTranslation.present) {
      map['scenario_translation'] = Variable<String>(scenarioTranslation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('english: $english, ')
          ..write('chineseMeanings: $chineseMeanings, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('scenarioExample: $scenarioExample, ')
          ..write('scenarioTranslation: $scenarioTranslation, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WordBooksTable extends WordBooks
    with TableInfo<$WordBooksTable, WordBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalWordsMeta = const VerificationMeta(
    'totalWords',
  );
  @override
  late final GeneratedColumn<int> totalWords = GeneratedColumn<int>(
    'total_words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, totalWords, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_words')) {
      context.handle(
        _totalWordsMeta,
        totalWords.isAcceptableOrUnknown(data['total_words']!, _totalWordsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      totalWords: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_words'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WordBooksTable createAlias(String alias) {
    return $WordBooksTable(attachedDatabase, alias);
  }
}

class WordBook extends DataClass implements Insertable<WordBook> {
  final int id;
  final String name;
  final int totalWords;
  final int createdAt;
  const WordBook({
    required this.id,
    required this.name,
    required this.totalWords,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['total_words'] = Variable<int>(totalWords);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WordBooksCompanion toCompanion(bool nullToAbsent) {
    return WordBooksCompanion(
      id: Value(id),
      name: Value(name),
      totalWords: Value(totalWords),
      createdAt: Value(createdAt),
    );
  }

  factory WordBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordBook(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      totalWords: serializer.fromJson<int>(json['totalWords']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'totalWords': serializer.toJson<int>(totalWords),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  WordBook copyWith({int? id, String? name, int? totalWords, int? createdAt}) =>
      WordBook(
        id: id ?? this.id,
        name: name ?? this.name,
        totalWords: totalWords ?? this.totalWords,
        createdAt: createdAt ?? this.createdAt,
      );
  WordBook copyWithCompanion(WordBooksCompanion data) {
    return WordBook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      totalWords: data.totalWords.present
          ? data.totalWords.value
          : this.totalWords,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordBook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalWords: $totalWords, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, totalWords, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordBook &&
          other.id == this.id &&
          other.name == this.name &&
          other.totalWords == this.totalWords &&
          other.createdAt == this.createdAt);
}

class WordBooksCompanion extends UpdateCompanion<WordBook> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> totalWords;
  final Value<int> createdAt;
  const WordBooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.totalWords = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordBooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.totalWords = const Value.absent(),
    required int createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<WordBook> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? totalWords,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (totalWords != null) 'total_words': totalWords,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordBooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? totalWords,
    Value<int>? createdAt,
  }) {
    return WordBooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      totalWords: totalWords ?? this.totalWords,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalWords.present) {
      map['total_words'] = Variable<int>(totalWords.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordBooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalWords: $totalWords, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WordListsTable extends WordLists
    with TableInfo<$WordListsTable, WordList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_books (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPassedMeta = const VerificationMeta(
    'isPassed',
  );
  @override
  late final GeneratedColumn<bool> isPassed = GeneratedColumn<bool>(
    'is_passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_passed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _passThresholdMeta = const VerificationMeta(
    'passThreshold',
  );
  @override
  late final GeneratedColumn<double> passThreshold = GeneratedColumn<double>(
    'pass_threshold',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.75),
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isShuffledMeta = const VerificationMeta(
    'isShuffled',
  );
  @override
  late final GeneratedColumn<bool> isShuffled = GeneratedColumn<bool>(
    'is_shuffled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shuffled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    name,
    isPassed,
    passThreshold,
    wordCount,
    isShuffled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_passed')) {
      context.handle(
        _isPassedMeta,
        isPassed.isAcceptableOrUnknown(data['is_passed']!, _isPassedMeta),
      );
    }
    if (data.containsKey('pass_threshold')) {
      context.handle(
        _passThresholdMeta,
        passThreshold.isAcceptableOrUnknown(
          data['pass_threshold']!,
          _passThresholdMeta,
        ),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    if (data.containsKey('is_shuffled')) {
      context.handle(
        _isShuffledMeta,
        isShuffled.isAcceptableOrUnknown(data['is_shuffled']!, _isShuffledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isPassed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_passed'],
      )!,
      passThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pass_threshold'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      isShuffled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shuffled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WordListsTable createAlias(String alias) {
    return $WordListsTable(attachedDatabase, alias);
  }
}

class WordList extends DataClass implements Insertable<WordList> {
  final int id;
  final int? bookId;
  final String name;
  final bool isPassed;
  final double passThreshold;
  final int wordCount;
  final bool isShuffled;
  final int createdAt;
  const WordList({
    required this.id,
    this.bookId,
    required this.name,
    required this.isPassed,
    required this.passThreshold,
    required this.wordCount,
    required this.isShuffled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<int>(bookId);
    }
    map['name'] = Variable<String>(name);
    map['is_passed'] = Variable<bool>(isPassed);
    map['pass_threshold'] = Variable<double>(passThreshold);
    map['word_count'] = Variable<int>(wordCount);
    map['is_shuffled'] = Variable<bool>(isShuffled);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WordListsCompanion toCompanion(bool nullToAbsent) {
    return WordListsCompanion(
      id: Value(id),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      name: Value(name),
      isPassed: Value(isPassed),
      passThreshold: Value(passThreshold),
      wordCount: Value(wordCount),
      isShuffled: Value(isShuffled),
      createdAt: Value(createdAt),
    );
  }

  factory WordList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordList(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int?>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      isPassed: serializer.fromJson<bool>(json['isPassed']),
      passThreshold: serializer.fromJson<double>(json['passThreshold']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      isShuffled: serializer.fromJson<bool>(json['isShuffled']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int?>(bookId),
      'name': serializer.toJson<String>(name),
      'isPassed': serializer.toJson<bool>(isPassed),
      'passThreshold': serializer.toJson<double>(passThreshold),
      'wordCount': serializer.toJson<int>(wordCount),
      'isShuffled': serializer.toJson<bool>(isShuffled),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  WordList copyWith({
    int? id,
    Value<int?> bookId = const Value.absent(),
    String? name,
    bool? isPassed,
    double? passThreshold,
    int? wordCount,
    bool? isShuffled,
    int? createdAt,
  }) => WordList(
    id: id ?? this.id,
    bookId: bookId.present ? bookId.value : this.bookId,
    name: name ?? this.name,
    isPassed: isPassed ?? this.isPassed,
    passThreshold: passThreshold ?? this.passThreshold,
    wordCount: wordCount ?? this.wordCount,
    isShuffled: isShuffled ?? this.isShuffled,
    createdAt: createdAt ?? this.createdAt,
  );
  WordList copyWithCompanion(WordListsCompanion data) {
    return WordList(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      isPassed: data.isPassed.present ? data.isPassed.value : this.isPassed,
      passThreshold: data.passThreshold.present
          ? data.passThreshold.value
          : this.passThreshold,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      isShuffled: data.isShuffled.present
          ? data.isShuffled.value
          : this.isShuffled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordList(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('isPassed: $isPassed, ')
          ..write('passThreshold: $passThreshold, ')
          ..write('wordCount: $wordCount, ')
          ..write('isShuffled: $isShuffled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    name,
    isPassed,
    passThreshold,
    wordCount,
    isShuffled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordList &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.isPassed == this.isPassed &&
          other.passThreshold == this.passThreshold &&
          other.wordCount == this.wordCount &&
          other.isShuffled == this.isShuffled &&
          other.createdAt == this.createdAt);
}

class WordListsCompanion extends UpdateCompanion<WordList> {
  final Value<int> id;
  final Value<int?> bookId;
  final Value<String> name;
  final Value<bool> isPassed;
  final Value<double> passThreshold;
  final Value<int> wordCount;
  final Value<bool> isShuffled;
  final Value<int> createdAt;
  const WordListsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.isPassed = const Value.absent(),
    this.passThreshold = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.isShuffled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordListsCompanion.insert({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    required String name,
    this.isPassed = const Value.absent(),
    this.passThreshold = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.isShuffled = const Value.absent(),
    required int createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<WordList> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? name,
    Expression<bool>? isPassed,
    Expression<double>? passThreshold,
    Expression<int>? wordCount,
    Expression<bool>? isShuffled,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (isPassed != null) 'is_passed': isPassed,
      if (passThreshold != null) 'pass_threshold': passThreshold,
      if (wordCount != null) 'word_count': wordCount,
      if (isShuffled != null) 'is_shuffled': isShuffled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordListsCompanion copyWith({
    Value<int>? id,
    Value<int?>? bookId,
    Value<String>? name,
    Value<bool>? isPassed,
    Value<double>? passThreshold,
    Value<int>? wordCount,
    Value<bool>? isShuffled,
    Value<int>? createdAt,
  }) {
    return WordListsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      isPassed: isPassed ?? this.isPassed,
      passThreshold: passThreshold ?? this.passThreshold,
      wordCount: wordCount ?? this.wordCount,
      isShuffled: isShuffled ?? this.isShuffled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isPassed.present) {
      map['is_passed'] = Variable<bool>(isPassed.value);
    }
    if (passThreshold.present) {
      map['pass_threshold'] = Variable<double>(passThreshold.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (isShuffled.present) {
      map['is_shuffled'] = Variable<bool>(isShuffled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordListsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('isPassed: $isPassed, ')
          ..write('passThreshold: $passThreshold, ')
          ..write('wordCount: $wordCount, ')
          ..write('isShuffled: $isShuffled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ListWordsTable extends ListWords
    with TableInfo<$ListWordsTable, ListWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_lists (id)',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isForgottenMeta = const VerificationMeta(
    'isForgotten',
  );
  @override
  late final GeneratedColumn<bool> isForgotten = GeneratedColumn<bool>(
    'is_forgotten',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_forgotten" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _forgottenCountMeta = const VerificationMeta(
    'forgottenCount',
  );
  @override
  late final GeneratedColumn<int> forgottenCount = GeneratedColumn<int>(
    'forgotten_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    wordId,
    sortOrder,
    isForgotten,
    forgottenCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_forgotten')) {
      context.handle(
        _isForgottenMeta,
        isForgotten.isAcceptableOrUnknown(
          data['is_forgotten']!,
          _isForgottenMeta,
        ),
      );
    }
    if (data.containsKey('forgotten_count')) {
      context.handle(
        _forgottenCountMeta,
        forgottenCount.isAcceptableOrUnknown(
          data['forgotten_count']!,
          _forgottenCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isForgotten: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_forgotten'],
      )!,
      forgottenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}forgotten_count'],
      )!,
    );
  }

  @override
  $ListWordsTable createAlias(String alias) {
    return $ListWordsTable(attachedDatabase, alias);
  }
}

class ListWord extends DataClass implements Insertable<ListWord> {
  final int id;
  final int listId;
  final int wordId;
  final int sortOrder;
  final bool isForgotten;
  final int forgottenCount;
  const ListWord({
    required this.id,
    required this.listId,
    required this.wordId,
    required this.sortOrder,
    required this.isForgotten,
    required this.forgottenCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['word_id'] = Variable<int>(wordId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_forgotten'] = Variable<bool>(isForgotten);
    map['forgotten_count'] = Variable<int>(forgottenCount);
    return map;
  }

  ListWordsCompanion toCompanion(bool nullToAbsent) {
    return ListWordsCompanion(
      id: Value(id),
      listId: Value(listId),
      wordId: Value(wordId),
      sortOrder: Value(sortOrder),
      isForgotten: Value(isForgotten),
      forgottenCount: Value(forgottenCount),
    );
  }

  factory ListWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListWord(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isForgotten: serializer.fromJson<bool>(json['isForgotten']),
      forgottenCount: serializer.fromJson<int>(json['forgottenCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'wordId': serializer.toJson<int>(wordId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isForgotten': serializer.toJson<bool>(isForgotten),
      'forgottenCount': serializer.toJson<int>(forgottenCount),
    };
  }

  ListWord copyWith({
    int? id,
    int? listId,
    int? wordId,
    int? sortOrder,
    bool? isForgotten,
    int? forgottenCount,
  }) => ListWord(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    wordId: wordId ?? this.wordId,
    sortOrder: sortOrder ?? this.sortOrder,
    isForgotten: isForgotten ?? this.isForgotten,
    forgottenCount: forgottenCount ?? this.forgottenCount,
  );
  ListWord copyWithCompanion(ListWordsCompanion data) {
    return ListWord(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isForgotten: data.isForgotten.present
          ? data.isForgotten.value
          : this.isForgotten,
      forgottenCount: data.forgottenCount.present
          ? data.forgottenCount.value
          : this.forgottenCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListWord(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('wordId: $wordId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isForgotten: $isForgotten, ')
          ..write('forgottenCount: $forgottenCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, listId, wordId, sortOrder, isForgotten, forgottenCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListWord &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.wordId == this.wordId &&
          other.sortOrder == this.sortOrder &&
          other.isForgotten == this.isForgotten &&
          other.forgottenCount == this.forgottenCount);
}

class ListWordsCompanion extends UpdateCompanion<ListWord> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int> wordId;
  final Value<int> sortOrder;
  final Value<bool> isForgotten;
  final Value<int> forgottenCount;
  const ListWordsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isForgotten = const Value.absent(),
    this.forgottenCount = const Value.absent(),
  });
  ListWordsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required int wordId,
    required int sortOrder,
    this.isForgotten = const Value.absent(),
    this.forgottenCount = const Value.absent(),
  }) : listId = Value(listId),
       wordId = Value(wordId),
       sortOrder = Value(sortOrder);
  static Insertable<ListWord> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? wordId,
    Expression<int>? sortOrder,
    Expression<bool>? isForgotten,
    Expression<int>? forgottenCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (wordId != null) 'word_id': wordId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isForgotten != null) 'is_forgotten': isForgotten,
      if (forgottenCount != null) 'forgotten_count': forgottenCount,
    });
  }

  ListWordsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<int>? wordId,
    Value<int>? sortOrder,
    Value<bool>? isForgotten,
    Value<int>? forgottenCount,
  }) {
    return ListWordsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      wordId: wordId ?? this.wordId,
      sortOrder: sortOrder ?? this.sortOrder,
      isForgotten: isForgotten ?? this.isForgotten,
      forgottenCount: forgottenCount ?? this.forgottenCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isForgotten.present) {
      map['is_forgotten'] = Variable<bool>(isForgotten.value);
    }
    if (forgottenCount.present) {
      map['forgotten_count'] = Variable<int>(forgottenCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListWordsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('wordId: $wordId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isForgotten: $isForgotten, ')
          ..write('forgottenCount: $forgottenCount')
          ..write(')'))
        .toString();
  }
}

class $PracticeSessionsTable extends PracticeSessions
    with TableInfo<$PracticeSessionsTable, PracticeSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_lists (id)',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    mode,
    totalCount,
    correctCount,
    accuracy,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCountMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $PracticeSessionsTable createAlias(String alias) {
    return $PracticeSessionsTable(attachedDatabase, alias);
  }
}

class PracticeSession extends DataClass implements Insertable<PracticeSession> {
  final int id;
  final int listId;
  final String mode;
  final int totalCount;
  final int correctCount;
  final double accuracy;
  final int startedAt;
  final int? finishedAt;
  const PracticeSession({
    required this.id,
    required this.listId,
    required this.mode,
    required this.totalCount,
    required this.correctCount,
    required this.accuracy,
    required this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['mode'] = Variable<String>(mode);
    map['total_count'] = Variable<int>(totalCount);
    map['correct_count'] = Variable<int>(correctCount);
    map['accuracy'] = Variable<double>(accuracy);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(finishedAt);
    }
    return map;
  }

  PracticeSessionsCompanion toCompanion(bool nullToAbsent) {
    return PracticeSessionsCompanion(
      id: Value(id),
      listId: Value(listId),
      mode: Value(mode),
      totalCount: Value(totalCount),
      correctCount: Value(correctCount),
      accuracy: Value(accuracy),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory PracticeSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSession(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      mode: serializer.fromJson<String>(json['mode']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      finishedAt: serializer.fromJson<int?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'mode': serializer.toJson<String>(mode),
      'totalCount': serializer.toJson<int>(totalCount),
      'correctCount': serializer.toJson<int>(correctCount),
      'accuracy': serializer.toJson<double>(accuracy),
      'startedAt': serializer.toJson<int>(startedAt),
      'finishedAt': serializer.toJson<int?>(finishedAt),
    };
  }

  PracticeSession copyWith({
    int? id,
    int? listId,
    String? mode,
    int? totalCount,
    int? correctCount,
    double? accuracy,
    int? startedAt,
    Value<int?> finishedAt = const Value.absent(),
  }) => PracticeSession(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    mode: mode ?? this.mode,
    totalCount: totalCount ?? this.totalCount,
    correctCount: correctCount ?? this.correctCount,
    accuracy: accuracy ?? this.accuracy,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  PracticeSession copyWithCompanion(PracticeSessionsCompanion data) {
    return PracticeSession(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      mode: data.mode.present ? data.mode.value : this.mode,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSession(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('mode: $mode, ')
          ..write('totalCount: $totalCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('accuracy: $accuracy, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    mode,
    totalCount,
    correctCount,
    accuracy,
    startedAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSession &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.mode == this.mode &&
          other.totalCount == this.totalCount &&
          other.correctCount == this.correctCount &&
          other.accuracy == this.accuracy &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class PracticeSessionsCompanion extends UpdateCompanion<PracticeSession> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> mode;
  final Value<int> totalCount;
  final Value<int> correctCount;
  final Value<double> accuracy;
  final Value<int> startedAt;
  final Value<int?> finishedAt;
  const PracticeSessionsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.mode = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  });
  PracticeSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String mode,
    required int totalCount,
    required int correctCount,
    required double accuracy,
    required int startedAt,
    this.finishedAt = const Value.absent(),
  }) : listId = Value(listId),
       mode = Value(mode),
       totalCount = Value(totalCount),
       correctCount = Value(correctCount),
       accuracy = Value(accuracy),
       startedAt = Value(startedAt);
  static Insertable<PracticeSession> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? mode,
    Expression<int>? totalCount,
    Expression<int>? correctCount,
    Expression<double>? accuracy,
    Expression<int>? startedAt,
    Expression<int>? finishedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (mode != null) 'mode': mode,
      if (totalCount != null) 'total_count': totalCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (accuracy != null) 'accuracy': accuracy,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
    });
  }

  PracticeSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<String>? mode,
    Value<int>? totalCount,
    Value<int>? correctCount,
    Value<double>? accuracy,
    Value<int>? startedAt,
    Value<int?>? finishedAt,
  }) {
    return PracticeSessionsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      mode: mode ?? this.mode,
      totalCount: totalCount ?? this.totalCount,
      correctCount: correctCount ?? this.correctCount,
      accuracy: accuracy ?? this.accuracy,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('mode: $mode, ')
          ..write('totalCount: $totalCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('accuracy: $accuracy, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }
}

class $PracticeAnswersTable extends PracticeAnswers
    with TableInfo<$PracticeAnswersTable, PracticeAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _userAnswerMeta = const VerificationMeta(
    'userAnswer',
  );
  @override
  late final GeneratedColumn<String> userAnswer = GeneratedColumn<String>(
    'user_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    wordId,
    isCorrect,
    userAnswer,
    correctAnswer,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('user_answer')) {
      context.handle(
        _userAnswerMeta,
        userAnswer.isAcceptableOrUnknown(data['user_answer']!, _userAnswerMeta),
      );
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      userAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_answer'],
      ),
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $PracticeAnswersTable createAlias(String alias) {
    return $PracticeAnswersTable(attachedDatabase, alias);
  }
}

class PracticeAnswer extends DataClass implements Insertable<PracticeAnswer> {
  final int id;
  final int sessionId;
  final int wordId;
  final bool isCorrect;
  final String? userAnswer;
  final String correctAnswer;
  final int answeredAt;
  const PracticeAnswer({
    required this.id,
    required this.sessionId,
    required this.wordId,
    required this.isCorrect,
    this.userAnswer,
    required this.correctAnswer,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['word_id'] = Variable<int>(wordId);
    map['is_correct'] = Variable<bool>(isCorrect);
    if (!nullToAbsent || userAnswer != null) {
      map['user_answer'] = Variable<String>(userAnswer);
    }
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['answered_at'] = Variable<int>(answeredAt);
    return map;
  }

  PracticeAnswersCompanion toCompanion(bool nullToAbsent) {
    return PracticeAnswersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      wordId: Value(wordId),
      isCorrect: Value(isCorrect),
      userAnswer: userAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(userAnswer),
      correctAnswer: Value(correctAnswer),
      answeredAt: Value(answeredAt),
    );
  }

  factory PracticeAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeAnswer(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      userAnswer: serializer.fromJson<String?>(json['userAnswer']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      answeredAt: serializer.fromJson<int>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'wordId': serializer.toJson<int>(wordId),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'userAnswer': serializer.toJson<String?>(userAnswer),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'answeredAt': serializer.toJson<int>(answeredAt),
    };
  }

  PracticeAnswer copyWith({
    int? id,
    int? sessionId,
    int? wordId,
    bool? isCorrect,
    Value<String?> userAnswer = const Value.absent(),
    String? correctAnswer,
    int? answeredAt,
  }) => PracticeAnswer(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    wordId: wordId ?? this.wordId,
    isCorrect: isCorrect ?? this.isCorrect,
    userAnswer: userAnswer.present ? userAnswer.value : this.userAnswer,
    correctAnswer: correctAnswer ?? this.correctAnswer,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  PracticeAnswer copyWithCompanion(PracticeAnswersCompanion data) {
    return PracticeAnswer(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      userAnswer: data.userAnswer.present
          ? data.userAnswer.value
          : this.userAnswer,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswer(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    wordId,
    isCorrect,
    userAnswer,
    correctAnswer,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeAnswer &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.wordId == this.wordId &&
          other.isCorrect == this.isCorrect &&
          other.userAnswer == this.userAnswer &&
          other.correctAnswer == this.correctAnswer &&
          other.answeredAt == this.answeredAt);
}

class PracticeAnswersCompanion extends UpdateCompanion<PracticeAnswer> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> wordId;
  final Value<bool> isCorrect;
  final Value<String?> userAnswer;
  final Value<String> correctAnswer;
  final Value<int> answeredAt;
  const PracticeAnswersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.userAnswer = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  PracticeAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int wordId,
    required bool isCorrect,
    this.userAnswer = const Value.absent(),
    required String correctAnswer,
    required int answeredAt,
  }) : sessionId = Value(sessionId),
       wordId = Value(wordId),
       isCorrect = Value(isCorrect),
       correctAnswer = Value(correctAnswer),
       answeredAt = Value(answeredAt);
  static Insertable<PracticeAnswer> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? wordId,
    Expression<bool>? isCorrect,
    Expression<String>? userAnswer,
    Expression<String>? correctAnswer,
    Expression<int>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (wordId != null) 'word_id': wordId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (userAnswer != null) 'user_answer': userAnswer,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  PracticeAnswersCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? wordId,
    Value<bool>? isCorrect,
    Value<String?>? userAnswer,
    Value<String>? correctAnswer,
    Value<int>? answeredAt,
  }) {
    return PracticeAnswersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      wordId: wordId ?? this.wordId,
      isCorrect: isCorrect ?? this.isCorrect,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (userAnswer.present) {
      map['user_answer'] = Variable<String>(userAnswer.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $ErrorWordsTable extends ErrorWords
    with TableInfo<$ErrorWordsTable, ErrorWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ErrorWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_lists (id)',
    ),
  );
  static const VerificationMeta _errorCountMeta = const VerificationMeta(
    'errorCount',
  );
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
    'error_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isResolvedMeta = const VerificationMeta(
    'isResolved',
  );
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
    'is_resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nextRetestAtMeta = const VerificationMeta(
    'nextRetestAt',
  );
  @override
  late final GeneratedColumn<int> nextRetestAt = GeneratedColumn<int>(
    'next_retest_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    listId,
    errorCount,
    isResolved,
    nextRetestAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'error_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<ErrorWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
        _isResolvedMeta,
        isResolved.isAcceptableOrUnknown(data['is_resolved']!, _isResolvedMeta),
      );
    }
    if (data.containsKey('next_retest_at')) {
      context.handle(
        _nextRetestAtMeta,
        nextRetestAt.isAcceptableOrUnknown(
          data['next_retest_at']!,
          _nextRetestAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ErrorWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ErrorWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
      isResolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_resolved'],
      )!,
      nextRetestAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_retest_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ErrorWordsTable createAlias(String alias) {
    return $ErrorWordsTable(attachedDatabase, alias);
  }
}

class ErrorWord extends DataClass implements Insertable<ErrorWord> {
  final int id;
  final int wordId;
  final int listId;
  final int errorCount;
  final bool isResolved;
  final int? nextRetestAt;
  final int createdAt;
  const ErrorWord({
    required this.id,
    required this.wordId,
    required this.listId,
    required this.errorCount,
    required this.isResolved,
    this.nextRetestAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['list_id'] = Variable<int>(listId);
    map['error_count'] = Variable<int>(errorCount);
    map['is_resolved'] = Variable<bool>(isResolved);
    if (!nullToAbsent || nextRetestAt != null) {
      map['next_retest_at'] = Variable<int>(nextRetestAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ErrorWordsCompanion toCompanion(bool nullToAbsent) {
    return ErrorWordsCompanion(
      id: Value(id),
      wordId: Value(wordId),
      listId: Value(listId),
      errorCount: Value(errorCount),
      isResolved: Value(isResolved),
      nextRetestAt: nextRetestAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetestAt),
      createdAt: Value(createdAt),
    );
  }

  factory ErrorWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ErrorWord(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      listId: serializer.fromJson<int>(json['listId']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
      nextRetestAt: serializer.fromJson<int?>(json['nextRetestAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'listId': serializer.toJson<int>(listId),
      'errorCount': serializer.toJson<int>(errorCount),
      'isResolved': serializer.toJson<bool>(isResolved),
      'nextRetestAt': serializer.toJson<int?>(nextRetestAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ErrorWord copyWith({
    int? id,
    int? wordId,
    int? listId,
    int? errorCount,
    bool? isResolved,
    Value<int?> nextRetestAt = const Value.absent(),
    int? createdAt,
  }) => ErrorWord(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    listId: listId ?? this.listId,
    errorCount: errorCount ?? this.errorCount,
    isResolved: isResolved ?? this.isResolved,
    nextRetestAt: nextRetestAt.present ? nextRetestAt.value : this.nextRetestAt,
    createdAt: createdAt ?? this.createdAt,
  );
  ErrorWord copyWithCompanion(ErrorWordsCompanion data) {
    return ErrorWord(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      listId: data.listId.present ? data.listId.value : this.listId,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
      isResolved: data.isResolved.present
          ? data.isResolved.value
          : this.isResolved,
      nextRetestAt: data.nextRetestAt.present
          ? data.nextRetestAt.value
          : this.nextRetestAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ErrorWord(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('listId: $listId, ')
          ..write('errorCount: $errorCount, ')
          ..write('isResolved: $isResolved, ')
          ..write('nextRetestAt: $nextRetestAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordId,
    listId,
    errorCount,
    isResolved,
    nextRetestAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ErrorWord &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.listId == this.listId &&
          other.errorCount == this.errorCount &&
          other.isResolved == this.isResolved &&
          other.nextRetestAt == this.nextRetestAt &&
          other.createdAt == this.createdAt);
}

class ErrorWordsCompanion extends UpdateCompanion<ErrorWord> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<int> listId;
  final Value<int> errorCount;
  final Value<bool> isResolved;
  final Value<int?> nextRetestAt;
  final Value<int> createdAt;
  const ErrorWordsCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.listId = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.nextRetestAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ErrorWordsCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required int listId,
    this.errorCount = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.nextRetestAt = const Value.absent(),
    required int createdAt,
  }) : wordId = Value(wordId),
       listId = Value(listId),
       createdAt = Value(createdAt);
  static Insertable<ErrorWord> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<int>? listId,
    Expression<int>? errorCount,
    Expression<bool>? isResolved,
    Expression<int>? nextRetestAt,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (listId != null) 'list_id': listId,
      if (errorCount != null) 'error_count': errorCount,
      if (isResolved != null) 'is_resolved': isResolved,
      if (nextRetestAt != null) 'next_retest_at': nextRetestAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ErrorWordsCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<int>? listId,
    Value<int>? errorCount,
    Value<bool>? isResolved,
    Value<int?>? nextRetestAt,
    Value<int>? createdAt,
  }) {
    return ErrorWordsCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      listId: listId ?? this.listId,
      errorCount: errorCount ?? this.errorCount,
      isResolved: isResolved ?? this.isResolved,
      nextRetestAt: nextRetestAt ?? this.nextRetestAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (nextRetestAt.present) {
      map['next_retest_at'] = Variable<int>(nextRetestAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ErrorWordsCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('listId: $listId, ')
          ..write('errorCount: $errorCount, ')
          ..write('isResolved: $isResolved, ')
          ..write('nextRetestAt: $nextRetestAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AiContentTable extends AiContent
    with TableInfo<$AiContentTable, AiContentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiContentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishContentMeta = const VerificationMeta(
    'englishContent',
  );
  @override
  late final GeneratedColumn<String> englishContent = GeneratedColumn<String>(
    'english_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chineseTranslationMeta =
      const VerificationMeta('chineseTranslation');
  @override
  late final GeneratedColumn<String> chineseTranslation =
      GeneratedColumn<String>(
        'chinese_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<int> generatedAt = GeneratedColumn<int>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    contentType,
    englishContent,
    chineseTranslation,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_content';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiContentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('english_content')) {
      context.handle(
        _englishContentMeta,
        englishContent.isAcceptableOrUnknown(
          data['english_content']!,
          _englishContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishContentMeta);
    }
    if (data.containsKey('chinese_translation')) {
      context.handle(
        _chineseTranslationMeta,
        chineseTranslation.isAcceptableOrUnknown(
          data['chinese_translation']!,
          _chineseTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chineseTranslationMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiContentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiContentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      englishContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_content'],
      )!,
      chineseTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chinese_translation'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $AiContentTable createAlias(String alias) {
    return $AiContentTable(attachedDatabase, alias);
  }
}

class AiContentData extends DataClass implements Insertable<AiContentData> {
  final int id;
  final int wordId;
  final String contentType;
  final String englishContent;
  final String chineseTranslation;
  final int generatedAt;
  const AiContentData({
    required this.id,
    required this.wordId,
    required this.contentType,
    required this.englishContent,
    required this.chineseTranslation,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['content_type'] = Variable<String>(contentType);
    map['english_content'] = Variable<String>(englishContent);
    map['chinese_translation'] = Variable<String>(chineseTranslation);
    map['generated_at'] = Variable<int>(generatedAt);
    return map;
  }

  AiContentCompanion toCompanion(bool nullToAbsent) {
    return AiContentCompanion(
      id: Value(id),
      wordId: Value(wordId),
      contentType: Value(contentType),
      englishContent: Value(englishContent),
      chineseTranslation: Value(chineseTranslation),
      generatedAt: Value(generatedAt),
    );
  }

  factory AiContentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiContentData(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      contentType: serializer.fromJson<String>(json['contentType']),
      englishContent: serializer.fromJson<String>(json['englishContent']),
      chineseTranslation: serializer.fromJson<String>(
        json['chineseTranslation'],
      ),
      generatedAt: serializer.fromJson<int>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'contentType': serializer.toJson<String>(contentType),
      'englishContent': serializer.toJson<String>(englishContent),
      'chineseTranslation': serializer.toJson<String>(chineseTranslation),
      'generatedAt': serializer.toJson<int>(generatedAt),
    };
  }

  AiContentData copyWith({
    int? id,
    int? wordId,
    String? contentType,
    String? englishContent,
    String? chineseTranslation,
    int? generatedAt,
  }) => AiContentData(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    contentType: contentType ?? this.contentType,
    englishContent: englishContent ?? this.englishContent,
    chineseTranslation: chineseTranslation ?? this.chineseTranslation,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  AiContentData copyWithCompanion(AiContentCompanion data) {
    return AiContentData(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      englishContent: data.englishContent.present
          ? data.englishContent.value
          : this.englishContent,
      chineseTranslation: data.chineseTranslation.present
          ? data.chineseTranslation.value
          : this.chineseTranslation,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiContentData(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('contentType: $contentType, ')
          ..write('englishContent: $englishContent, ')
          ..write('chineseTranslation: $chineseTranslation, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordId,
    contentType,
    englishContent,
    chineseTranslation,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiContentData &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.contentType == this.contentType &&
          other.englishContent == this.englishContent &&
          other.chineseTranslation == this.chineseTranslation &&
          other.generatedAt == this.generatedAt);
}

class AiContentCompanion extends UpdateCompanion<AiContentData> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String> contentType;
  final Value<String> englishContent;
  final Value<String> chineseTranslation;
  final Value<int> generatedAt;
  const AiContentCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.contentType = const Value.absent(),
    this.englishContent = const Value.absent(),
    this.chineseTranslation = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  AiContentCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required String contentType,
    required String englishContent,
    required String chineseTranslation,
    required int generatedAt,
  }) : wordId = Value(wordId),
       contentType = Value(contentType),
       englishContent = Value(englishContent),
       chineseTranslation = Value(chineseTranslation),
       generatedAt = Value(generatedAt);
  static Insertable<AiContentData> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? contentType,
    Expression<String>? englishContent,
    Expression<String>? chineseTranslation,
    Expression<int>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (contentType != null) 'content_type': contentType,
      if (englishContent != null) 'english_content': englishContent,
      if (chineseTranslation != null) 'chinese_translation': chineseTranslation,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  AiContentCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<String>? contentType,
    Value<String>? englishContent,
    Value<String>? chineseTranslation,
    Value<int>? generatedAt,
  }) {
    return AiContentCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      contentType: contentType ?? this.contentType,
      englishContent: englishContent ?? this.englishContent,
      chineseTranslation: chineseTranslation ?? this.chineseTranslation,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (englishContent.present) {
      map['english_content'] = Variable<String>(englishContent.value);
    }
    if (chineseTranslation.present) {
      map['chinese_translation'] = Variable<String>(chineseTranslation.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<int>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiContentCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('contentType: $contentType, ')
          ..write('englishContent: $englishContent, ')
          ..write('chineseTranslation: $chineseTranslation, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsUsageRecordsTable extends TtsUsageRecords
    with TableInfo<$TtsUsageRecordsTable, TtsUsageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsUsageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceMeta = const VerificationMeta('voice');
  @override
  late final GeneratedColumn<String> voice = GeneratedColumn<String>(
    'voice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargedCharactersMeta = const VerificationMeta(
    'chargedCharacters',
  );
  @override
  late final GeneratedColumn<int> chargedCharacters = GeneratedColumn<int>(
    'charged_characters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioBytesMeta = const VerificationMeta(
    'audioBytes',
  );
  @override
  late final GeneratedColumn<int> audioBytes = GeneratedColumn<int>(
    'audio_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    action,
    textValue,
    language,
    model,
    voice,
    resourceId,
    chargedCharacters,
    audioBytes,
    durationMs,
    requestId,
    logId,
    status,
    errorMessage,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_usage_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TtsUsageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('voice')) {
      context.handle(
        _voiceMeta,
        voice.isAcceptableOrUnknown(data['voice']!, _voiceMeta),
      );
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    }
    if (data.containsKey('charged_characters')) {
      context.handle(
        _chargedCharactersMeta,
        chargedCharacters.isAcceptableOrUnknown(
          data['charged_characters']!,
          _chargedCharactersMeta,
        ),
      );
    }
    if (data.containsKey('audio_bytes')) {
      context.handle(
        _audioBytesMeta,
        audioBytes.isAcceptableOrUnknown(data['audio_bytes']!, _audioBytesMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsUsageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsUsageRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      voice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice'],
      ),
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      ),
      chargedCharacters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charged_characters'],
      ),
      audioBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_bytes'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TtsUsageRecordsTable createAlias(String alias) {
    return $TtsUsageRecordsTable(attachedDatabase, alias);
  }
}

class TtsUsageRecord extends DataClass implements Insertable<TtsUsageRecord> {
  final int id;
  final String provider;
  final String action;
  final String textValue;
  final String language;
  final String? model;
  final String? voice;
  final String? resourceId;
  final int? chargedCharacters;
  final int? audioBytes;
  final int? durationMs;
  final String? requestId;
  final String? logId;
  final String status;
  final String? errorMessage;
  final int createdAt;
  const TtsUsageRecord({
    required this.id,
    required this.provider,
    required this.action,
    required this.textValue,
    required this.language,
    this.model,
    this.voice,
    this.resourceId,
    this.chargedCharacters,
    this.audioBytes,
    this.durationMs,
    this.requestId,
    this.logId,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider'] = Variable<String>(provider);
    map['action'] = Variable<String>(action);
    map['text'] = Variable<String>(textValue);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || voice != null) {
      map['voice'] = Variable<String>(voice);
    }
    if (!nullToAbsent || resourceId != null) {
      map['resource_id'] = Variable<String>(resourceId);
    }
    if (!nullToAbsent || chargedCharacters != null) {
      map['charged_characters'] = Variable<int>(chargedCharacters);
    }
    if (!nullToAbsent || audioBytes != null) {
      map['audio_bytes'] = Variable<int>(audioBytes);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    if (!nullToAbsent || logId != null) {
      map['log_id'] = Variable<String>(logId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TtsUsageRecordsCompanion toCompanion(bool nullToAbsent) {
    return TtsUsageRecordsCompanion(
      id: Value(id),
      provider: Value(provider),
      action: Value(action),
      textValue: Value(textValue),
      language: Value(language),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      voice: voice == null && nullToAbsent
          ? const Value.absent()
          : Value(voice),
      resourceId: resourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceId),
      chargedCharacters: chargedCharacters == null && nullToAbsent
          ? const Value.absent()
          : Value(chargedCharacters),
      audioBytes: audioBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(audioBytes),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      logId: logId == null && nullToAbsent
          ? const Value.absent()
          : Value(logId),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
    );
  }

  factory TtsUsageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsUsageRecord(
      id: serializer.fromJson<int>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      action: serializer.fromJson<String>(json['action']),
      textValue: serializer.fromJson<String>(json['textValue']),
      language: serializer.fromJson<String>(json['language']),
      model: serializer.fromJson<String?>(json['model']),
      voice: serializer.fromJson<String?>(json['voice']),
      resourceId: serializer.fromJson<String?>(json['resourceId']),
      chargedCharacters: serializer.fromJson<int?>(json['chargedCharacters']),
      audioBytes: serializer.fromJson<int?>(json['audioBytes']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      logId: serializer.fromJson<String?>(json['logId']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(provider),
      'action': serializer.toJson<String>(action),
      'textValue': serializer.toJson<String>(textValue),
      'language': serializer.toJson<String>(language),
      'model': serializer.toJson<String?>(model),
      'voice': serializer.toJson<String?>(voice),
      'resourceId': serializer.toJson<String?>(resourceId),
      'chargedCharacters': serializer.toJson<int?>(chargedCharacters),
      'audioBytes': serializer.toJson<int?>(audioBytes),
      'durationMs': serializer.toJson<int?>(durationMs),
      'requestId': serializer.toJson<String?>(requestId),
      'logId': serializer.toJson<String?>(logId),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TtsUsageRecord copyWith({
    int? id,
    String? provider,
    String? action,
    String? textValue,
    String? language,
    Value<String?> model = const Value.absent(),
    Value<String?> voice = const Value.absent(),
    Value<String?> resourceId = const Value.absent(),
    Value<int?> chargedCharacters = const Value.absent(),
    Value<int?> audioBytes = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> requestId = const Value.absent(),
    Value<String?> logId = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    int? createdAt,
  }) => TtsUsageRecord(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    action: action ?? this.action,
    textValue: textValue ?? this.textValue,
    language: language ?? this.language,
    model: model.present ? model.value : this.model,
    voice: voice.present ? voice.value : this.voice,
    resourceId: resourceId.present ? resourceId.value : this.resourceId,
    chargedCharacters: chargedCharacters.present
        ? chargedCharacters.value
        : this.chargedCharacters,
    audioBytes: audioBytes.present ? audioBytes.value : this.audioBytes,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    requestId: requestId.present ? requestId.value : this.requestId,
    logId: logId.present ? logId.value : this.logId,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
  );
  TtsUsageRecord copyWithCompanion(TtsUsageRecordsCompanion data) {
    return TtsUsageRecord(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      action: data.action.present ? data.action.value : this.action,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      language: data.language.present ? data.language.value : this.language,
      model: data.model.present ? data.model.value : this.model,
      voice: data.voice.present ? data.voice.value : this.voice,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      chargedCharacters: data.chargedCharacters.present
          ? data.chargedCharacters.value
          : this.chargedCharacters,
      audioBytes: data.audioBytes.present
          ? data.audioBytes.value
          : this.audioBytes,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      logId: data.logId.present ? data.logId.value : this.logId,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsUsageRecord(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('action: $action, ')
          ..write('textValue: $textValue, ')
          ..write('language: $language, ')
          ..write('model: $model, ')
          ..write('voice: $voice, ')
          ..write('resourceId: $resourceId, ')
          ..write('chargedCharacters: $chargedCharacters, ')
          ..write('audioBytes: $audioBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('requestId: $requestId, ')
          ..write('logId: $logId, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    action,
    textValue,
    language,
    model,
    voice,
    resourceId,
    chargedCharacters,
    audioBytes,
    durationMs,
    requestId,
    logId,
    status,
    errorMessage,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsUsageRecord &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.action == this.action &&
          other.textValue == this.textValue &&
          other.language == this.language &&
          other.model == this.model &&
          other.voice == this.voice &&
          other.resourceId == this.resourceId &&
          other.chargedCharacters == this.chargedCharacters &&
          other.audioBytes == this.audioBytes &&
          other.durationMs == this.durationMs &&
          other.requestId == this.requestId &&
          other.logId == this.logId &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt);
}

class TtsUsageRecordsCompanion extends UpdateCompanion<TtsUsageRecord> {
  final Value<int> id;
  final Value<String> provider;
  final Value<String> action;
  final Value<String> textValue;
  final Value<String> language;
  final Value<String?> model;
  final Value<String?> voice;
  final Value<String?> resourceId;
  final Value<int?> chargedCharacters;
  final Value<int?> audioBytes;
  final Value<int?> durationMs;
  final Value<String?> requestId;
  final Value<String?> logId;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int> createdAt;
  const TtsUsageRecordsCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.action = const Value.absent(),
    this.textValue = const Value.absent(),
    this.language = const Value.absent(),
    this.model = const Value.absent(),
    this.voice = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.chargedCharacters = const Value.absent(),
    this.audioBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.requestId = const Value.absent(),
    this.logId = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TtsUsageRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String provider,
    required String action,
    required String textValue,
    required String language,
    this.model = const Value.absent(),
    this.voice = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.chargedCharacters = const Value.absent(),
    this.audioBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.requestId = const Value.absent(),
    this.logId = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    required int createdAt,
  }) : provider = Value(provider),
       action = Value(action),
       textValue = Value(textValue),
       language = Value(language),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<TtsUsageRecord> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? action,
    Expression<String>? textValue,
    Expression<String>? language,
    Expression<String>? model,
    Expression<String>? voice,
    Expression<String>? resourceId,
    Expression<int>? chargedCharacters,
    Expression<int>? audioBytes,
    Expression<int>? durationMs,
    Expression<String>? requestId,
    Expression<String>? logId,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (action != null) 'action': action,
      if (textValue != null) 'text': textValue,
      if (language != null) 'language': language,
      if (model != null) 'model': model,
      if (voice != null) 'voice': voice,
      if (resourceId != null) 'resource_id': resourceId,
      if (chargedCharacters != null) 'charged_characters': chargedCharacters,
      if (audioBytes != null) 'audio_bytes': audioBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (requestId != null) 'request_id': requestId,
      if (logId != null) 'log_id': logId,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TtsUsageRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? provider,
    Value<String>? action,
    Value<String>? textValue,
    Value<String>? language,
    Value<String?>? model,
    Value<String?>? voice,
    Value<String?>? resourceId,
    Value<int?>? chargedCharacters,
    Value<int?>? audioBytes,
    Value<int?>? durationMs,
    Value<String?>? requestId,
    Value<String?>? logId,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<int>? createdAt,
  }) {
    return TtsUsageRecordsCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      action: action ?? this.action,
      textValue: textValue ?? this.textValue,
      language: language ?? this.language,
      model: model ?? this.model,
      voice: voice ?? this.voice,
      resourceId: resourceId ?? this.resourceId,
      chargedCharacters: chargedCharacters ?? this.chargedCharacters,
      audioBytes: audioBytes ?? this.audioBytes,
      durationMs: durationMs ?? this.durationMs,
      requestId: requestId ?? this.requestId,
      logId: logId ?? this.logId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (textValue.present) {
      map['text'] = Variable<String>(textValue.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (voice.present) {
      map['voice'] = Variable<String>(voice.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (chargedCharacters.present) {
      map['charged_characters'] = Variable<int>(chargedCharacters.value);
    }
    if (audioBytes.present) {
      map['audio_bytes'] = Variable<int>(audioBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsUsageRecordsCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('action: $action, ')
          ..write('textValue: $textValue, ')
          ..write('language: $language, ')
          ..write('model: $model, ')
          ..write('voice: $voice, ')
          ..write('resourceId: $resourceId, ')
          ..write('chargedCharacters: $chargedCharacters, ')
          ..write('audioBytes: $audioBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('requestId: $requestId, ')
          ..write('logId: $logId, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TtsCacheRecordsTable extends TtsCacheRecords
    with TableInfo<$TtsCacheRecordsTable, TtsCacheRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsCacheRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachePathMeta = const VerificationMeta(
    'cachePath',
  );
  @override
  late final GeneratedColumn<String> cachePath = GeneratedColumn<String>(
    'cache_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioBytesMeta = const VerificationMeta(
    'audioBytes',
  );
  @override
  late final GeneratedColumn<int> audioBytes = GeneratedColumn<int>(
    'audio_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargedCharactersMeta = const VerificationMeta(
    'chargedCharacters',
  );
  @override
  late final GeneratedColumn<int> chargedCharacters = GeneratedColumn<int>(
    'charged_characters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    language,
    textValue,
    cacheKey,
    status,
    cachePath,
    errorMessage,
    audioBytes,
    chargedCharacters,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_cache_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TtsCacheRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('cache_path')) {
      context.handle(
        _cachePathMeta,
        cachePath.isAcceptableOrUnknown(data['cache_path']!, _cachePathMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('audio_bytes')) {
      context.handle(
        _audioBytesMeta,
        audioBytes.isAcceptableOrUnknown(data['audio_bytes']!, _audioBytesMeta),
      );
    }
    if (data.containsKey('charged_characters')) {
      context.handle(
        _chargedCharactersMeta,
        chargedCharacters.isAcceptableOrUnknown(
          data['charged_characters']!,
          _chargedCharactersMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsCacheRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsCacheRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cachePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_path'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      audioBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_bytes'],
      ),
      chargedCharacters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charged_characters'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TtsCacheRecordsTable createAlias(String alias) {
    return $TtsCacheRecordsTable(attachedDatabase, alias);
  }
}

class TtsCacheRecord extends DataClass implements Insertable<TtsCacheRecord> {
  final int id;
  final String provider;
  final String language;
  final String textValue;
  final String cacheKey;
  final String status;
  final String? cachePath;
  final String? errorMessage;
  final int? audioBytes;
  final int? chargedCharacters;
  final int updatedAt;
  const TtsCacheRecord({
    required this.id,
    required this.provider,
    required this.language,
    required this.textValue,
    required this.cacheKey,
    required this.status,
    this.cachePath,
    this.errorMessage,
    this.audioBytes,
    this.chargedCharacters,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider'] = Variable<String>(provider);
    map['language'] = Variable<String>(language);
    map['text'] = Variable<String>(textValue);
    map['cache_key'] = Variable<String>(cacheKey);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || cachePath != null) {
      map['cache_path'] = Variable<String>(cachePath);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || audioBytes != null) {
      map['audio_bytes'] = Variable<int>(audioBytes);
    }
    if (!nullToAbsent || chargedCharacters != null) {
      map['charged_characters'] = Variable<int>(chargedCharacters);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TtsCacheRecordsCompanion toCompanion(bool nullToAbsent) {
    return TtsCacheRecordsCompanion(
      id: Value(id),
      provider: Value(provider),
      language: Value(language),
      textValue: Value(textValue),
      cacheKey: Value(cacheKey),
      status: Value(status),
      cachePath: cachePath == null && nullToAbsent
          ? const Value.absent()
          : Value(cachePath),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      audioBytes: audioBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(audioBytes),
      chargedCharacters: chargedCharacters == null && nullToAbsent
          ? const Value.absent()
          : Value(chargedCharacters),
      updatedAt: Value(updatedAt),
    );
  }

  factory TtsCacheRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsCacheRecord(
      id: serializer.fromJson<int>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      language: serializer.fromJson<String>(json['language']),
      textValue: serializer.fromJson<String>(json['textValue']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      status: serializer.fromJson<String>(json['status']),
      cachePath: serializer.fromJson<String?>(json['cachePath']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      audioBytes: serializer.fromJson<int?>(json['audioBytes']),
      chargedCharacters: serializer.fromJson<int?>(json['chargedCharacters']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(provider),
      'language': serializer.toJson<String>(language),
      'textValue': serializer.toJson<String>(textValue),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'status': serializer.toJson<String>(status),
      'cachePath': serializer.toJson<String?>(cachePath),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'audioBytes': serializer.toJson<int?>(audioBytes),
      'chargedCharacters': serializer.toJson<int?>(chargedCharacters),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TtsCacheRecord copyWith({
    int? id,
    String? provider,
    String? language,
    String? textValue,
    String? cacheKey,
    String? status,
    Value<String?> cachePath = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<int?> audioBytes = const Value.absent(),
    Value<int?> chargedCharacters = const Value.absent(),
    int? updatedAt,
  }) => TtsCacheRecord(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    language: language ?? this.language,
    textValue: textValue ?? this.textValue,
    cacheKey: cacheKey ?? this.cacheKey,
    status: status ?? this.status,
    cachePath: cachePath.present ? cachePath.value : this.cachePath,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    audioBytes: audioBytes.present ? audioBytes.value : this.audioBytes,
    chargedCharacters: chargedCharacters.present
        ? chargedCharacters.value
        : this.chargedCharacters,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TtsCacheRecord copyWithCompanion(TtsCacheRecordsCompanion data) {
    return TtsCacheRecord(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      language: data.language.present ? data.language.value : this.language,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      status: data.status.present ? data.status.value : this.status,
      cachePath: data.cachePath.present ? data.cachePath.value : this.cachePath,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      audioBytes: data.audioBytes.present
          ? data.audioBytes.value
          : this.audioBytes,
      chargedCharacters: data.chargedCharacters.present
          ? data.chargedCharacters.value
          : this.chargedCharacters,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsCacheRecord(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('language: $language, ')
          ..write('textValue: $textValue, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('status: $status, ')
          ..write('cachePath: $cachePath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('audioBytes: $audioBytes, ')
          ..write('chargedCharacters: $chargedCharacters, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    language,
    textValue,
    cacheKey,
    status,
    cachePath,
    errorMessage,
    audioBytes,
    chargedCharacters,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsCacheRecord &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.language == this.language &&
          other.textValue == this.textValue &&
          other.cacheKey == this.cacheKey &&
          other.status == this.status &&
          other.cachePath == this.cachePath &&
          other.errorMessage == this.errorMessage &&
          other.audioBytes == this.audioBytes &&
          other.chargedCharacters == this.chargedCharacters &&
          other.updatedAt == this.updatedAt);
}

class TtsCacheRecordsCompanion extends UpdateCompanion<TtsCacheRecord> {
  final Value<int> id;
  final Value<String> provider;
  final Value<String> language;
  final Value<String> textValue;
  final Value<String> cacheKey;
  final Value<String> status;
  final Value<String?> cachePath;
  final Value<String?> errorMessage;
  final Value<int?> audioBytes;
  final Value<int?> chargedCharacters;
  final Value<int> updatedAt;
  const TtsCacheRecordsCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.language = const Value.absent(),
    this.textValue = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.status = const Value.absent(),
    this.cachePath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.audioBytes = const Value.absent(),
    this.chargedCharacters = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TtsCacheRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String provider,
    required String language,
    required String textValue,
    required String cacheKey,
    required String status,
    this.cachePath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.audioBytes = const Value.absent(),
    this.chargedCharacters = const Value.absent(),
    required int updatedAt,
  }) : provider = Value(provider),
       language = Value(language),
       textValue = Value(textValue),
       cacheKey = Value(cacheKey),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<TtsCacheRecord> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? language,
    Expression<String>? textValue,
    Expression<String>? cacheKey,
    Expression<String>? status,
    Expression<String>? cachePath,
    Expression<String>? errorMessage,
    Expression<int>? audioBytes,
    Expression<int>? chargedCharacters,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (language != null) 'language': language,
      if (textValue != null) 'text': textValue,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (status != null) 'status': status,
      if (cachePath != null) 'cache_path': cachePath,
      if (errorMessage != null) 'error_message': errorMessage,
      if (audioBytes != null) 'audio_bytes': audioBytes,
      if (chargedCharacters != null) 'charged_characters': chargedCharacters,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TtsCacheRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? provider,
    Value<String>? language,
    Value<String>? textValue,
    Value<String>? cacheKey,
    Value<String>? status,
    Value<String?>? cachePath,
    Value<String?>? errorMessage,
    Value<int?>? audioBytes,
    Value<int?>? chargedCharacters,
    Value<int>? updatedAt,
  }) {
    return TtsCacheRecordsCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      language: language ?? this.language,
      textValue: textValue ?? this.textValue,
      cacheKey: cacheKey ?? this.cacheKey,
      status: status ?? this.status,
      cachePath: cachePath ?? this.cachePath,
      errorMessage: errorMessage ?? this.errorMessage,
      audioBytes: audioBytes ?? this.audioBytes,
      chargedCharacters: chargedCharacters ?? this.chargedCharacters,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (textValue.present) {
      map['text'] = Variable<String>(textValue.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cachePath.present) {
      map['cache_path'] = Variable<String>(cachePath.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (audioBytes.present) {
      map['audio_bytes'] = Variable<int>(audioBytes.value);
    }
    if (chargedCharacters.present) {
      map['charged_characters'] = Variable<int>(chargedCharacters.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsCacheRecordsCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('language: $language, ')
          ..write('textValue: $textValue, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('status: $status, ')
          ..write('cachePath: $cachePath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('audioBytes: $audioBytes, ')
          ..write('chargedCharacters: $chargedCharacters, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordBooksTable wordBooks = $WordBooksTable(this);
  late final $WordListsTable wordLists = $WordListsTable(this);
  late final $ListWordsTable listWords = $ListWordsTable(this);
  late final $PracticeSessionsTable practiceSessions = $PracticeSessionsTable(
    this,
  );
  late final $PracticeAnswersTable practiceAnswers = $PracticeAnswersTable(
    this,
  );
  late final $ErrorWordsTable errorWords = $ErrorWordsTable(this);
  late final $AiContentTable aiContent = $AiContentTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $TtsUsageRecordsTable ttsUsageRecords = $TtsUsageRecordsTable(
    this,
  );
  late final $TtsCacheRecordsTable ttsCacheRecords = $TtsCacheRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    wordBooks,
    wordLists,
    listWords,
    practiceSessions,
    practiceAnswers,
    errorWords,
    aiContent,
    settings,
    ttsUsageRecords,
    ttsCacheRecords,
  ];
}

typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String english,
      required String chineseMeanings,
      Value<String?> pronunciation,
      Value<String?> exampleSentence,
      Value<String?> scenarioExample,
      Value<String?> scenarioTranslation,
      required int createdAt,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> english,
      Value<String> chineseMeanings,
      Value<String?> pronunciation,
      Value<String?> exampleSentence,
      Value<String?> scenarioExample,
      Value<String?> scenarioTranslation,
      Value<int> createdAt,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ListWordsTable, List<ListWord>>
  _listWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.listWords,
    aliasName: $_aliasNameGenerator(db.words.id, db.listWords.wordId),
  );

  $$ListWordsTableProcessedTableManager get listWordsRefs {
    final manager = $$ListWordsTableTableManager(
      $_db,
      $_db.listWords,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_listWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PracticeAnswersTable, List<PracticeAnswer>>
  _practiceAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceAnswers,
    aliasName: $_aliasNameGenerator(db.words.id, db.practiceAnswers.wordId),
  );

  $$PracticeAnswersTableProcessedTableManager get practiceAnswersRefs {
    final manager = $$PracticeAnswersTableTableManager(
      $_db,
      $_db.practiceAnswers,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practiceAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ErrorWordsTable, List<ErrorWord>>
  _errorWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.errorWords,
    aliasName: $_aliasNameGenerator(db.words.id, db.errorWords.wordId),
  );

  $$ErrorWordsTableProcessedTableManager get errorWordsRefs {
    final manager = $$ErrorWordsTableTableManager(
      $_db,
      $_db.errorWords,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_errorWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AiContentTable, List<AiContentData>>
  _aiContentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.aiContent,
    aliasName: $_aliasNameGenerator(db.words.id, db.aiContent.wordId),
  );

  $$AiContentTableProcessedTableManager get aiContentRefs {
    final manager = $$AiContentTableTableManager(
      $_db,
      $_db.aiContent,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_aiContentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chineseMeanings => $composableBuilder(
    column: $table.chineseMeanings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioExample => $composableBuilder(
    column: $table.scenarioExample,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioTranslation => $composableBuilder(
    column: $table.scenarioTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> listWordsRefs(
    Expression<bool> Function($$ListWordsTableFilterComposer f) f,
  ) {
    final $$ListWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListWordsTableFilterComposer(
            $db: $db,
            $table: $db.listWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> practiceAnswersRefs(
    Expression<bool> Function($$PracticeAnswersTableFilterComposer f) f,
  ) {
    final $$PracticeAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableFilterComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> errorWordsRefs(
    Expression<bool> Function($$ErrorWordsTableFilterComposer f) f,
  ) {
    final $$ErrorWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.errorWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ErrorWordsTableFilterComposer(
            $db: $db,
            $table: $db.errorWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> aiContentRefs(
    Expression<bool> Function($$AiContentTableFilterComposer f) f,
  ) {
    final $$AiContentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiContent,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiContentTableFilterComposer(
            $db: $db,
            $table: $db.aiContent,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chineseMeanings => $composableBuilder(
    column: $table.chineseMeanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioExample => $composableBuilder(
    column: $table.scenarioExample,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioTranslation => $composableBuilder(
    column: $table.scenarioTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<String> get chineseMeanings => $composableBuilder(
    column: $table.chineseMeanings,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scenarioExample => $composableBuilder(
    column: $table.scenarioExample,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scenarioTranslation => $composableBuilder(
    column: $table.scenarioTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> listWordsRefs<T extends Object>(
    Expression<T> Function($$ListWordsTableAnnotationComposer a) f,
  ) {
    final $$ListWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.listWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> practiceAnswersRefs<T extends Object>(
    Expression<T> Function($$PracticeAnswersTableAnnotationComposer a) f,
  ) {
    final $$PracticeAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> errorWordsRefs<T extends Object>(
    Expression<T> Function($$ErrorWordsTableAnnotationComposer a) f,
  ) {
    final $$ErrorWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.errorWords,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ErrorWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.errorWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> aiContentRefs<T extends Object>(
    Expression<T> Function($$AiContentTableAnnotationComposer a) f,
  ) {
    final $$AiContentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aiContent,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiContentTableAnnotationComposer(
            $db: $db,
            $table: $db.aiContent,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({
            bool listWordsRefs,
            bool practiceAnswersRefs,
            bool errorWordsRefs,
            bool aiContentRefs,
          })
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<String> chineseMeanings = const Value.absent(),
                Value<String?> pronunciation = const Value.absent(),
                Value<String?> exampleSentence = const Value.absent(),
                Value<String?> scenarioExample = const Value.absent(),
                Value<String?> scenarioTranslation = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                english: english,
                chineseMeanings: chineseMeanings,
                pronunciation: pronunciation,
                exampleSentence: exampleSentence,
                scenarioExample: scenarioExample,
                scenarioTranslation: scenarioTranslation,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String english,
                required String chineseMeanings,
                Value<String?> pronunciation = const Value.absent(),
                Value<String?> exampleSentence = const Value.absent(),
                Value<String?> scenarioExample = const Value.absent(),
                Value<String?> scenarioTranslation = const Value.absent(),
                required int createdAt,
              }) => WordsCompanion.insert(
                id: id,
                english: english,
                chineseMeanings: chineseMeanings,
                pronunciation: pronunciation,
                exampleSentence: exampleSentence,
                scenarioExample: scenarioExample,
                scenarioTranslation: scenarioTranslation,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                listWordsRefs = false,
                practiceAnswersRefs = false,
                errorWordsRefs = false,
                aiContentRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (listWordsRefs) db.listWords,
                    if (practiceAnswersRefs) db.practiceAnswers,
                    if (errorWordsRefs) db.errorWords,
                    if (aiContentRefs) db.aiContent,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (listWordsRefs)
                        await $_getPrefetchedData<Word, $WordsTable, ListWord>(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._listWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).listWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (practiceAnswersRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          PracticeAnswer
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._practiceAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).practiceAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (errorWordsRefs)
                        await $_getPrefetchedData<Word, $WordsTable, ErrorWord>(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._errorWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).errorWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (aiContentRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          AiContentData
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._aiContentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).aiContentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({
        bool listWordsRefs,
        bool practiceAnswersRefs,
        bool errorWordsRefs,
        bool aiContentRefs,
      })
    >;
typedef $$WordBooksTableCreateCompanionBuilder =
    WordBooksCompanion Function({
      Value<int> id,
      required String name,
      Value<int> totalWords,
      required int createdAt,
    });
typedef $$WordBooksTableUpdateCompanionBuilder =
    WordBooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> totalWords,
      Value<int> createdAt,
    });

final class $$WordBooksTableReferences
    extends BaseReferences<_$AppDatabase, $WordBooksTable, WordBook> {
  $$WordBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordListsTable, List<WordList>>
  _wordListsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordLists,
    aliasName: $_aliasNameGenerator(db.wordBooks.id, db.wordLists.bookId),
  );

  $$WordListsTableProcessedTableManager get wordListsRefs {
    final manager = $$WordListsTableTableManager(
      $_db,
      $_db.wordLists,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordListsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordBooksTableFilterComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordListsRefs(
    Expression<bool> Function($$WordListsTableFilterComposer f) f,
  ) {
    final $$WordListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableFilterComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> wordListsRefs<T extends Object>(
    Expression<T> Function($$WordListsTableAnnotationComposer a) f,
  ) {
    final $$WordListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordBooksTable,
          WordBook,
          $$WordBooksTableFilterComposer,
          $$WordBooksTableOrderingComposer,
          $$WordBooksTableAnnotationComposer,
          $$WordBooksTableCreateCompanionBuilder,
          $$WordBooksTableUpdateCompanionBuilder,
          (WordBook, $$WordBooksTableReferences),
          WordBook,
          PrefetchHooks Function({bool wordListsRefs})
        > {
  $$WordBooksTableTableManager(_$AppDatabase db, $WordBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> totalWords = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => WordBooksCompanion(
                id: id,
                name: name,
                totalWords: totalWords,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> totalWords = const Value.absent(),
                required int createdAt,
              }) => WordBooksCompanion.insert(
                id: id,
                name: name,
                totalWords: totalWords,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordListsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordListsRefs) db.wordLists],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordListsRefs)
                    await $_getPrefetchedData<
                      WordBook,
                      $WordBooksTable,
                      WordList
                    >(
                      currentTable: table,
                      referencedTable: $$WordBooksTableReferences
                          ._wordListsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordBooksTableReferences(
                            db,
                            table,
                            p0,
                          ).wordListsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordBooksTable,
      WordBook,
      $$WordBooksTableFilterComposer,
      $$WordBooksTableOrderingComposer,
      $$WordBooksTableAnnotationComposer,
      $$WordBooksTableCreateCompanionBuilder,
      $$WordBooksTableUpdateCompanionBuilder,
      (WordBook, $$WordBooksTableReferences),
      WordBook,
      PrefetchHooks Function({bool wordListsRefs})
    >;
typedef $$WordListsTableCreateCompanionBuilder =
    WordListsCompanion Function({
      Value<int> id,
      Value<int?> bookId,
      required String name,
      Value<bool> isPassed,
      Value<double> passThreshold,
      Value<int> wordCount,
      Value<bool> isShuffled,
      required int createdAt,
    });
typedef $$WordListsTableUpdateCompanionBuilder =
    WordListsCompanion Function({
      Value<int> id,
      Value<int?> bookId,
      Value<String> name,
      Value<bool> isPassed,
      Value<double> passThreshold,
      Value<int> wordCount,
      Value<bool> isShuffled,
      Value<int> createdAt,
    });

final class $$WordListsTableReferences
    extends BaseReferences<_$AppDatabase, $WordListsTable, WordList> {
  $$WordListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordBooksTable _bookIdTable(_$AppDatabase db) => db.wordBooks
      .createAlias($_aliasNameGenerator(db.wordLists.bookId, db.wordBooks.id));

  $$WordBooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<int>('book_id');
    if ($_column == null) return null;
    final manager = $$WordBooksTableTableManager(
      $_db,
      $_db.wordBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ListWordsTable, List<ListWord>>
  _listWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.listWords,
    aliasName: $_aliasNameGenerator(db.wordLists.id, db.listWords.listId),
  );

  $$ListWordsTableProcessedTableManager get listWordsRefs {
    final manager = $$ListWordsTableTableManager(
      $_db,
      $_db.listWords,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_listWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PracticeSessionsTable, List<PracticeSession>>
  _practiceSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceSessions,
    aliasName: $_aliasNameGenerator(
      db.wordLists.id,
      db.practiceSessions.listId,
    ),
  );

  $$PracticeSessionsTableProcessedTableManager get practiceSessionsRefs {
    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practiceSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ErrorWordsTable, List<ErrorWord>>
  _errorWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.errorWords,
    aliasName: $_aliasNameGenerator(db.wordLists.id, db.errorWords.listId),
  );

  $$ErrorWordsTableProcessedTableManager get errorWordsRefs {
    final manager = $$ErrorWordsTableTableManager(
      $_db,
      $_db.errorWords,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_errorWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordListsTableFilterComposer
    extends Composer<_$AppDatabase, $WordListsTable> {
  $$WordListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPassed => $composableBuilder(
    column: $table.isPassed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get passThreshold => $composableBuilder(
    column: $table.passThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShuffled => $composableBuilder(
    column: $table.isShuffled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordBooksTableFilterComposer get bookId {
    final $$WordBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableFilterComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> listWordsRefs(
    Expression<bool> Function($$ListWordsTableFilterComposer f) f,
  ) {
    final $$ListWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listWords,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListWordsTableFilterComposer(
            $db: $db,
            $table: $db.listWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> practiceSessionsRefs(
    Expression<bool> Function($$PracticeSessionsTableFilterComposer f) f,
  ) {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> errorWordsRefs(
    Expression<bool> Function($$ErrorWordsTableFilterComposer f) f,
  ) {
    final $$ErrorWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.errorWords,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ErrorWordsTableFilterComposer(
            $db: $db,
            $table: $db.errorWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordListsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordListsTable> {
  $$WordListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPassed => $composableBuilder(
    column: $table.isPassed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get passThreshold => $composableBuilder(
    column: $table.passThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShuffled => $composableBuilder(
    column: $table.isShuffled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordBooksTableOrderingComposer get bookId {
    final $$WordBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableOrderingComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordListsTable> {
  $$WordListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isPassed =>
      $composableBuilder(column: $table.isPassed, builder: (column) => column);

  GeneratedColumn<double> get passThreshold => $composableBuilder(
    column: $table.passThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<bool> get isShuffled => $composableBuilder(
    column: $table.isShuffled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WordBooksTableAnnotationComposer get bookId {
    final $$WordBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> listWordsRefs<T extends Object>(
    Expression<T> Function($$ListWordsTableAnnotationComposer a) f,
  ) {
    final $$ListWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listWords,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.listWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> practiceSessionsRefs<T extends Object>(
    Expression<T> Function($$PracticeSessionsTableAnnotationComposer a) f,
  ) {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> errorWordsRefs<T extends Object>(
    Expression<T> Function($$ErrorWordsTableAnnotationComposer a) f,
  ) {
    final $$ErrorWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.errorWords,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ErrorWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.errorWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordListsTable,
          WordList,
          $$WordListsTableFilterComposer,
          $$WordListsTableOrderingComposer,
          $$WordListsTableAnnotationComposer,
          $$WordListsTableCreateCompanionBuilder,
          $$WordListsTableUpdateCompanionBuilder,
          (WordList, $$WordListsTableReferences),
          WordList,
          PrefetchHooks Function({
            bool bookId,
            bool listWordsRefs,
            bool practiceSessionsRefs,
            bool errorWordsRefs,
          })
        > {
  $$WordListsTableTableManager(_$AppDatabase db, $WordListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isPassed = const Value.absent(),
                Value<double> passThreshold = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<bool> isShuffled = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => WordListsCompanion(
                id: id,
                bookId: bookId,
                name: name,
                isPassed: isPassed,
                passThreshold: passThreshold,
                wordCount: wordCount,
                isShuffled: isShuffled,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                required String name,
                Value<bool> isPassed = const Value.absent(),
                Value<double> passThreshold = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<bool> isShuffled = const Value.absent(),
                required int createdAt,
              }) => WordListsCompanion.insert(
                id: id,
                bookId: bookId,
                name: name,
                isPassed: isPassed,
                passThreshold: passThreshold,
                wordCount: wordCount,
                isShuffled: isShuffled,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bookId = false,
                listWordsRefs = false,
                practiceSessionsRefs = false,
                errorWordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (listWordsRefs) db.listWords,
                    if (practiceSessionsRefs) db.practiceSessions,
                    if (errorWordsRefs) db.errorWords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable: $$WordListsTableReferences
                                        ._bookIdTable(db),
                                    referencedColumn: $$WordListsTableReferences
                                        ._bookIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (listWordsRefs)
                        await $_getPrefetchedData<
                          WordList,
                          $WordListsTable,
                          ListWord
                        >(
                          currentTable: table,
                          referencedTable: $$WordListsTableReferences
                              ._listWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordListsTableReferences(
                                db,
                                table,
                                p0,
                              ).listWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.listId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (practiceSessionsRefs)
                        await $_getPrefetchedData<
                          WordList,
                          $WordListsTable,
                          PracticeSession
                        >(
                          currentTable: table,
                          referencedTable: $$WordListsTableReferences
                              ._practiceSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordListsTableReferences(
                                db,
                                table,
                                p0,
                              ).practiceSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.listId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (errorWordsRefs)
                        await $_getPrefetchedData<
                          WordList,
                          $WordListsTable,
                          ErrorWord
                        >(
                          currentTable: table,
                          referencedTable: $$WordListsTableReferences
                              ._errorWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordListsTableReferences(
                                db,
                                table,
                                p0,
                              ).errorWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.listId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordListsTable,
      WordList,
      $$WordListsTableFilterComposer,
      $$WordListsTableOrderingComposer,
      $$WordListsTableAnnotationComposer,
      $$WordListsTableCreateCompanionBuilder,
      $$WordListsTableUpdateCompanionBuilder,
      (WordList, $$WordListsTableReferences),
      WordList,
      PrefetchHooks Function({
        bool bookId,
        bool listWordsRefs,
        bool practiceSessionsRefs,
        bool errorWordsRefs,
      })
    >;
typedef $$ListWordsTableCreateCompanionBuilder =
    ListWordsCompanion Function({
      Value<int> id,
      required int listId,
      required int wordId,
      required int sortOrder,
      Value<bool> isForgotten,
      Value<int> forgottenCount,
    });
typedef $$ListWordsTableUpdateCompanionBuilder =
    ListWordsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<int> wordId,
      Value<int> sortOrder,
      Value<bool> isForgotten,
      Value<int> forgottenCount,
    });

final class $$ListWordsTableReferences
    extends BaseReferences<_$AppDatabase, $ListWordsTable, ListWord> {
  $$ListWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordListsTable _listIdTable(_$AppDatabase db) => db.wordLists
      .createAlias($_aliasNameGenerator(db.listWords.listId, db.wordLists.id));

  $$WordListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$WordListsTableTableManager(
      $_db,
      $_db.wordLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.listWords.wordId, db.words.id),
  );

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ListWordsTableFilterComposer
    extends Composer<_$AppDatabase, $ListWordsTable> {
  $$ListWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isForgotten => $composableBuilder(
    column: $table.isForgotten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get forgottenCount => $composableBuilder(
    column: $table.forgottenCount,
    builder: (column) => ColumnFilters(column),
  );

  $$WordListsTableFilterComposer get listId {
    final $$WordListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableFilterComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListWordsTable> {
  $$ListWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isForgotten => $composableBuilder(
    column: $table.isForgotten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get forgottenCount => $composableBuilder(
    column: $table.forgottenCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordListsTableOrderingComposer get listId {
    final $$WordListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableOrderingComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListWordsTable> {
  $$ListWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isForgotten => $composableBuilder(
    column: $table.isForgotten,
    builder: (column) => column,
  );

  GeneratedColumn<int> get forgottenCount => $composableBuilder(
    column: $table.forgottenCount,
    builder: (column) => column,
  );

  $$WordListsTableAnnotationComposer get listId {
    final $$WordListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListWordsTable,
          ListWord,
          $$ListWordsTableFilterComposer,
          $$ListWordsTableOrderingComposer,
          $$ListWordsTableAnnotationComposer,
          $$ListWordsTableCreateCompanionBuilder,
          $$ListWordsTableUpdateCompanionBuilder,
          (ListWord, $$ListWordsTableReferences),
          ListWord,
          PrefetchHooks Function({bool listId, bool wordId})
        > {
  $$ListWordsTableTableManager(_$AppDatabase db, $ListWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isForgotten = const Value.absent(),
                Value<int> forgottenCount = const Value.absent(),
              }) => ListWordsCompanion(
                id: id,
                listId: listId,
                wordId: wordId,
                sortOrder: sortOrder,
                isForgotten: isForgotten,
                forgottenCount: forgottenCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required int wordId,
                required int sortOrder,
                Value<bool> isForgotten = const Value.absent(),
                Value<int> forgottenCount = const Value.absent(),
              }) => ListWordsCompanion.insert(
                id: id,
                listId: listId,
                wordId: wordId,
                sortOrder: sortOrder,
                isForgotten: isForgotten,
                forgottenCount: forgottenCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ListWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable: $$ListWordsTableReferences
                                    ._listIdTable(db),
                                referencedColumn: $$ListWordsTableReferences
                                    ._listIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$ListWordsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$ListWordsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ListWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListWordsTable,
      ListWord,
      $$ListWordsTableFilterComposer,
      $$ListWordsTableOrderingComposer,
      $$ListWordsTableAnnotationComposer,
      $$ListWordsTableCreateCompanionBuilder,
      $$ListWordsTableUpdateCompanionBuilder,
      (ListWord, $$ListWordsTableReferences),
      ListWord,
      PrefetchHooks Function({bool listId, bool wordId})
    >;
typedef $$PracticeSessionsTableCreateCompanionBuilder =
    PracticeSessionsCompanion Function({
      Value<int> id,
      required int listId,
      required String mode,
      required int totalCount,
      required int correctCount,
      required double accuracy,
      required int startedAt,
      Value<int?> finishedAt,
    });
typedef $$PracticeSessionsTableUpdateCompanionBuilder =
    PracticeSessionsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<String> mode,
      Value<int> totalCount,
      Value<int> correctCount,
      Value<double> accuracy,
      Value<int> startedAt,
      Value<int?> finishedAt,
    });

final class $$PracticeSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PracticeSessionsTable, PracticeSession> {
  $$PracticeSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordListsTable _listIdTable(_$AppDatabase db) =>
      db.wordLists.createAlias(
        $_aliasNameGenerator(db.practiceSessions.listId, db.wordLists.id),
      );

  $$WordListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$WordListsTableTableManager(
      $_db,
      $_db.wordLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PracticeAnswersTable, List<PracticeAnswer>>
  _practiceAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceAnswers,
    aliasName: $_aliasNameGenerator(
      db.practiceSessions.id,
      db.practiceAnswers.sessionId,
    ),
  );

  $$PracticeAnswersTableProcessedTableManager get practiceAnswersRefs {
    final manager = $$PracticeAnswersTableTableManager(
      $_db,
      $_db.practiceAnswers,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practiceAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PracticeSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordListsTableFilterComposer get listId {
    final $$WordListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableFilterComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> practiceAnswersRefs(
    Expression<bool> Function($$PracticeAnswersTableFilterComposer f) f,
  ) {
    final $$PracticeAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableFilterComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordListsTableOrderingComposer get listId {
    final $$WordListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableOrderingComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$WordListsTableAnnotationComposer get listId {
    final $$WordListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> practiceAnswersRefs<T extends Object>(
    Expression<T> Function($$PracticeAnswersTableAnnotationComposer a) f,
  ) {
    final $$PracticeAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeSessionsTable,
          PracticeSession,
          $$PracticeSessionsTableFilterComposer,
          $$PracticeSessionsTableOrderingComposer,
          $$PracticeSessionsTableAnnotationComposer,
          $$PracticeSessionsTableCreateCompanionBuilder,
          $$PracticeSessionsTableUpdateCompanionBuilder,
          (PracticeSession, $$PracticeSessionsTableReferences),
          PracticeSession,
          PrefetchHooks Function({bool listId, bool practiceAnswersRefs})
        > {
  $$PracticeSessionsTableTableManager(
    _$AppDatabase db,
    $PracticeSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
              }) => PracticeSessionsCompanion(
                id: id,
                listId: listId,
                mode: mode,
                totalCount: totalCount,
                correctCount: correctCount,
                accuracy: accuracy,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required String mode,
                required int totalCount,
                required int correctCount,
                required double accuracy,
                required int startedAt,
                Value<int?> finishedAt = const Value.absent(),
              }) => PracticeSessionsCompanion.insert(
                id: id,
                listId: listId,
                mode: mode,
                totalCount: totalCount,
                correctCount: correctCount,
                accuracy: accuracy,
                startedAt: startedAt,
                finishedAt: finishedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PracticeSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({listId = false, practiceAnswersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (practiceAnswersRefs) db.practiceAnswers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (listId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.listId,
                                    referencedTable:
                                        $$PracticeSessionsTableReferences
                                            ._listIdTable(db),
                                    referencedColumn:
                                        $$PracticeSessionsTableReferences
                                            ._listIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (practiceAnswersRefs)
                        await $_getPrefetchedData<
                          PracticeSession,
                          $PracticeSessionsTable,
                          PracticeAnswer
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._practiceAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).practiceAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PracticeSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeSessionsTable,
      PracticeSession,
      $$PracticeSessionsTableFilterComposer,
      $$PracticeSessionsTableOrderingComposer,
      $$PracticeSessionsTableAnnotationComposer,
      $$PracticeSessionsTableCreateCompanionBuilder,
      $$PracticeSessionsTableUpdateCompanionBuilder,
      (PracticeSession, $$PracticeSessionsTableReferences),
      PracticeSession,
      PrefetchHooks Function({bool listId, bool practiceAnswersRefs})
    >;
typedef $$PracticeAnswersTableCreateCompanionBuilder =
    PracticeAnswersCompanion Function({
      Value<int> id,
      required int sessionId,
      required int wordId,
      required bool isCorrect,
      Value<String?> userAnswer,
      required String correctAnswer,
      required int answeredAt,
    });
typedef $$PracticeAnswersTableUpdateCompanionBuilder =
    PracticeAnswersCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> wordId,
      Value<bool> isCorrect,
      Value<String?> userAnswer,
      Value<String> correctAnswer,
      Value<int> answeredAt,
    });

final class $$PracticeAnswersTableReferences
    extends
        BaseReferences<_$AppDatabase, $PracticeAnswersTable, PracticeAnswer> {
  $$PracticeAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.practiceSessions.createAlias(
        $_aliasNameGenerator(
          db.practiceAnswers.sessionId,
          db.practiceSessions.id,
        ),
      );

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.practiceAnswers.wordId, db.words.id),
  );

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PracticeAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeAnswersTable,
          PracticeAnswer,
          $$PracticeAnswersTableFilterComposer,
          $$PracticeAnswersTableOrderingComposer,
          $$PracticeAnswersTableAnnotationComposer,
          $$PracticeAnswersTableCreateCompanionBuilder,
          $$PracticeAnswersTableUpdateCompanionBuilder,
          (PracticeAnswer, $$PracticeAnswersTableReferences),
          PracticeAnswer,
          PrefetchHooks Function({bool sessionId, bool wordId})
        > {
  $$PracticeAnswersTableTableManager(
    _$AppDatabase db,
    $PracticeAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<String?> userAnswer = const Value.absent(),
                Value<String> correctAnswer = const Value.absent(),
                Value<int> answeredAt = const Value.absent(),
              }) => PracticeAnswersCompanion(
                id: id,
                sessionId: sessionId,
                wordId: wordId,
                isCorrect: isCorrect,
                userAnswer: userAnswer,
                correctAnswer: correctAnswer,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int wordId,
                required bool isCorrect,
                Value<String?> userAnswer = const Value.absent(),
                required String correctAnswer,
                required int answeredAt,
              }) => PracticeAnswersCompanion.insert(
                id: id,
                sessionId: sessionId,
                wordId: wordId,
                isCorrect: isCorrect,
                userAnswer: userAnswer,
                correctAnswer: correctAnswer,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PracticeAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$PracticeAnswersTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$PracticeAnswersTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable:
                                    $$PracticeAnswersTableReferences
                                        ._wordIdTable(db),
                                referencedColumn:
                                    $$PracticeAnswersTableReferences
                                        ._wordIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PracticeAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeAnswersTable,
      PracticeAnswer,
      $$PracticeAnswersTableFilterComposer,
      $$PracticeAnswersTableOrderingComposer,
      $$PracticeAnswersTableAnnotationComposer,
      $$PracticeAnswersTableCreateCompanionBuilder,
      $$PracticeAnswersTableUpdateCompanionBuilder,
      (PracticeAnswer, $$PracticeAnswersTableReferences),
      PracticeAnswer,
      PrefetchHooks Function({bool sessionId, bool wordId})
    >;
typedef $$ErrorWordsTableCreateCompanionBuilder =
    ErrorWordsCompanion Function({
      Value<int> id,
      required int wordId,
      required int listId,
      Value<int> errorCount,
      Value<bool> isResolved,
      Value<int?> nextRetestAt,
      required int createdAt,
    });
typedef $$ErrorWordsTableUpdateCompanionBuilder =
    ErrorWordsCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<int> listId,
      Value<int> errorCount,
      Value<bool> isResolved,
      Value<int?> nextRetestAt,
      Value<int> createdAt,
    });

final class $$ErrorWordsTableReferences
    extends BaseReferences<_$AppDatabase, $ErrorWordsTable, ErrorWord> {
  $$ErrorWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.errorWords.wordId, db.words.id),
  );

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordListsTable _listIdTable(_$AppDatabase db) => db.wordLists
      .createAlias($_aliasNameGenerator(db.errorWords.listId, db.wordLists.id));

  $$WordListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$WordListsTableTableManager(
      $_db,
      $_db.wordLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ErrorWordsTableFilterComposer
    extends Composer<_$AppDatabase, $ErrorWordsTable> {
  $$ErrorWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRetestAt => $composableBuilder(
    column: $table.nextRetestAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordListsTableFilterComposer get listId {
    final $$WordListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableFilterComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ErrorWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ErrorWordsTable> {
  $$ErrorWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRetestAt => $composableBuilder(
    column: $table.nextRetestAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordListsTableOrderingComposer get listId {
    final $$WordListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableOrderingComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ErrorWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ErrorWordsTable> {
  $$ErrorWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextRetestAt => $composableBuilder(
    column: $table.nextRetestAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordListsTableAnnotationComposer get listId {
    final $$WordListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ErrorWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ErrorWordsTable,
          ErrorWord,
          $$ErrorWordsTableFilterComposer,
          $$ErrorWordsTableOrderingComposer,
          $$ErrorWordsTableAnnotationComposer,
          $$ErrorWordsTableCreateCompanionBuilder,
          $$ErrorWordsTableUpdateCompanionBuilder,
          (ErrorWord, $$ErrorWordsTableReferences),
          ErrorWord,
          PrefetchHooks Function({bool wordId, bool listId})
        > {
  $$ErrorWordsTableTableManager(_$AppDatabase db, $ErrorWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ErrorWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ErrorWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ErrorWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<bool> isResolved = const Value.absent(),
                Value<int?> nextRetestAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => ErrorWordsCompanion(
                id: id,
                wordId: wordId,
                listId: listId,
                errorCount: errorCount,
                isResolved: isResolved,
                nextRetestAt: nextRetestAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required int listId,
                Value<int> errorCount = const Value.absent(),
                Value<bool> isResolved = const Value.absent(),
                Value<int?> nextRetestAt = const Value.absent(),
                required int createdAt,
              }) => ErrorWordsCompanion.insert(
                id: id,
                wordId: wordId,
                listId: listId,
                errorCount: errorCount,
                isResolved: isResolved,
                nextRetestAt: nextRetestAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ErrorWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false, listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$ErrorWordsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$ErrorWordsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable: $$ErrorWordsTableReferences
                                    ._listIdTable(db),
                                referencedColumn: $$ErrorWordsTableReferences
                                    ._listIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ErrorWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ErrorWordsTable,
      ErrorWord,
      $$ErrorWordsTableFilterComposer,
      $$ErrorWordsTableOrderingComposer,
      $$ErrorWordsTableAnnotationComposer,
      $$ErrorWordsTableCreateCompanionBuilder,
      $$ErrorWordsTableUpdateCompanionBuilder,
      (ErrorWord, $$ErrorWordsTableReferences),
      ErrorWord,
      PrefetchHooks Function({bool wordId, bool listId})
    >;
typedef $$AiContentTableCreateCompanionBuilder =
    AiContentCompanion Function({
      Value<int> id,
      required int wordId,
      required String contentType,
      required String englishContent,
      required String chineseTranslation,
      required int generatedAt,
    });
typedef $$AiContentTableUpdateCompanionBuilder =
    AiContentCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<String> contentType,
      Value<String> englishContent,
      Value<String> chineseTranslation,
      Value<int> generatedAt,
    });

final class $$AiContentTableReferences
    extends BaseReferences<_$AppDatabase, $AiContentTable, AiContentData> {
  $$AiContentTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.aiContent.wordId, db.words.id),
  );

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AiContentTableFilterComposer
    extends Composer<_$AppDatabase, $AiContentTable> {
  $$AiContentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishContent => $composableBuilder(
    column: $table.englishContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chineseTranslation => $composableBuilder(
    column: $table.chineseTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiContentTableOrderingComposer
    extends Composer<_$AppDatabase, $AiContentTable> {
  $$AiContentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishContent => $composableBuilder(
    column: $table.englishContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chineseTranslation => $composableBuilder(
    column: $table.chineseTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiContentTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiContentTable> {
  $$AiContentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishContent => $composableBuilder(
    column: $table.englishContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chineseTranslation => $composableBuilder(
    column: $table.chineseTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AiContentTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiContentTable,
          AiContentData,
          $$AiContentTableFilterComposer,
          $$AiContentTableOrderingComposer,
          $$AiContentTableAnnotationComposer,
          $$AiContentTableCreateCompanionBuilder,
          $$AiContentTableUpdateCompanionBuilder,
          (AiContentData, $$AiContentTableReferences),
          AiContentData,
          PrefetchHooks Function({bool wordId})
        > {
  $$AiContentTableTableManager(_$AppDatabase db, $AiContentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiContentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiContentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiContentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> englishContent = const Value.absent(),
                Value<String> chineseTranslation = const Value.absent(),
                Value<int> generatedAt = const Value.absent(),
              }) => AiContentCompanion(
                id: id,
                wordId: wordId,
                contentType: contentType,
                englishContent: englishContent,
                chineseTranslation: chineseTranslation,
                generatedAt: generatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required String contentType,
                required String englishContent,
                required String chineseTranslation,
                required int generatedAt,
              }) => AiContentCompanion.insert(
                id: id,
                wordId: wordId,
                contentType: contentType,
                englishContent: englishContent,
                chineseTranslation: chineseTranslation,
                generatedAt: generatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiContentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$AiContentTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$AiContentTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AiContentTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiContentTable,
      AiContentData,
      $$AiContentTableFilterComposer,
      $$AiContentTableOrderingComposer,
      $$AiContentTableAnnotationComposer,
      $$AiContentTableCreateCompanionBuilder,
      $$AiContentTableUpdateCompanionBuilder,
      (AiContentData, $$AiContentTableReferences),
      AiContentData,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$TtsUsageRecordsTableCreateCompanionBuilder =
    TtsUsageRecordsCompanion Function({
      Value<int> id,
      required String provider,
      required String action,
      required String textValue,
      required String language,
      Value<String?> model,
      Value<String?> voice,
      Value<String?> resourceId,
      Value<int?> chargedCharacters,
      Value<int?> audioBytes,
      Value<int?> durationMs,
      Value<String?> requestId,
      Value<String?> logId,
      required String status,
      Value<String?> errorMessage,
      required int createdAt,
    });
typedef $$TtsUsageRecordsTableUpdateCompanionBuilder =
    TtsUsageRecordsCompanion Function({
      Value<int> id,
      Value<String> provider,
      Value<String> action,
      Value<String> textValue,
      Value<String> language,
      Value<String?> model,
      Value<String?> voice,
      Value<String?> resourceId,
      Value<int?> chargedCharacters,
      Value<int?> audioBytes,
      Value<int?> durationMs,
      Value<String?> requestId,
      Value<String?> logId,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> createdAt,
    });

class $$TtsUsageRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TtsUsageRecordsTable> {
  $$TtsUsageRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voice => $composableBuilder(
    column: $table.voice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargedCharacters => $composableBuilder(
    column: $table.chargedCharacters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TtsUsageRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsUsageRecordsTable> {
  $$TtsUsageRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voice => $composableBuilder(
    column: $table.voice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargedCharacters => $composableBuilder(
    column: $table.chargedCharacters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TtsUsageRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsUsageRecordsTable> {
  $$TtsUsageRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get voice =>
      $composableBuilder(column: $table.voice, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargedCharacters => $composableBuilder(
    column: $table.chargedCharacters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TtsUsageRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TtsUsageRecordsTable,
          TtsUsageRecord,
          $$TtsUsageRecordsTableFilterComposer,
          $$TtsUsageRecordsTableOrderingComposer,
          $$TtsUsageRecordsTableAnnotationComposer,
          $$TtsUsageRecordsTableCreateCompanionBuilder,
          $$TtsUsageRecordsTableUpdateCompanionBuilder,
          (
            TtsUsageRecord,
            BaseReferences<
              _$AppDatabase,
              $TtsUsageRecordsTable,
              TtsUsageRecord
            >,
          ),
          TtsUsageRecord,
          PrefetchHooks Function()
        > {
  $$TtsUsageRecordsTableTableManager(
    _$AppDatabase db,
    $TtsUsageRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsUsageRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsUsageRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsUsageRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> voice = const Value.absent(),
                Value<String?> resourceId = const Value.absent(),
                Value<int?> chargedCharacters = const Value.absent(),
                Value<int?> audioBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> logId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => TtsUsageRecordsCompanion(
                id: id,
                provider: provider,
                action: action,
                textValue: textValue,
                language: language,
                model: model,
                voice: voice,
                resourceId: resourceId,
                chargedCharacters: chargedCharacters,
                audioBytes: audioBytes,
                durationMs: durationMs,
                requestId: requestId,
                logId: logId,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String provider,
                required String action,
                required String textValue,
                required String language,
                Value<String?> model = const Value.absent(),
                Value<String?> voice = const Value.absent(),
                Value<String?> resourceId = const Value.absent(),
                Value<int?> chargedCharacters = const Value.absent(),
                Value<int?> audioBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> logId = const Value.absent(),
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                required int createdAt,
              }) => TtsUsageRecordsCompanion.insert(
                id: id,
                provider: provider,
                action: action,
                textValue: textValue,
                language: language,
                model: model,
                voice: voice,
                resourceId: resourceId,
                chargedCharacters: chargedCharacters,
                audioBytes: audioBytes,
                durationMs: durationMs,
                requestId: requestId,
                logId: logId,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TtsUsageRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TtsUsageRecordsTable,
      TtsUsageRecord,
      $$TtsUsageRecordsTableFilterComposer,
      $$TtsUsageRecordsTableOrderingComposer,
      $$TtsUsageRecordsTableAnnotationComposer,
      $$TtsUsageRecordsTableCreateCompanionBuilder,
      $$TtsUsageRecordsTableUpdateCompanionBuilder,
      (
        TtsUsageRecord,
        BaseReferences<_$AppDatabase, $TtsUsageRecordsTable, TtsUsageRecord>,
      ),
      TtsUsageRecord,
      PrefetchHooks Function()
    >;
typedef $$TtsCacheRecordsTableCreateCompanionBuilder =
    TtsCacheRecordsCompanion Function({
      Value<int> id,
      required String provider,
      required String language,
      required String textValue,
      required String cacheKey,
      required String status,
      Value<String?> cachePath,
      Value<String?> errorMessage,
      Value<int?> audioBytes,
      Value<int?> chargedCharacters,
      required int updatedAt,
    });
typedef $$TtsCacheRecordsTableUpdateCompanionBuilder =
    TtsCacheRecordsCompanion Function({
      Value<int> id,
      Value<String> provider,
      Value<String> language,
      Value<String> textValue,
      Value<String> cacheKey,
      Value<String> status,
      Value<String?> cachePath,
      Value<String?> errorMessage,
      Value<int?> audioBytes,
      Value<int?> chargedCharacters,
      Value<int> updatedAt,
    });

class $$TtsCacheRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TtsCacheRecordsTable> {
  $$TtsCacheRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachePath => $composableBuilder(
    column: $table.cachePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargedCharacters => $composableBuilder(
    column: $table.chargedCharacters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TtsCacheRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsCacheRecordsTable> {
  $$TtsCacheRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachePath => $composableBuilder(
    column: $table.cachePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargedCharacters => $composableBuilder(
    column: $table.chargedCharacters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TtsCacheRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsCacheRecordsTable> {
  $$TtsCacheRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get cachePath =>
      $composableBuilder(column: $table.cachePath, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargedCharacters => $composableBuilder(
    column: $table.chargedCharacters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TtsCacheRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TtsCacheRecordsTable,
          TtsCacheRecord,
          $$TtsCacheRecordsTableFilterComposer,
          $$TtsCacheRecordsTableOrderingComposer,
          $$TtsCacheRecordsTableAnnotationComposer,
          $$TtsCacheRecordsTableCreateCompanionBuilder,
          $$TtsCacheRecordsTableUpdateCompanionBuilder,
          (
            TtsCacheRecord,
            BaseReferences<
              _$AppDatabase,
              $TtsCacheRecordsTable,
              TtsCacheRecord
            >,
          ),
          TtsCacheRecord,
          PrefetchHooks Function()
        > {
  $$TtsCacheRecordsTableTableManager(
    _$AppDatabase db,
    $TtsCacheRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsCacheRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsCacheRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsCacheRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> cachePath = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> audioBytes = const Value.absent(),
                Value<int?> chargedCharacters = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => TtsCacheRecordsCompanion(
                id: id,
                provider: provider,
                language: language,
                textValue: textValue,
                cacheKey: cacheKey,
                status: status,
                cachePath: cachePath,
                errorMessage: errorMessage,
                audioBytes: audioBytes,
                chargedCharacters: chargedCharacters,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String provider,
                required String language,
                required String textValue,
                required String cacheKey,
                required String status,
                Value<String?> cachePath = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> audioBytes = const Value.absent(),
                Value<int?> chargedCharacters = const Value.absent(),
                required int updatedAt,
              }) => TtsCacheRecordsCompanion.insert(
                id: id,
                provider: provider,
                language: language,
                textValue: textValue,
                cacheKey: cacheKey,
                status: status,
                cachePath: cachePath,
                errorMessage: errorMessage,
                audioBytes: audioBytes,
                chargedCharacters: chargedCharacters,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TtsCacheRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TtsCacheRecordsTable,
      TtsCacheRecord,
      $$TtsCacheRecordsTableFilterComposer,
      $$TtsCacheRecordsTableOrderingComposer,
      $$TtsCacheRecordsTableAnnotationComposer,
      $$TtsCacheRecordsTableCreateCompanionBuilder,
      $$TtsCacheRecordsTableUpdateCompanionBuilder,
      (
        TtsCacheRecord,
        BaseReferences<_$AppDatabase, $TtsCacheRecordsTable, TtsCacheRecord>,
      ),
      TtsCacheRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordBooksTableTableManager get wordBooks =>
      $$WordBooksTableTableManager(_db, _db.wordBooks);
  $$WordListsTableTableManager get wordLists =>
      $$WordListsTableTableManager(_db, _db.wordLists);
  $$ListWordsTableTableManager get listWords =>
      $$ListWordsTableTableManager(_db, _db.listWords);
  $$PracticeSessionsTableTableManager get practiceSessions =>
      $$PracticeSessionsTableTableManager(_db, _db.practiceSessions);
  $$PracticeAnswersTableTableManager get practiceAnswers =>
      $$PracticeAnswersTableTableManager(_db, _db.practiceAnswers);
  $$ErrorWordsTableTableManager get errorWords =>
      $$ErrorWordsTableTableManager(_db, _db.errorWords);
  $$AiContentTableTableManager get aiContent =>
      $$AiContentTableTableManager(_db, _db.aiContent);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$TtsUsageRecordsTableTableManager get ttsUsageRecords =>
      $$TtsUsageRecordsTableTableManager(_db, _db.ttsUsageRecords);
  $$TtsCacheRecordsTableTableManager get ttsCacheRecords =>
      $$TtsCacheRecordsTableTableManager(_db, _db.ttsCacheRecords);
}
