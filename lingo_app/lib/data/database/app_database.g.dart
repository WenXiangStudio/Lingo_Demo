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
  static const VerificationMeta _isCueMemoryMeta = const VerificationMeta(
    'isCueMemory',
  );
  @override
  late final GeneratedColumn<bool> isCueMemory = GeneratedColumn<bool>(
    'is_cue_memory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cue_memory" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cueMemoryCountMeta = const VerificationMeta(
    'cueMemoryCount',
  );
  @override
  late final GeneratedColumn<int> cueMemoryCount = GeneratedColumn<int>(
    'cue_memory_count',
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
    isCueMemory,
    cueMemoryCount,
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
    if (data.containsKey('is_cue_memory')) {
      context.handle(
        _isCueMemoryMeta,
        isCueMemory.isAcceptableOrUnknown(
          data['is_cue_memory']!,
          _isCueMemoryMeta,
        ),
      );
    }
    if (data.containsKey('cue_memory_count')) {
      context.handle(
        _cueMemoryCountMeta,
        cueMemoryCount.isAcceptableOrUnknown(
          data['cue_memory_count']!,
          _cueMemoryCountMeta,
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
      isCueMemory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cue_memory'],
      )!,
      cueMemoryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cue_memory_count'],
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
  final bool isCueMemory;
  final int cueMemoryCount;
  const ListWord({
    required this.id,
    required this.listId,
    required this.wordId,
    required this.sortOrder,
    required this.isForgotten,
    required this.forgottenCount,
    required this.isCueMemory,
    required this.cueMemoryCount,
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
    map['is_cue_memory'] = Variable<bool>(isCueMemory);
    map['cue_memory_count'] = Variable<int>(cueMemoryCount);
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
      isCueMemory: Value(isCueMemory),
      cueMemoryCount: Value(cueMemoryCount),
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
      isCueMemory: serializer.fromJson<bool>(json['isCueMemory']),
      cueMemoryCount: serializer.fromJson<int>(json['cueMemoryCount']),
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
      'isCueMemory': serializer.toJson<bool>(isCueMemory),
      'cueMemoryCount': serializer.toJson<int>(cueMemoryCount),
    };
  }

  ListWord copyWith({
    int? id,
    int? listId,
    int? wordId,
    int? sortOrder,
    bool? isForgotten,
    int? forgottenCount,
    bool? isCueMemory,
    int? cueMemoryCount,
  }) => ListWord(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    wordId: wordId ?? this.wordId,
    sortOrder: sortOrder ?? this.sortOrder,
    isForgotten: isForgotten ?? this.isForgotten,
    forgottenCount: forgottenCount ?? this.forgottenCount,
    isCueMemory: isCueMemory ?? this.isCueMemory,
    cueMemoryCount: cueMemoryCount ?? this.cueMemoryCount,
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
      isCueMemory: data.isCueMemory.present
          ? data.isCueMemory.value
          : this.isCueMemory,
      cueMemoryCount: data.cueMemoryCount.present
          ? data.cueMemoryCount.value
          : this.cueMemoryCount,
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
          ..write('forgottenCount: $forgottenCount, ')
          ..write('isCueMemory: $isCueMemory, ')
          ..write('cueMemoryCount: $cueMemoryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    wordId,
    sortOrder,
    isForgotten,
    forgottenCount,
    isCueMemory,
    cueMemoryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListWord &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.wordId == this.wordId &&
          other.sortOrder == this.sortOrder &&
          other.isForgotten == this.isForgotten &&
          other.forgottenCount == this.forgottenCount &&
          other.isCueMemory == this.isCueMemory &&
          other.cueMemoryCount == this.cueMemoryCount);
}

class ListWordsCompanion extends UpdateCompanion<ListWord> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int> wordId;
  final Value<int> sortOrder;
  final Value<bool> isForgotten;
  final Value<int> forgottenCount;
  final Value<bool> isCueMemory;
  final Value<int> cueMemoryCount;
  const ListWordsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isForgotten = const Value.absent(),
    this.forgottenCount = const Value.absent(),
    this.isCueMemory = const Value.absent(),
    this.cueMemoryCount = const Value.absent(),
  });
  ListWordsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required int wordId,
    required int sortOrder,
    this.isForgotten = const Value.absent(),
    this.forgottenCount = const Value.absent(),
    this.isCueMemory = const Value.absent(),
    this.cueMemoryCount = const Value.absent(),
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
    Expression<bool>? isCueMemory,
    Expression<int>? cueMemoryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (wordId != null) 'word_id': wordId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isForgotten != null) 'is_forgotten': isForgotten,
      if (forgottenCount != null) 'forgotten_count': forgottenCount,
      if (isCueMemory != null) 'is_cue_memory': isCueMemory,
      if (cueMemoryCount != null) 'cue_memory_count': cueMemoryCount,
    });
  }

  ListWordsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<int>? wordId,
    Value<int>? sortOrder,
    Value<bool>? isForgotten,
    Value<int>? forgottenCount,
    Value<bool>? isCueMemory,
    Value<int>? cueMemoryCount,
  }) {
    return ListWordsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      wordId: wordId ?? this.wordId,
      sortOrder: sortOrder ?? this.sortOrder,
      isForgotten: isForgotten ?? this.isForgotten,
      forgottenCount: forgottenCount ?? this.forgottenCount,
      isCueMemory: isCueMemory ?? this.isCueMemory,
      cueMemoryCount: cueMemoryCount ?? this.cueMemoryCount,
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
    if (isCueMemory.present) {
      map['is_cue_memory'] = Variable<bool>(isCueMemory.value);
    }
    if (cueMemoryCount.present) {
      map['cue_memory_count'] = Variable<int>(cueMemoryCount.value);
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
          ..write('forgottenCount: $forgottenCount, ')
          ..write('isCueMemory: $isCueMemory, ')
          ..write('cueMemoryCount: $cueMemoryCount')
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
  static const VerificationMeta _sessionKindMeta = const VerificationMeta(
    'sessionKind',
  );
  @override
  late final GeneratedColumn<String> sessionKind = GeneratedColumn<String>(
    'session_kind',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(PracticeSessionKind.memorization),
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
    sessionKind,
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
    if (data.containsKey('session_kind')) {
      context.handle(
        _sessionKindMeta,
        sessionKind.isAcceptableOrUnknown(
          data['session_kind']!,
          _sessionKindMeta,
        ),
      );
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
      sessionKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_kind'],
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
  final String sessionKind;
  final int totalCount;
  final int correctCount;
  final double accuracy;
  final int startedAt;
  final int? finishedAt;
  const PracticeSession({
    required this.id,
    required this.listId,
    required this.mode,
    required this.sessionKind,
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
    map['session_kind'] = Variable<String>(sessionKind);
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
      sessionKind: Value(sessionKind),
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
      sessionKind: serializer.fromJson<String>(json['sessionKind']),
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
      'sessionKind': serializer.toJson<String>(sessionKind),
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
    String? sessionKind,
    int? totalCount,
    int? correctCount,
    double? accuracy,
    int? startedAt,
    Value<int?> finishedAt = const Value.absent(),
  }) => PracticeSession(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    mode: mode ?? this.mode,
    sessionKind: sessionKind ?? this.sessionKind,
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
      sessionKind: data.sessionKind.present
          ? data.sessionKind.value
          : this.sessionKind,
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
          ..write('sessionKind: $sessionKind, ')
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
    sessionKind,
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
          other.sessionKind == this.sessionKind &&
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
  final Value<String> sessionKind;
  final Value<int> totalCount;
  final Value<int> correctCount;
  final Value<double> accuracy;
  final Value<int> startedAt;
  final Value<int?> finishedAt;
  const PracticeSessionsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.mode = const Value.absent(),
    this.sessionKind = const Value.absent(),
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
    this.sessionKind = const Value.absent(),
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
    Expression<String>? sessionKind,
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
      if (sessionKind != null) 'session_kind': sessionKind,
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
    Value<String>? sessionKind,
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
      sessionKind: sessionKind ?? this.sessionKind,
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
    if (sessionKind.present) {
      map['session_kind'] = Variable<String>(sessionKind.value);
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
          ..write('sessionKind: $sessionKind, ')
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

class $LearningActivityRecordsTable extends LearningActivityRecords
    with TableInfo<$LearningActivityRecordsTable, LearningActivityRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningActivityRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
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
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _turnCountMeta = const VerificationMeta(
    'turnCount',
  );
  @override
  late final GeneratedColumn<int> turnCount = GeneratedColumn<int>(
    'turn_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetWordUseCountMeta =
      const VerificationMeta('targetWordUseCount');
  @override
  late final GeneratedColumn<int> targetWordUseCount = GeneratedColumn<int>(
    'target_word_use_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _naturalnessAverageMeta =
      const VerificationMeta('naturalnessAverage');
  @override
  late final GeneratedColumn<double> naturalnessAverage =
      GeneratedColumn<double>(
        'naturalness_average',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _contextFitAverageMeta = const VerificationMeta(
    'contextFitAverage',
  );
  @override
  late final GeneratedColumn<double> contextFitAverage =
      GeneratedColumn<double>(
        'context_fit_average',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _skillRunCountMeta = const VerificationMeta(
    'skillRunCount',
  );
  @override
  late final GeneratedColumn<int> skillRunCount = GeneratedColumn<int>(
    'skill_run_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _involvedWordCountMeta = const VerificationMeta(
    'involvedWordCount',
  );
  @override
  late final GeneratedColumn<int> involvedWordCount = GeneratedColumn<int>(
    'involved_word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityType,
    subtype,
    status,
    startedAt,
    finishedAt,
    questionCount,
    correctCount,
    accuracy,
    turnCount,
    targetWordUseCount,
    naturalnessAverage,
    contextFitAverage,
    skillRunCount,
    involvedWordCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_activity_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningActivityRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
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
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('turn_count')) {
      context.handle(
        _turnCountMeta,
        turnCount.isAcceptableOrUnknown(data['turn_count']!, _turnCountMeta),
      );
    }
    if (data.containsKey('target_word_use_count')) {
      context.handle(
        _targetWordUseCountMeta,
        targetWordUseCount.isAcceptableOrUnknown(
          data['target_word_use_count']!,
          _targetWordUseCountMeta,
        ),
      );
    }
    if (data.containsKey('naturalness_average')) {
      context.handle(
        _naturalnessAverageMeta,
        naturalnessAverage.isAcceptableOrUnknown(
          data['naturalness_average']!,
          _naturalnessAverageMeta,
        ),
      );
    }
    if (data.containsKey('context_fit_average')) {
      context.handle(
        _contextFitAverageMeta,
        contextFitAverage.isAcceptableOrUnknown(
          data['context_fit_average']!,
          _contextFitAverageMeta,
        ),
      );
    }
    if (data.containsKey('skill_run_count')) {
      context.handle(
        _skillRunCountMeta,
        skillRunCount.isAcceptableOrUnknown(
          data['skill_run_count']!,
          _skillRunCountMeta,
        ),
      );
    }
    if (data.containsKey('involved_word_count')) {
      context.handle(
        _involvedWordCountMeta,
        involvedWordCount.isAcceptableOrUnknown(
          data['involved_word_count']!,
          _involvedWordCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningActivityRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningActivityRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      turnCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_count'],
      )!,
      targetWordUseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_word_use_count'],
      )!,
      naturalnessAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}naturalness_average'],
      ),
      contextFitAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}context_fit_average'],
      ),
      skillRunCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skill_run_count'],
      )!,
      involvedWordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}involved_word_count'],
      )!,
    );
  }

  @override
  $LearningActivityRecordsTable createAlias(String alias) {
    return $LearningActivityRecordsTable(attachedDatabase, alias);
  }
}

class LearningActivityRecord extends DataClass
    implements Insertable<LearningActivityRecord> {
  final int id;
  final String activityType;
  final String? subtype;
  final String status;
  final int startedAt;
  final int? finishedAt;
  final int questionCount;
  final int correctCount;
  final double? accuracy;
  final int turnCount;
  final int targetWordUseCount;
  final double? naturalnessAverage;
  final double? contextFitAverage;
  final int skillRunCount;
  final int involvedWordCount;
  const LearningActivityRecord({
    required this.id,
    required this.activityType,
    this.subtype,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    required this.questionCount,
    required this.correctCount,
    this.accuracy,
    required this.turnCount,
    required this.targetWordUseCount,
    this.naturalnessAverage,
    this.contextFitAverage,
    required this.skillRunCount,
    required this.involvedWordCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_type'] = Variable<String>(activityType);
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(finishedAt);
    }
    map['question_count'] = Variable<int>(questionCount);
    map['correct_count'] = Variable<int>(correctCount);
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    map['turn_count'] = Variable<int>(turnCount);
    map['target_word_use_count'] = Variable<int>(targetWordUseCount);
    if (!nullToAbsent || naturalnessAverage != null) {
      map['naturalness_average'] = Variable<double>(naturalnessAverage);
    }
    if (!nullToAbsent || contextFitAverage != null) {
      map['context_fit_average'] = Variable<double>(contextFitAverage);
    }
    map['skill_run_count'] = Variable<int>(skillRunCount);
    map['involved_word_count'] = Variable<int>(involvedWordCount);
    return map;
  }

  LearningActivityRecordsCompanion toCompanion(bool nullToAbsent) {
    return LearningActivityRecordsCompanion(
      id: Value(id),
      activityType: Value(activityType),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      status: Value(status),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      questionCount: Value(questionCount),
      correctCount: Value(correctCount),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      turnCount: Value(turnCount),
      targetWordUseCount: Value(targetWordUseCount),
      naturalnessAverage: naturalnessAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(naturalnessAverage),
      contextFitAverage: contextFitAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(contextFitAverage),
      skillRunCount: Value(skillRunCount),
      involvedWordCount: Value(involvedWordCount),
    );
  }

  factory LearningActivityRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningActivityRecord(
      id: serializer.fromJson<int>(json['id']),
      activityType: serializer.fromJson<String>(json['activityType']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      finishedAt: serializer.fromJson<int?>(json['finishedAt']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      turnCount: serializer.fromJson<int>(json['turnCount']),
      targetWordUseCount: serializer.fromJson<int>(json['targetWordUseCount']),
      naturalnessAverage: serializer.fromJson<double?>(
        json['naturalnessAverage'],
      ),
      contextFitAverage: serializer.fromJson<double?>(
        json['contextFitAverage'],
      ),
      skillRunCount: serializer.fromJson<int>(json['skillRunCount']),
      involvedWordCount: serializer.fromJson<int>(json['involvedWordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityType': serializer.toJson<String>(activityType),
      'subtype': serializer.toJson<String?>(subtype),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'finishedAt': serializer.toJson<int?>(finishedAt),
      'questionCount': serializer.toJson<int>(questionCount),
      'correctCount': serializer.toJson<int>(correctCount),
      'accuracy': serializer.toJson<double?>(accuracy),
      'turnCount': serializer.toJson<int>(turnCount),
      'targetWordUseCount': serializer.toJson<int>(targetWordUseCount),
      'naturalnessAverage': serializer.toJson<double?>(naturalnessAverage),
      'contextFitAverage': serializer.toJson<double?>(contextFitAverage),
      'skillRunCount': serializer.toJson<int>(skillRunCount),
      'involvedWordCount': serializer.toJson<int>(involvedWordCount),
    };
  }

  LearningActivityRecord copyWith({
    int? id,
    String? activityType,
    Value<String?> subtype = const Value.absent(),
    String? status,
    int? startedAt,
    Value<int?> finishedAt = const Value.absent(),
    int? questionCount,
    int? correctCount,
    Value<double?> accuracy = const Value.absent(),
    int? turnCount,
    int? targetWordUseCount,
    Value<double?> naturalnessAverage = const Value.absent(),
    Value<double?> contextFitAverage = const Value.absent(),
    int? skillRunCount,
    int? involvedWordCount,
  }) => LearningActivityRecord(
    id: id ?? this.id,
    activityType: activityType ?? this.activityType,
    subtype: subtype.present ? subtype.value : this.subtype,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    questionCount: questionCount ?? this.questionCount,
    correctCount: correctCount ?? this.correctCount,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    turnCount: turnCount ?? this.turnCount,
    targetWordUseCount: targetWordUseCount ?? this.targetWordUseCount,
    naturalnessAverage: naturalnessAverage.present
        ? naturalnessAverage.value
        : this.naturalnessAverage,
    contextFitAverage: contextFitAverage.present
        ? contextFitAverage.value
        : this.contextFitAverage,
    skillRunCount: skillRunCount ?? this.skillRunCount,
    involvedWordCount: involvedWordCount ?? this.involvedWordCount,
  );
  LearningActivityRecord copyWithCompanion(
    LearningActivityRecordsCompanion data,
  ) {
    return LearningActivityRecord(
      id: data.id.present ? data.id.value : this.id,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      turnCount: data.turnCount.present ? data.turnCount.value : this.turnCount,
      targetWordUseCount: data.targetWordUseCount.present
          ? data.targetWordUseCount.value
          : this.targetWordUseCount,
      naturalnessAverage: data.naturalnessAverage.present
          ? data.naturalnessAverage.value
          : this.naturalnessAverage,
      contextFitAverage: data.contextFitAverage.present
          ? data.contextFitAverage.value
          : this.contextFitAverage,
      skillRunCount: data.skillRunCount.present
          ? data.skillRunCount.value
          : this.skillRunCount,
      involvedWordCount: data.involvedWordCount.present
          ? data.involvedWordCount.value
          : this.involvedWordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningActivityRecord(')
          ..write('id: $id, ')
          ..write('activityType: $activityType, ')
          ..write('subtype: $subtype, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('questionCount: $questionCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('accuracy: $accuracy, ')
          ..write('turnCount: $turnCount, ')
          ..write('targetWordUseCount: $targetWordUseCount, ')
          ..write('naturalnessAverage: $naturalnessAverage, ')
          ..write('contextFitAverage: $contextFitAverage, ')
          ..write('skillRunCount: $skillRunCount, ')
          ..write('involvedWordCount: $involvedWordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityType,
    subtype,
    status,
    startedAt,
    finishedAt,
    questionCount,
    correctCount,
    accuracy,
    turnCount,
    targetWordUseCount,
    naturalnessAverage,
    contextFitAverage,
    skillRunCount,
    involvedWordCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningActivityRecord &&
          other.id == this.id &&
          other.activityType == this.activityType &&
          other.subtype == this.subtype &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.questionCount == this.questionCount &&
          other.correctCount == this.correctCount &&
          other.accuracy == this.accuracy &&
          other.turnCount == this.turnCount &&
          other.targetWordUseCount == this.targetWordUseCount &&
          other.naturalnessAverage == this.naturalnessAverage &&
          other.contextFitAverage == this.contextFitAverage &&
          other.skillRunCount == this.skillRunCount &&
          other.involvedWordCount == this.involvedWordCount);
}

class LearningActivityRecordsCompanion
    extends UpdateCompanion<LearningActivityRecord> {
  final Value<int> id;
  final Value<String> activityType;
  final Value<String?> subtype;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int?> finishedAt;
  final Value<int> questionCount;
  final Value<int> correctCount;
  final Value<double?> accuracy;
  final Value<int> turnCount;
  final Value<int> targetWordUseCount;
  final Value<double?> naturalnessAverage;
  final Value<double?> contextFitAverage;
  final Value<int> skillRunCount;
  final Value<int> involvedWordCount;
  const LearningActivityRecordsCompanion({
    this.id = const Value.absent(),
    this.activityType = const Value.absent(),
    this.subtype = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.turnCount = const Value.absent(),
    this.targetWordUseCount = const Value.absent(),
    this.naturalnessAverage = const Value.absent(),
    this.contextFitAverage = const Value.absent(),
    this.skillRunCount = const Value.absent(),
    this.involvedWordCount = const Value.absent(),
  });
  LearningActivityRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String activityType,
    this.subtype = const Value.absent(),
    required String status,
    required int startedAt,
    this.finishedAt = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.turnCount = const Value.absent(),
    this.targetWordUseCount = const Value.absent(),
    this.naturalnessAverage = const Value.absent(),
    this.contextFitAverage = const Value.absent(),
    this.skillRunCount = const Value.absent(),
    this.involvedWordCount = const Value.absent(),
  }) : activityType = Value(activityType),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<LearningActivityRecord> custom({
    Expression<int>? id,
    Expression<String>? activityType,
    Expression<String>? subtype,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? finishedAt,
    Expression<int>? questionCount,
    Expression<int>? correctCount,
    Expression<double>? accuracy,
    Expression<int>? turnCount,
    Expression<int>? targetWordUseCount,
    Expression<double>? naturalnessAverage,
    Expression<double>? contextFitAverage,
    Expression<int>? skillRunCount,
    Expression<int>? involvedWordCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityType != null) 'activity_type': activityType,
      if (subtype != null) 'subtype': subtype,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (questionCount != null) 'question_count': questionCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (accuracy != null) 'accuracy': accuracy,
      if (turnCount != null) 'turn_count': turnCount,
      if (targetWordUseCount != null)
        'target_word_use_count': targetWordUseCount,
      if (naturalnessAverage != null) 'naturalness_average': naturalnessAverage,
      if (contextFitAverage != null) 'context_fit_average': contextFitAverage,
      if (skillRunCount != null) 'skill_run_count': skillRunCount,
      if (involvedWordCount != null) 'involved_word_count': involvedWordCount,
    });
  }

  LearningActivityRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? activityType,
    Value<String?>? subtype,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int?>? finishedAt,
    Value<int>? questionCount,
    Value<int>? correctCount,
    Value<double?>? accuracy,
    Value<int>? turnCount,
    Value<int>? targetWordUseCount,
    Value<double?>? naturalnessAverage,
    Value<double?>? contextFitAverage,
    Value<int>? skillRunCount,
    Value<int>? involvedWordCount,
  }) {
    return LearningActivityRecordsCompanion(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      subtype: subtype ?? this.subtype,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      questionCount: questionCount ?? this.questionCount,
      correctCount: correctCount ?? this.correctCount,
      accuracy: accuracy ?? this.accuracy,
      turnCount: turnCount ?? this.turnCount,
      targetWordUseCount: targetWordUseCount ?? this.targetWordUseCount,
      naturalnessAverage: naturalnessAverage ?? this.naturalnessAverage,
      contextFitAverage: contextFitAverage ?? this.contextFitAverage,
      skillRunCount: skillRunCount ?? this.skillRunCount,
      involvedWordCount: involvedWordCount ?? this.involvedWordCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (turnCount.present) {
      map['turn_count'] = Variable<int>(turnCount.value);
    }
    if (targetWordUseCount.present) {
      map['target_word_use_count'] = Variable<int>(targetWordUseCount.value);
    }
    if (naturalnessAverage.present) {
      map['naturalness_average'] = Variable<double>(naturalnessAverage.value);
    }
    if (contextFitAverage.present) {
      map['context_fit_average'] = Variable<double>(contextFitAverage.value);
    }
    if (skillRunCount.present) {
      map['skill_run_count'] = Variable<int>(skillRunCount.value);
    }
    if (involvedWordCount.present) {
      map['involved_word_count'] = Variable<int>(involvedWordCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningActivityRecordsCompanion(')
          ..write('id: $id, ')
          ..write('activityType: $activityType, ')
          ..write('subtype: $subtype, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('questionCount: $questionCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('accuracy: $accuracy, ')
          ..write('turnCount: $turnCount, ')
          ..write('targetWordUseCount: $targetWordUseCount, ')
          ..write('naturalnessAverage: $naturalnessAverage, ')
          ..write('contextFitAverage: $contextFitAverage, ')
          ..write('skillRunCount: $skillRunCount, ')
          ..write('involvedWordCount: $involvedWordCount')
          ..write(')'))
        .toString();
  }
}

class $LearningActivityListsTable extends LearningActivityLists
    with TableInfo<$LearningActivityListsTable, LearningActivityList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningActivityListsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES learning_activity_records (id) ON DELETE CASCADE',
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
      'REFERENCES word_lists (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, activityId, listId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_activity_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningActivityList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningActivityList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningActivityList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
    );
  }

  @override
  $LearningActivityListsTable createAlias(String alias) {
    return $LearningActivityListsTable(attachedDatabase, alias);
  }
}

class LearningActivityList extends DataClass
    implements Insertable<LearningActivityList> {
  final int id;
  final int activityId;
  final int listId;
  const LearningActivityList({
    required this.id,
    required this.activityId,
    required this.listId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<int>(activityId);
    map['list_id'] = Variable<int>(listId);
    return map;
  }

  LearningActivityListsCompanion toCompanion(bool nullToAbsent) {
    return LearningActivityListsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      listId: Value(listId),
    );
  }

  factory LearningActivityList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningActivityList(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int>(json['activityId']),
      listId: serializer.fromJson<int>(json['listId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int>(activityId),
      'listId': serializer.toJson<int>(listId),
    };
  }

  LearningActivityList copyWith({int? id, int? activityId, int? listId}) =>
      LearningActivityList(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        listId: listId ?? this.listId,
      );
  LearningActivityList copyWithCompanion(LearningActivityListsCompanion data) {
    return LearningActivityList(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      listId: data.listId.present ? data.listId.value : this.listId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningActivityList(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('listId: $listId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, activityId, listId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningActivityList &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.listId == this.listId);
}

class LearningActivityListsCompanion
    extends UpdateCompanion<LearningActivityList> {
  final Value<int> id;
  final Value<int> activityId;
  final Value<int> listId;
  const LearningActivityListsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.listId = const Value.absent(),
  });
  LearningActivityListsCompanion.insert({
    this.id = const Value.absent(),
    required int activityId,
    required int listId,
  }) : activityId = Value(activityId),
       listId = Value(listId);
  static Insertable<LearningActivityList> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<int>? listId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (listId != null) 'list_id': listId,
    });
  }

  LearningActivityListsCompanion copyWith({
    Value<int>? id,
    Value<int>? activityId,
    Value<int>? listId,
  }) {
    return LearningActivityListsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      listId: listId ?? this.listId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningActivityListsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('listId: $listId')
          ..write(')'))
        .toString();
  }
}

class $LearningActivityWordsTable extends LearningActivityWords
    with TableInfo<$LearningActivityWordsTable, LearningActivityWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningActivityWordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES learning_activity_records (id) ON DELETE CASCADE',
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
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    wordId,
    usageCount,
    errorCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_activity_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningActivityWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningActivityWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningActivityWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
    );
  }

  @override
  $LearningActivityWordsTable createAlias(String alias) {
    return $LearningActivityWordsTable(attachedDatabase, alias);
  }
}

class LearningActivityWord extends DataClass
    implements Insertable<LearningActivityWord> {
  final int id;
  final int activityId;
  final int wordId;
  final int usageCount;
  final int errorCount;
  const LearningActivityWord({
    required this.id,
    required this.activityId,
    required this.wordId,
    required this.usageCount,
    required this.errorCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<int>(activityId);
    map['word_id'] = Variable<int>(wordId);
    map['usage_count'] = Variable<int>(usageCount);
    map['error_count'] = Variable<int>(errorCount);
    return map;
  }

  LearningActivityWordsCompanion toCompanion(bool nullToAbsent) {
    return LearningActivityWordsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      wordId: Value(wordId),
      usageCount: Value(usageCount),
      errorCount: Value(errorCount),
    );
  }

  factory LearningActivityWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningActivityWord(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int>(json['activityId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int>(activityId),
      'wordId': serializer.toJson<int>(wordId),
      'usageCount': serializer.toJson<int>(usageCount),
      'errorCount': serializer.toJson<int>(errorCount),
    };
  }

  LearningActivityWord copyWith({
    int? id,
    int? activityId,
    int? wordId,
    int? usageCount,
    int? errorCount,
  }) => LearningActivityWord(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    wordId: wordId ?? this.wordId,
    usageCount: usageCount ?? this.usageCount,
    errorCount: errorCount ?? this.errorCount,
  );
  LearningActivityWord copyWithCompanion(LearningActivityWordsCompanion data) {
    return LearningActivityWord(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningActivityWord(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('wordId: $wordId, ')
          ..write('usageCount: $usageCount, ')
          ..write('errorCount: $errorCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, activityId, wordId, usageCount, errorCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningActivityWord &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.wordId == this.wordId &&
          other.usageCount == this.usageCount &&
          other.errorCount == this.errorCount);
}

class LearningActivityWordsCompanion
    extends UpdateCompanion<LearningActivityWord> {
  final Value<int> id;
  final Value<int> activityId;
  final Value<int> wordId;
  final Value<int> usageCount;
  final Value<int> errorCount;
  const LearningActivityWordsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.errorCount = const Value.absent(),
  });
  LearningActivityWordsCompanion.insert({
    this.id = const Value.absent(),
    required int activityId,
    required int wordId,
    this.usageCount = const Value.absent(),
    this.errorCount = const Value.absent(),
  }) : activityId = Value(activityId),
       wordId = Value(wordId);
  static Insertable<LearningActivityWord> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<int>? wordId,
    Expression<int>? usageCount,
    Expression<int>? errorCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (wordId != null) 'word_id': wordId,
      if (usageCount != null) 'usage_count': usageCount,
      if (errorCount != null) 'error_count': errorCount,
    });
  }

  LearningActivityWordsCompanion copyWith({
    Value<int>? id,
    Value<int>? activityId,
    Value<int>? wordId,
    Value<int>? usageCount,
    Value<int>? errorCount,
  }) {
    return LearningActivityWordsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      wordId: wordId ?? this.wordId,
      usageCount: usageCount ?? this.usageCount,
      errorCount: errorCount ?? this.errorCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningActivityWordsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('wordId: $wordId, ')
          ..write('usageCount: $usageCount, ')
          ..write('errorCount: $errorCount')
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

class $NarrationSessionsTable extends NarrationSessions
    with TableInfo<$NarrationSessionsTable, NarrationSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTranscriptMeta = const VerificationMeta(
    'rawTranscript',
  );
  @override
  late final GeneratedColumn<String> rawTranscript = GeneratedColumn<String>(
    'raw_transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cleanedTranscriptMeta = const VerificationMeta(
    'cleanedTranscript',
  );
  @override
  late final GeneratedColumn<String> cleanedTranscript =
      GeneratedColumn<String>(
        'cleaned_transcript',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _transcriptConfidenceMeta =
      const VerificationMeta('transcriptConfidence');
  @override
  late final GeneratedColumn<String> transcriptConfidence =
      GeneratedColumn<String>(
        'transcript_confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('medium'),
      );
  static const VerificationMeta _uncertainSegmentsJsonMeta =
      const VerificationMeta('uncertainSegmentsJson');
  @override
  late final GeneratedColumn<String> uncertainSegmentsJson =
      GeneratedColumn<String>(
        'uncertain_segments_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _chineseTranslationMeta =
      const VerificationMeta('chineseTranslation');
  @override
  late final GeneratedColumn<String> chineseTranslation =
      GeneratedColumn<String>(
        'chinese_translation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _translationConfirmedMeta =
      const VerificationMeta('translationConfirmed');
  @override
  late final GeneratedColumn<bool> translationConfirmed = GeneratedColumn<bool>(
    'translation_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("translation_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetEnglishMeta = const VerificationMeta(
    'targetEnglish',
  );
  @override
  late final GeneratedColumn<String> targetEnglish = GeneratedColumn<String>(
    'target_english',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetAlternativesJsonMeta =
      const VerificationMeta('targetAlternativesJson');
  @override
  late final GeneratedColumn<String> targetAlternativesJson =
      GeneratedColumn<String>(
        'target_alternatives_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _targetConfirmedMeta = const VerificationMeta(
    'targetConfirmed',
  );
  @override
  late final GeneratedColumn<bool> targetConfirmed = GeneratedColumn<bool>(
    'target_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("target_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _normalizedTranscriptMeta =
      const VerificationMeta('normalizedTranscript');
  @override
  late final GeneratedColumn<String> normalizedTranscript =
      GeneratedColumn<String>(
        'normalized_transcript',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _analysisJsonMeta = const VerificationMeta(
    'analysisJson',
  );
  @override
  late final GeneratedColumn<String> analysisJson = GeneratedColumn<String>(
    'analysis_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctedExpressionMeta =
      const VerificationMeta('correctedExpression');
  @override
  late final GeneratedColumn<String> correctedExpression =
      GeneratedColumn<String>(
        'corrected_expression',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _finalExpressionMeta = const VerificationMeta(
    'finalExpression',
  );
  @override
  late final GeneratedColumn<String> finalExpression = GeneratedColumn<String>(
    'final_expression',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalConfirmedMeta = const VerificationMeta(
    'finalConfirmed',
  );
  @override
  late final GeneratedColumn<bool> finalConfirmed = GeneratedColumn<bool>(
    'final_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("final_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioRetainedMeta = const VerificationMeta(
    'audioRetained',
  );
  @override
  late final GeneratedColumn<bool> audioRetained = GeneratedColumn<bool>(
    'audio_retained',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("audio_retained" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _accentMeta = const VerificationMeta('accent');
  @override
  late final GeneratedColumn<String> accent = GeneratedColumn<String>(
    'accent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('british'),
  );
  static const VerificationMeta _speechRegisterMeta = const VerificationMeta(
    'speechRegister',
  );
  @override
  late final GeneratedColumn<String> speechRegister = GeneratedColumn<String>(
    'speech_register',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('spoken'),
  );
  static const VerificationMeta _thinkingEnabledMeta = const VerificationMeta(
    'thinkingEnabled',
  );
  @override
  late final GeneratedColumn<bool> thinkingEnabled = GeneratedColumn<bool>(
    'thinking_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("thinking_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _analysisDurationMsMeta =
      const VerificationMeta('analysisDurationMs');
  @override
  late final GeneratedColumn<int> analysisDurationMs = GeneratedColumn<int>(
    'analysis_duration_ms',
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
    status,
    rawTranscript,
    cleanedTranscript,
    transcriptConfidence,
    uncertainSegmentsJson,
    chineseTranslation,
    translationConfirmed,
    targetEnglish,
    targetAlternativesJson,
    targetConfirmed,
    normalizedTranscript,
    analysisJson,
    correctedExpression,
    finalExpression,
    finalConfirmed,
    audioPath,
    audioRetained,
    accent,
    speechRegister,
    thinkingEnabled,
    analysisDurationMs,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('raw_transcript')) {
      context.handle(
        _rawTranscriptMeta,
        rawTranscript.isAcceptableOrUnknown(
          data['raw_transcript']!,
          _rawTranscriptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawTranscriptMeta);
    }
    if (data.containsKey('cleaned_transcript')) {
      context.handle(
        _cleanedTranscriptMeta,
        cleanedTranscript.isAcceptableOrUnknown(
          data['cleaned_transcript']!,
          _cleanedTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('transcript_confidence')) {
      context.handle(
        _transcriptConfidenceMeta,
        transcriptConfidence.isAcceptableOrUnknown(
          data['transcript_confidence']!,
          _transcriptConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('uncertain_segments_json')) {
      context.handle(
        _uncertainSegmentsJsonMeta,
        uncertainSegmentsJson.isAcceptableOrUnknown(
          data['uncertain_segments_json']!,
          _uncertainSegmentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('chinese_translation')) {
      context.handle(
        _chineseTranslationMeta,
        chineseTranslation.isAcceptableOrUnknown(
          data['chinese_translation']!,
          _chineseTranslationMeta,
        ),
      );
    }
    if (data.containsKey('translation_confirmed')) {
      context.handle(
        _translationConfirmedMeta,
        translationConfirmed.isAcceptableOrUnknown(
          data['translation_confirmed']!,
          _translationConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('target_english')) {
      context.handle(
        _targetEnglishMeta,
        targetEnglish.isAcceptableOrUnknown(
          data['target_english']!,
          _targetEnglishMeta,
        ),
      );
    }
    if (data.containsKey('target_alternatives_json')) {
      context.handle(
        _targetAlternativesJsonMeta,
        targetAlternativesJson.isAcceptableOrUnknown(
          data['target_alternatives_json']!,
          _targetAlternativesJsonMeta,
        ),
      );
    }
    if (data.containsKey('target_confirmed')) {
      context.handle(
        _targetConfirmedMeta,
        targetConfirmed.isAcceptableOrUnknown(
          data['target_confirmed']!,
          _targetConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('normalized_transcript')) {
      context.handle(
        _normalizedTranscriptMeta,
        normalizedTranscript.isAcceptableOrUnknown(
          data['normalized_transcript']!,
          _normalizedTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('analysis_json')) {
      context.handle(
        _analysisJsonMeta,
        analysisJson.isAcceptableOrUnknown(
          data['analysis_json']!,
          _analysisJsonMeta,
        ),
      );
    }
    if (data.containsKey('corrected_expression')) {
      context.handle(
        _correctedExpressionMeta,
        correctedExpression.isAcceptableOrUnknown(
          data['corrected_expression']!,
          _correctedExpressionMeta,
        ),
      );
    }
    if (data.containsKey('final_expression')) {
      context.handle(
        _finalExpressionMeta,
        finalExpression.isAcceptableOrUnknown(
          data['final_expression']!,
          _finalExpressionMeta,
        ),
      );
    }
    if (data.containsKey('final_confirmed')) {
      context.handle(
        _finalConfirmedMeta,
        finalConfirmed.isAcceptableOrUnknown(
          data['final_confirmed']!,
          _finalConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('audio_retained')) {
      context.handle(
        _audioRetainedMeta,
        audioRetained.isAcceptableOrUnknown(
          data['audio_retained']!,
          _audioRetainedMeta,
        ),
      );
    }
    if (data.containsKey('accent')) {
      context.handle(
        _accentMeta,
        accent.isAcceptableOrUnknown(data['accent']!, _accentMeta),
      );
    }
    if (data.containsKey('speech_register')) {
      context.handle(
        _speechRegisterMeta,
        speechRegister.isAcceptableOrUnknown(
          data['speech_register']!,
          _speechRegisterMeta,
        ),
      );
    }
    if (data.containsKey('thinking_enabled')) {
      context.handle(
        _thinkingEnabledMeta,
        thinkingEnabled.isAcceptableOrUnknown(
          data['thinking_enabled']!,
          _thinkingEnabledMeta,
        ),
      );
    }
    if (data.containsKey('analysis_duration_ms')) {
      context.handle(
        _analysisDurationMsMeta,
        analysisDurationMs.isAcceptableOrUnknown(
          data['analysis_duration_ms']!,
          _analysisDurationMsMeta,
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
  NarrationSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rawTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_transcript'],
      )!,
      cleanedTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cleaned_transcript'],
      ),
      transcriptConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_confidence'],
      )!,
      uncertainSegmentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uncertain_segments_json'],
      )!,
      chineseTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chinese_translation'],
      ),
      translationConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}translation_confirmed'],
      )!,
      targetEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_english'],
      ),
      targetAlternativesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_alternatives_json'],
      )!,
      targetConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}target_confirmed'],
      )!,
      normalizedTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_transcript'],
      ),
      analysisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_json'],
      ),
      correctedExpression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_expression'],
      ),
      finalExpression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_expression'],
      ),
      finalConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}final_confirmed'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      audioRetained: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}audio_retained'],
      )!,
      accent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent'],
      )!,
      speechRegister: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speech_register'],
      )!,
      thinkingEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}thinking_enabled'],
      )!,
      analysisDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}analysis_duration_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NarrationSessionsTable createAlias(String alias) {
    return $NarrationSessionsTable(attachedDatabase, alias);
  }
}

class NarrationSession extends DataClass
    implements Insertable<NarrationSession> {
  final int id;
  final String status;
  final String rawTranscript;
  final String? cleanedTranscript;
  final String transcriptConfidence;
  final String uncertainSegmentsJson;
  final String? chineseTranslation;
  final bool translationConfirmed;
  final String? targetEnglish;
  final String targetAlternativesJson;
  final bool targetConfirmed;
  final String? normalizedTranscript;
  final String? analysisJson;
  final String? correctedExpression;
  final String? finalExpression;
  final bool finalConfirmed;
  final String? audioPath;
  final bool audioRetained;
  final String accent;
  final String speechRegister;
  final bool thinkingEnabled;
  final int? analysisDurationMs;
  final int createdAt;
  final int updatedAt;
  const NarrationSession({
    required this.id,
    required this.status,
    required this.rawTranscript,
    this.cleanedTranscript,
    required this.transcriptConfidence,
    required this.uncertainSegmentsJson,
    this.chineseTranslation,
    required this.translationConfirmed,
    this.targetEnglish,
    required this.targetAlternativesJson,
    required this.targetConfirmed,
    this.normalizedTranscript,
    this.analysisJson,
    this.correctedExpression,
    this.finalExpression,
    required this.finalConfirmed,
    this.audioPath,
    required this.audioRetained,
    required this.accent,
    required this.speechRegister,
    required this.thinkingEnabled,
    this.analysisDurationMs,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<String>(status);
    map['raw_transcript'] = Variable<String>(rawTranscript);
    if (!nullToAbsent || cleanedTranscript != null) {
      map['cleaned_transcript'] = Variable<String>(cleanedTranscript);
    }
    map['transcript_confidence'] = Variable<String>(transcriptConfidence);
    map['uncertain_segments_json'] = Variable<String>(uncertainSegmentsJson);
    if (!nullToAbsent || chineseTranslation != null) {
      map['chinese_translation'] = Variable<String>(chineseTranslation);
    }
    map['translation_confirmed'] = Variable<bool>(translationConfirmed);
    if (!nullToAbsent || targetEnglish != null) {
      map['target_english'] = Variable<String>(targetEnglish);
    }
    map['target_alternatives_json'] = Variable<String>(targetAlternativesJson);
    map['target_confirmed'] = Variable<bool>(targetConfirmed);
    if (!nullToAbsent || normalizedTranscript != null) {
      map['normalized_transcript'] = Variable<String>(normalizedTranscript);
    }
    if (!nullToAbsent || analysisJson != null) {
      map['analysis_json'] = Variable<String>(analysisJson);
    }
    if (!nullToAbsent || correctedExpression != null) {
      map['corrected_expression'] = Variable<String>(correctedExpression);
    }
    if (!nullToAbsent || finalExpression != null) {
      map['final_expression'] = Variable<String>(finalExpression);
    }
    map['final_confirmed'] = Variable<bool>(finalConfirmed);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['audio_retained'] = Variable<bool>(audioRetained);
    map['accent'] = Variable<String>(accent);
    map['speech_register'] = Variable<String>(speechRegister);
    map['thinking_enabled'] = Variable<bool>(thinkingEnabled);
    if (!nullToAbsent || analysisDurationMs != null) {
      map['analysis_duration_ms'] = Variable<int>(analysisDurationMs);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NarrationSessionsCompanion toCompanion(bool nullToAbsent) {
    return NarrationSessionsCompanion(
      id: Value(id),
      status: Value(status),
      rawTranscript: Value(rawTranscript),
      cleanedTranscript: cleanedTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(cleanedTranscript),
      transcriptConfidence: Value(transcriptConfidence),
      uncertainSegmentsJson: Value(uncertainSegmentsJson),
      chineseTranslation: chineseTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(chineseTranslation),
      translationConfirmed: Value(translationConfirmed),
      targetEnglish: targetEnglish == null && nullToAbsent
          ? const Value.absent()
          : Value(targetEnglish),
      targetAlternativesJson: Value(targetAlternativesJson),
      targetConfirmed: Value(targetConfirmed),
      normalizedTranscript: normalizedTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedTranscript),
      analysisJson: analysisJson == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisJson),
      correctedExpression: correctedExpression == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedExpression),
      finalExpression: finalExpression == null && nullToAbsent
          ? const Value.absent()
          : Value(finalExpression),
      finalConfirmed: Value(finalConfirmed),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      audioRetained: Value(audioRetained),
      accent: Value(accent),
      speechRegister: Value(speechRegister),
      thinkingEnabled: Value(thinkingEnabled),
      analysisDurationMs: analysisDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisDurationMs),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NarrationSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationSession(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      rawTranscript: serializer.fromJson<String>(json['rawTranscript']),
      cleanedTranscript: serializer.fromJson<String?>(
        json['cleanedTranscript'],
      ),
      transcriptConfidence: serializer.fromJson<String>(
        json['transcriptConfidence'],
      ),
      uncertainSegmentsJson: serializer.fromJson<String>(
        json['uncertainSegmentsJson'],
      ),
      chineseTranslation: serializer.fromJson<String?>(
        json['chineseTranslation'],
      ),
      translationConfirmed: serializer.fromJson<bool>(
        json['translationConfirmed'],
      ),
      targetEnglish: serializer.fromJson<String?>(json['targetEnglish']),
      targetAlternativesJson: serializer.fromJson<String>(
        json['targetAlternativesJson'],
      ),
      targetConfirmed: serializer.fromJson<bool>(json['targetConfirmed']),
      normalizedTranscript: serializer.fromJson<String?>(
        json['normalizedTranscript'],
      ),
      analysisJson: serializer.fromJson<String?>(json['analysisJson']),
      correctedExpression: serializer.fromJson<String?>(
        json['correctedExpression'],
      ),
      finalExpression: serializer.fromJson<String?>(json['finalExpression']),
      finalConfirmed: serializer.fromJson<bool>(json['finalConfirmed']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      audioRetained: serializer.fromJson<bool>(json['audioRetained']),
      accent: serializer.fromJson<String>(json['accent']),
      speechRegister: serializer.fromJson<String>(json['speechRegister']),
      thinkingEnabled: serializer.fromJson<bool>(json['thinkingEnabled']),
      analysisDurationMs: serializer.fromJson<int?>(json['analysisDurationMs']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(status),
      'rawTranscript': serializer.toJson<String>(rawTranscript),
      'cleanedTranscript': serializer.toJson<String?>(cleanedTranscript),
      'transcriptConfidence': serializer.toJson<String>(transcriptConfidence),
      'uncertainSegmentsJson': serializer.toJson<String>(uncertainSegmentsJson),
      'chineseTranslation': serializer.toJson<String?>(chineseTranslation),
      'translationConfirmed': serializer.toJson<bool>(translationConfirmed),
      'targetEnglish': serializer.toJson<String?>(targetEnglish),
      'targetAlternativesJson': serializer.toJson<String>(
        targetAlternativesJson,
      ),
      'targetConfirmed': serializer.toJson<bool>(targetConfirmed),
      'normalizedTranscript': serializer.toJson<String?>(normalizedTranscript),
      'analysisJson': serializer.toJson<String?>(analysisJson),
      'correctedExpression': serializer.toJson<String?>(correctedExpression),
      'finalExpression': serializer.toJson<String?>(finalExpression),
      'finalConfirmed': serializer.toJson<bool>(finalConfirmed),
      'audioPath': serializer.toJson<String?>(audioPath),
      'audioRetained': serializer.toJson<bool>(audioRetained),
      'accent': serializer.toJson<String>(accent),
      'speechRegister': serializer.toJson<String>(speechRegister),
      'thinkingEnabled': serializer.toJson<bool>(thinkingEnabled),
      'analysisDurationMs': serializer.toJson<int?>(analysisDurationMs),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NarrationSession copyWith({
    int? id,
    String? status,
    String? rawTranscript,
    Value<String?> cleanedTranscript = const Value.absent(),
    String? transcriptConfidence,
    String? uncertainSegmentsJson,
    Value<String?> chineseTranslation = const Value.absent(),
    bool? translationConfirmed,
    Value<String?> targetEnglish = const Value.absent(),
    String? targetAlternativesJson,
    bool? targetConfirmed,
    Value<String?> normalizedTranscript = const Value.absent(),
    Value<String?> analysisJson = const Value.absent(),
    Value<String?> correctedExpression = const Value.absent(),
    Value<String?> finalExpression = const Value.absent(),
    bool? finalConfirmed,
    Value<String?> audioPath = const Value.absent(),
    bool? audioRetained,
    String? accent,
    String? speechRegister,
    bool? thinkingEnabled,
    Value<int?> analysisDurationMs = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => NarrationSession(
    id: id ?? this.id,
    status: status ?? this.status,
    rawTranscript: rawTranscript ?? this.rawTranscript,
    cleanedTranscript: cleanedTranscript.present
        ? cleanedTranscript.value
        : this.cleanedTranscript,
    transcriptConfidence: transcriptConfidence ?? this.transcriptConfidence,
    uncertainSegmentsJson: uncertainSegmentsJson ?? this.uncertainSegmentsJson,
    chineseTranslation: chineseTranslation.present
        ? chineseTranslation.value
        : this.chineseTranslation,
    translationConfirmed: translationConfirmed ?? this.translationConfirmed,
    targetEnglish: targetEnglish.present
        ? targetEnglish.value
        : this.targetEnglish,
    targetAlternativesJson:
        targetAlternativesJson ?? this.targetAlternativesJson,
    targetConfirmed: targetConfirmed ?? this.targetConfirmed,
    normalizedTranscript: normalizedTranscript.present
        ? normalizedTranscript.value
        : this.normalizedTranscript,
    analysisJson: analysisJson.present ? analysisJson.value : this.analysisJson,
    correctedExpression: correctedExpression.present
        ? correctedExpression.value
        : this.correctedExpression,
    finalExpression: finalExpression.present
        ? finalExpression.value
        : this.finalExpression,
    finalConfirmed: finalConfirmed ?? this.finalConfirmed,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    audioRetained: audioRetained ?? this.audioRetained,
    accent: accent ?? this.accent,
    speechRegister: speechRegister ?? this.speechRegister,
    thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
    analysisDurationMs: analysisDurationMs.present
        ? analysisDurationMs.value
        : this.analysisDurationMs,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NarrationSession copyWithCompanion(NarrationSessionsCompanion data) {
    return NarrationSession(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      rawTranscript: data.rawTranscript.present
          ? data.rawTranscript.value
          : this.rawTranscript,
      cleanedTranscript: data.cleanedTranscript.present
          ? data.cleanedTranscript.value
          : this.cleanedTranscript,
      transcriptConfidence: data.transcriptConfidence.present
          ? data.transcriptConfidence.value
          : this.transcriptConfidence,
      uncertainSegmentsJson: data.uncertainSegmentsJson.present
          ? data.uncertainSegmentsJson.value
          : this.uncertainSegmentsJson,
      chineseTranslation: data.chineseTranslation.present
          ? data.chineseTranslation.value
          : this.chineseTranslation,
      translationConfirmed: data.translationConfirmed.present
          ? data.translationConfirmed.value
          : this.translationConfirmed,
      targetEnglish: data.targetEnglish.present
          ? data.targetEnglish.value
          : this.targetEnglish,
      targetAlternativesJson: data.targetAlternativesJson.present
          ? data.targetAlternativesJson.value
          : this.targetAlternativesJson,
      targetConfirmed: data.targetConfirmed.present
          ? data.targetConfirmed.value
          : this.targetConfirmed,
      normalizedTranscript: data.normalizedTranscript.present
          ? data.normalizedTranscript.value
          : this.normalizedTranscript,
      analysisJson: data.analysisJson.present
          ? data.analysisJson.value
          : this.analysisJson,
      correctedExpression: data.correctedExpression.present
          ? data.correctedExpression.value
          : this.correctedExpression,
      finalExpression: data.finalExpression.present
          ? data.finalExpression.value
          : this.finalExpression,
      finalConfirmed: data.finalConfirmed.present
          ? data.finalConfirmed.value
          : this.finalConfirmed,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      audioRetained: data.audioRetained.present
          ? data.audioRetained.value
          : this.audioRetained,
      accent: data.accent.present ? data.accent.value : this.accent,
      speechRegister: data.speechRegister.present
          ? data.speechRegister.value
          : this.speechRegister,
      thinkingEnabled: data.thinkingEnabled.present
          ? data.thinkingEnabled.value
          : this.thinkingEnabled,
      analysisDurationMs: data.analysisDurationMs.present
          ? data.analysisDurationMs.value
          : this.analysisDurationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationSession(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('cleanedTranscript: $cleanedTranscript, ')
          ..write('transcriptConfidence: $transcriptConfidence, ')
          ..write('uncertainSegmentsJson: $uncertainSegmentsJson, ')
          ..write('chineseTranslation: $chineseTranslation, ')
          ..write('translationConfirmed: $translationConfirmed, ')
          ..write('targetEnglish: $targetEnglish, ')
          ..write('targetAlternativesJson: $targetAlternativesJson, ')
          ..write('targetConfirmed: $targetConfirmed, ')
          ..write('normalizedTranscript: $normalizedTranscript, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('correctedExpression: $correctedExpression, ')
          ..write('finalExpression: $finalExpression, ')
          ..write('finalConfirmed: $finalConfirmed, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioRetained: $audioRetained, ')
          ..write('accent: $accent, ')
          ..write('speechRegister: $speechRegister, ')
          ..write('thinkingEnabled: $thinkingEnabled, ')
          ..write('analysisDurationMs: $analysisDurationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    status,
    rawTranscript,
    cleanedTranscript,
    transcriptConfidence,
    uncertainSegmentsJson,
    chineseTranslation,
    translationConfirmed,
    targetEnglish,
    targetAlternativesJson,
    targetConfirmed,
    normalizedTranscript,
    analysisJson,
    correctedExpression,
    finalExpression,
    finalConfirmed,
    audioPath,
    audioRetained,
    accent,
    speechRegister,
    thinkingEnabled,
    analysisDurationMs,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationSession &&
          other.id == this.id &&
          other.status == this.status &&
          other.rawTranscript == this.rawTranscript &&
          other.cleanedTranscript == this.cleanedTranscript &&
          other.transcriptConfidence == this.transcriptConfidence &&
          other.uncertainSegmentsJson == this.uncertainSegmentsJson &&
          other.chineseTranslation == this.chineseTranslation &&
          other.translationConfirmed == this.translationConfirmed &&
          other.targetEnglish == this.targetEnglish &&
          other.targetAlternativesJson == this.targetAlternativesJson &&
          other.targetConfirmed == this.targetConfirmed &&
          other.normalizedTranscript == this.normalizedTranscript &&
          other.analysisJson == this.analysisJson &&
          other.correctedExpression == this.correctedExpression &&
          other.finalExpression == this.finalExpression &&
          other.finalConfirmed == this.finalConfirmed &&
          other.audioPath == this.audioPath &&
          other.audioRetained == this.audioRetained &&
          other.accent == this.accent &&
          other.speechRegister == this.speechRegister &&
          other.thinkingEnabled == this.thinkingEnabled &&
          other.analysisDurationMs == this.analysisDurationMs &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NarrationSessionsCompanion extends UpdateCompanion<NarrationSession> {
  final Value<int> id;
  final Value<String> status;
  final Value<String> rawTranscript;
  final Value<String?> cleanedTranscript;
  final Value<String> transcriptConfidence;
  final Value<String> uncertainSegmentsJson;
  final Value<String?> chineseTranslation;
  final Value<bool> translationConfirmed;
  final Value<String?> targetEnglish;
  final Value<String> targetAlternativesJson;
  final Value<bool> targetConfirmed;
  final Value<String?> normalizedTranscript;
  final Value<String?> analysisJson;
  final Value<String?> correctedExpression;
  final Value<String?> finalExpression;
  final Value<bool> finalConfirmed;
  final Value<String?> audioPath;
  final Value<bool> audioRetained;
  final Value<String> accent;
  final Value<String> speechRegister;
  final Value<bool> thinkingEnabled;
  final Value<int?> analysisDurationMs;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const NarrationSessionsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.cleanedTranscript = const Value.absent(),
    this.transcriptConfidence = const Value.absent(),
    this.uncertainSegmentsJson = const Value.absent(),
    this.chineseTranslation = const Value.absent(),
    this.translationConfirmed = const Value.absent(),
    this.targetEnglish = const Value.absent(),
    this.targetAlternativesJson = const Value.absent(),
    this.targetConfirmed = const Value.absent(),
    this.normalizedTranscript = const Value.absent(),
    this.analysisJson = const Value.absent(),
    this.correctedExpression = const Value.absent(),
    this.finalExpression = const Value.absent(),
    this.finalConfirmed = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioRetained = const Value.absent(),
    this.accent = const Value.absent(),
    this.speechRegister = const Value.absent(),
    this.thinkingEnabled = const Value.absent(),
    this.analysisDurationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NarrationSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String status,
    required String rawTranscript,
    this.cleanedTranscript = const Value.absent(),
    this.transcriptConfidence = const Value.absent(),
    this.uncertainSegmentsJson = const Value.absent(),
    this.chineseTranslation = const Value.absent(),
    this.translationConfirmed = const Value.absent(),
    this.targetEnglish = const Value.absent(),
    this.targetAlternativesJson = const Value.absent(),
    this.targetConfirmed = const Value.absent(),
    this.normalizedTranscript = const Value.absent(),
    this.analysisJson = const Value.absent(),
    this.correctedExpression = const Value.absent(),
    this.finalExpression = const Value.absent(),
    this.finalConfirmed = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioRetained = const Value.absent(),
    this.accent = const Value.absent(),
    this.speechRegister = const Value.absent(),
    this.thinkingEnabled = const Value.absent(),
    this.analysisDurationMs = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : status = Value(status),
       rawTranscript = Value(rawTranscript),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NarrationSession> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<String>? rawTranscript,
    Expression<String>? cleanedTranscript,
    Expression<String>? transcriptConfidence,
    Expression<String>? uncertainSegmentsJson,
    Expression<String>? chineseTranslation,
    Expression<bool>? translationConfirmed,
    Expression<String>? targetEnglish,
    Expression<String>? targetAlternativesJson,
    Expression<bool>? targetConfirmed,
    Expression<String>? normalizedTranscript,
    Expression<String>? analysisJson,
    Expression<String>? correctedExpression,
    Expression<String>? finalExpression,
    Expression<bool>? finalConfirmed,
    Expression<String>? audioPath,
    Expression<bool>? audioRetained,
    Expression<String>? accent,
    Expression<String>? speechRegister,
    Expression<bool>? thinkingEnabled,
    Expression<int>? analysisDurationMs,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (rawTranscript != null) 'raw_transcript': rawTranscript,
      if (cleanedTranscript != null) 'cleaned_transcript': cleanedTranscript,
      if (transcriptConfidence != null)
        'transcript_confidence': transcriptConfidence,
      if (uncertainSegmentsJson != null)
        'uncertain_segments_json': uncertainSegmentsJson,
      if (chineseTranslation != null) 'chinese_translation': chineseTranslation,
      if (translationConfirmed != null)
        'translation_confirmed': translationConfirmed,
      if (targetEnglish != null) 'target_english': targetEnglish,
      if (targetAlternativesJson != null)
        'target_alternatives_json': targetAlternativesJson,
      if (targetConfirmed != null) 'target_confirmed': targetConfirmed,
      if (normalizedTranscript != null)
        'normalized_transcript': normalizedTranscript,
      if (analysisJson != null) 'analysis_json': analysisJson,
      if (correctedExpression != null)
        'corrected_expression': correctedExpression,
      if (finalExpression != null) 'final_expression': finalExpression,
      if (finalConfirmed != null) 'final_confirmed': finalConfirmed,
      if (audioPath != null) 'audio_path': audioPath,
      if (audioRetained != null) 'audio_retained': audioRetained,
      if (accent != null) 'accent': accent,
      if (speechRegister != null) 'speech_register': speechRegister,
      if (thinkingEnabled != null) 'thinking_enabled': thinkingEnabled,
      if (analysisDurationMs != null)
        'analysis_duration_ms': analysisDurationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NarrationSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? status,
    Value<String>? rawTranscript,
    Value<String?>? cleanedTranscript,
    Value<String>? transcriptConfidence,
    Value<String>? uncertainSegmentsJson,
    Value<String?>? chineseTranslation,
    Value<bool>? translationConfirmed,
    Value<String?>? targetEnglish,
    Value<String>? targetAlternativesJson,
    Value<bool>? targetConfirmed,
    Value<String?>? normalizedTranscript,
    Value<String?>? analysisJson,
    Value<String?>? correctedExpression,
    Value<String?>? finalExpression,
    Value<bool>? finalConfirmed,
    Value<String?>? audioPath,
    Value<bool>? audioRetained,
    Value<String>? accent,
    Value<String>? speechRegister,
    Value<bool>? thinkingEnabled,
    Value<int?>? analysisDurationMs,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return NarrationSessionsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      cleanedTranscript: cleanedTranscript ?? this.cleanedTranscript,
      transcriptConfidence: transcriptConfidence ?? this.transcriptConfidence,
      uncertainSegmentsJson:
          uncertainSegmentsJson ?? this.uncertainSegmentsJson,
      chineseTranslation: chineseTranslation ?? this.chineseTranslation,
      translationConfirmed: translationConfirmed ?? this.translationConfirmed,
      targetEnglish: targetEnglish ?? this.targetEnglish,
      targetAlternativesJson:
          targetAlternativesJson ?? this.targetAlternativesJson,
      targetConfirmed: targetConfirmed ?? this.targetConfirmed,
      normalizedTranscript: normalizedTranscript ?? this.normalizedTranscript,
      analysisJson: analysisJson ?? this.analysisJson,
      correctedExpression: correctedExpression ?? this.correctedExpression,
      finalExpression: finalExpression ?? this.finalExpression,
      finalConfirmed: finalConfirmed ?? this.finalConfirmed,
      audioPath: audioPath ?? this.audioPath,
      audioRetained: audioRetained ?? this.audioRetained,
      accent: accent ?? this.accent,
      speechRegister: speechRegister ?? this.speechRegister,
      thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
      analysisDurationMs: analysisDurationMs ?? this.analysisDurationMs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rawTranscript.present) {
      map['raw_transcript'] = Variable<String>(rawTranscript.value);
    }
    if (cleanedTranscript.present) {
      map['cleaned_transcript'] = Variable<String>(cleanedTranscript.value);
    }
    if (transcriptConfidence.present) {
      map['transcript_confidence'] = Variable<String>(
        transcriptConfidence.value,
      );
    }
    if (uncertainSegmentsJson.present) {
      map['uncertain_segments_json'] = Variable<String>(
        uncertainSegmentsJson.value,
      );
    }
    if (chineseTranslation.present) {
      map['chinese_translation'] = Variable<String>(chineseTranslation.value);
    }
    if (translationConfirmed.present) {
      map['translation_confirmed'] = Variable<bool>(translationConfirmed.value);
    }
    if (targetEnglish.present) {
      map['target_english'] = Variable<String>(targetEnglish.value);
    }
    if (targetAlternativesJson.present) {
      map['target_alternatives_json'] = Variable<String>(
        targetAlternativesJson.value,
      );
    }
    if (targetConfirmed.present) {
      map['target_confirmed'] = Variable<bool>(targetConfirmed.value);
    }
    if (normalizedTranscript.present) {
      map['normalized_transcript'] = Variable<String>(
        normalizedTranscript.value,
      );
    }
    if (analysisJson.present) {
      map['analysis_json'] = Variable<String>(analysisJson.value);
    }
    if (correctedExpression.present) {
      map['corrected_expression'] = Variable<String>(correctedExpression.value);
    }
    if (finalExpression.present) {
      map['final_expression'] = Variable<String>(finalExpression.value);
    }
    if (finalConfirmed.present) {
      map['final_confirmed'] = Variable<bool>(finalConfirmed.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (audioRetained.present) {
      map['audio_retained'] = Variable<bool>(audioRetained.value);
    }
    if (accent.present) {
      map['accent'] = Variable<String>(accent.value);
    }
    if (speechRegister.present) {
      map['speech_register'] = Variable<String>(speechRegister.value);
    }
    if (thinkingEnabled.present) {
      map['thinking_enabled'] = Variable<bool>(thinkingEnabled.value);
    }
    if (analysisDurationMs.present) {
      map['analysis_duration_ms'] = Variable<int>(analysisDurationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationSessionsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('cleanedTranscript: $cleanedTranscript, ')
          ..write('transcriptConfidence: $transcriptConfidence, ')
          ..write('uncertainSegmentsJson: $uncertainSegmentsJson, ')
          ..write('chineseTranslation: $chineseTranslation, ')
          ..write('translationConfirmed: $translationConfirmed, ')
          ..write('targetEnglish: $targetEnglish, ')
          ..write('targetAlternativesJson: $targetAlternativesJson, ')
          ..write('targetConfirmed: $targetConfirmed, ')
          ..write('normalizedTranscript: $normalizedTranscript, ')
          ..write('analysisJson: $analysisJson, ')
          ..write('correctedExpression: $correctedExpression, ')
          ..write('finalExpression: $finalExpression, ')
          ..write('finalConfirmed: $finalConfirmed, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioRetained: $audioRetained, ')
          ..write('accent: $accent, ')
          ..write('speechRegister: $speechRegister, ')
          ..write('thinkingEnabled: $thinkingEnabled, ')
          ..write('analysisDurationMs: $analysisDurationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationTranscriptionLogsTable extends NarrationTranscriptionLogs
    with
        TableInfo<$NarrationTranscriptionLogsTable, NarrationTranscriptionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationTranscriptionLogsTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES narration_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rawTranscriptMeta = const VerificationMeta(
    'rawTranscript',
  );
  @override
  late final GeneratedColumn<String> rawTranscript = GeneratedColumn<String>(
    'raw_transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctedTranscriptMeta =
      const VerificationMeta('correctedTranscript');
  @override
  late final GeneratedColumn<String> correctedTranscript =
      GeneratedColumn<String>(
        'corrected_transcript',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uncertainSegmentsJsonMeta =
      const VerificationMeta('uncertainSegmentsJson');
  @override
  late final GeneratedColumn<String> uncertainSegmentsJson =
      GeneratedColumn<String>(
        'uncertain_segments_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _confirmationResultMeta =
      const VerificationMeta('confirmationResult');
  @override
  late final GeneratedColumn<String> confirmationResult =
      GeneratedColumn<String>(
        'confirmation_result',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _rerecordedMeta = const VerificationMeta(
    'rerecorded',
  );
  @override
  late final GeneratedColumn<bool> rerecorded = GeneratedColumn<bool>(
    'rerecorded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rerecorded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _alignmentStatusMeta = const VerificationMeta(
    'alignmentStatus',
  );
  @override
  late final GeneratedColumn<String> alignmentStatus = GeneratedColumn<String>(
    'alignment_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualCleanupJsonMeta = const VerificationMeta(
    'manualCleanupJson',
  );
  @override
  late final GeneratedColumn<String> manualCleanupJson =
      GeneratedColumn<String>(
        'manual_cleanup_json',
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
    sessionId,
    rawTranscript,
    correctedTranscript,
    confidence,
    uncertainSegmentsJson,
    confirmationResult,
    rerecorded,
    alignmentStatus,
    manualCleanupJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_transcription_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationTranscriptionLog> instance, {
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
    if (data.containsKey('raw_transcript')) {
      context.handle(
        _rawTranscriptMeta,
        rawTranscript.isAcceptableOrUnknown(
          data['raw_transcript']!,
          _rawTranscriptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawTranscriptMeta);
    }
    if (data.containsKey('corrected_transcript')) {
      context.handle(
        _correctedTranscriptMeta,
        correctedTranscript.isAcceptableOrUnknown(
          data['corrected_transcript']!,
          _correctedTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('uncertain_segments_json')) {
      context.handle(
        _uncertainSegmentsJsonMeta,
        uncertainSegmentsJson.isAcceptableOrUnknown(
          data['uncertain_segments_json']!,
          _uncertainSegmentsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uncertainSegmentsJsonMeta);
    }
    if (data.containsKey('confirmation_result')) {
      context.handle(
        _confirmationResultMeta,
        confirmationResult.isAcceptableOrUnknown(
          data['confirmation_result']!,
          _confirmationResultMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmationResultMeta);
    }
    if (data.containsKey('rerecorded')) {
      context.handle(
        _rerecordedMeta,
        rerecorded.isAcceptableOrUnknown(data['rerecorded']!, _rerecordedMeta),
      );
    }
    if (data.containsKey('alignment_status')) {
      context.handle(
        _alignmentStatusMeta,
        alignmentStatus.isAcceptableOrUnknown(
          data['alignment_status']!,
          _alignmentStatusMeta,
        ),
      );
    }
    if (data.containsKey('manual_cleanup_json')) {
      context.handle(
        _manualCleanupJsonMeta,
        manualCleanupJson.isAcceptableOrUnknown(
          data['manual_cleanup_json']!,
          _manualCleanupJsonMeta,
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
  NarrationTranscriptionLog map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationTranscriptionLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      rawTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_transcript'],
      )!,
      correctedTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_transcript'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      uncertainSegmentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uncertain_segments_json'],
      )!,
      confirmationResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmation_result'],
      )!,
      rerecorded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rerecorded'],
      )!,
      alignmentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alignment_status'],
      ),
      manualCleanupJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_cleanup_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NarrationTranscriptionLogsTable createAlias(String alias) {
    return $NarrationTranscriptionLogsTable(attachedDatabase, alias);
  }
}

class NarrationTranscriptionLog extends DataClass
    implements Insertable<NarrationTranscriptionLog> {
  final int id;
  final int sessionId;
  final String rawTranscript;
  final String? correctedTranscript;
  final String confidence;
  final String uncertainSegmentsJson;
  final String confirmationResult;
  final bool rerecorded;
  final String? alignmentStatus;
  final String? manualCleanupJson;
  final int createdAt;
  const NarrationTranscriptionLog({
    required this.id,
    required this.sessionId,
    required this.rawTranscript,
    this.correctedTranscript,
    required this.confidence,
    required this.uncertainSegmentsJson,
    required this.confirmationResult,
    required this.rerecorded,
    this.alignmentStatus,
    this.manualCleanupJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['raw_transcript'] = Variable<String>(rawTranscript);
    if (!nullToAbsent || correctedTranscript != null) {
      map['corrected_transcript'] = Variable<String>(correctedTranscript);
    }
    map['confidence'] = Variable<String>(confidence);
    map['uncertain_segments_json'] = Variable<String>(uncertainSegmentsJson);
    map['confirmation_result'] = Variable<String>(confirmationResult);
    map['rerecorded'] = Variable<bool>(rerecorded);
    if (!nullToAbsent || alignmentStatus != null) {
      map['alignment_status'] = Variable<String>(alignmentStatus);
    }
    if (!nullToAbsent || manualCleanupJson != null) {
      map['manual_cleanup_json'] = Variable<String>(manualCleanupJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NarrationTranscriptionLogsCompanion toCompanion(bool nullToAbsent) {
    return NarrationTranscriptionLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      rawTranscript: Value(rawTranscript),
      correctedTranscript: correctedTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedTranscript),
      confidence: Value(confidence),
      uncertainSegmentsJson: Value(uncertainSegmentsJson),
      confirmationResult: Value(confirmationResult),
      rerecorded: Value(rerecorded),
      alignmentStatus: alignmentStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(alignmentStatus),
      manualCleanupJson: manualCleanupJson == null && nullToAbsent
          ? const Value.absent()
          : Value(manualCleanupJson),
      createdAt: Value(createdAt),
    );
  }

  factory NarrationTranscriptionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationTranscriptionLog(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      rawTranscript: serializer.fromJson<String>(json['rawTranscript']),
      correctedTranscript: serializer.fromJson<String?>(
        json['correctedTranscript'],
      ),
      confidence: serializer.fromJson<String>(json['confidence']),
      uncertainSegmentsJson: serializer.fromJson<String>(
        json['uncertainSegmentsJson'],
      ),
      confirmationResult: serializer.fromJson<String>(
        json['confirmationResult'],
      ),
      rerecorded: serializer.fromJson<bool>(json['rerecorded']),
      alignmentStatus: serializer.fromJson<String?>(json['alignmentStatus']),
      manualCleanupJson: serializer.fromJson<String?>(
        json['manualCleanupJson'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'rawTranscript': serializer.toJson<String>(rawTranscript),
      'correctedTranscript': serializer.toJson<String?>(correctedTranscript),
      'confidence': serializer.toJson<String>(confidence),
      'uncertainSegmentsJson': serializer.toJson<String>(uncertainSegmentsJson),
      'confirmationResult': serializer.toJson<String>(confirmationResult),
      'rerecorded': serializer.toJson<bool>(rerecorded),
      'alignmentStatus': serializer.toJson<String?>(alignmentStatus),
      'manualCleanupJson': serializer.toJson<String?>(manualCleanupJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NarrationTranscriptionLog copyWith({
    int? id,
    int? sessionId,
    String? rawTranscript,
    Value<String?> correctedTranscript = const Value.absent(),
    String? confidence,
    String? uncertainSegmentsJson,
    String? confirmationResult,
    bool? rerecorded,
    Value<String?> alignmentStatus = const Value.absent(),
    Value<String?> manualCleanupJson = const Value.absent(),
    int? createdAt,
  }) => NarrationTranscriptionLog(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    rawTranscript: rawTranscript ?? this.rawTranscript,
    correctedTranscript: correctedTranscript.present
        ? correctedTranscript.value
        : this.correctedTranscript,
    confidence: confidence ?? this.confidence,
    uncertainSegmentsJson: uncertainSegmentsJson ?? this.uncertainSegmentsJson,
    confirmationResult: confirmationResult ?? this.confirmationResult,
    rerecorded: rerecorded ?? this.rerecorded,
    alignmentStatus: alignmentStatus.present
        ? alignmentStatus.value
        : this.alignmentStatus,
    manualCleanupJson: manualCleanupJson.present
        ? manualCleanupJson.value
        : this.manualCleanupJson,
    createdAt: createdAt ?? this.createdAt,
  );
  NarrationTranscriptionLog copyWithCompanion(
    NarrationTranscriptionLogsCompanion data,
  ) {
    return NarrationTranscriptionLog(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      rawTranscript: data.rawTranscript.present
          ? data.rawTranscript.value
          : this.rawTranscript,
      correctedTranscript: data.correctedTranscript.present
          ? data.correctedTranscript.value
          : this.correctedTranscript,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      uncertainSegmentsJson: data.uncertainSegmentsJson.present
          ? data.uncertainSegmentsJson.value
          : this.uncertainSegmentsJson,
      confirmationResult: data.confirmationResult.present
          ? data.confirmationResult.value
          : this.confirmationResult,
      rerecorded: data.rerecorded.present
          ? data.rerecorded.value
          : this.rerecorded,
      alignmentStatus: data.alignmentStatus.present
          ? data.alignmentStatus.value
          : this.alignmentStatus,
      manualCleanupJson: data.manualCleanupJson.present
          ? data.manualCleanupJson.value
          : this.manualCleanupJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationTranscriptionLog(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('correctedTranscript: $correctedTranscript, ')
          ..write('confidence: $confidence, ')
          ..write('uncertainSegmentsJson: $uncertainSegmentsJson, ')
          ..write('confirmationResult: $confirmationResult, ')
          ..write('rerecorded: $rerecorded, ')
          ..write('alignmentStatus: $alignmentStatus, ')
          ..write('manualCleanupJson: $manualCleanupJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    rawTranscript,
    correctedTranscript,
    confidence,
    uncertainSegmentsJson,
    confirmationResult,
    rerecorded,
    alignmentStatus,
    manualCleanupJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationTranscriptionLog &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.rawTranscript == this.rawTranscript &&
          other.correctedTranscript == this.correctedTranscript &&
          other.confidence == this.confidence &&
          other.uncertainSegmentsJson == this.uncertainSegmentsJson &&
          other.confirmationResult == this.confirmationResult &&
          other.rerecorded == this.rerecorded &&
          other.alignmentStatus == this.alignmentStatus &&
          other.manualCleanupJson == this.manualCleanupJson &&
          other.createdAt == this.createdAt);
}

class NarrationTranscriptionLogsCompanion
    extends UpdateCompanion<NarrationTranscriptionLog> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> rawTranscript;
  final Value<String?> correctedTranscript;
  final Value<String> confidence;
  final Value<String> uncertainSegmentsJson;
  final Value<String> confirmationResult;
  final Value<bool> rerecorded;
  final Value<String?> alignmentStatus;
  final Value<String?> manualCleanupJson;
  final Value<int> createdAt;
  const NarrationTranscriptionLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.correctedTranscript = const Value.absent(),
    this.confidence = const Value.absent(),
    this.uncertainSegmentsJson = const Value.absent(),
    this.confirmationResult = const Value.absent(),
    this.rerecorded = const Value.absent(),
    this.alignmentStatus = const Value.absent(),
    this.manualCleanupJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NarrationTranscriptionLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String rawTranscript,
    this.correctedTranscript = const Value.absent(),
    required String confidence,
    required String uncertainSegmentsJson,
    required String confirmationResult,
    this.rerecorded = const Value.absent(),
    this.alignmentStatus = const Value.absent(),
    this.manualCleanupJson = const Value.absent(),
    required int createdAt,
  }) : sessionId = Value(sessionId),
       rawTranscript = Value(rawTranscript),
       confidence = Value(confidence),
       uncertainSegmentsJson = Value(uncertainSegmentsJson),
       confirmationResult = Value(confirmationResult),
       createdAt = Value(createdAt);
  static Insertable<NarrationTranscriptionLog> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? rawTranscript,
    Expression<String>? correctedTranscript,
    Expression<String>? confidence,
    Expression<String>? uncertainSegmentsJson,
    Expression<String>? confirmationResult,
    Expression<bool>? rerecorded,
    Expression<String>? alignmentStatus,
    Expression<String>? manualCleanupJson,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (rawTranscript != null) 'raw_transcript': rawTranscript,
      if (correctedTranscript != null)
        'corrected_transcript': correctedTranscript,
      if (confidence != null) 'confidence': confidence,
      if (uncertainSegmentsJson != null)
        'uncertain_segments_json': uncertainSegmentsJson,
      if (confirmationResult != null) 'confirmation_result': confirmationResult,
      if (rerecorded != null) 'rerecorded': rerecorded,
      if (alignmentStatus != null) 'alignment_status': alignmentStatus,
      if (manualCleanupJson != null) 'manual_cleanup_json': manualCleanupJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NarrationTranscriptionLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? rawTranscript,
    Value<String?>? correctedTranscript,
    Value<String>? confidence,
    Value<String>? uncertainSegmentsJson,
    Value<String>? confirmationResult,
    Value<bool>? rerecorded,
    Value<String?>? alignmentStatus,
    Value<String?>? manualCleanupJson,
    Value<int>? createdAt,
  }) {
    return NarrationTranscriptionLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      correctedTranscript: correctedTranscript ?? this.correctedTranscript,
      confidence: confidence ?? this.confidence,
      uncertainSegmentsJson:
          uncertainSegmentsJson ?? this.uncertainSegmentsJson,
      confirmationResult: confirmationResult ?? this.confirmationResult,
      rerecorded: rerecorded ?? this.rerecorded,
      alignmentStatus: alignmentStatus ?? this.alignmentStatus,
      manualCleanupJson: manualCleanupJson ?? this.manualCleanupJson,
      createdAt: createdAt ?? this.createdAt,
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
    if (rawTranscript.present) {
      map['raw_transcript'] = Variable<String>(rawTranscript.value);
    }
    if (correctedTranscript.present) {
      map['corrected_transcript'] = Variable<String>(correctedTranscript.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (uncertainSegmentsJson.present) {
      map['uncertain_segments_json'] = Variable<String>(
        uncertainSegmentsJson.value,
      );
    }
    if (confirmationResult.present) {
      map['confirmation_result'] = Variable<String>(confirmationResult.value);
    }
    if (rerecorded.present) {
      map['rerecorded'] = Variable<bool>(rerecorded.value);
    }
    if (alignmentStatus.present) {
      map['alignment_status'] = Variable<String>(alignmentStatus.value);
    }
    if (manualCleanupJson.present) {
      map['manual_cleanup_json'] = Variable<String>(manualCleanupJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationTranscriptionLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('correctedTranscript: $correctedTranscript, ')
          ..write('confidence: $confidence, ')
          ..write('uncertainSegmentsJson: $uncertainSegmentsJson, ')
          ..write('confirmationResult: $confirmationResult, ')
          ..write('rerecorded: $rerecorded, ')
          ..write('alignmentStatus: $alignmentStatus, ')
          ..write('manualCleanupJson: $manualCleanupJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationSelfCheckLogsTable extends NarrationSelfCheckLogs
    with TableInfo<$NarrationSelfCheckLogsTable, NarrationSelfCheckLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationSelfCheckLogsTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES narration_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reportJsonMeta = const VerificationMeta(
    'reportJson',
  );
  @override
  late final GeneratedColumn<String> reportJson = GeneratedColumn<String>(
    'report_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iterationCountMeta = const VerificationMeta(
    'iterationCount',
  );
  @override
  late final GeneratedColumn<int> iterationCount = GeneratedColumn<int>(
    'iteration_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
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
    sessionId,
    reportJson,
    iterationCount,
    passed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_self_check_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationSelfCheckLog> instance, {
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
    if (data.containsKey('report_json')) {
      context.handle(
        _reportJsonMeta,
        reportJson.isAcceptableOrUnknown(data['report_json']!, _reportJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_reportJsonMeta);
    }
    if (data.containsKey('iteration_count')) {
      context.handle(
        _iterationCountMeta,
        iterationCount.isAcceptableOrUnknown(
          data['iteration_count']!,
          _iterationCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iterationCountMeta);
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    } else if (isInserting) {
      context.missing(_passedMeta);
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
  NarrationSelfCheckLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationSelfCheckLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      reportJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_json'],
      )!,
      iterationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iteration_count'],
      )!,
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NarrationSelfCheckLogsTable createAlias(String alias) {
    return $NarrationSelfCheckLogsTable(attachedDatabase, alias);
  }
}

class NarrationSelfCheckLog extends DataClass
    implements Insertable<NarrationSelfCheckLog> {
  final int id;
  final int sessionId;
  final String reportJson;
  final int iterationCount;
  final bool passed;
  final int createdAt;
  const NarrationSelfCheckLog({
    required this.id,
    required this.sessionId,
    required this.reportJson,
    required this.iterationCount,
    required this.passed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['report_json'] = Variable<String>(reportJson);
    map['iteration_count'] = Variable<int>(iterationCount);
    map['passed'] = Variable<bool>(passed);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NarrationSelfCheckLogsCompanion toCompanion(bool nullToAbsent) {
    return NarrationSelfCheckLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      reportJson: Value(reportJson),
      iterationCount: Value(iterationCount),
      passed: Value(passed),
      createdAt: Value(createdAt),
    );
  }

  factory NarrationSelfCheckLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationSelfCheckLog(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      reportJson: serializer.fromJson<String>(json['reportJson']),
      iterationCount: serializer.fromJson<int>(json['iterationCount']),
      passed: serializer.fromJson<bool>(json['passed']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'reportJson': serializer.toJson<String>(reportJson),
      'iterationCount': serializer.toJson<int>(iterationCount),
      'passed': serializer.toJson<bool>(passed),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NarrationSelfCheckLog copyWith({
    int? id,
    int? sessionId,
    String? reportJson,
    int? iterationCount,
    bool? passed,
    int? createdAt,
  }) => NarrationSelfCheckLog(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    reportJson: reportJson ?? this.reportJson,
    iterationCount: iterationCount ?? this.iterationCount,
    passed: passed ?? this.passed,
    createdAt: createdAt ?? this.createdAt,
  );
  NarrationSelfCheckLog copyWithCompanion(
    NarrationSelfCheckLogsCompanion data,
  ) {
    return NarrationSelfCheckLog(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      reportJson: data.reportJson.present
          ? data.reportJson.value
          : this.reportJson,
      iterationCount: data.iterationCount.present
          ? data.iterationCount.value
          : this.iterationCount,
      passed: data.passed.present ? data.passed.value : this.passed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationSelfCheckLog(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('reportJson: $reportJson, ')
          ..write('iterationCount: $iterationCount, ')
          ..write('passed: $passed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, reportJson, iterationCount, passed, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationSelfCheckLog &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.reportJson == this.reportJson &&
          other.iterationCount == this.iterationCount &&
          other.passed == this.passed &&
          other.createdAt == this.createdAt);
}

class NarrationSelfCheckLogsCompanion
    extends UpdateCompanion<NarrationSelfCheckLog> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> reportJson;
  final Value<int> iterationCount;
  final Value<bool> passed;
  final Value<int> createdAt;
  const NarrationSelfCheckLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.reportJson = const Value.absent(),
    this.iterationCount = const Value.absent(),
    this.passed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NarrationSelfCheckLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String reportJson,
    required int iterationCount,
    required bool passed,
    required int createdAt,
  }) : sessionId = Value(sessionId),
       reportJson = Value(reportJson),
       iterationCount = Value(iterationCount),
       passed = Value(passed),
       createdAt = Value(createdAt);
  static Insertable<NarrationSelfCheckLog> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? reportJson,
    Expression<int>? iterationCount,
    Expression<bool>? passed,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (reportJson != null) 'report_json': reportJson,
      if (iterationCount != null) 'iteration_count': iterationCount,
      if (passed != null) 'passed': passed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NarrationSelfCheckLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? reportJson,
    Value<int>? iterationCount,
    Value<bool>? passed,
    Value<int>? createdAt,
  }) {
    return NarrationSelfCheckLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      reportJson: reportJson ?? this.reportJson,
      iterationCount: iterationCount ?? this.iterationCount,
      passed: passed ?? this.passed,
      createdAt: createdAt ?? this.createdAt,
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
    if (reportJson.present) {
      map['report_json'] = Variable<String>(reportJson.value);
    }
    if (iterationCount.present) {
      map['iteration_count'] = Variable<int>(iterationCount.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationSelfCheckLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('reportJson: $reportJson, ')
          ..write('iterationCount: $iterationCount, ')
          ..write('passed: $passed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationFeedbackLogsTable extends NarrationFeedbackLogs
    with TableInfo<$NarrationFeedbackLogsTable, NarrationFeedbackLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationFeedbackLogsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES narration_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _learningItemIdMeta = const VerificationMeta(
    'learningItemId',
  );
  @override
  late final GeneratedColumn<int> learningItemId = GeneratedColumn<int>(
    'learning_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalJudgementMeta = const VerificationMeta(
    'originalJudgement',
  );
  @override
  late final GeneratedColumn<String> originalJudgement =
      GeneratedColumn<String>(
        'original_judgement',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _systemExplanationMeta = const VerificationMeta(
    'systemExplanation',
  );
  @override
  late final GeneratedColumn<String> systemExplanation =
      GeneratedColumn<String>(
        'system_explanation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _userReasonMeta = const VerificationMeta(
    'userReason',
  );
  @override
  late final GeneratedColumn<String> userReason = GeneratedColumn<String>(
    'user_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customResultMeta = const VerificationMeta(
    'customResult',
  );
  @override
  late final GeneratedColumn<String> customResult = GeneratedColumn<String>(
    'custom_result',
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
    sessionId,
    learningItemId,
    stage,
    originalJudgement,
    systemExplanation,
    userReason,
    resolution,
    customResult,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_feedback_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationFeedbackLog> instance, {
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
    }
    if (data.containsKey('learning_item_id')) {
      context.handle(
        _learningItemIdMeta,
        learningItemId.isAcceptableOrUnknown(
          data['learning_item_id']!,
          _learningItemIdMeta,
        ),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('original_judgement')) {
      context.handle(
        _originalJudgementMeta,
        originalJudgement.isAcceptableOrUnknown(
          data['original_judgement']!,
          _originalJudgementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalJudgementMeta);
    }
    if (data.containsKey('system_explanation')) {
      context.handle(
        _systemExplanationMeta,
        systemExplanation.isAcceptableOrUnknown(
          data['system_explanation']!,
          _systemExplanationMeta,
        ),
      );
    }
    if (data.containsKey('user_reason')) {
      context.handle(
        _userReasonMeta,
        userReason.isAcceptableOrUnknown(data['user_reason']!, _userReasonMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    } else if (isInserting) {
      context.missing(_resolutionMeta);
    }
    if (data.containsKey('custom_result')) {
      context.handle(
        _customResultMeta,
        customResult.isAcceptableOrUnknown(
          data['custom_result']!,
          _customResultMeta,
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
  NarrationFeedbackLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationFeedbackLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      learningItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_item_id'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      originalJudgement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_judgement'],
      )!,
      systemExplanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_explanation'],
      ),
      userReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_reason'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      )!,
      customResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_result'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NarrationFeedbackLogsTable createAlias(String alias) {
    return $NarrationFeedbackLogsTable(attachedDatabase, alias);
  }
}

class NarrationFeedbackLog extends DataClass
    implements Insertable<NarrationFeedbackLog> {
  final int id;
  final int? sessionId;
  final int? learningItemId;
  final String stage;
  final String originalJudgement;
  final String? systemExplanation;
  final String? userReason;
  final String resolution;
  final String? customResult;
  final int createdAt;
  const NarrationFeedbackLog({
    required this.id,
    this.sessionId,
    this.learningItemId,
    required this.stage,
    required this.originalJudgement,
    this.systemExplanation,
    this.userReason,
    required this.resolution,
    this.customResult,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    if (!nullToAbsent || learningItemId != null) {
      map['learning_item_id'] = Variable<int>(learningItemId);
    }
    map['stage'] = Variable<String>(stage);
    map['original_judgement'] = Variable<String>(originalJudgement);
    if (!nullToAbsent || systemExplanation != null) {
      map['system_explanation'] = Variable<String>(systemExplanation);
    }
    if (!nullToAbsent || userReason != null) {
      map['user_reason'] = Variable<String>(userReason);
    }
    map['resolution'] = Variable<String>(resolution);
    if (!nullToAbsent || customResult != null) {
      map['custom_result'] = Variable<String>(customResult);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NarrationFeedbackLogsCompanion toCompanion(bool nullToAbsent) {
    return NarrationFeedbackLogsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      learningItemId: learningItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(learningItemId),
      stage: Value(stage),
      originalJudgement: Value(originalJudgement),
      systemExplanation: systemExplanation == null && nullToAbsent
          ? const Value.absent()
          : Value(systemExplanation),
      userReason: userReason == null && nullToAbsent
          ? const Value.absent()
          : Value(userReason),
      resolution: Value(resolution),
      customResult: customResult == null && nullToAbsent
          ? const Value.absent()
          : Value(customResult),
      createdAt: Value(createdAt),
    );
  }

  factory NarrationFeedbackLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationFeedbackLog(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      learningItemId: serializer.fromJson<int?>(json['learningItemId']),
      stage: serializer.fromJson<String>(json['stage']),
      originalJudgement: serializer.fromJson<String>(json['originalJudgement']),
      systemExplanation: serializer.fromJson<String?>(
        json['systemExplanation'],
      ),
      userReason: serializer.fromJson<String?>(json['userReason']),
      resolution: serializer.fromJson<String>(json['resolution']),
      customResult: serializer.fromJson<String?>(json['customResult']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'learningItemId': serializer.toJson<int?>(learningItemId),
      'stage': serializer.toJson<String>(stage),
      'originalJudgement': serializer.toJson<String>(originalJudgement),
      'systemExplanation': serializer.toJson<String?>(systemExplanation),
      'userReason': serializer.toJson<String?>(userReason),
      'resolution': serializer.toJson<String>(resolution),
      'customResult': serializer.toJson<String?>(customResult),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NarrationFeedbackLog copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    Value<int?> learningItemId = const Value.absent(),
    String? stage,
    String? originalJudgement,
    Value<String?> systemExplanation = const Value.absent(),
    Value<String?> userReason = const Value.absent(),
    String? resolution,
    Value<String?> customResult = const Value.absent(),
    int? createdAt,
  }) => NarrationFeedbackLog(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    learningItemId: learningItemId.present
        ? learningItemId.value
        : this.learningItemId,
    stage: stage ?? this.stage,
    originalJudgement: originalJudgement ?? this.originalJudgement,
    systemExplanation: systemExplanation.present
        ? systemExplanation.value
        : this.systemExplanation,
    userReason: userReason.present ? userReason.value : this.userReason,
    resolution: resolution ?? this.resolution,
    customResult: customResult.present ? customResult.value : this.customResult,
    createdAt: createdAt ?? this.createdAt,
  );
  NarrationFeedbackLog copyWithCompanion(NarrationFeedbackLogsCompanion data) {
    return NarrationFeedbackLog(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      learningItemId: data.learningItemId.present
          ? data.learningItemId.value
          : this.learningItemId,
      stage: data.stage.present ? data.stage.value : this.stage,
      originalJudgement: data.originalJudgement.present
          ? data.originalJudgement.value
          : this.originalJudgement,
      systemExplanation: data.systemExplanation.present
          ? data.systemExplanation.value
          : this.systemExplanation,
      userReason: data.userReason.present
          ? data.userReason.value
          : this.userReason,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      customResult: data.customResult.present
          ? data.customResult.value
          : this.customResult,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationFeedbackLog(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('learningItemId: $learningItemId, ')
          ..write('stage: $stage, ')
          ..write('originalJudgement: $originalJudgement, ')
          ..write('systemExplanation: $systemExplanation, ')
          ..write('userReason: $userReason, ')
          ..write('resolution: $resolution, ')
          ..write('customResult: $customResult, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    learningItemId,
    stage,
    originalJudgement,
    systemExplanation,
    userReason,
    resolution,
    customResult,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationFeedbackLog &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.learningItemId == this.learningItemId &&
          other.stage == this.stage &&
          other.originalJudgement == this.originalJudgement &&
          other.systemExplanation == this.systemExplanation &&
          other.userReason == this.userReason &&
          other.resolution == this.resolution &&
          other.customResult == this.customResult &&
          other.createdAt == this.createdAt);
}

class NarrationFeedbackLogsCompanion
    extends UpdateCompanion<NarrationFeedbackLog> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<int?> learningItemId;
  final Value<String> stage;
  final Value<String> originalJudgement;
  final Value<String?> systemExplanation;
  final Value<String?> userReason;
  final Value<String> resolution;
  final Value<String?> customResult;
  final Value<int> createdAt;
  const NarrationFeedbackLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.learningItemId = const Value.absent(),
    this.stage = const Value.absent(),
    this.originalJudgement = const Value.absent(),
    this.systemExplanation = const Value.absent(),
    this.userReason = const Value.absent(),
    this.resolution = const Value.absent(),
    this.customResult = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NarrationFeedbackLogsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.learningItemId = const Value.absent(),
    required String stage,
    required String originalJudgement,
    this.systemExplanation = const Value.absent(),
    this.userReason = const Value.absent(),
    required String resolution,
    this.customResult = const Value.absent(),
    required int createdAt,
  }) : stage = Value(stage),
       originalJudgement = Value(originalJudgement),
       resolution = Value(resolution),
       createdAt = Value(createdAt);
  static Insertable<NarrationFeedbackLog> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? learningItemId,
    Expression<String>? stage,
    Expression<String>? originalJudgement,
    Expression<String>? systemExplanation,
    Expression<String>? userReason,
    Expression<String>? resolution,
    Expression<String>? customResult,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (learningItemId != null) 'learning_item_id': learningItemId,
      if (stage != null) 'stage': stage,
      if (originalJudgement != null) 'original_judgement': originalJudgement,
      if (systemExplanation != null) 'system_explanation': systemExplanation,
      if (userReason != null) 'user_reason': userReason,
      if (resolution != null) 'resolution': resolution,
      if (customResult != null) 'custom_result': customResult,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NarrationFeedbackLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<int?>? learningItemId,
    Value<String>? stage,
    Value<String>? originalJudgement,
    Value<String?>? systemExplanation,
    Value<String?>? userReason,
    Value<String>? resolution,
    Value<String?>? customResult,
    Value<int>? createdAt,
  }) {
    return NarrationFeedbackLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      learningItemId: learningItemId ?? this.learningItemId,
      stage: stage ?? this.stage,
      originalJudgement: originalJudgement ?? this.originalJudgement,
      systemExplanation: systemExplanation ?? this.systemExplanation,
      userReason: userReason ?? this.userReason,
      resolution: resolution ?? this.resolution,
      customResult: customResult ?? this.customResult,
      createdAt: createdAt ?? this.createdAt,
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
    if (learningItemId.present) {
      map['learning_item_id'] = Variable<int>(learningItemId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (originalJudgement.present) {
      map['original_judgement'] = Variable<String>(originalJudgement.value);
    }
    if (systemExplanation.present) {
      map['system_explanation'] = Variable<String>(systemExplanation.value);
    }
    if (userReason.present) {
      map['user_reason'] = Variable<String>(userReason.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (customResult.present) {
      map['custom_result'] = Variable<String>(customResult.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationFeedbackLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('learningItemId: $learningItemId, ')
          ..write('stage: $stage, ')
          ..write('originalJudgement: $originalJudgement, ')
          ..write('systemExplanation: $systemExplanation, ')
          ..write('userReason: $userReason, ')
          ..write('resolution: $resolution, ')
          ..write('customResult: $customResult, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationLearningItemsTable extends NarrationLearningItems
    with TableInfo<$NarrationLearningItemsTable, NarrationLearningItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationLearningItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stableKeyMeta = const VerificationMeta(
    'stableKey',
  );
  @override
  late final GeneratedColumn<String> stableKey = GeneratedColumn<String>(
    'stable_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishMeta = const VerificationMeta(
    'english',
  );
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
    'english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chineseMeta = const VerificationMeta(
    'chinese',
  );
  @override
  late final GeneratedColumn<String> chinese = GeneratedColumn<String>(
    'chinese',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _classificationMeta = const VerificationMeta(
    'classification',
  );
  @override
  late final GeneratedColumn<String> classification = GeneratedColumn<String>(
    'classification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _knowledgeLevelMeta = const VerificationMeta(
    'knowledgeLevel',
  );
  @override
  late final GeneratedColumn<String> knowledgeLevel = GeneratedColumn<String>(
    'knowledge_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reviewRequiredMeta = const VerificationMeta(
    'reviewRequired',
  );
  @override
  late final GeneratedColumn<bool> reviewRequired = GeneratedColumn<bool>(
    'review_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("review_required" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<int> firstSeenAt = GeneratedColumn<int>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenAt = GeneratedColumn<int>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceCountMeta = const VerificationMeta(
    'occurrenceCount',
  );
  @override
  late final GeneratedColumn<int> occurrenceCount = GeneratedColumn<int>(
    'occurrence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _masteryStateMeta = const VerificationMeta(
    'masteryState',
  );
  @override
  late final GeneratedColumn<String> masteryState = GeneratedColumn<String>(
    'mastery_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _reviewPassCountMeta = const VerificationMeta(
    'reviewPassCount',
  );
  @override
  late final GeneratedColumn<int> reviewPassCount = GeneratedColumn<int>(
    'review_pass_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recognitionPassedMeta = const VerificationMeta(
    'recognitionPassed',
  );
  @override
  late final GeneratedColumn<bool> recognitionPassed = GeneratedColumn<bool>(
    'recognition_passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recognition_passed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _applicationPassedMeta = const VerificationMeta(
    'applicationPassed',
  );
  @override
  late final GeneratedColumn<bool> applicationPassed = GeneratedColumn<bool>(
    'application_passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("application_passed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _realUseSuccessCountMeta =
      const VerificationMeta('realUseSuccessCount');
  @override
  late final GeneratedColumn<int> realUseSuccessCount = GeneratedColumn<int>(
    'real_use_success_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _realUseFailureCountMeta =
      const VerificationMeta('realUseFailureCount');
  @override
  late final GeneratedColumn<int> realUseFailureCount = GeneratedColumn<int>(
    'real_use_failure_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<int> nextReviewAt = GeneratedColumn<int>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewIntervalIndexMeta =
      const VerificationMeta('reviewIntervalIndex');
  @override
  late final GeneratedColumn<int> reviewIntervalIndex = GeneratedColumn<int>(
    'review_interval_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastTriggerAtMeta = const VerificationMeta(
    'lastTriggerAt',
  );
  @override
  late final GeneratedColumn<int> lastTriggerAt = GeneratedColumn<int>(
    'last_trigger_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFailureAtMeta = const VerificationMeta(
    'lastFailureAt',
  );
  @override
  late final GeneratedColumn<int> lastFailureAt = GeneratedColumn<int>(
    'last_failure_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queueStateMeta = const VerificationMeta(
    'queueState',
  );
  @override
  late final GeneratedColumn<String> queueState = GeneratedColumn<String>(
    'queue_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _userConfirmedMeta = const VerificationMeta(
    'userConfirmed',
  );
  @override
  late final GeneratedColumn<bool> userConfirmed = GeneratedColumn<bool>(
    'user_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemType,
    stableKey,
    english,
    chinese,
    partOfSpeech,
    classification,
    knowledgeLevel,
    explanation,
    reviewRequired,
    firstSeenAt,
    lastSeenAt,
    occurrenceCount,
    masteryState,
    reviewPassCount,
    recognitionPassed,
    applicationPassed,
    realUseSuccessCount,
    realUseFailureCount,
    nextReviewAt,
    reviewIntervalIndex,
    lastTriggerAt,
    lastFailureAt,
    queueState,
    userConfirmed,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_learning_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationLearningItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('stable_key')) {
      context.handle(
        _stableKeyMeta,
        stableKey.isAcceptableOrUnknown(data['stable_key']!, _stableKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stableKeyMeta);
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('chinese')) {
      context.handle(
        _chineseMeta,
        chinese.isAcceptableOrUnknown(data['chinese']!, _chineseMeta),
      );
    } else if (isInserting) {
      context.missing(_chineseMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('classification')) {
      context.handle(
        _classificationMeta,
        classification.isAcceptableOrUnknown(
          data['classification']!,
          _classificationMeta,
        ),
      );
    }
    if (data.containsKey('knowledge_level')) {
      context.handle(
        _knowledgeLevelMeta,
        knowledgeLevel.isAcceptableOrUnknown(
          data['knowledge_level']!,
          _knowledgeLevelMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('review_required')) {
      context.handle(
        _reviewRequiredMeta,
        reviewRequired.isAcceptableOrUnknown(
          data['review_required']!,
          _reviewRequiredMeta,
        ),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('occurrence_count')) {
      context.handle(
        _occurrenceCountMeta,
        occurrenceCount.isAcceptableOrUnknown(
          data['occurrence_count']!,
          _occurrenceCountMeta,
        ),
      );
    }
    if (data.containsKey('mastery_state')) {
      context.handle(
        _masteryStateMeta,
        masteryState.isAcceptableOrUnknown(
          data['mastery_state']!,
          _masteryStateMeta,
        ),
      );
    }
    if (data.containsKey('review_pass_count')) {
      context.handle(
        _reviewPassCountMeta,
        reviewPassCount.isAcceptableOrUnknown(
          data['review_pass_count']!,
          _reviewPassCountMeta,
        ),
      );
    }
    if (data.containsKey('recognition_passed')) {
      context.handle(
        _recognitionPassedMeta,
        recognitionPassed.isAcceptableOrUnknown(
          data['recognition_passed']!,
          _recognitionPassedMeta,
        ),
      );
    }
    if (data.containsKey('application_passed')) {
      context.handle(
        _applicationPassedMeta,
        applicationPassed.isAcceptableOrUnknown(
          data['application_passed']!,
          _applicationPassedMeta,
        ),
      );
    }
    if (data.containsKey('real_use_success_count')) {
      context.handle(
        _realUseSuccessCountMeta,
        realUseSuccessCount.isAcceptableOrUnknown(
          data['real_use_success_count']!,
          _realUseSuccessCountMeta,
        ),
      );
    }
    if (data.containsKey('real_use_failure_count')) {
      context.handle(
        _realUseFailureCountMeta,
        realUseFailureCount.isAcceptableOrUnknown(
          data['real_use_failure_count']!,
          _realUseFailureCountMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('review_interval_index')) {
      context.handle(
        _reviewIntervalIndexMeta,
        reviewIntervalIndex.isAcceptableOrUnknown(
          data['review_interval_index']!,
          _reviewIntervalIndexMeta,
        ),
      );
    }
    if (data.containsKey('last_trigger_at')) {
      context.handle(
        _lastTriggerAtMeta,
        lastTriggerAt.isAcceptableOrUnknown(
          data['last_trigger_at']!,
          _lastTriggerAtMeta,
        ),
      );
    }
    if (data.containsKey('last_failure_at')) {
      context.handle(
        _lastFailureAtMeta,
        lastFailureAt.isAcceptableOrUnknown(
          data['last_failure_at']!,
          _lastFailureAtMeta,
        ),
      );
    }
    if (data.containsKey('queue_state')) {
      context.handle(
        _queueStateMeta,
        queueState.isAcceptableOrUnknown(data['queue_state']!, _queueStateMeta),
      );
    }
    if (data.containsKey('user_confirmed')) {
      context.handle(
        _userConfirmedMeta,
        userConfirmed.isAcceptableOrUnknown(
          data['user_confirmed']!,
          _userConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NarrationLearningItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationLearningItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      stableKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stable_key'],
      )!,
      english: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english'],
      )!,
      chinese: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chinese'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      classification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification'],
      )!,
      knowledgeLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}knowledge_level'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      reviewRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}review_required'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at'],
      )!,
      occurrenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_count'],
      )!,
      masteryState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mastery_state'],
      )!,
      reviewPassCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_pass_count'],
      )!,
      recognitionPassed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recognition_passed'],
      )!,
      applicationPassed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}application_passed'],
      )!,
      realUseSuccessCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}real_use_success_count'],
      )!,
      realUseFailureCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}real_use_failure_count'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_review_at'],
      ),
      reviewIntervalIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_interval_index'],
      )!,
      lastTriggerAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_trigger_at'],
      ),
      lastFailureAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_failure_at'],
      ),
      queueState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_state'],
      )!,
      userConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_confirmed'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $NarrationLearningItemsTable createAlias(String alias) {
    return $NarrationLearningItemsTable(attachedDatabase, alias);
  }
}

class NarrationLearningItem extends DataClass
    implements Insertable<NarrationLearningItem> {
  final int id;
  final String itemType;
  final String stableKey;
  final String english;
  final String chinese;
  final String partOfSpeech;
  final String classification;
  final String knowledgeLevel;
  final String explanation;
  final bool reviewRequired;
  final int firstSeenAt;
  final int lastSeenAt;
  final int occurrenceCount;
  final String masteryState;
  final int reviewPassCount;
  final bool recognitionPassed;
  final bool applicationPassed;
  final int realUseSuccessCount;
  final int realUseFailureCount;
  final int? nextReviewAt;
  final int reviewIntervalIndex;
  final int? lastTriggerAt;
  final int? lastFailureAt;
  final String queueState;
  final bool userConfirmed;
  final String notes;
  const NarrationLearningItem({
    required this.id,
    required this.itemType,
    required this.stableKey,
    required this.english,
    required this.chinese,
    required this.partOfSpeech,
    required this.classification,
    required this.knowledgeLevel,
    required this.explanation,
    required this.reviewRequired,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.occurrenceCount,
    required this.masteryState,
    required this.reviewPassCount,
    required this.recognitionPassed,
    required this.applicationPassed,
    required this.realUseSuccessCount,
    required this.realUseFailureCount,
    this.nextReviewAt,
    required this.reviewIntervalIndex,
    this.lastTriggerAt,
    this.lastFailureAt,
    required this.queueState,
    required this.userConfirmed,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_type'] = Variable<String>(itemType);
    map['stable_key'] = Variable<String>(stableKey);
    map['english'] = Variable<String>(english);
    map['chinese'] = Variable<String>(chinese);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['classification'] = Variable<String>(classification);
    map['knowledge_level'] = Variable<String>(knowledgeLevel);
    map['explanation'] = Variable<String>(explanation);
    map['review_required'] = Variable<bool>(reviewRequired);
    map['first_seen_at'] = Variable<int>(firstSeenAt);
    map['last_seen_at'] = Variable<int>(lastSeenAt);
    map['occurrence_count'] = Variable<int>(occurrenceCount);
    map['mastery_state'] = Variable<String>(masteryState);
    map['review_pass_count'] = Variable<int>(reviewPassCount);
    map['recognition_passed'] = Variable<bool>(recognitionPassed);
    map['application_passed'] = Variable<bool>(applicationPassed);
    map['real_use_success_count'] = Variable<int>(realUseSuccessCount);
    map['real_use_failure_count'] = Variable<int>(realUseFailureCount);
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<int>(nextReviewAt);
    }
    map['review_interval_index'] = Variable<int>(reviewIntervalIndex);
    if (!nullToAbsent || lastTriggerAt != null) {
      map['last_trigger_at'] = Variable<int>(lastTriggerAt);
    }
    if (!nullToAbsent || lastFailureAt != null) {
      map['last_failure_at'] = Variable<int>(lastFailureAt);
    }
    map['queue_state'] = Variable<String>(queueState);
    map['user_confirmed'] = Variable<bool>(userConfirmed);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  NarrationLearningItemsCompanion toCompanion(bool nullToAbsent) {
    return NarrationLearningItemsCompanion(
      id: Value(id),
      itemType: Value(itemType),
      stableKey: Value(stableKey),
      english: Value(english),
      chinese: Value(chinese),
      partOfSpeech: Value(partOfSpeech),
      classification: Value(classification),
      knowledgeLevel: Value(knowledgeLevel),
      explanation: Value(explanation),
      reviewRequired: Value(reviewRequired),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
      occurrenceCount: Value(occurrenceCount),
      masteryState: Value(masteryState),
      reviewPassCount: Value(reviewPassCount),
      recognitionPassed: Value(recognitionPassed),
      applicationPassed: Value(applicationPassed),
      realUseSuccessCount: Value(realUseSuccessCount),
      realUseFailureCount: Value(realUseFailureCount),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      reviewIntervalIndex: Value(reviewIntervalIndex),
      lastTriggerAt: lastTriggerAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTriggerAt),
      lastFailureAt: lastFailureAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFailureAt),
      queueState: Value(queueState),
      userConfirmed: Value(userConfirmed),
      notes: Value(notes),
    );
  }

  factory NarrationLearningItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationLearningItem(
      id: serializer.fromJson<int>(json['id']),
      itemType: serializer.fromJson<String>(json['itemType']),
      stableKey: serializer.fromJson<String>(json['stableKey']),
      english: serializer.fromJson<String>(json['english']),
      chinese: serializer.fromJson<String>(json['chinese']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      classification: serializer.fromJson<String>(json['classification']),
      knowledgeLevel: serializer.fromJson<String>(json['knowledgeLevel']),
      explanation: serializer.fromJson<String>(json['explanation']),
      reviewRequired: serializer.fromJson<bool>(json['reviewRequired']),
      firstSeenAt: serializer.fromJson<int>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<int>(json['lastSeenAt']),
      occurrenceCount: serializer.fromJson<int>(json['occurrenceCount']),
      masteryState: serializer.fromJson<String>(json['masteryState']),
      reviewPassCount: serializer.fromJson<int>(json['reviewPassCount']),
      recognitionPassed: serializer.fromJson<bool>(json['recognitionPassed']),
      applicationPassed: serializer.fromJson<bool>(json['applicationPassed']),
      realUseSuccessCount: serializer.fromJson<int>(
        json['realUseSuccessCount'],
      ),
      realUseFailureCount: serializer.fromJson<int>(
        json['realUseFailureCount'],
      ),
      nextReviewAt: serializer.fromJson<int?>(json['nextReviewAt']),
      reviewIntervalIndex: serializer.fromJson<int>(
        json['reviewIntervalIndex'],
      ),
      lastTriggerAt: serializer.fromJson<int?>(json['lastTriggerAt']),
      lastFailureAt: serializer.fromJson<int?>(json['lastFailureAt']),
      queueState: serializer.fromJson<String>(json['queueState']),
      userConfirmed: serializer.fromJson<bool>(json['userConfirmed']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemType': serializer.toJson<String>(itemType),
      'stableKey': serializer.toJson<String>(stableKey),
      'english': serializer.toJson<String>(english),
      'chinese': serializer.toJson<String>(chinese),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'classification': serializer.toJson<String>(classification),
      'knowledgeLevel': serializer.toJson<String>(knowledgeLevel),
      'explanation': serializer.toJson<String>(explanation),
      'reviewRequired': serializer.toJson<bool>(reviewRequired),
      'firstSeenAt': serializer.toJson<int>(firstSeenAt),
      'lastSeenAt': serializer.toJson<int>(lastSeenAt),
      'occurrenceCount': serializer.toJson<int>(occurrenceCount),
      'masteryState': serializer.toJson<String>(masteryState),
      'reviewPassCount': serializer.toJson<int>(reviewPassCount),
      'recognitionPassed': serializer.toJson<bool>(recognitionPassed),
      'applicationPassed': serializer.toJson<bool>(applicationPassed),
      'realUseSuccessCount': serializer.toJson<int>(realUseSuccessCount),
      'realUseFailureCount': serializer.toJson<int>(realUseFailureCount),
      'nextReviewAt': serializer.toJson<int?>(nextReviewAt),
      'reviewIntervalIndex': serializer.toJson<int>(reviewIntervalIndex),
      'lastTriggerAt': serializer.toJson<int?>(lastTriggerAt),
      'lastFailureAt': serializer.toJson<int?>(lastFailureAt),
      'queueState': serializer.toJson<String>(queueState),
      'userConfirmed': serializer.toJson<bool>(userConfirmed),
      'notes': serializer.toJson<String>(notes),
    };
  }

  NarrationLearningItem copyWith({
    int? id,
    String? itemType,
    String? stableKey,
    String? english,
    String? chinese,
    String? partOfSpeech,
    String? classification,
    String? knowledgeLevel,
    String? explanation,
    bool? reviewRequired,
    int? firstSeenAt,
    int? lastSeenAt,
    int? occurrenceCount,
    String? masteryState,
    int? reviewPassCount,
    bool? recognitionPassed,
    bool? applicationPassed,
    int? realUseSuccessCount,
    int? realUseFailureCount,
    Value<int?> nextReviewAt = const Value.absent(),
    int? reviewIntervalIndex,
    Value<int?> lastTriggerAt = const Value.absent(),
    Value<int?> lastFailureAt = const Value.absent(),
    String? queueState,
    bool? userConfirmed,
    String? notes,
  }) => NarrationLearningItem(
    id: id ?? this.id,
    itemType: itemType ?? this.itemType,
    stableKey: stableKey ?? this.stableKey,
    english: english ?? this.english,
    chinese: chinese ?? this.chinese,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    classification: classification ?? this.classification,
    knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
    explanation: explanation ?? this.explanation,
    reviewRequired: reviewRequired ?? this.reviewRequired,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    masteryState: masteryState ?? this.masteryState,
    reviewPassCount: reviewPassCount ?? this.reviewPassCount,
    recognitionPassed: recognitionPassed ?? this.recognitionPassed,
    applicationPassed: applicationPassed ?? this.applicationPassed,
    realUseSuccessCount: realUseSuccessCount ?? this.realUseSuccessCount,
    realUseFailureCount: realUseFailureCount ?? this.realUseFailureCount,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    reviewIntervalIndex: reviewIntervalIndex ?? this.reviewIntervalIndex,
    lastTriggerAt: lastTriggerAt.present
        ? lastTriggerAt.value
        : this.lastTriggerAt,
    lastFailureAt: lastFailureAt.present
        ? lastFailureAt.value
        : this.lastFailureAt,
    queueState: queueState ?? this.queueState,
    userConfirmed: userConfirmed ?? this.userConfirmed,
    notes: notes ?? this.notes,
  );
  NarrationLearningItem copyWithCompanion(
    NarrationLearningItemsCompanion data,
  ) {
    return NarrationLearningItem(
      id: data.id.present ? data.id.value : this.id,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      stableKey: data.stableKey.present ? data.stableKey.value : this.stableKey,
      english: data.english.present ? data.english.value : this.english,
      chinese: data.chinese.present ? data.chinese.value : this.chinese,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      classification: data.classification.present
          ? data.classification.value
          : this.classification,
      knowledgeLevel: data.knowledgeLevel.present
          ? data.knowledgeLevel.value
          : this.knowledgeLevel,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      reviewRequired: data.reviewRequired.present
          ? data.reviewRequired.value
          : this.reviewRequired,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      occurrenceCount: data.occurrenceCount.present
          ? data.occurrenceCount.value
          : this.occurrenceCount,
      masteryState: data.masteryState.present
          ? data.masteryState.value
          : this.masteryState,
      reviewPassCount: data.reviewPassCount.present
          ? data.reviewPassCount.value
          : this.reviewPassCount,
      recognitionPassed: data.recognitionPassed.present
          ? data.recognitionPassed.value
          : this.recognitionPassed,
      applicationPassed: data.applicationPassed.present
          ? data.applicationPassed.value
          : this.applicationPassed,
      realUseSuccessCount: data.realUseSuccessCount.present
          ? data.realUseSuccessCount.value
          : this.realUseSuccessCount,
      realUseFailureCount: data.realUseFailureCount.present
          ? data.realUseFailureCount.value
          : this.realUseFailureCount,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      reviewIntervalIndex: data.reviewIntervalIndex.present
          ? data.reviewIntervalIndex.value
          : this.reviewIntervalIndex,
      lastTriggerAt: data.lastTriggerAt.present
          ? data.lastTriggerAt.value
          : this.lastTriggerAt,
      lastFailureAt: data.lastFailureAt.present
          ? data.lastFailureAt.value
          : this.lastFailureAt,
      queueState: data.queueState.present
          ? data.queueState.value
          : this.queueState,
      userConfirmed: data.userConfirmed.present
          ? data.userConfirmed.value
          : this.userConfirmed,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationLearningItem(')
          ..write('id: $id, ')
          ..write('itemType: $itemType, ')
          ..write('stableKey: $stableKey, ')
          ..write('english: $english, ')
          ..write('chinese: $chinese, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('classification: $classification, ')
          ..write('knowledgeLevel: $knowledgeLevel, ')
          ..write('explanation: $explanation, ')
          ..write('reviewRequired: $reviewRequired, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('masteryState: $masteryState, ')
          ..write('reviewPassCount: $reviewPassCount, ')
          ..write('recognitionPassed: $recognitionPassed, ')
          ..write('applicationPassed: $applicationPassed, ')
          ..write('realUseSuccessCount: $realUseSuccessCount, ')
          ..write('realUseFailureCount: $realUseFailureCount, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('reviewIntervalIndex: $reviewIntervalIndex, ')
          ..write('lastTriggerAt: $lastTriggerAt, ')
          ..write('lastFailureAt: $lastFailureAt, ')
          ..write('queueState: $queueState, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    itemType,
    stableKey,
    english,
    chinese,
    partOfSpeech,
    classification,
    knowledgeLevel,
    explanation,
    reviewRequired,
    firstSeenAt,
    lastSeenAt,
    occurrenceCount,
    masteryState,
    reviewPassCount,
    recognitionPassed,
    applicationPassed,
    realUseSuccessCount,
    realUseFailureCount,
    nextReviewAt,
    reviewIntervalIndex,
    lastTriggerAt,
    lastFailureAt,
    queueState,
    userConfirmed,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationLearningItem &&
          other.id == this.id &&
          other.itemType == this.itemType &&
          other.stableKey == this.stableKey &&
          other.english == this.english &&
          other.chinese == this.chinese &&
          other.partOfSpeech == this.partOfSpeech &&
          other.classification == this.classification &&
          other.knowledgeLevel == this.knowledgeLevel &&
          other.explanation == this.explanation &&
          other.reviewRequired == this.reviewRequired &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.occurrenceCount == this.occurrenceCount &&
          other.masteryState == this.masteryState &&
          other.reviewPassCount == this.reviewPassCount &&
          other.recognitionPassed == this.recognitionPassed &&
          other.applicationPassed == this.applicationPassed &&
          other.realUseSuccessCount == this.realUseSuccessCount &&
          other.realUseFailureCount == this.realUseFailureCount &&
          other.nextReviewAt == this.nextReviewAt &&
          other.reviewIntervalIndex == this.reviewIntervalIndex &&
          other.lastTriggerAt == this.lastTriggerAt &&
          other.lastFailureAt == this.lastFailureAt &&
          other.queueState == this.queueState &&
          other.userConfirmed == this.userConfirmed &&
          other.notes == this.notes);
}

class NarrationLearningItemsCompanion
    extends UpdateCompanion<NarrationLearningItem> {
  final Value<int> id;
  final Value<String> itemType;
  final Value<String> stableKey;
  final Value<String> english;
  final Value<String> chinese;
  final Value<String> partOfSpeech;
  final Value<String> classification;
  final Value<String> knowledgeLevel;
  final Value<String> explanation;
  final Value<bool> reviewRequired;
  final Value<int> firstSeenAt;
  final Value<int> lastSeenAt;
  final Value<int> occurrenceCount;
  final Value<String> masteryState;
  final Value<int> reviewPassCount;
  final Value<bool> recognitionPassed;
  final Value<bool> applicationPassed;
  final Value<int> realUseSuccessCount;
  final Value<int> realUseFailureCount;
  final Value<int?> nextReviewAt;
  final Value<int> reviewIntervalIndex;
  final Value<int?> lastTriggerAt;
  final Value<int?> lastFailureAt;
  final Value<String> queueState;
  final Value<bool> userConfirmed;
  final Value<String> notes;
  const NarrationLearningItemsCompanion({
    this.id = const Value.absent(),
    this.itemType = const Value.absent(),
    this.stableKey = const Value.absent(),
    this.english = const Value.absent(),
    this.chinese = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.classification = const Value.absent(),
    this.knowledgeLevel = const Value.absent(),
    this.explanation = const Value.absent(),
    this.reviewRequired = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.masteryState = const Value.absent(),
    this.reviewPassCount = const Value.absent(),
    this.recognitionPassed = const Value.absent(),
    this.applicationPassed = const Value.absent(),
    this.realUseSuccessCount = const Value.absent(),
    this.realUseFailureCount = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.reviewIntervalIndex = const Value.absent(),
    this.lastTriggerAt = const Value.absent(),
    this.lastFailureAt = const Value.absent(),
    this.queueState = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.notes = const Value.absent(),
  });
  NarrationLearningItemsCompanion.insert({
    this.id = const Value.absent(),
    required String itemType,
    required String stableKey,
    required String english,
    required String chinese,
    this.partOfSpeech = const Value.absent(),
    this.classification = const Value.absent(),
    this.knowledgeLevel = const Value.absent(),
    this.explanation = const Value.absent(),
    this.reviewRequired = const Value.absent(),
    required int firstSeenAt,
    required int lastSeenAt,
    this.occurrenceCount = const Value.absent(),
    this.masteryState = const Value.absent(),
    this.reviewPassCount = const Value.absent(),
    this.recognitionPassed = const Value.absent(),
    this.applicationPassed = const Value.absent(),
    this.realUseSuccessCount = const Value.absent(),
    this.realUseFailureCount = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.reviewIntervalIndex = const Value.absent(),
    this.lastTriggerAt = const Value.absent(),
    this.lastFailureAt = const Value.absent(),
    this.queueState = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.notes = const Value.absent(),
  }) : itemType = Value(itemType),
       stableKey = Value(stableKey),
       english = Value(english),
       chinese = Value(chinese),
       firstSeenAt = Value(firstSeenAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<NarrationLearningItem> custom({
    Expression<int>? id,
    Expression<String>? itemType,
    Expression<String>? stableKey,
    Expression<String>? english,
    Expression<String>? chinese,
    Expression<String>? partOfSpeech,
    Expression<String>? classification,
    Expression<String>? knowledgeLevel,
    Expression<String>? explanation,
    Expression<bool>? reviewRequired,
    Expression<int>? firstSeenAt,
    Expression<int>? lastSeenAt,
    Expression<int>? occurrenceCount,
    Expression<String>? masteryState,
    Expression<int>? reviewPassCount,
    Expression<bool>? recognitionPassed,
    Expression<bool>? applicationPassed,
    Expression<int>? realUseSuccessCount,
    Expression<int>? realUseFailureCount,
    Expression<int>? nextReviewAt,
    Expression<int>? reviewIntervalIndex,
    Expression<int>? lastTriggerAt,
    Expression<int>? lastFailureAt,
    Expression<String>? queueState,
    Expression<bool>? userConfirmed,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemType != null) 'item_type': itemType,
      if (stableKey != null) 'stable_key': stableKey,
      if (english != null) 'english': english,
      if (chinese != null) 'chinese': chinese,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (classification != null) 'classification': classification,
      if (knowledgeLevel != null) 'knowledge_level': knowledgeLevel,
      if (explanation != null) 'explanation': explanation,
      if (reviewRequired != null) 'review_required': reviewRequired,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
      if (masteryState != null) 'mastery_state': masteryState,
      if (reviewPassCount != null) 'review_pass_count': reviewPassCount,
      if (recognitionPassed != null) 'recognition_passed': recognitionPassed,
      if (applicationPassed != null) 'application_passed': applicationPassed,
      if (realUseSuccessCount != null)
        'real_use_success_count': realUseSuccessCount,
      if (realUseFailureCount != null)
        'real_use_failure_count': realUseFailureCount,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (reviewIntervalIndex != null)
        'review_interval_index': reviewIntervalIndex,
      if (lastTriggerAt != null) 'last_trigger_at': lastTriggerAt,
      if (lastFailureAt != null) 'last_failure_at': lastFailureAt,
      if (queueState != null) 'queue_state': queueState,
      if (userConfirmed != null) 'user_confirmed': userConfirmed,
      if (notes != null) 'notes': notes,
    });
  }

  NarrationLearningItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? itemType,
    Value<String>? stableKey,
    Value<String>? english,
    Value<String>? chinese,
    Value<String>? partOfSpeech,
    Value<String>? classification,
    Value<String>? knowledgeLevel,
    Value<String>? explanation,
    Value<bool>? reviewRequired,
    Value<int>? firstSeenAt,
    Value<int>? lastSeenAt,
    Value<int>? occurrenceCount,
    Value<String>? masteryState,
    Value<int>? reviewPassCount,
    Value<bool>? recognitionPassed,
    Value<bool>? applicationPassed,
    Value<int>? realUseSuccessCount,
    Value<int>? realUseFailureCount,
    Value<int?>? nextReviewAt,
    Value<int>? reviewIntervalIndex,
    Value<int?>? lastTriggerAt,
    Value<int?>? lastFailureAt,
    Value<String>? queueState,
    Value<bool>? userConfirmed,
    Value<String>? notes,
  }) {
    return NarrationLearningItemsCompanion(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      stableKey: stableKey ?? this.stableKey,
      english: english ?? this.english,
      chinese: chinese ?? this.chinese,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      classification: classification ?? this.classification,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      explanation: explanation ?? this.explanation,
      reviewRequired: reviewRequired ?? this.reviewRequired,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      masteryState: masteryState ?? this.masteryState,
      reviewPassCount: reviewPassCount ?? this.reviewPassCount,
      recognitionPassed: recognitionPassed ?? this.recognitionPassed,
      applicationPassed: applicationPassed ?? this.applicationPassed,
      realUseSuccessCount: realUseSuccessCount ?? this.realUseSuccessCount,
      realUseFailureCount: realUseFailureCount ?? this.realUseFailureCount,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewIntervalIndex: reviewIntervalIndex ?? this.reviewIntervalIndex,
      lastTriggerAt: lastTriggerAt ?? this.lastTriggerAt,
      lastFailureAt: lastFailureAt ?? this.lastFailureAt,
      queueState: queueState ?? this.queueState,
      userConfirmed: userConfirmed ?? this.userConfirmed,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (stableKey.present) {
      map['stable_key'] = Variable<String>(stableKey.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (chinese.present) {
      map['chinese'] = Variable<String>(chinese.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (classification.present) {
      map['classification'] = Variable<String>(classification.value);
    }
    if (knowledgeLevel.present) {
      map['knowledge_level'] = Variable<String>(knowledgeLevel.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (reviewRequired.present) {
      map['review_required'] = Variable<bool>(reviewRequired.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<int>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<int>(lastSeenAt.value);
    }
    if (occurrenceCount.present) {
      map['occurrence_count'] = Variable<int>(occurrenceCount.value);
    }
    if (masteryState.present) {
      map['mastery_state'] = Variable<String>(masteryState.value);
    }
    if (reviewPassCount.present) {
      map['review_pass_count'] = Variable<int>(reviewPassCount.value);
    }
    if (recognitionPassed.present) {
      map['recognition_passed'] = Variable<bool>(recognitionPassed.value);
    }
    if (applicationPassed.present) {
      map['application_passed'] = Variable<bool>(applicationPassed.value);
    }
    if (realUseSuccessCount.present) {
      map['real_use_success_count'] = Variable<int>(realUseSuccessCount.value);
    }
    if (realUseFailureCount.present) {
      map['real_use_failure_count'] = Variable<int>(realUseFailureCount.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<int>(nextReviewAt.value);
    }
    if (reviewIntervalIndex.present) {
      map['review_interval_index'] = Variable<int>(reviewIntervalIndex.value);
    }
    if (lastTriggerAt.present) {
      map['last_trigger_at'] = Variable<int>(lastTriggerAt.value);
    }
    if (lastFailureAt.present) {
      map['last_failure_at'] = Variable<int>(lastFailureAt.value);
    }
    if (queueState.present) {
      map['queue_state'] = Variable<String>(queueState.value);
    }
    if (userConfirmed.present) {
      map['user_confirmed'] = Variable<bool>(userConfirmed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationLearningItemsCompanion(')
          ..write('id: $id, ')
          ..write('itemType: $itemType, ')
          ..write('stableKey: $stableKey, ')
          ..write('english: $english, ')
          ..write('chinese: $chinese, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('classification: $classification, ')
          ..write('knowledgeLevel: $knowledgeLevel, ')
          ..write('explanation: $explanation, ')
          ..write('reviewRequired: $reviewRequired, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('masteryState: $masteryState, ')
          ..write('reviewPassCount: $reviewPassCount, ')
          ..write('recognitionPassed: $recognitionPassed, ')
          ..write('applicationPassed: $applicationPassed, ')
          ..write('realUseSuccessCount: $realUseSuccessCount, ')
          ..write('realUseFailureCount: $realUseFailureCount, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('reviewIntervalIndex: $reviewIntervalIndex, ')
          ..write('lastTriggerAt: $lastTriggerAt, ')
          ..write('lastFailureAt: $lastFailureAt, ')
          ..write('queueState: $queueState, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $NarrationLearningSourcesTable extends NarrationLearningSources
    with TableInfo<$NarrationLearningSourcesTable, NarrationLearningSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationLearningSourcesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _learningItemIdMeta = const VerificationMeta(
    'learningItemId',
  );
  @override
  late final GeneratedColumn<int> learningItemId = GeneratedColumn<int>(
    'learning_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES narration_learning_items (id) ON DELETE CASCADE',
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
      'REFERENCES narration_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorGradeMeta = const VerificationMeta(
    'errorGrade',
  );
  @override
  late final GeneratedColumn<String> errorGrade = GeneratedColumn<String>(
    'error_grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evidenceMeta = const VerificationMeta(
    'evidence',
  );
  @override
  late final GeneratedColumn<String> evidence = GeneratedColumn<String>(
    'evidence',
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
    learningItemId,
    sessionId,
    sourceType,
    errorGrade,
    evidence,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_learning_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationLearningSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('learning_item_id')) {
      context.handle(
        _learningItemIdMeta,
        learningItemId.isAcceptableOrUnknown(
          data['learning_item_id']!,
          _learningItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningItemIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('error_grade')) {
      context.handle(
        _errorGradeMeta,
        errorGrade.isAcceptableOrUnknown(data['error_grade']!, _errorGradeMeta),
      );
    }
    if (data.containsKey('evidence')) {
      context.handle(
        _evidenceMeta,
        evidence.isAcceptableOrUnknown(data['evidence']!, _evidenceMeta),
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
  NarrationLearningSource map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationLearningSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      learningItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_item_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      errorGrade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_grade'],
      ),
      evidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NarrationLearningSourcesTable createAlias(String alias) {
    return $NarrationLearningSourcesTable(attachedDatabase, alias);
  }
}

class NarrationLearningSource extends DataClass
    implements Insertable<NarrationLearningSource> {
  final int id;
  final int learningItemId;
  final int sessionId;
  final String sourceType;
  final String? errorGrade;
  final String? evidence;
  final int createdAt;
  const NarrationLearningSource({
    required this.id,
    required this.learningItemId,
    required this.sessionId,
    required this.sourceType,
    this.errorGrade,
    this.evidence,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['learning_item_id'] = Variable<int>(learningItemId);
    map['session_id'] = Variable<int>(sessionId);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || errorGrade != null) {
      map['error_grade'] = Variable<String>(errorGrade);
    }
    if (!nullToAbsent || evidence != null) {
      map['evidence'] = Variable<String>(evidence);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NarrationLearningSourcesCompanion toCompanion(bool nullToAbsent) {
    return NarrationLearningSourcesCompanion(
      id: Value(id),
      learningItemId: Value(learningItemId),
      sessionId: Value(sessionId),
      sourceType: Value(sourceType),
      errorGrade: errorGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(errorGrade),
      evidence: evidence == null && nullToAbsent
          ? const Value.absent()
          : Value(evidence),
      createdAt: Value(createdAt),
    );
  }

  factory NarrationLearningSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationLearningSource(
      id: serializer.fromJson<int>(json['id']),
      learningItemId: serializer.fromJson<int>(json['learningItemId']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      errorGrade: serializer.fromJson<String?>(json['errorGrade']),
      evidence: serializer.fromJson<String?>(json['evidence']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'learningItemId': serializer.toJson<int>(learningItemId),
      'sessionId': serializer.toJson<int>(sessionId),
      'sourceType': serializer.toJson<String>(sourceType),
      'errorGrade': serializer.toJson<String?>(errorGrade),
      'evidence': serializer.toJson<String?>(evidence),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NarrationLearningSource copyWith({
    int? id,
    int? learningItemId,
    int? sessionId,
    String? sourceType,
    Value<String?> errorGrade = const Value.absent(),
    Value<String?> evidence = const Value.absent(),
    int? createdAt,
  }) => NarrationLearningSource(
    id: id ?? this.id,
    learningItemId: learningItemId ?? this.learningItemId,
    sessionId: sessionId ?? this.sessionId,
    sourceType: sourceType ?? this.sourceType,
    errorGrade: errorGrade.present ? errorGrade.value : this.errorGrade,
    evidence: evidence.present ? evidence.value : this.evidence,
    createdAt: createdAt ?? this.createdAt,
  );
  NarrationLearningSource copyWithCompanion(
    NarrationLearningSourcesCompanion data,
  ) {
    return NarrationLearningSource(
      id: data.id.present ? data.id.value : this.id,
      learningItemId: data.learningItemId.present
          ? data.learningItemId.value
          : this.learningItemId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      errorGrade: data.errorGrade.present
          ? data.errorGrade.value
          : this.errorGrade,
      evidence: data.evidence.present ? data.evidence.value : this.evidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationLearningSource(')
          ..write('id: $id, ')
          ..write('learningItemId: $learningItemId, ')
          ..write('sessionId: $sessionId, ')
          ..write('sourceType: $sourceType, ')
          ..write('errorGrade: $errorGrade, ')
          ..write('evidence: $evidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    learningItemId,
    sessionId,
    sourceType,
    errorGrade,
    evidence,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationLearningSource &&
          other.id == this.id &&
          other.learningItemId == this.learningItemId &&
          other.sessionId == this.sessionId &&
          other.sourceType == this.sourceType &&
          other.errorGrade == this.errorGrade &&
          other.evidence == this.evidence &&
          other.createdAt == this.createdAt);
}

class NarrationLearningSourcesCompanion
    extends UpdateCompanion<NarrationLearningSource> {
  final Value<int> id;
  final Value<int> learningItemId;
  final Value<int> sessionId;
  final Value<String> sourceType;
  final Value<String?> errorGrade;
  final Value<String?> evidence;
  final Value<int> createdAt;
  const NarrationLearningSourcesCompanion({
    this.id = const Value.absent(),
    this.learningItemId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.errorGrade = const Value.absent(),
    this.evidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NarrationLearningSourcesCompanion.insert({
    this.id = const Value.absent(),
    required int learningItemId,
    required int sessionId,
    required String sourceType,
    this.errorGrade = const Value.absent(),
    this.evidence = const Value.absent(),
    required int createdAt,
  }) : learningItemId = Value(learningItemId),
       sessionId = Value(sessionId),
       sourceType = Value(sourceType),
       createdAt = Value(createdAt);
  static Insertable<NarrationLearningSource> custom({
    Expression<int>? id,
    Expression<int>? learningItemId,
    Expression<int>? sessionId,
    Expression<String>? sourceType,
    Expression<String>? errorGrade,
    Expression<String>? evidence,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (learningItemId != null) 'learning_item_id': learningItemId,
      if (sessionId != null) 'session_id': sessionId,
      if (sourceType != null) 'source_type': sourceType,
      if (errorGrade != null) 'error_grade': errorGrade,
      if (evidence != null) 'evidence': evidence,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NarrationLearningSourcesCompanion copyWith({
    Value<int>? id,
    Value<int>? learningItemId,
    Value<int>? sessionId,
    Value<String>? sourceType,
    Value<String?>? errorGrade,
    Value<String?>? evidence,
    Value<int>? createdAt,
  }) {
    return NarrationLearningSourcesCompanion(
      id: id ?? this.id,
      learningItemId: learningItemId ?? this.learningItemId,
      sessionId: sessionId ?? this.sessionId,
      sourceType: sourceType ?? this.sourceType,
      errorGrade: errorGrade ?? this.errorGrade,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (learningItemId.present) {
      map['learning_item_id'] = Variable<int>(learningItemId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (errorGrade.present) {
      map['error_grade'] = Variable<String>(errorGrade.value);
    }
    if (evidence.present) {
      map['evidence'] = Variable<String>(evidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationLearningSourcesCompanion(')
          ..write('id: $id, ')
          ..write('learningItemId: $learningItemId, ')
          ..write('sessionId: $sessionId, ')
          ..write('sourceType: $sourceType, ')
          ..write('errorGrade: $errorGrade, ')
          ..write('evidence: $evidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationReviewRecordsTable extends NarrationReviewRecords
    with TableInfo<$NarrationReviewRecordsTable, NarrationReviewRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationReviewRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _learningItemIdMeta = const VerificationMeta(
    'learningItemId',
  );
  @override
  late final GeneratedColumn<int> learningItemId = GeneratedColumn<int>(
    'learning_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES narration_learning_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _layerMeta = const VerificationMeta('layer');
  @override
  late final GeneratedColumn<String> layer = GeneratedColumn<String>(
    'layer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guidedMeta = const VerificationMeta('guided');
  @override
  late final GeneratedColumn<bool> guided = GeneratedColumn<bool>(
    'guided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("guided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evidenceMeta = const VerificationMeta(
    'evidence',
  );
  @override
  late final GeneratedColumn<String> evidence = GeneratedColumn<String>(
    'evidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    learningItemId,
    layer,
    outcome,
    guided,
    answer,
    evidence,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_review_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationReviewRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('learning_item_id')) {
      context.handle(
        _learningItemIdMeta,
        learningItemId.isAcceptableOrUnknown(
          data['learning_item_id']!,
          _learningItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningItemIdMeta);
    }
    if (data.containsKey('layer')) {
      context.handle(
        _layerMeta,
        layer.isAcceptableOrUnknown(data['layer']!, _layerMeta),
      );
    } else if (isInserting) {
      context.missing(_layerMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('guided')) {
      context.handle(
        _guidedMeta,
        guided.isAcceptableOrUnknown(data['guided']!, _guidedMeta),
      );
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    }
    if (data.containsKey('evidence')) {
      context.handle(
        _evidenceMeta,
        evidence.isAcceptableOrUnknown(data['evidence']!, _evidenceMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NarrationReviewRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationReviewRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      learningItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_item_id'],
      )!,
      layer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layer'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      guided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}guided'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      ),
      evidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_at'],
      )!,
    );
  }

  @override
  $NarrationReviewRecordsTable createAlias(String alias) {
    return $NarrationReviewRecordsTable(attachedDatabase, alias);
  }
}

class NarrationReviewRecord extends DataClass
    implements Insertable<NarrationReviewRecord> {
  final int id;
  final int learningItemId;
  final String layer;
  final String outcome;
  final bool guided;
  final String? answer;
  final String? evidence;
  final int reviewedAt;
  const NarrationReviewRecord({
    required this.id,
    required this.learningItemId,
    required this.layer,
    required this.outcome,
    required this.guided,
    this.answer,
    this.evidence,
    required this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['learning_item_id'] = Variable<int>(learningItemId);
    map['layer'] = Variable<String>(layer);
    map['outcome'] = Variable<String>(outcome);
    map['guided'] = Variable<bool>(guided);
    if (!nullToAbsent || answer != null) {
      map['answer'] = Variable<String>(answer);
    }
    if (!nullToAbsent || evidence != null) {
      map['evidence'] = Variable<String>(evidence);
    }
    map['reviewed_at'] = Variable<int>(reviewedAt);
    return map;
  }

  NarrationReviewRecordsCompanion toCompanion(bool nullToAbsent) {
    return NarrationReviewRecordsCompanion(
      id: Value(id),
      learningItemId: Value(learningItemId),
      layer: Value(layer),
      outcome: Value(outcome),
      guided: Value(guided),
      answer: answer == null && nullToAbsent
          ? const Value.absent()
          : Value(answer),
      evidence: evidence == null && nullToAbsent
          ? const Value.absent()
          : Value(evidence),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory NarrationReviewRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationReviewRecord(
      id: serializer.fromJson<int>(json['id']),
      learningItemId: serializer.fromJson<int>(json['learningItemId']),
      layer: serializer.fromJson<String>(json['layer']),
      outcome: serializer.fromJson<String>(json['outcome']),
      guided: serializer.fromJson<bool>(json['guided']),
      answer: serializer.fromJson<String?>(json['answer']),
      evidence: serializer.fromJson<String?>(json['evidence']),
      reviewedAt: serializer.fromJson<int>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'learningItemId': serializer.toJson<int>(learningItemId),
      'layer': serializer.toJson<String>(layer),
      'outcome': serializer.toJson<String>(outcome),
      'guided': serializer.toJson<bool>(guided),
      'answer': serializer.toJson<String?>(answer),
      'evidence': serializer.toJson<String?>(evidence),
      'reviewedAt': serializer.toJson<int>(reviewedAt),
    };
  }

  NarrationReviewRecord copyWith({
    int? id,
    int? learningItemId,
    String? layer,
    String? outcome,
    bool? guided,
    Value<String?> answer = const Value.absent(),
    Value<String?> evidence = const Value.absent(),
    int? reviewedAt,
  }) => NarrationReviewRecord(
    id: id ?? this.id,
    learningItemId: learningItemId ?? this.learningItemId,
    layer: layer ?? this.layer,
    outcome: outcome ?? this.outcome,
    guided: guided ?? this.guided,
    answer: answer.present ? answer.value : this.answer,
    evidence: evidence.present ? evidence.value : this.evidence,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  NarrationReviewRecord copyWithCompanion(
    NarrationReviewRecordsCompanion data,
  ) {
    return NarrationReviewRecord(
      id: data.id.present ? data.id.value : this.id,
      learningItemId: data.learningItemId.present
          ? data.learningItemId.value
          : this.learningItemId,
      layer: data.layer.present ? data.layer.value : this.layer,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      guided: data.guided.present ? data.guided.value : this.guided,
      answer: data.answer.present ? data.answer.value : this.answer,
      evidence: data.evidence.present ? data.evidence.value : this.evidence,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationReviewRecord(')
          ..write('id: $id, ')
          ..write('learningItemId: $learningItemId, ')
          ..write('layer: $layer, ')
          ..write('outcome: $outcome, ')
          ..write('guided: $guided, ')
          ..write('answer: $answer, ')
          ..write('evidence: $evidence, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    learningItemId,
    layer,
    outcome,
    guided,
    answer,
    evidence,
    reviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationReviewRecord &&
          other.id == this.id &&
          other.learningItemId == this.learningItemId &&
          other.layer == this.layer &&
          other.outcome == this.outcome &&
          other.guided == this.guided &&
          other.answer == this.answer &&
          other.evidence == this.evidence &&
          other.reviewedAt == this.reviewedAt);
}

class NarrationReviewRecordsCompanion
    extends UpdateCompanion<NarrationReviewRecord> {
  final Value<int> id;
  final Value<int> learningItemId;
  final Value<String> layer;
  final Value<String> outcome;
  final Value<bool> guided;
  final Value<String?> answer;
  final Value<String?> evidence;
  final Value<int> reviewedAt;
  const NarrationReviewRecordsCompanion({
    this.id = const Value.absent(),
    this.learningItemId = const Value.absent(),
    this.layer = const Value.absent(),
    this.outcome = const Value.absent(),
    this.guided = const Value.absent(),
    this.answer = const Value.absent(),
    this.evidence = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  NarrationReviewRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int learningItemId,
    required String layer,
    required String outcome,
    this.guided = const Value.absent(),
    this.answer = const Value.absent(),
    this.evidence = const Value.absent(),
    required int reviewedAt,
  }) : learningItemId = Value(learningItemId),
       layer = Value(layer),
       outcome = Value(outcome),
       reviewedAt = Value(reviewedAt);
  static Insertable<NarrationReviewRecord> custom({
    Expression<int>? id,
    Expression<int>? learningItemId,
    Expression<String>? layer,
    Expression<String>? outcome,
    Expression<bool>? guided,
    Expression<String>? answer,
    Expression<String>? evidence,
    Expression<int>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (learningItemId != null) 'learning_item_id': learningItemId,
      if (layer != null) 'layer': layer,
      if (outcome != null) 'outcome': outcome,
      if (guided != null) 'guided': guided,
      if (answer != null) 'answer': answer,
      if (evidence != null) 'evidence': evidence,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  NarrationReviewRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? learningItemId,
    Value<String>? layer,
    Value<String>? outcome,
    Value<bool>? guided,
    Value<String?>? answer,
    Value<String?>? evidence,
    Value<int>? reviewedAt,
  }) {
    return NarrationReviewRecordsCompanion(
      id: id ?? this.id,
      learningItemId: learningItemId ?? this.learningItemId,
      layer: layer ?? this.layer,
      outcome: outcome ?? this.outcome,
      guided: guided ?? this.guided,
      answer: answer ?? this.answer,
      evidence: evidence ?? this.evidence,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (learningItemId.present) {
      map['learning_item_id'] = Variable<int>(learningItemId.value);
    }
    if (layer.present) {
      map['layer'] = Variable<String>(layer.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (guided.present) {
      map['guided'] = Variable<bool>(guided.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (evidence.present) {
      map['evidence'] = Variable<String>(evidence.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationReviewRecordsCompanion(')
          ..write('id: $id, ')
          ..write('learningItemId: $learningItemId, ')
          ..write('layer: $layer, ')
          ..write('outcome: $outcome, ')
          ..write('guided: $guided, ')
          ..write('answer: $answer, ')
          ..write('evidence: $evidence, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationProgressRecordsTable extends NarrationProgressRecords
    with TableInfo<$NarrationProgressRecordsTable, NarrationProgressRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationProgressRecordsTable(this.attachedDatabase, [this._alias]);
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
      'UNIQUE REFERENCES narration_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _errorACountMeta = const VerificationMeta(
    'errorACount',
  );
  @override
  late final GeneratedColumn<int> errorACount = GeneratedColumn<int>(
    'error_a_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorBCountMeta = const VerificationMeta(
    'errorBCount',
  );
  @override
  late final GeneratedColumn<int> errorBCount = GeneratedColumn<int>(
    'error_b_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCCountMeta = const VerificationMeta(
    'errorCCount',
  );
  @override
  late final GeneratedColumn<int> errorCCount = GeneratedColumn<int>(
    'error_c_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectedWordCountMeta =
      const VerificationMeta('collectedWordCount');
  @override
  late final GeneratedColumn<int> collectedWordCount = GeneratedColumn<int>(
    'collected_word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coreKnowledgeCountMeta =
      const VerificationMeta('coreKnowledgeCount');
  @override
  late final GeneratedColumn<int> coreKnowledgeCount = GeneratedColumn<int>(
    'core_knowledge_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _realUseSuccessCountMeta =
      const VerificationMeta('realUseSuccessCount');
  @override
  late final GeneratedColumn<int> realUseSuccessCount = GeneratedColumn<int>(
    'real_use_success_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _realUseFailureCountMeta =
      const VerificationMeta('realUseFailureCount');
  @override
  late final GeneratedColumn<int> realUseFailureCount = GeneratedColumn<int>(
    'real_use_failure_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishWordCountMeta = const VerificationMeta(
    'englishWordCount',
  );
  @override
  late final GeneratedColumn<int> englishWordCount = GeneratedColumn<int>(
    'english_word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentenceCountMeta = const VerificationMeta(
    'sentenceCount',
  );
  @override
  late final GeneratedColumn<int> sentenceCount = GeneratedColumn<int>(
    'sentence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chineseSubstituteCountMeta =
      const VerificationMeta('chineseSubstituteCount');
  @override
  late final GeneratedColumn<int> chineseSubstituteCount = GeneratedColumn<int>(
    'chinese_substitute_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _complexityMeta = const VerificationMeta(
    'complexity',
  );
  @override
  late final GeneratedColumn<double> complexity = GeneratedColumn<double>(
    'complexity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    sessionId,
    errorACount,
    errorBCount,
    errorCCount,
    collectedWordCount,
    coreKnowledgeCount,
    realUseSuccessCount,
    realUseFailureCount,
    englishWordCount,
    sentenceCount,
    chineseSubstituteCount,
    complexity,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_progress_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationProgressRecord> instance, {
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
    if (data.containsKey('error_a_count')) {
      context.handle(
        _errorACountMeta,
        errorACount.isAcceptableOrUnknown(
          data['error_a_count']!,
          _errorACountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_errorACountMeta);
    }
    if (data.containsKey('error_b_count')) {
      context.handle(
        _errorBCountMeta,
        errorBCount.isAcceptableOrUnknown(
          data['error_b_count']!,
          _errorBCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_errorBCountMeta);
    }
    if (data.containsKey('error_c_count')) {
      context.handle(
        _errorCCountMeta,
        errorCCount.isAcceptableOrUnknown(
          data['error_c_count']!,
          _errorCCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_errorCCountMeta);
    }
    if (data.containsKey('collected_word_count')) {
      context.handle(
        _collectedWordCountMeta,
        collectedWordCount.isAcceptableOrUnknown(
          data['collected_word_count']!,
          _collectedWordCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedWordCountMeta);
    }
    if (data.containsKey('core_knowledge_count')) {
      context.handle(
        _coreKnowledgeCountMeta,
        coreKnowledgeCount.isAcceptableOrUnknown(
          data['core_knowledge_count']!,
          _coreKnowledgeCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coreKnowledgeCountMeta);
    }
    if (data.containsKey('real_use_success_count')) {
      context.handle(
        _realUseSuccessCountMeta,
        realUseSuccessCount.isAcceptableOrUnknown(
          data['real_use_success_count']!,
          _realUseSuccessCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_realUseSuccessCountMeta);
    }
    if (data.containsKey('real_use_failure_count')) {
      context.handle(
        _realUseFailureCountMeta,
        realUseFailureCount.isAcceptableOrUnknown(
          data['real_use_failure_count']!,
          _realUseFailureCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_realUseFailureCountMeta);
    }
    if (data.containsKey('english_word_count')) {
      context.handle(
        _englishWordCountMeta,
        englishWordCount.isAcceptableOrUnknown(
          data['english_word_count']!,
          _englishWordCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_englishWordCountMeta);
    }
    if (data.containsKey('sentence_count')) {
      context.handle(
        _sentenceCountMeta,
        sentenceCount.isAcceptableOrUnknown(
          data['sentence_count']!,
          _sentenceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sentenceCountMeta);
    }
    if (data.containsKey('chinese_substitute_count')) {
      context.handle(
        _chineseSubstituteCountMeta,
        chineseSubstituteCount.isAcceptableOrUnknown(
          data['chinese_substitute_count']!,
          _chineseSubstituteCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chineseSubstituteCountMeta);
    }
    if (data.containsKey('complexity')) {
      context.handle(
        _complexityMeta,
        complexity.isAcceptableOrUnknown(data['complexity']!, _complexityMeta),
      );
    } else if (isInserting) {
      context.missing(_complexityMeta);
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
  NarrationProgressRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationProgressRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      errorACount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_a_count'],
      )!,
      errorBCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_b_count'],
      )!,
      errorCCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_c_count'],
      )!,
      collectedWordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collected_word_count'],
      )!,
      coreKnowledgeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}core_knowledge_count'],
      )!,
      realUseSuccessCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}real_use_success_count'],
      )!,
      realUseFailureCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}real_use_failure_count'],
      )!,
      englishWordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}english_word_count'],
      )!,
      sentenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sentence_count'],
      )!,
      chineseSubstituteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chinese_substitute_count'],
      )!,
      complexity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}complexity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NarrationProgressRecordsTable createAlias(String alias) {
    return $NarrationProgressRecordsTable(attachedDatabase, alias);
  }
}

class NarrationProgressRecord extends DataClass
    implements Insertable<NarrationProgressRecord> {
  final int id;
  final int sessionId;
  final int errorACount;
  final int errorBCount;
  final int errorCCount;
  final int collectedWordCount;
  final int coreKnowledgeCount;
  final int realUseSuccessCount;
  final int realUseFailureCount;
  final int englishWordCount;
  final int sentenceCount;
  final int chineseSubstituteCount;
  final double complexity;
  final int createdAt;
  const NarrationProgressRecord({
    required this.id,
    required this.sessionId,
    required this.errorACount,
    required this.errorBCount,
    required this.errorCCount,
    required this.collectedWordCount,
    required this.coreKnowledgeCount,
    required this.realUseSuccessCount,
    required this.realUseFailureCount,
    required this.englishWordCount,
    required this.sentenceCount,
    required this.chineseSubstituteCount,
    required this.complexity,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['error_a_count'] = Variable<int>(errorACount);
    map['error_b_count'] = Variable<int>(errorBCount);
    map['error_c_count'] = Variable<int>(errorCCount);
    map['collected_word_count'] = Variable<int>(collectedWordCount);
    map['core_knowledge_count'] = Variable<int>(coreKnowledgeCount);
    map['real_use_success_count'] = Variable<int>(realUseSuccessCount);
    map['real_use_failure_count'] = Variable<int>(realUseFailureCount);
    map['english_word_count'] = Variable<int>(englishWordCount);
    map['sentence_count'] = Variable<int>(sentenceCount);
    map['chinese_substitute_count'] = Variable<int>(chineseSubstituteCount);
    map['complexity'] = Variable<double>(complexity);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NarrationProgressRecordsCompanion toCompanion(bool nullToAbsent) {
    return NarrationProgressRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      errorACount: Value(errorACount),
      errorBCount: Value(errorBCount),
      errorCCount: Value(errorCCount),
      collectedWordCount: Value(collectedWordCount),
      coreKnowledgeCount: Value(coreKnowledgeCount),
      realUseSuccessCount: Value(realUseSuccessCount),
      realUseFailureCount: Value(realUseFailureCount),
      englishWordCount: Value(englishWordCount),
      sentenceCount: Value(sentenceCount),
      chineseSubstituteCount: Value(chineseSubstituteCount),
      complexity: Value(complexity),
      createdAt: Value(createdAt),
    );
  }

  factory NarrationProgressRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationProgressRecord(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      errorACount: serializer.fromJson<int>(json['errorACount']),
      errorBCount: serializer.fromJson<int>(json['errorBCount']),
      errorCCount: serializer.fromJson<int>(json['errorCCount']),
      collectedWordCount: serializer.fromJson<int>(json['collectedWordCount']),
      coreKnowledgeCount: serializer.fromJson<int>(json['coreKnowledgeCount']),
      realUseSuccessCount: serializer.fromJson<int>(
        json['realUseSuccessCount'],
      ),
      realUseFailureCount: serializer.fromJson<int>(
        json['realUseFailureCount'],
      ),
      englishWordCount: serializer.fromJson<int>(json['englishWordCount']),
      sentenceCount: serializer.fromJson<int>(json['sentenceCount']),
      chineseSubstituteCount: serializer.fromJson<int>(
        json['chineseSubstituteCount'],
      ),
      complexity: serializer.fromJson<double>(json['complexity']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'errorACount': serializer.toJson<int>(errorACount),
      'errorBCount': serializer.toJson<int>(errorBCount),
      'errorCCount': serializer.toJson<int>(errorCCount),
      'collectedWordCount': serializer.toJson<int>(collectedWordCount),
      'coreKnowledgeCount': serializer.toJson<int>(coreKnowledgeCount),
      'realUseSuccessCount': serializer.toJson<int>(realUseSuccessCount),
      'realUseFailureCount': serializer.toJson<int>(realUseFailureCount),
      'englishWordCount': serializer.toJson<int>(englishWordCount),
      'sentenceCount': serializer.toJson<int>(sentenceCount),
      'chineseSubstituteCount': serializer.toJson<int>(chineseSubstituteCount),
      'complexity': serializer.toJson<double>(complexity),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NarrationProgressRecord copyWith({
    int? id,
    int? sessionId,
    int? errorACount,
    int? errorBCount,
    int? errorCCount,
    int? collectedWordCount,
    int? coreKnowledgeCount,
    int? realUseSuccessCount,
    int? realUseFailureCount,
    int? englishWordCount,
    int? sentenceCount,
    int? chineseSubstituteCount,
    double? complexity,
    int? createdAt,
  }) => NarrationProgressRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    errorACount: errorACount ?? this.errorACount,
    errorBCount: errorBCount ?? this.errorBCount,
    errorCCount: errorCCount ?? this.errorCCount,
    collectedWordCount: collectedWordCount ?? this.collectedWordCount,
    coreKnowledgeCount: coreKnowledgeCount ?? this.coreKnowledgeCount,
    realUseSuccessCount: realUseSuccessCount ?? this.realUseSuccessCount,
    realUseFailureCount: realUseFailureCount ?? this.realUseFailureCount,
    englishWordCount: englishWordCount ?? this.englishWordCount,
    sentenceCount: sentenceCount ?? this.sentenceCount,
    chineseSubstituteCount:
        chineseSubstituteCount ?? this.chineseSubstituteCount,
    complexity: complexity ?? this.complexity,
    createdAt: createdAt ?? this.createdAt,
  );
  NarrationProgressRecord copyWithCompanion(
    NarrationProgressRecordsCompanion data,
  ) {
    return NarrationProgressRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      errorACount: data.errorACount.present
          ? data.errorACount.value
          : this.errorACount,
      errorBCount: data.errorBCount.present
          ? data.errorBCount.value
          : this.errorBCount,
      errorCCount: data.errorCCount.present
          ? data.errorCCount.value
          : this.errorCCount,
      collectedWordCount: data.collectedWordCount.present
          ? data.collectedWordCount.value
          : this.collectedWordCount,
      coreKnowledgeCount: data.coreKnowledgeCount.present
          ? data.coreKnowledgeCount.value
          : this.coreKnowledgeCount,
      realUseSuccessCount: data.realUseSuccessCount.present
          ? data.realUseSuccessCount.value
          : this.realUseSuccessCount,
      realUseFailureCount: data.realUseFailureCount.present
          ? data.realUseFailureCount.value
          : this.realUseFailureCount,
      englishWordCount: data.englishWordCount.present
          ? data.englishWordCount.value
          : this.englishWordCount,
      sentenceCount: data.sentenceCount.present
          ? data.sentenceCount.value
          : this.sentenceCount,
      chineseSubstituteCount: data.chineseSubstituteCount.present
          ? data.chineseSubstituteCount.value
          : this.chineseSubstituteCount,
      complexity: data.complexity.present
          ? data.complexity.value
          : this.complexity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationProgressRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('errorACount: $errorACount, ')
          ..write('errorBCount: $errorBCount, ')
          ..write('errorCCount: $errorCCount, ')
          ..write('collectedWordCount: $collectedWordCount, ')
          ..write('coreKnowledgeCount: $coreKnowledgeCount, ')
          ..write('realUseSuccessCount: $realUseSuccessCount, ')
          ..write('realUseFailureCount: $realUseFailureCount, ')
          ..write('englishWordCount: $englishWordCount, ')
          ..write('sentenceCount: $sentenceCount, ')
          ..write('chineseSubstituteCount: $chineseSubstituteCount, ')
          ..write('complexity: $complexity, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    errorACount,
    errorBCount,
    errorCCount,
    collectedWordCount,
    coreKnowledgeCount,
    realUseSuccessCount,
    realUseFailureCount,
    englishWordCount,
    sentenceCount,
    chineseSubstituteCount,
    complexity,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationProgressRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.errorACount == this.errorACount &&
          other.errorBCount == this.errorBCount &&
          other.errorCCount == this.errorCCount &&
          other.collectedWordCount == this.collectedWordCount &&
          other.coreKnowledgeCount == this.coreKnowledgeCount &&
          other.realUseSuccessCount == this.realUseSuccessCount &&
          other.realUseFailureCount == this.realUseFailureCount &&
          other.englishWordCount == this.englishWordCount &&
          other.sentenceCount == this.sentenceCount &&
          other.chineseSubstituteCount == this.chineseSubstituteCount &&
          other.complexity == this.complexity &&
          other.createdAt == this.createdAt);
}

class NarrationProgressRecordsCompanion
    extends UpdateCompanion<NarrationProgressRecord> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> errorACount;
  final Value<int> errorBCount;
  final Value<int> errorCCount;
  final Value<int> collectedWordCount;
  final Value<int> coreKnowledgeCount;
  final Value<int> realUseSuccessCount;
  final Value<int> realUseFailureCount;
  final Value<int> englishWordCount;
  final Value<int> sentenceCount;
  final Value<int> chineseSubstituteCount;
  final Value<double> complexity;
  final Value<int> createdAt;
  const NarrationProgressRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.errorACount = const Value.absent(),
    this.errorBCount = const Value.absent(),
    this.errorCCount = const Value.absent(),
    this.collectedWordCount = const Value.absent(),
    this.coreKnowledgeCount = const Value.absent(),
    this.realUseSuccessCount = const Value.absent(),
    this.realUseFailureCount = const Value.absent(),
    this.englishWordCount = const Value.absent(),
    this.sentenceCount = const Value.absent(),
    this.chineseSubstituteCount = const Value.absent(),
    this.complexity = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NarrationProgressRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int errorACount,
    required int errorBCount,
    required int errorCCount,
    required int collectedWordCount,
    required int coreKnowledgeCount,
    required int realUseSuccessCount,
    required int realUseFailureCount,
    required int englishWordCount,
    required int sentenceCount,
    required int chineseSubstituteCount,
    required double complexity,
    required int createdAt,
  }) : sessionId = Value(sessionId),
       errorACount = Value(errorACount),
       errorBCount = Value(errorBCount),
       errorCCount = Value(errorCCount),
       collectedWordCount = Value(collectedWordCount),
       coreKnowledgeCount = Value(coreKnowledgeCount),
       realUseSuccessCount = Value(realUseSuccessCount),
       realUseFailureCount = Value(realUseFailureCount),
       englishWordCount = Value(englishWordCount),
       sentenceCount = Value(sentenceCount),
       chineseSubstituteCount = Value(chineseSubstituteCount),
       complexity = Value(complexity),
       createdAt = Value(createdAt);
  static Insertable<NarrationProgressRecord> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? errorACount,
    Expression<int>? errorBCount,
    Expression<int>? errorCCount,
    Expression<int>? collectedWordCount,
    Expression<int>? coreKnowledgeCount,
    Expression<int>? realUseSuccessCount,
    Expression<int>? realUseFailureCount,
    Expression<int>? englishWordCount,
    Expression<int>? sentenceCount,
    Expression<int>? chineseSubstituteCount,
    Expression<double>? complexity,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (errorACount != null) 'error_a_count': errorACount,
      if (errorBCount != null) 'error_b_count': errorBCount,
      if (errorCCount != null) 'error_c_count': errorCCount,
      if (collectedWordCount != null)
        'collected_word_count': collectedWordCount,
      if (coreKnowledgeCount != null)
        'core_knowledge_count': coreKnowledgeCount,
      if (realUseSuccessCount != null)
        'real_use_success_count': realUseSuccessCount,
      if (realUseFailureCount != null)
        'real_use_failure_count': realUseFailureCount,
      if (englishWordCount != null) 'english_word_count': englishWordCount,
      if (sentenceCount != null) 'sentence_count': sentenceCount,
      if (chineseSubstituteCount != null)
        'chinese_substitute_count': chineseSubstituteCount,
      if (complexity != null) 'complexity': complexity,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NarrationProgressRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? errorACount,
    Value<int>? errorBCount,
    Value<int>? errorCCount,
    Value<int>? collectedWordCount,
    Value<int>? coreKnowledgeCount,
    Value<int>? realUseSuccessCount,
    Value<int>? realUseFailureCount,
    Value<int>? englishWordCount,
    Value<int>? sentenceCount,
    Value<int>? chineseSubstituteCount,
    Value<double>? complexity,
    Value<int>? createdAt,
  }) {
    return NarrationProgressRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      errorACount: errorACount ?? this.errorACount,
      errorBCount: errorBCount ?? this.errorBCount,
      errorCCount: errorCCount ?? this.errorCCount,
      collectedWordCount: collectedWordCount ?? this.collectedWordCount,
      coreKnowledgeCount: coreKnowledgeCount ?? this.coreKnowledgeCount,
      realUseSuccessCount: realUseSuccessCount ?? this.realUseSuccessCount,
      realUseFailureCount: realUseFailureCount ?? this.realUseFailureCount,
      englishWordCount: englishWordCount ?? this.englishWordCount,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      chineseSubstituteCount:
          chineseSubstituteCount ?? this.chineseSubstituteCount,
      complexity: complexity ?? this.complexity,
      createdAt: createdAt ?? this.createdAt,
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
    if (errorACount.present) {
      map['error_a_count'] = Variable<int>(errorACount.value);
    }
    if (errorBCount.present) {
      map['error_b_count'] = Variable<int>(errorBCount.value);
    }
    if (errorCCount.present) {
      map['error_c_count'] = Variable<int>(errorCCount.value);
    }
    if (collectedWordCount.present) {
      map['collected_word_count'] = Variable<int>(collectedWordCount.value);
    }
    if (coreKnowledgeCount.present) {
      map['core_knowledge_count'] = Variable<int>(coreKnowledgeCount.value);
    }
    if (realUseSuccessCount.present) {
      map['real_use_success_count'] = Variable<int>(realUseSuccessCount.value);
    }
    if (realUseFailureCount.present) {
      map['real_use_failure_count'] = Variable<int>(realUseFailureCount.value);
    }
    if (englishWordCount.present) {
      map['english_word_count'] = Variable<int>(englishWordCount.value);
    }
    if (sentenceCount.present) {
      map['sentence_count'] = Variable<int>(sentenceCount.value);
    }
    if (chineseSubstituteCount.present) {
      map['chinese_substitute_count'] = Variable<int>(
        chineseSubstituteCount.value,
      );
    }
    if (complexity.present) {
      map['complexity'] = Variable<double>(complexity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationProgressRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('errorACount: $errorACount, ')
          ..write('errorBCount: $errorBCount, ')
          ..write('errorCCount: $errorCCount, ')
          ..write('collectedWordCount: $collectedWordCount, ')
          ..write('coreKnowledgeCount: $coreKnowledgeCount, ')
          ..write('realUseSuccessCount: $realUseSuccessCount, ')
          ..write('realUseFailureCount: $realUseFailureCount, ')
          ..write('englishWordCount: $englishWordCount, ')
          ..write('sentenceCount: $sentenceCount, ')
          ..write('chineseSubstituteCount: $chineseSubstituteCount, ')
          ..write('complexity: $complexity, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NarrationConsentRecordsTable extends NarrationConsentRecords
    with TableInfo<$NarrationConsentRecordsTable, NarrationConsentRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationConsentRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _consentTypeMeta = const VerificationMeta(
    'consentType',
  );
  @override
  late final GeneratedColumn<String> consentType = GeneratedColumn<String>(
    'consent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _policyVersionMeta = const VerificationMeta(
    'policyVersion',
  );
  @override
  late final GeneratedColumn<String> policyVersion = GeneratedColumn<String>(
    'policy_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantedMeta = const VerificationMeta(
    'granted',
  );
  @override
  late final GeneratedColumn<bool> granted = GeneratedColumn<bool>(
    'granted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("granted" IN (0, 1))',
    ),
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
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<int> revokedAt = GeneratedColumn<int>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    consentType,
    policyVersion,
    granted,
    createdAt,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narration_consent_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NarrationConsentRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('consent_type')) {
      context.handle(
        _consentTypeMeta,
        consentType.isAcceptableOrUnknown(
          data['consent_type']!,
          _consentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consentTypeMeta);
    }
    if (data.containsKey('policy_version')) {
      context.handle(
        _policyVersionMeta,
        policyVersion.isAcceptableOrUnknown(
          data['policy_version']!,
          _policyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_policyVersionMeta);
    }
    if (data.containsKey('granted')) {
      context.handle(
        _grantedMeta,
        granted.isAcceptableOrUnknown(data['granted']!, _grantedMeta),
      );
    } else if (isInserting) {
      context.missing(_grantedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NarrationConsentRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrationConsentRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      consentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consent_type'],
      )!,
      policyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_version'],
      )!,
      granted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}granted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $NarrationConsentRecordsTable createAlias(String alias) {
    return $NarrationConsentRecordsTable(attachedDatabase, alias);
  }
}

class NarrationConsentRecord extends DataClass
    implements Insertable<NarrationConsentRecord> {
  final int id;
  final String consentType;
  final String policyVersion;
  final bool granted;
  final int createdAt;
  final int? revokedAt;
  const NarrationConsentRecord({
    required this.id,
    required this.consentType,
    required this.policyVersion,
    required this.granted,
    required this.createdAt,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['consent_type'] = Variable<String>(consentType);
    map['policy_version'] = Variable<String>(policyVersion);
    map['granted'] = Variable<bool>(granted);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<int>(revokedAt);
    }
    return map;
  }

  NarrationConsentRecordsCompanion toCompanion(bool nullToAbsent) {
    return NarrationConsentRecordsCompanion(
      id: Value(id),
      consentType: Value(consentType),
      policyVersion: Value(policyVersion),
      granted: Value(granted),
      createdAt: Value(createdAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
    );
  }

  factory NarrationConsentRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrationConsentRecord(
      id: serializer.fromJson<int>(json['id']),
      consentType: serializer.fromJson<String>(json['consentType']),
      policyVersion: serializer.fromJson<String>(json['policyVersion']),
      granted: serializer.fromJson<bool>(json['granted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      revokedAt: serializer.fromJson<int?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'consentType': serializer.toJson<String>(consentType),
      'policyVersion': serializer.toJson<String>(policyVersion),
      'granted': serializer.toJson<bool>(granted),
      'createdAt': serializer.toJson<int>(createdAt),
      'revokedAt': serializer.toJson<int?>(revokedAt),
    };
  }

  NarrationConsentRecord copyWith({
    int? id,
    String? consentType,
    String? policyVersion,
    bool? granted,
    int? createdAt,
    Value<int?> revokedAt = const Value.absent(),
  }) => NarrationConsentRecord(
    id: id ?? this.id,
    consentType: consentType ?? this.consentType,
    policyVersion: policyVersion ?? this.policyVersion,
    granted: granted ?? this.granted,
    createdAt: createdAt ?? this.createdAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  NarrationConsentRecord copyWithCompanion(
    NarrationConsentRecordsCompanion data,
  ) {
    return NarrationConsentRecord(
      id: data.id.present ? data.id.value : this.id,
      consentType: data.consentType.present
          ? data.consentType.value
          : this.consentType,
      policyVersion: data.policyVersion.present
          ? data.policyVersion.value
          : this.policyVersion,
      granted: data.granted.present ? data.granted.value : this.granted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrationConsentRecord(')
          ..write('id: $id, ')
          ..write('consentType: $consentType, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('granted: $granted, ')
          ..write('createdAt: $createdAt, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    consentType,
    policyVersion,
    granted,
    createdAt,
    revokedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrationConsentRecord &&
          other.id == this.id &&
          other.consentType == this.consentType &&
          other.policyVersion == this.policyVersion &&
          other.granted == this.granted &&
          other.createdAt == this.createdAt &&
          other.revokedAt == this.revokedAt);
}

class NarrationConsentRecordsCompanion
    extends UpdateCompanion<NarrationConsentRecord> {
  final Value<int> id;
  final Value<String> consentType;
  final Value<String> policyVersion;
  final Value<bool> granted;
  final Value<int> createdAt;
  final Value<int?> revokedAt;
  const NarrationConsentRecordsCompanion({
    this.id = const Value.absent(),
    this.consentType = const Value.absent(),
    this.policyVersion = const Value.absent(),
    this.granted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
  });
  NarrationConsentRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String consentType,
    required String policyVersion,
    required bool granted,
    required int createdAt,
    this.revokedAt = const Value.absent(),
  }) : consentType = Value(consentType),
       policyVersion = Value(policyVersion),
       granted = Value(granted),
       createdAt = Value(createdAt);
  static Insertable<NarrationConsentRecord> custom({
    Expression<int>? id,
    Expression<String>? consentType,
    Expression<String>? policyVersion,
    Expression<bool>? granted,
    Expression<int>? createdAt,
    Expression<int>? revokedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (consentType != null) 'consent_type': consentType,
      if (policyVersion != null) 'policy_version': policyVersion,
      if (granted != null) 'granted': granted,
      if (createdAt != null) 'created_at': createdAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
    });
  }

  NarrationConsentRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? consentType,
    Value<String>? policyVersion,
    Value<bool>? granted,
    Value<int>? createdAt,
    Value<int?>? revokedAt,
  }) {
    return NarrationConsentRecordsCompanion(
      id: id ?? this.id,
      consentType: consentType ?? this.consentType,
      policyVersion: policyVersion ?? this.policyVersion,
      granted: granted ?? this.granted,
      createdAt: createdAt ?? this.createdAt,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (consentType.present) {
      map['consent_type'] = Variable<String>(consentType.value);
    }
    if (policyVersion.present) {
      map['policy_version'] = Variable<String>(policyVersion.value);
    }
    if (granted.present) {
      map['granted'] = Variable<bool>(granted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<int>(revokedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationConsentRecordsCompanion(')
          ..write('id: $id, ')
          ..write('consentType: $consentType, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('granted: $granted, ')
          ..write('createdAt: $createdAt, ')
          ..write('revokedAt: $revokedAt')
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
  late final $LearningActivityRecordsTable learningActivityRecords =
      $LearningActivityRecordsTable(this);
  late final $LearningActivityListsTable learningActivityLists =
      $LearningActivityListsTable(this);
  late final $LearningActivityWordsTable learningActivityWords =
      $LearningActivityWordsTable(this);
  late final $TtsUsageRecordsTable ttsUsageRecords = $TtsUsageRecordsTable(
    this,
  );
  late final $TtsCacheRecordsTable ttsCacheRecords = $TtsCacheRecordsTable(
    this,
  );
  late final $NarrationSessionsTable narrationSessions =
      $NarrationSessionsTable(this);
  late final $NarrationTranscriptionLogsTable narrationTranscriptionLogs =
      $NarrationTranscriptionLogsTable(this);
  late final $NarrationSelfCheckLogsTable narrationSelfCheckLogs =
      $NarrationSelfCheckLogsTable(this);
  late final $NarrationFeedbackLogsTable narrationFeedbackLogs =
      $NarrationFeedbackLogsTable(this);
  late final $NarrationLearningItemsTable narrationLearningItems =
      $NarrationLearningItemsTable(this);
  late final $NarrationLearningSourcesTable narrationLearningSources =
      $NarrationLearningSourcesTable(this);
  late final $NarrationReviewRecordsTable narrationReviewRecords =
      $NarrationReviewRecordsTable(this);
  late final $NarrationProgressRecordsTable narrationProgressRecords =
      $NarrationProgressRecordsTable(this);
  late final $NarrationConsentRecordsTable narrationConsentRecords =
      $NarrationConsentRecordsTable(this);
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
    learningActivityRecords,
    learningActivityLists,
    learningActivityWords,
    ttsUsageRecords,
    ttsCacheRecords,
    narrationSessions,
    narrationTranscriptionLogs,
    narrationSelfCheckLogs,
    narrationFeedbackLogs,
    narrationLearningItems,
    narrationLearningSources,
    narrationReviewRecords,
    narrationProgressRecords,
    narrationConsentRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'learning_activity_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_activity_lists', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_activity_lists', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'learning_activity_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_activity_words', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_activity_words', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('narration_transcription_logs', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('narration_self_check_logs', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('narration_feedback_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_learning_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('narration_learning_sources', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('narration_learning_sources', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_learning_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('narration_review_records', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'narration_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('narration_progress_records', kind: UpdateKind.delete),
      ],
    ),
  ]);
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

  static MultiTypedResultKey<
    $LearningActivityWordsTable,
    List<LearningActivityWord>
  >
  _learningActivityWordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.learningActivityWords,
        aliasName: $_aliasNameGenerator(
          db.words.id,
          db.learningActivityWords.wordId,
        ),
      );

  $$LearningActivityWordsTableProcessedTableManager
  get learningActivityWordsRefs {
    final manager = $$LearningActivityWordsTableTableManager(
      $_db,
      $_db.learningActivityWords,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _learningActivityWordsRefsTable($_db),
    );
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

  Expression<bool> learningActivityWordsRefs(
    Expression<bool> Function($$LearningActivityWordsTableFilterComposer f) f,
  ) {
    final $$LearningActivityWordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityWords,
          getReferencedColumn: (t) => t.wordId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityWordsTableFilterComposer(
                $db: $db,
                $table: $db.learningActivityWords,
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

  Expression<T> learningActivityWordsRefs<T extends Object>(
    Expression<T> Function($$LearningActivityWordsTableAnnotationComposer a) f,
  ) {
    final $$LearningActivityWordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityWords,
          getReferencedColumn: (t) => t.wordId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityWordsTableAnnotationComposer(
                $db: $db,
                $table: $db.learningActivityWords,
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
            bool learningActivityWordsRefs,
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
                learningActivityWordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (listWordsRefs) db.listWords,
                    if (practiceAnswersRefs) db.practiceAnswers,
                    if (errorWordsRefs) db.errorWords,
                    if (aiContentRefs) db.aiContent,
                    if (learningActivityWordsRefs) db.learningActivityWords,
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
                      if (learningActivityWordsRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          LearningActivityWord
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._learningActivityWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningActivityWordsRefs,
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
        bool learningActivityWordsRefs,
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

  static MultiTypedResultKey<
    $LearningActivityListsTable,
    List<LearningActivityList>
  >
  _learningActivityListsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.learningActivityLists,
        aliasName: $_aliasNameGenerator(
          db.wordLists.id,
          db.learningActivityLists.listId,
        ),
      );

  $$LearningActivityListsTableProcessedTableManager
  get learningActivityListsRefs {
    final manager = $$LearningActivityListsTableTableManager(
      $_db,
      $_db.learningActivityLists,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _learningActivityListsRefsTable($_db),
    );
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

  Expression<bool> learningActivityListsRefs(
    Expression<bool> Function($$LearningActivityListsTableFilterComposer f) f,
  ) {
    final $$LearningActivityListsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityLists,
          getReferencedColumn: (t) => t.listId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityListsTableFilterComposer(
                $db: $db,
                $table: $db.learningActivityLists,
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

  Expression<T> learningActivityListsRefs<T extends Object>(
    Expression<T> Function($$LearningActivityListsTableAnnotationComposer a) f,
  ) {
    final $$LearningActivityListsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityLists,
          getReferencedColumn: (t) => t.listId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityListsTableAnnotationComposer(
                $db: $db,
                $table: $db.learningActivityLists,
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
            bool learningActivityListsRefs,
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
                learningActivityListsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (listWordsRefs) db.listWords,
                    if (practiceSessionsRefs) db.practiceSessions,
                    if (errorWordsRefs) db.errorWords,
                    if (learningActivityListsRefs) db.learningActivityLists,
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
                      if (learningActivityListsRefs)
                        await $_getPrefetchedData<
                          WordList,
                          $WordListsTable,
                          LearningActivityList
                        >(
                          currentTable: table,
                          referencedTable: $$WordListsTableReferences
                              ._learningActivityListsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordListsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningActivityListsRefs,
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
        bool learningActivityListsRefs,
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
      Value<bool> isCueMemory,
      Value<int> cueMemoryCount,
    });
typedef $$ListWordsTableUpdateCompanionBuilder =
    ListWordsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<int> wordId,
      Value<int> sortOrder,
      Value<bool> isForgotten,
      Value<int> forgottenCount,
      Value<bool> isCueMemory,
      Value<int> cueMemoryCount,
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

  ColumnFilters<bool> get isCueMemory => $composableBuilder(
    column: $table.isCueMemory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cueMemoryCount => $composableBuilder(
    column: $table.cueMemoryCount,
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

  ColumnOrderings<bool> get isCueMemory => $composableBuilder(
    column: $table.isCueMemory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cueMemoryCount => $composableBuilder(
    column: $table.cueMemoryCount,
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

  GeneratedColumn<bool> get isCueMemory => $composableBuilder(
    column: $table.isCueMemory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cueMemoryCount => $composableBuilder(
    column: $table.cueMemoryCount,
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
                Value<bool> isCueMemory = const Value.absent(),
                Value<int> cueMemoryCount = const Value.absent(),
              }) => ListWordsCompanion(
                id: id,
                listId: listId,
                wordId: wordId,
                sortOrder: sortOrder,
                isForgotten: isForgotten,
                forgottenCount: forgottenCount,
                isCueMemory: isCueMemory,
                cueMemoryCount: cueMemoryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required int wordId,
                required int sortOrder,
                Value<bool> isForgotten = const Value.absent(),
                Value<int> forgottenCount = const Value.absent(),
                Value<bool> isCueMemory = const Value.absent(),
                Value<int> cueMemoryCount = const Value.absent(),
              }) => ListWordsCompanion.insert(
                id: id,
                listId: listId,
                wordId: wordId,
                sortOrder: sortOrder,
                isForgotten: isForgotten,
                forgottenCount: forgottenCount,
                isCueMemory: isCueMemory,
                cueMemoryCount: cueMemoryCount,
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
      Value<String> sessionKind,
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
      Value<String> sessionKind,
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

  ColumnFilters<String> get sessionKind => $composableBuilder(
    column: $table.sessionKind,
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

  ColumnOrderings<String> get sessionKind => $composableBuilder(
    column: $table.sessionKind,
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

  GeneratedColumn<String> get sessionKind => $composableBuilder(
    column: $table.sessionKind,
    builder: (column) => column,
  );

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
                Value<String> sessionKind = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
              }) => PracticeSessionsCompanion(
                id: id,
                listId: listId,
                mode: mode,
                sessionKind: sessionKind,
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
                Value<String> sessionKind = const Value.absent(),
                required int totalCount,
                required int correctCount,
                required double accuracy,
                required int startedAt,
                Value<int?> finishedAt = const Value.absent(),
              }) => PracticeSessionsCompanion.insert(
                id: id,
                listId: listId,
                mode: mode,
                sessionKind: sessionKind,
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
typedef $$LearningActivityRecordsTableCreateCompanionBuilder =
    LearningActivityRecordsCompanion Function({
      Value<int> id,
      required String activityType,
      Value<String?> subtype,
      required String status,
      required int startedAt,
      Value<int?> finishedAt,
      Value<int> questionCount,
      Value<int> correctCount,
      Value<double?> accuracy,
      Value<int> turnCount,
      Value<int> targetWordUseCount,
      Value<double?> naturalnessAverage,
      Value<double?> contextFitAverage,
      Value<int> skillRunCount,
      Value<int> involvedWordCount,
    });
typedef $$LearningActivityRecordsTableUpdateCompanionBuilder =
    LearningActivityRecordsCompanion Function({
      Value<int> id,
      Value<String> activityType,
      Value<String?> subtype,
      Value<String> status,
      Value<int> startedAt,
      Value<int?> finishedAt,
      Value<int> questionCount,
      Value<int> correctCount,
      Value<double?> accuracy,
      Value<int> turnCount,
      Value<int> targetWordUseCount,
      Value<double?> naturalnessAverage,
      Value<double?> contextFitAverage,
      Value<int> skillRunCount,
      Value<int> involvedWordCount,
    });

final class $$LearningActivityRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LearningActivityRecordsTable,
          LearningActivityRecord
        > {
  $$LearningActivityRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $LearningActivityListsTable,
    List<LearningActivityList>
  >
  _learningActivityListsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.learningActivityLists,
        aliasName: $_aliasNameGenerator(
          db.learningActivityRecords.id,
          db.learningActivityLists.activityId,
        ),
      );

  $$LearningActivityListsTableProcessedTableManager
  get learningActivityListsRefs {
    final manager = $$LearningActivityListsTableTableManager(
      $_db,
      $_db.learningActivityLists,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _learningActivityListsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LearningActivityWordsTable,
    List<LearningActivityWord>
  >
  _learningActivityWordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.learningActivityWords,
        aliasName: $_aliasNameGenerator(
          db.learningActivityRecords.id,
          db.learningActivityWords.activityId,
        ),
      );

  $$LearningActivityWordsTableProcessedTableManager
  get learningActivityWordsRefs {
    final manager = $$LearningActivityWordsTableTableManager(
      $_db,
      $_db.learningActivityWords,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _learningActivityWordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LearningActivityRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LearningActivityRecordsTable> {
  $$LearningActivityRecordsTableFilterComposer({
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

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
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

  ColumnFilters<int> get turnCount => $composableBuilder(
    column: $table.turnCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWordUseCount => $composableBuilder(
    column: $table.targetWordUseCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get naturalnessAverage => $composableBuilder(
    column: $table.naturalnessAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get contextFitAverage => $composableBuilder(
    column: $table.contextFitAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skillRunCount => $composableBuilder(
    column: $table.skillRunCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get involvedWordCount => $composableBuilder(
    column: $table.involvedWordCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> learningActivityListsRefs(
    Expression<bool> Function($$LearningActivityListsTableFilterComposer f) f,
  ) {
    final $$LearningActivityListsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityLists,
          getReferencedColumn: (t) => t.activityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityListsTableFilterComposer(
                $db: $db,
                $table: $db.learningActivityLists,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> learningActivityWordsRefs(
    Expression<bool> Function($$LearningActivityWordsTableFilterComposer f) f,
  ) {
    final $$LearningActivityWordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityWords,
          getReferencedColumn: (t) => t.activityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityWordsTableFilterComposer(
                $db: $db,
                $table: $db.learningActivityWords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LearningActivityRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningActivityRecordsTable> {
  $$LearningActivityRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
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

  ColumnOrderings<int> get turnCount => $composableBuilder(
    column: $table.turnCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWordUseCount => $composableBuilder(
    column: $table.targetWordUseCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get naturalnessAverage => $composableBuilder(
    column: $table.naturalnessAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get contextFitAverage => $composableBuilder(
    column: $table.contextFitAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillRunCount => $composableBuilder(
    column: $table.skillRunCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get involvedWordCount => $composableBuilder(
    column: $table.involvedWordCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearningActivityRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningActivityRecordsTable> {
  $$LearningActivityRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get turnCount =>
      $composableBuilder(column: $table.turnCount, builder: (column) => column);

  GeneratedColumn<int> get targetWordUseCount => $composableBuilder(
    column: $table.targetWordUseCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get naturalnessAverage => $composableBuilder(
    column: $table.naturalnessAverage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get contextFitAverage => $composableBuilder(
    column: $table.contextFitAverage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skillRunCount => $composableBuilder(
    column: $table.skillRunCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get involvedWordCount => $composableBuilder(
    column: $table.involvedWordCount,
    builder: (column) => column,
  );

  Expression<T> learningActivityListsRefs<T extends Object>(
    Expression<T> Function($$LearningActivityListsTableAnnotationComposer a) f,
  ) {
    final $$LearningActivityListsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityLists,
          getReferencedColumn: (t) => t.activityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityListsTableAnnotationComposer(
                $db: $db,
                $table: $db.learningActivityLists,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> learningActivityWordsRefs<T extends Object>(
    Expression<T> Function($$LearningActivityWordsTableAnnotationComposer a) f,
  ) {
    final $$LearningActivityWordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.learningActivityWords,
          getReferencedColumn: (t) => t.activityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityWordsTableAnnotationComposer(
                $db: $db,
                $table: $db.learningActivityWords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LearningActivityRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearningActivityRecordsTable,
          LearningActivityRecord,
          $$LearningActivityRecordsTableFilterComposer,
          $$LearningActivityRecordsTableOrderingComposer,
          $$LearningActivityRecordsTableAnnotationComposer,
          $$LearningActivityRecordsTableCreateCompanionBuilder,
          $$LearningActivityRecordsTableUpdateCompanionBuilder,
          (LearningActivityRecord, $$LearningActivityRecordsTableReferences),
          LearningActivityRecord,
          PrefetchHooks Function({
            bool learningActivityListsRefs,
            bool learningActivityWordsRefs,
          })
        > {
  $$LearningActivityRecordsTableTableManager(
    _$AppDatabase db,
    $LearningActivityRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningActivityRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LearningActivityRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LearningActivityRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<int> turnCount = const Value.absent(),
                Value<int> targetWordUseCount = const Value.absent(),
                Value<double?> naturalnessAverage = const Value.absent(),
                Value<double?> contextFitAverage = const Value.absent(),
                Value<int> skillRunCount = const Value.absent(),
                Value<int> involvedWordCount = const Value.absent(),
              }) => LearningActivityRecordsCompanion(
                id: id,
                activityType: activityType,
                subtype: subtype,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                questionCount: questionCount,
                correctCount: correctCount,
                accuracy: accuracy,
                turnCount: turnCount,
                targetWordUseCount: targetWordUseCount,
                naturalnessAverage: naturalnessAverage,
                contextFitAverage: contextFitAverage,
                skillRunCount: skillRunCount,
                involvedWordCount: involvedWordCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String activityType,
                Value<String?> subtype = const Value.absent(),
                required String status,
                required int startedAt,
                Value<int?> finishedAt = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<int> turnCount = const Value.absent(),
                Value<int> targetWordUseCount = const Value.absent(),
                Value<double?> naturalnessAverage = const Value.absent(),
                Value<double?> contextFitAverage = const Value.absent(),
                Value<int> skillRunCount = const Value.absent(),
                Value<int> involvedWordCount = const Value.absent(),
              }) => LearningActivityRecordsCompanion.insert(
                id: id,
                activityType: activityType,
                subtype: subtype,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                questionCount: questionCount,
                correctCount: correctCount,
                accuracy: accuracy,
                turnCount: turnCount,
                targetWordUseCount: targetWordUseCount,
                naturalnessAverage: naturalnessAverage,
                contextFitAverage: contextFitAverage,
                skillRunCount: skillRunCount,
                involvedWordCount: involvedWordCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LearningActivityRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                learningActivityListsRefs = false,
                learningActivityWordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (learningActivityListsRefs) db.learningActivityLists,
                    if (learningActivityWordsRefs) db.learningActivityWords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (learningActivityListsRefs)
                        await $_getPrefetchedData<
                          LearningActivityRecord,
                          $LearningActivityRecordsTable,
                          LearningActivityList
                        >(
                          currentTable: table,
                          referencedTable:
                              $$LearningActivityRecordsTableReferences
                                  ._learningActivityListsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LearningActivityRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningActivityListsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (learningActivityWordsRefs)
                        await $_getPrefetchedData<
                          LearningActivityRecord,
                          $LearningActivityRecordsTable,
                          LearningActivityWord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$LearningActivityRecordsTableReferences
                                  ._learningActivityWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LearningActivityRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningActivityWordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
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

typedef $$LearningActivityRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearningActivityRecordsTable,
      LearningActivityRecord,
      $$LearningActivityRecordsTableFilterComposer,
      $$LearningActivityRecordsTableOrderingComposer,
      $$LearningActivityRecordsTableAnnotationComposer,
      $$LearningActivityRecordsTableCreateCompanionBuilder,
      $$LearningActivityRecordsTableUpdateCompanionBuilder,
      (LearningActivityRecord, $$LearningActivityRecordsTableReferences),
      LearningActivityRecord,
      PrefetchHooks Function({
        bool learningActivityListsRefs,
        bool learningActivityWordsRefs,
      })
    >;
typedef $$LearningActivityListsTableCreateCompanionBuilder =
    LearningActivityListsCompanion Function({
      Value<int> id,
      required int activityId,
      required int listId,
    });
typedef $$LearningActivityListsTableUpdateCompanionBuilder =
    LearningActivityListsCompanion Function({
      Value<int> id,
      Value<int> activityId,
      Value<int> listId,
    });

final class $$LearningActivityListsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LearningActivityListsTable,
          LearningActivityList
        > {
  $$LearningActivityListsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LearningActivityRecordsTable _activityIdTable(_$AppDatabase db) =>
      db.learningActivityRecords.createAlias(
        $_aliasNameGenerator(
          db.learningActivityLists.activityId,
          db.learningActivityRecords.id,
        ),
      );

  $$LearningActivityRecordsTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<int>('activity_id')!;

    final manager = $$LearningActivityRecordsTableTableManager(
      $_db,
      $_db.learningActivityRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordListsTable _listIdTable(_$AppDatabase db) =>
      db.wordLists.createAlias(
        $_aliasNameGenerator(db.learningActivityLists.listId, db.wordLists.id),
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
}

class $$LearningActivityListsTableFilterComposer
    extends Composer<_$AppDatabase, $LearningActivityListsTable> {
  $$LearningActivityListsTableFilterComposer({
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

  $$LearningActivityRecordsTableFilterComposer get activityId {
    final $$LearningActivityRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $db.learningActivityRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityRecordsTableFilterComposer(
                $db: $db,
                $table: $db.learningActivityRecords,
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

class $$LearningActivityListsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningActivityListsTable> {
  $$LearningActivityListsTableOrderingComposer({
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

  $$LearningActivityRecordsTableOrderingComposer get activityId {
    final $$LearningActivityRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $db.learningActivityRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.learningActivityRecords,
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

class $$LearningActivityListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningActivityListsTable> {
  $$LearningActivityListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$LearningActivityRecordsTableAnnotationComposer get activityId {
    final $$LearningActivityRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $db.learningActivityRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.learningActivityRecords,
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

class $$LearningActivityListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearningActivityListsTable,
          LearningActivityList,
          $$LearningActivityListsTableFilterComposer,
          $$LearningActivityListsTableOrderingComposer,
          $$LearningActivityListsTableAnnotationComposer,
          $$LearningActivityListsTableCreateCompanionBuilder,
          $$LearningActivityListsTableUpdateCompanionBuilder,
          (LearningActivityList, $$LearningActivityListsTableReferences),
          LearningActivityList,
          PrefetchHooks Function({bool activityId, bool listId})
        > {
  $$LearningActivityListsTableTableManager(
    _$AppDatabase db,
    $LearningActivityListsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningActivityListsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LearningActivityListsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LearningActivityListsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> activityId = const Value.absent(),
                Value<int> listId = const Value.absent(),
              }) => LearningActivityListsCompanion(
                id: id,
                activityId: activityId,
                listId: listId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int activityId,
                required int listId,
              }) => LearningActivityListsCompanion.insert(
                id: id,
                activityId: activityId,
                listId: listId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LearningActivityListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false, listId = false}) {
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
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable:
                                    $$LearningActivityListsTableReferences
                                        ._activityIdTable(db),
                                referencedColumn:
                                    $$LearningActivityListsTableReferences
                                        ._activityIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$LearningActivityListsTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$LearningActivityListsTableReferences
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

typedef $$LearningActivityListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearningActivityListsTable,
      LearningActivityList,
      $$LearningActivityListsTableFilterComposer,
      $$LearningActivityListsTableOrderingComposer,
      $$LearningActivityListsTableAnnotationComposer,
      $$LearningActivityListsTableCreateCompanionBuilder,
      $$LearningActivityListsTableUpdateCompanionBuilder,
      (LearningActivityList, $$LearningActivityListsTableReferences),
      LearningActivityList,
      PrefetchHooks Function({bool activityId, bool listId})
    >;
typedef $$LearningActivityWordsTableCreateCompanionBuilder =
    LearningActivityWordsCompanion Function({
      Value<int> id,
      required int activityId,
      required int wordId,
      Value<int> usageCount,
      Value<int> errorCount,
    });
typedef $$LearningActivityWordsTableUpdateCompanionBuilder =
    LearningActivityWordsCompanion Function({
      Value<int> id,
      Value<int> activityId,
      Value<int> wordId,
      Value<int> usageCount,
      Value<int> errorCount,
    });

final class $$LearningActivityWordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LearningActivityWordsTable,
          LearningActivityWord
        > {
  $$LearningActivityWordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LearningActivityRecordsTable _activityIdTable(_$AppDatabase db) =>
      db.learningActivityRecords.createAlias(
        $_aliasNameGenerator(
          db.learningActivityWords.activityId,
          db.learningActivityRecords.id,
        ),
      );

  $$LearningActivityRecordsTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<int>('activity_id')!;

    final manager = $$LearningActivityRecordsTableTableManager(
      $_db,
      $_db.learningActivityRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words.createAlias(
    $_aliasNameGenerator(db.learningActivityWords.wordId, db.words.id),
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

class $$LearningActivityWordsTableFilterComposer
    extends Composer<_$AppDatabase, $LearningActivityWordsTable> {
  $$LearningActivityWordsTableFilterComposer({
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

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  $$LearningActivityRecordsTableFilterComposer get activityId {
    final $$LearningActivityRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $db.learningActivityRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityRecordsTableFilterComposer(
                $db: $db,
                $table: $db.learningActivityRecords,
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

class $$LearningActivityWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningActivityWordsTable> {
  $$LearningActivityWordsTableOrderingComposer({
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

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$LearningActivityRecordsTableOrderingComposer get activityId {
    final $$LearningActivityRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $db.learningActivityRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.learningActivityRecords,
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

class $$LearningActivityWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningActivityWordsTable> {
  $$LearningActivityWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  $$LearningActivityRecordsTableAnnotationComposer get activityId {
    final $$LearningActivityRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.activityId,
          referencedTable: $db.learningActivityRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LearningActivityRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.learningActivityRecords,
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

class $$LearningActivityWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearningActivityWordsTable,
          LearningActivityWord,
          $$LearningActivityWordsTableFilterComposer,
          $$LearningActivityWordsTableOrderingComposer,
          $$LearningActivityWordsTableAnnotationComposer,
          $$LearningActivityWordsTableCreateCompanionBuilder,
          $$LearningActivityWordsTableUpdateCompanionBuilder,
          (LearningActivityWord, $$LearningActivityWordsTableReferences),
          LearningActivityWord,
          PrefetchHooks Function({bool activityId, bool wordId})
        > {
  $$LearningActivityWordsTableTableManager(
    _$AppDatabase db,
    $LearningActivityWordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningActivityWordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LearningActivityWordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LearningActivityWordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> activityId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
              }) => LearningActivityWordsCompanion(
                id: id,
                activityId: activityId,
                wordId: wordId,
                usageCount: usageCount,
                errorCount: errorCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int activityId,
                required int wordId,
                Value<int> usageCount = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
              }) => LearningActivityWordsCompanion.insert(
                id: id,
                activityId: activityId,
                wordId: wordId,
                usageCount: usageCount,
                errorCount: errorCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LearningActivityWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false, wordId = false}) {
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
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable:
                                    $$LearningActivityWordsTableReferences
                                        ._activityIdTable(db),
                                referencedColumn:
                                    $$LearningActivityWordsTableReferences
                                        ._activityIdTable(db)
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
                                    $$LearningActivityWordsTableReferences
                                        ._wordIdTable(db),
                                referencedColumn:
                                    $$LearningActivityWordsTableReferences
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

typedef $$LearningActivityWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearningActivityWordsTable,
      LearningActivityWord,
      $$LearningActivityWordsTableFilterComposer,
      $$LearningActivityWordsTableOrderingComposer,
      $$LearningActivityWordsTableAnnotationComposer,
      $$LearningActivityWordsTableCreateCompanionBuilder,
      $$LearningActivityWordsTableUpdateCompanionBuilder,
      (LearningActivityWord, $$LearningActivityWordsTableReferences),
      LearningActivityWord,
      PrefetchHooks Function({bool activityId, bool wordId})
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
typedef $$NarrationSessionsTableCreateCompanionBuilder =
    NarrationSessionsCompanion Function({
      Value<int> id,
      required String status,
      required String rawTranscript,
      Value<String?> cleanedTranscript,
      Value<String> transcriptConfidence,
      Value<String> uncertainSegmentsJson,
      Value<String?> chineseTranslation,
      Value<bool> translationConfirmed,
      Value<String?> targetEnglish,
      Value<String> targetAlternativesJson,
      Value<bool> targetConfirmed,
      Value<String?> normalizedTranscript,
      Value<String?> analysisJson,
      Value<String?> correctedExpression,
      Value<String?> finalExpression,
      Value<bool> finalConfirmed,
      Value<String?> audioPath,
      Value<bool> audioRetained,
      Value<String> accent,
      Value<String> speechRegister,
      Value<bool> thinkingEnabled,
      Value<int?> analysisDurationMs,
      required int createdAt,
      required int updatedAt,
    });
typedef $$NarrationSessionsTableUpdateCompanionBuilder =
    NarrationSessionsCompanion Function({
      Value<int> id,
      Value<String> status,
      Value<String> rawTranscript,
      Value<String?> cleanedTranscript,
      Value<String> transcriptConfidence,
      Value<String> uncertainSegmentsJson,
      Value<String?> chineseTranslation,
      Value<bool> translationConfirmed,
      Value<String?> targetEnglish,
      Value<String> targetAlternativesJson,
      Value<bool> targetConfirmed,
      Value<String?> normalizedTranscript,
      Value<String?> analysisJson,
      Value<String?> correctedExpression,
      Value<String?> finalExpression,
      Value<bool> finalConfirmed,
      Value<String?> audioPath,
      Value<bool> audioRetained,
      Value<String> accent,
      Value<String> speechRegister,
      Value<bool> thinkingEnabled,
      Value<int?> analysisDurationMs,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

final class $$NarrationSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationSessionsTable,
          NarrationSession
        > {
  $$NarrationSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $NarrationTranscriptionLogsTable,
    List<NarrationTranscriptionLog>
  >
  _narrationTranscriptionLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationTranscriptionLogs,
        aliasName: $_aliasNameGenerator(
          db.narrationSessions.id,
          db.narrationTranscriptionLogs.sessionId,
        ),
      );

  $$NarrationTranscriptionLogsTableProcessedTableManager
  get narrationTranscriptionLogsRefs {
    final manager = $$NarrationTranscriptionLogsTableTableManager(
      $_db,
      $_db.narrationTranscriptionLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationTranscriptionLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NarrationSelfCheckLogsTable,
    List<NarrationSelfCheckLog>
  >
  _narrationSelfCheckLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationSelfCheckLogs,
        aliasName: $_aliasNameGenerator(
          db.narrationSessions.id,
          db.narrationSelfCheckLogs.sessionId,
        ),
      );

  $$NarrationSelfCheckLogsTableProcessedTableManager
  get narrationSelfCheckLogsRefs {
    final manager = $$NarrationSelfCheckLogsTableTableManager(
      $_db,
      $_db.narrationSelfCheckLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationSelfCheckLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NarrationFeedbackLogsTable,
    List<NarrationFeedbackLog>
  >
  _narrationFeedbackLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationFeedbackLogs,
        aliasName: $_aliasNameGenerator(
          db.narrationSessions.id,
          db.narrationFeedbackLogs.sessionId,
        ),
      );

  $$NarrationFeedbackLogsTableProcessedTableManager
  get narrationFeedbackLogsRefs {
    final manager = $$NarrationFeedbackLogsTableTableManager(
      $_db,
      $_db.narrationFeedbackLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationFeedbackLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NarrationLearningSourcesTable,
    List<NarrationLearningSource>
  >
  _narrationLearningSourcesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationLearningSources,
        aliasName: $_aliasNameGenerator(
          db.narrationSessions.id,
          db.narrationLearningSources.sessionId,
        ),
      );

  $$NarrationLearningSourcesTableProcessedTableManager
  get narrationLearningSourcesRefs {
    final manager = $$NarrationLearningSourcesTableTableManager(
      $_db,
      $_db.narrationLearningSources,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationLearningSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NarrationProgressRecordsTable,
    List<NarrationProgressRecord>
  >
  _narrationProgressRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationProgressRecords,
        aliasName: $_aliasNameGenerator(
          db.narrationSessions.id,
          db.narrationProgressRecords.sessionId,
        ),
      );

  $$NarrationProgressRecordsTableProcessedTableManager
  get narrationProgressRecordsRefs {
    final manager = $$NarrationProgressRecordsTableTableManager(
      $_db,
      $_db.narrationProgressRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationProgressRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NarrationSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationSessionsTable> {
  $$NarrationSessionsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cleanedTranscript => $composableBuilder(
    column: $table.cleanedTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uncertainSegmentsJson => $composableBuilder(
    column: $table.uncertainSegmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chineseTranslation => $composableBuilder(
    column: $table.chineseTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get translationConfirmed => $composableBuilder(
    column: $table.translationConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetEnglish => $composableBuilder(
    column: $table.targetEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetAlternativesJson => $composableBuilder(
    column: $table.targetAlternativesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get targetConfirmed => $composableBuilder(
    column: $table.targetConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedTranscript => $composableBuilder(
    column: $table.normalizedTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedExpression => $composableBuilder(
    column: $table.correctedExpression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalExpression => $composableBuilder(
    column: $table.finalExpression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get finalConfirmed => $composableBuilder(
    column: $table.finalConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get audioRetained => $composableBuilder(
    column: $table.audioRetained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speechRegister => $composableBuilder(
    column: $table.speechRegister,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get thinkingEnabled => $composableBuilder(
    column: $table.thinkingEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get analysisDurationMs => $composableBuilder(
    column: $table.analysisDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> narrationTranscriptionLogsRefs(
    Expression<bool> Function($$NarrationTranscriptionLogsTableFilterComposer f)
    f,
  ) {
    final $$NarrationTranscriptionLogsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationTranscriptionLogs,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationTranscriptionLogsTableFilterComposer(
                $db: $db,
                $table: $db.narrationTranscriptionLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> narrationSelfCheckLogsRefs(
    Expression<bool> Function($$NarrationSelfCheckLogsTableFilterComposer f) f,
  ) {
    final $$NarrationSelfCheckLogsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationSelfCheckLogs,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSelfCheckLogsTableFilterComposer(
                $db: $db,
                $table: $db.narrationSelfCheckLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> narrationFeedbackLogsRefs(
    Expression<bool> Function($$NarrationFeedbackLogsTableFilterComposer f) f,
  ) {
    final $$NarrationFeedbackLogsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationFeedbackLogs,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationFeedbackLogsTableFilterComposer(
                $db: $db,
                $table: $db.narrationFeedbackLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> narrationLearningSourcesRefs(
    Expression<bool> Function($$NarrationLearningSourcesTableFilterComposer f)
    f,
  ) {
    final $$NarrationLearningSourcesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationLearningSources,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningSourcesTableFilterComposer(
                $db: $db,
                $table: $db.narrationLearningSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> narrationProgressRecordsRefs(
    Expression<bool> Function($$NarrationProgressRecordsTableFilterComposer f)
    f,
  ) {
    final $$NarrationProgressRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationProgressRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationProgressRecordsTableFilterComposer(
                $db: $db,
                $table: $db.narrationProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NarrationSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationSessionsTable> {
  $$NarrationSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cleanedTranscript => $composableBuilder(
    column: $table.cleanedTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uncertainSegmentsJson => $composableBuilder(
    column: $table.uncertainSegmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chineseTranslation => $composableBuilder(
    column: $table.chineseTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get translationConfirmed => $composableBuilder(
    column: $table.translationConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetEnglish => $composableBuilder(
    column: $table.targetEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetAlternativesJson => $composableBuilder(
    column: $table.targetAlternativesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get targetConfirmed => $composableBuilder(
    column: $table.targetConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedTranscript => $composableBuilder(
    column: $table.normalizedTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedExpression => $composableBuilder(
    column: $table.correctedExpression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalExpression => $composableBuilder(
    column: $table.finalExpression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get finalConfirmed => $composableBuilder(
    column: $table.finalConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get audioRetained => $composableBuilder(
    column: $table.audioRetained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speechRegister => $composableBuilder(
    column: $table.speechRegister,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get thinkingEnabled => $composableBuilder(
    column: $table.thinkingEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get analysisDurationMs => $composableBuilder(
    column: $table.analysisDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NarrationSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationSessionsTable> {
  $$NarrationSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cleanedTranscript => $composableBuilder(
    column: $table.cleanedTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptConfidence => $composableBuilder(
    column: $table.transcriptConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uncertainSegmentsJson => $composableBuilder(
    column: $table.uncertainSegmentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chineseTranslation => $composableBuilder(
    column: $table.chineseTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get translationConfirmed => $composableBuilder(
    column: $table.translationConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetEnglish => $composableBuilder(
    column: $table.targetEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetAlternativesJson => $composableBuilder(
    column: $table.targetAlternativesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get targetConfirmed => $composableBuilder(
    column: $table.targetConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedTranscript => $composableBuilder(
    column: $table.normalizedTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisJson => $composableBuilder(
    column: $table.analysisJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctedExpression => $composableBuilder(
    column: $table.correctedExpression,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalExpression => $composableBuilder(
    column: $table.finalExpression,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get finalConfirmed => $composableBuilder(
    column: $table.finalConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<bool> get audioRetained => $composableBuilder(
    column: $table.audioRetained,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => column);

  GeneratedColumn<String> get speechRegister => $composableBuilder(
    column: $table.speechRegister,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get thinkingEnabled => $composableBuilder(
    column: $table.thinkingEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get analysisDurationMs => $composableBuilder(
    column: $table.analysisDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> narrationTranscriptionLogsRefs<T extends Object>(
    Expression<T> Function(
      $$NarrationTranscriptionLogsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$NarrationTranscriptionLogsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationTranscriptionLogs,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationTranscriptionLogsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationTranscriptionLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> narrationSelfCheckLogsRefs<T extends Object>(
    Expression<T> Function($$NarrationSelfCheckLogsTableAnnotationComposer a) f,
  ) {
    final $$NarrationSelfCheckLogsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationSelfCheckLogs,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSelfCheckLogsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationSelfCheckLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> narrationFeedbackLogsRefs<T extends Object>(
    Expression<T> Function($$NarrationFeedbackLogsTableAnnotationComposer a) f,
  ) {
    final $$NarrationFeedbackLogsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationFeedbackLogs,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationFeedbackLogsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationFeedbackLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> narrationLearningSourcesRefs<T extends Object>(
    Expression<T> Function($$NarrationLearningSourcesTableAnnotationComposer a)
    f,
  ) {
    final $$NarrationLearningSourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationLearningSources,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningSourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationLearningSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> narrationProgressRecordsRefs<T extends Object>(
    Expression<T> Function($$NarrationProgressRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$NarrationProgressRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationProgressRecords,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationProgressRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NarrationSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationSessionsTable,
          NarrationSession,
          $$NarrationSessionsTableFilterComposer,
          $$NarrationSessionsTableOrderingComposer,
          $$NarrationSessionsTableAnnotationComposer,
          $$NarrationSessionsTableCreateCompanionBuilder,
          $$NarrationSessionsTableUpdateCompanionBuilder,
          (NarrationSession, $$NarrationSessionsTableReferences),
          NarrationSession,
          PrefetchHooks Function({
            bool narrationTranscriptionLogsRefs,
            bool narrationSelfCheckLogsRefs,
            bool narrationFeedbackLogsRefs,
            bool narrationLearningSourcesRefs,
            bool narrationProgressRecordsRefs,
          })
        > {
  $$NarrationSessionsTableTableManager(
    _$AppDatabase db,
    $NarrationSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NarrationSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NarrationSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> rawTranscript = const Value.absent(),
                Value<String?> cleanedTranscript = const Value.absent(),
                Value<String> transcriptConfidence = const Value.absent(),
                Value<String> uncertainSegmentsJson = const Value.absent(),
                Value<String?> chineseTranslation = const Value.absent(),
                Value<bool> translationConfirmed = const Value.absent(),
                Value<String?> targetEnglish = const Value.absent(),
                Value<String> targetAlternativesJson = const Value.absent(),
                Value<bool> targetConfirmed = const Value.absent(),
                Value<String?> normalizedTranscript = const Value.absent(),
                Value<String?> analysisJson = const Value.absent(),
                Value<String?> correctedExpression = const Value.absent(),
                Value<String?> finalExpression = const Value.absent(),
                Value<bool> finalConfirmed = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<bool> audioRetained = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<String> speechRegister = const Value.absent(),
                Value<bool> thinkingEnabled = const Value.absent(),
                Value<int?> analysisDurationMs = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => NarrationSessionsCompanion(
                id: id,
                status: status,
                rawTranscript: rawTranscript,
                cleanedTranscript: cleanedTranscript,
                transcriptConfidence: transcriptConfidence,
                uncertainSegmentsJson: uncertainSegmentsJson,
                chineseTranslation: chineseTranslation,
                translationConfirmed: translationConfirmed,
                targetEnglish: targetEnglish,
                targetAlternativesJson: targetAlternativesJson,
                targetConfirmed: targetConfirmed,
                normalizedTranscript: normalizedTranscript,
                analysisJson: analysisJson,
                correctedExpression: correctedExpression,
                finalExpression: finalExpression,
                finalConfirmed: finalConfirmed,
                audioPath: audioPath,
                audioRetained: audioRetained,
                accent: accent,
                speechRegister: speechRegister,
                thinkingEnabled: thinkingEnabled,
                analysisDurationMs: analysisDurationMs,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String status,
                required String rawTranscript,
                Value<String?> cleanedTranscript = const Value.absent(),
                Value<String> transcriptConfidence = const Value.absent(),
                Value<String> uncertainSegmentsJson = const Value.absent(),
                Value<String?> chineseTranslation = const Value.absent(),
                Value<bool> translationConfirmed = const Value.absent(),
                Value<String?> targetEnglish = const Value.absent(),
                Value<String> targetAlternativesJson = const Value.absent(),
                Value<bool> targetConfirmed = const Value.absent(),
                Value<String?> normalizedTranscript = const Value.absent(),
                Value<String?> analysisJson = const Value.absent(),
                Value<String?> correctedExpression = const Value.absent(),
                Value<String?> finalExpression = const Value.absent(),
                Value<bool> finalConfirmed = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<bool> audioRetained = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<String> speechRegister = const Value.absent(),
                Value<bool> thinkingEnabled = const Value.absent(),
                Value<int?> analysisDurationMs = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => NarrationSessionsCompanion.insert(
                id: id,
                status: status,
                rawTranscript: rawTranscript,
                cleanedTranscript: cleanedTranscript,
                transcriptConfidence: transcriptConfidence,
                uncertainSegmentsJson: uncertainSegmentsJson,
                chineseTranslation: chineseTranslation,
                translationConfirmed: translationConfirmed,
                targetEnglish: targetEnglish,
                targetAlternativesJson: targetAlternativesJson,
                targetConfirmed: targetConfirmed,
                normalizedTranscript: normalizedTranscript,
                analysisJson: analysisJson,
                correctedExpression: correctedExpression,
                finalExpression: finalExpression,
                finalConfirmed: finalConfirmed,
                audioPath: audioPath,
                audioRetained: audioRetained,
                accent: accent,
                speechRegister: speechRegister,
                thinkingEnabled: thinkingEnabled,
                analysisDurationMs: analysisDurationMs,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                narrationTranscriptionLogsRefs = false,
                narrationSelfCheckLogsRefs = false,
                narrationFeedbackLogsRefs = false,
                narrationLearningSourcesRefs = false,
                narrationProgressRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (narrationTranscriptionLogsRefs)
                      db.narrationTranscriptionLogs,
                    if (narrationSelfCheckLogsRefs) db.narrationSelfCheckLogs,
                    if (narrationFeedbackLogsRefs) db.narrationFeedbackLogs,
                    if (narrationLearningSourcesRefs)
                      db.narrationLearningSources,
                    if (narrationProgressRecordsRefs)
                      db.narrationProgressRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (narrationTranscriptionLogsRefs)
                        await $_getPrefetchedData<
                          NarrationSession,
                          $NarrationSessionsTable,
                          NarrationTranscriptionLog
                        >(
                          currentTable: table,
                          referencedTable: $$NarrationSessionsTableReferences
                              ._narrationTranscriptionLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationTranscriptionLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (narrationSelfCheckLogsRefs)
                        await $_getPrefetchedData<
                          NarrationSession,
                          $NarrationSessionsTable,
                          NarrationSelfCheckLog
                        >(
                          currentTable: table,
                          referencedTable: $$NarrationSessionsTableReferences
                              ._narrationSelfCheckLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationSelfCheckLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (narrationFeedbackLogsRefs)
                        await $_getPrefetchedData<
                          NarrationSession,
                          $NarrationSessionsTable,
                          NarrationFeedbackLog
                        >(
                          currentTable: table,
                          referencedTable: $$NarrationSessionsTableReferences
                              ._narrationFeedbackLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationFeedbackLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (narrationLearningSourcesRefs)
                        await $_getPrefetchedData<
                          NarrationSession,
                          $NarrationSessionsTable,
                          NarrationLearningSource
                        >(
                          currentTable: table,
                          referencedTable: $$NarrationSessionsTableReferences
                              ._narrationLearningSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationLearningSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (narrationProgressRecordsRefs)
                        await $_getPrefetchedData<
                          NarrationSession,
                          $NarrationSessionsTable,
                          NarrationProgressRecord
                        >(
                          currentTable: table,
                          referencedTable: $$NarrationSessionsTableReferences
                              ._narrationProgressRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationProgressRecordsRefs,
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

typedef $$NarrationSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationSessionsTable,
      NarrationSession,
      $$NarrationSessionsTableFilterComposer,
      $$NarrationSessionsTableOrderingComposer,
      $$NarrationSessionsTableAnnotationComposer,
      $$NarrationSessionsTableCreateCompanionBuilder,
      $$NarrationSessionsTableUpdateCompanionBuilder,
      (NarrationSession, $$NarrationSessionsTableReferences),
      NarrationSession,
      PrefetchHooks Function({
        bool narrationTranscriptionLogsRefs,
        bool narrationSelfCheckLogsRefs,
        bool narrationFeedbackLogsRefs,
        bool narrationLearningSourcesRefs,
        bool narrationProgressRecordsRefs,
      })
    >;
typedef $$NarrationTranscriptionLogsTableCreateCompanionBuilder =
    NarrationTranscriptionLogsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String rawTranscript,
      Value<String?> correctedTranscript,
      required String confidence,
      required String uncertainSegmentsJson,
      required String confirmationResult,
      Value<bool> rerecorded,
      Value<String?> alignmentStatus,
      Value<String?> manualCleanupJson,
      required int createdAt,
    });
typedef $$NarrationTranscriptionLogsTableUpdateCompanionBuilder =
    NarrationTranscriptionLogsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> rawTranscript,
      Value<String?> correctedTranscript,
      Value<String> confidence,
      Value<String> uncertainSegmentsJson,
      Value<String> confirmationResult,
      Value<bool> rerecorded,
      Value<String?> alignmentStatus,
      Value<String?> manualCleanupJson,
      Value<int> createdAt,
    });

final class $$NarrationTranscriptionLogsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationTranscriptionLogsTable,
          NarrationTranscriptionLog
        > {
  $$NarrationTranscriptionLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NarrationSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.narrationSessions.createAlias(
        $_aliasNameGenerator(
          db.narrationTranscriptionLogs.sessionId,
          db.narrationSessions.id,
        ),
      );

  $$NarrationSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$NarrationSessionsTableTableManager(
      $_db,
      $_db.narrationSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NarrationTranscriptionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationTranscriptionLogsTable> {
  $$NarrationTranscriptionLogsTableFilterComposer({
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

  ColumnFilters<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedTranscript => $composableBuilder(
    column: $table.correctedTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uncertainSegmentsJson => $composableBuilder(
    column: $table.uncertainSegmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmationResult => $composableBuilder(
    column: $table.confirmationResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rerecorded => $composableBuilder(
    column: $table.rerecorded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alignmentStatus => $composableBuilder(
    column: $table.alignmentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manualCleanupJson => $composableBuilder(
    column: $table.manualCleanupJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NarrationSessionsTableFilterComposer get sessionId {
    final $$NarrationSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableFilterComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationTranscriptionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationTranscriptionLogsTable> {
  $$NarrationTranscriptionLogsTableOrderingComposer({
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

  ColumnOrderings<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedTranscript => $composableBuilder(
    column: $table.correctedTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uncertainSegmentsJson => $composableBuilder(
    column: $table.uncertainSegmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmationResult => $composableBuilder(
    column: $table.confirmationResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rerecorded => $composableBuilder(
    column: $table.rerecorded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alignmentStatus => $composableBuilder(
    column: $table.alignmentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manualCleanupJson => $composableBuilder(
    column: $table.manualCleanupJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NarrationSessionsTableOrderingComposer get sessionId {
    final $$NarrationSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationTranscriptionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationTranscriptionLogsTable> {
  $$NarrationTranscriptionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctedTranscript => $composableBuilder(
    column: $table.correctedTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uncertainSegmentsJson => $composableBuilder(
    column: $table.uncertainSegmentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmationResult => $composableBuilder(
    column: $table.confirmationResult,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rerecorded => $composableBuilder(
    column: $table.rerecorded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alignmentStatus => $composableBuilder(
    column: $table.alignmentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manualCleanupJson => $composableBuilder(
    column: $table.manualCleanupJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NarrationSessionsTableAnnotationComposer get sessionId {
    final $$NarrationSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.narrationSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationTranscriptionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationTranscriptionLogsTable,
          NarrationTranscriptionLog,
          $$NarrationTranscriptionLogsTableFilterComposer,
          $$NarrationTranscriptionLogsTableOrderingComposer,
          $$NarrationTranscriptionLogsTableAnnotationComposer,
          $$NarrationTranscriptionLogsTableCreateCompanionBuilder,
          $$NarrationTranscriptionLogsTableUpdateCompanionBuilder,
          (
            NarrationTranscriptionLog,
            $$NarrationTranscriptionLogsTableReferences,
          ),
          NarrationTranscriptionLog,
          PrefetchHooks Function({bool sessionId})
        > {
  $$NarrationTranscriptionLogsTableTableManager(
    _$AppDatabase db,
    $NarrationTranscriptionLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationTranscriptionLogsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationTranscriptionLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationTranscriptionLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> rawTranscript = const Value.absent(),
                Value<String?> correctedTranscript = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<String> uncertainSegmentsJson = const Value.absent(),
                Value<String> confirmationResult = const Value.absent(),
                Value<bool> rerecorded = const Value.absent(),
                Value<String?> alignmentStatus = const Value.absent(),
                Value<String?> manualCleanupJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => NarrationTranscriptionLogsCompanion(
                id: id,
                sessionId: sessionId,
                rawTranscript: rawTranscript,
                correctedTranscript: correctedTranscript,
                confidence: confidence,
                uncertainSegmentsJson: uncertainSegmentsJson,
                confirmationResult: confirmationResult,
                rerecorded: rerecorded,
                alignmentStatus: alignmentStatus,
                manualCleanupJson: manualCleanupJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String rawTranscript,
                Value<String?> correctedTranscript = const Value.absent(),
                required String confidence,
                required String uncertainSegmentsJson,
                required String confirmationResult,
                Value<bool> rerecorded = const Value.absent(),
                Value<String?> alignmentStatus = const Value.absent(),
                Value<String?> manualCleanupJson = const Value.absent(),
                required int createdAt,
              }) => NarrationTranscriptionLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                rawTranscript: rawTranscript,
                correctedTranscript: correctedTranscript,
                confidence: confidence,
                uncertainSegmentsJson: uncertainSegmentsJson,
                confirmationResult: confirmationResult,
                rerecorded: rerecorded,
                alignmentStatus: alignmentStatus,
                manualCleanupJson: manualCleanupJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationTranscriptionLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                                    $$NarrationTranscriptionLogsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$NarrationTranscriptionLogsTableReferences
                                        ._sessionIdTable(db)
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

typedef $$NarrationTranscriptionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationTranscriptionLogsTable,
      NarrationTranscriptionLog,
      $$NarrationTranscriptionLogsTableFilterComposer,
      $$NarrationTranscriptionLogsTableOrderingComposer,
      $$NarrationTranscriptionLogsTableAnnotationComposer,
      $$NarrationTranscriptionLogsTableCreateCompanionBuilder,
      $$NarrationTranscriptionLogsTableUpdateCompanionBuilder,
      (NarrationTranscriptionLog, $$NarrationTranscriptionLogsTableReferences),
      NarrationTranscriptionLog,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$NarrationSelfCheckLogsTableCreateCompanionBuilder =
    NarrationSelfCheckLogsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String reportJson,
      required int iterationCount,
      required bool passed,
      required int createdAt,
    });
typedef $$NarrationSelfCheckLogsTableUpdateCompanionBuilder =
    NarrationSelfCheckLogsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> reportJson,
      Value<int> iterationCount,
      Value<bool> passed,
      Value<int> createdAt,
    });

final class $$NarrationSelfCheckLogsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationSelfCheckLogsTable,
          NarrationSelfCheckLog
        > {
  $$NarrationSelfCheckLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NarrationSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.narrationSessions.createAlias(
        $_aliasNameGenerator(
          db.narrationSelfCheckLogs.sessionId,
          db.narrationSessions.id,
        ),
      );

  $$NarrationSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$NarrationSessionsTableTableManager(
      $_db,
      $_db.narrationSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NarrationSelfCheckLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationSelfCheckLogsTable> {
  $$NarrationSelfCheckLogsTableFilterComposer({
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

  ColumnFilters<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iterationCount => $composableBuilder(
    column: $table.iterationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NarrationSessionsTableFilterComposer get sessionId {
    final $$NarrationSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableFilterComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationSelfCheckLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationSelfCheckLogsTable> {
  $$NarrationSelfCheckLogsTableOrderingComposer({
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

  ColumnOrderings<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iterationCount => $composableBuilder(
    column: $table.iterationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NarrationSessionsTableOrderingComposer get sessionId {
    final $$NarrationSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationSelfCheckLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationSelfCheckLogsTable> {
  $$NarrationSelfCheckLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportJson => $composableBuilder(
    column: $table.reportJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iterationCount => $composableBuilder(
    column: $table.iterationCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NarrationSessionsTableAnnotationComposer get sessionId {
    final $$NarrationSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.narrationSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationSelfCheckLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationSelfCheckLogsTable,
          NarrationSelfCheckLog,
          $$NarrationSelfCheckLogsTableFilterComposer,
          $$NarrationSelfCheckLogsTableOrderingComposer,
          $$NarrationSelfCheckLogsTableAnnotationComposer,
          $$NarrationSelfCheckLogsTableCreateCompanionBuilder,
          $$NarrationSelfCheckLogsTableUpdateCompanionBuilder,
          (NarrationSelfCheckLog, $$NarrationSelfCheckLogsTableReferences),
          NarrationSelfCheckLog,
          PrefetchHooks Function({bool sessionId})
        > {
  $$NarrationSelfCheckLogsTableTableManager(
    _$AppDatabase db,
    $NarrationSelfCheckLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationSelfCheckLogsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationSelfCheckLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationSelfCheckLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> reportJson = const Value.absent(),
                Value<int> iterationCount = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => NarrationSelfCheckLogsCompanion(
                id: id,
                sessionId: sessionId,
                reportJson: reportJson,
                iterationCount: iterationCount,
                passed: passed,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String reportJson,
                required int iterationCount,
                required bool passed,
                required int createdAt,
              }) => NarrationSelfCheckLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                reportJson: reportJson,
                iterationCount: iterationCount,
                passed: passed,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationSelfCheckLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                                    $$NarrationSelfCheckLogsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$NarrationSelfCheckLogsTableReferences
                                        ._sessionIdTable(db)
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

typedef $$NarrationSelfCheckLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationSelfCheckLogsTable,
      NarrationSelfCheckLog,
      $$NarrationSelfCheckLogsTableFilterComposer,
      $$NarrationSelfCheckLogsTableOrderingComposer,
      $$NarrationSelfCheckLogsTableAnnotationComposer,
      $$NarrationSelfCheckLogsTableCreateCompanionBuilder,
      $$NarrationSelfCheckLogsTableUpdateCompanionBuilder,
      (NarrationSelfCheckLog, $$NarrationSelfCheckLogsTableReferences),
      NarrationSelfCheckLog,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$NarrationFeedbackLogsTableCreateCompanionBuilder =
    NarrationFeedbackLogsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<int?> learningItemId,
      required String stage,
      required String originalJudgement,
      Value<String?> systemExplanation,
      Value<String?> userReason,
      required String resolution,
      Value<String?> customResult,
      required int createdAt,
    });
typedef $$NarrationFeedbackLogsTableUpdateCompanionBuilder =
    NarrationFeedbackLogsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<int?> learningItemId,
      Value<String> stage,
      Value<String> originalJudgement,
      Value<String?> systemExplanation,
      Value<String?> userReason,
      Value<String> resolution,
      Value<String?> customResult,
      Value<int> createdAt,
    });

final class $$NarrationFeedbackLogsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationFeedbackLogsTable,
          NarrationFeedbackLog
        > {
  $$NarrationFeedbackLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NarrationSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.narrationSessions.createAlias(
        $_aliasNameGenerator(
          db.narrationFeedbackLogs.sessionId,
          db.narrationSessions.id,
        ),
      );

  $$NarrationSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$NarrationSessionsTableTableManager(
      $_db,
      $_db.narrationSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NarrationFeedbackLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationFeedbackLogsTable> {
  $$NarrationFeedbackLogsTableFilterComposer({
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

  ColumnFilters<int> get learningItemId => $composableBuilder(
    column: $table.learningItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalJudgement => $composableBuilder(
    column: $table.originalJudgement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemExplanation => $composableBuilder(
    column: $table.systemExplanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userReason => $composableBuilder(
    column: $table.userReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customResult => $composableBuilder(
    column: $table.customResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NarrationSessionsTableFilterComposer get sessionId {
    final $$NarrationSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableFilterComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationFeedbackLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationFeedbackLogsTable> {
  $$NarrationFeedbackLogsTableOrderingComposer({
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

  ColumnOrderings<int> get learningItemId => $composableBuilder(
    column: $table.learningItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalJudgement => $composableBuilder(
    column: $table.originalJudgement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemExplanation => $composableBuilder(
    column: $table.systemExplanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userReason => $composableBuilder(
    column: $table.userReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customResult => $composableBuilder(
    column: $table.customResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NarrationSessionsTableOrderingComposer get sessionId {
    final $$NarrationSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationFeedbackLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationFeedbackLogsTable> {
  $$NarrationFeedbackLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get learningItemId => $composableBuilder(
    column: $table.learningItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get originalJudgement => $composableBuilder(
    column: $table.originalJudgement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemExplanation => $composableBuilder(
    column: $table.systemExplanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userReason => $composableBuilder(
    column: $table.userReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customResult => $composableBuilder(
    column: $table.customResult,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NarrationSessionsTableAnnotationComposer get sessionId {
    final $$NarrationSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.narrationSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationFeedbackLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationFeedbackLogsTable,
          NarrationFeedbackLog,
          $$NarrationFeedbackLogsTableFilterComposer,
          $$NarrationFeedbackLogsTableOrderingComposer,
          $$NarrationFeedbackLogsTableAnnotationComposer,
          $$NarrationFeedbackLogsTableCreateCompanionBuilder,
          $$NarrationFeedbackLogsTableUpdateCompanionBuilder,
          (NarrationFeedbackLog, $$NarrationFeedbackLogsTableReferences),
          NarrationFeedbackLog,
          PrefetchHooks Function({bool sessionId})
        > {
  $$NarrationFeedbackLogsTableTableManager(
    _$AppDatabase db,
    $NarrationFeedbackLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationFeedbackLogsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationFeedbackLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationFeedbackLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> learningItemId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> originalJudgement = const Value.absent(),
                Value<String?> systemExplanation = const Value.absent(),
                Value<String?> userReason = const Value.absent(),
                Value<String> resolution = const Value.absent(),
                Value<String?> customResult = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => NarrationFeedbackLogsCompanion(
                id: id,
                sessionId: sessionId,
                learningItemId: learningItemId,
                stage: stage,
                originalJudgement: originalJudgement,
                systemExplanation: systemExplanation,
                userReason: userReason,
                resolution: resolution,
                customResult: customResult,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> learningItemId = const Value.absent(),
                required String stage,
                required String originalJudgement,
                Value<String?> systemExplanation = const Value.absent(),
                Value<String?> userReason = const Value.absent(),
                required String resolution,
                Value<String?> customResult = const Value.absent(),
                required int createdAt,
              }) => NarrationFeedbackLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                learningItemId: learningItemId,
                stage: stage,
                originalJudgement: originalJudgement,
                systemExplanation: systemExplanation,
                userReason: userReason,
                resolution: resolution,
                customResult: customResult,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationFeedbackLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                                    $$NarrationFeedbackLogsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$NarrationFeedbackLogsTableReferences
                                        ._sessionIdTable(db)
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

typedef $$NarrationFeedbackLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationFeedbackLogsTable,
      NarrationFeedbackLog,
      $$NarrationFeedbackLogsTableFilterComposer,
      $$NarrationFeedbackLogsTableOrderingComposer,
      $$NarrationFeedbackLogsTableAnnotationComposer,
      $$NarrationFeedbackLogsTableCreateCompanionBuilder,
      $$NarrationFeedbackLogsTableUpdateCompanionBuilder,
      (NarrationFeedbackLog, $$NarrationFeedbackLogsTableReferences),
      NarrationFeedbackLog,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$NarrationLearningItemsTableCreateCompanionBuilder =
    NarrationLearningItemsCompanion Function({
      Value<int> id,
      required String itemType,
      required String stableKey,
      required String english,
      required String chinese,
      Value<String> partOfSpeech,
      Value<String> classification,
      Value<String> knowledgeLevel,
      Value<String> explanation,
      Value<bool> reviewRequired,
      required int firstSeenAt,
      required int lastSeenAt,
      Value<int> occurrenceCount,
      Value<String> masteryState,
      Value<int> reviewPassCount,
      Value<bool> recognitionPassed,
      Value<bool> applicationPassed,
      Value<int> realUseSuccessCount,
      Value<int> realUseFailureCount,
      Value<int?> nextReviewAt,
      Value<int> reviewIntervalIndex,
      Value<int?> lastTriggerAt,
      Value<int?> lastFailureAt,
      Value<String> queueState,
      Value<bool> userConfirmed,
      Value<String> notes,
    });
typedef $$NarrationLearningItemsTableUpdateCompanionBuilder =
    NarrationLearningItemsCompanion Function({
      Value<int> id,
      Value<String> itemType,
      Value<String> stableKey,
      Value<String> english,
      Value<String> chinese,
      Value<String> partOfSpeech,
      Value<String> classification,
      Value<String> knowledgeLevel,
      Value<String> explanation,
      Value<bool> reviewRequired,
      Value<int> firstSeenAt,
      Value<int> lastSeenAt,
      Value<int> occurrenceCount,
      Value<String> masteryState,
      Value<int> reviewPassCount,
      Value<bool> recognitionPassed,
      Value<bool> applicationPassed,
      Value<int> realUseSuccessCount,
      Value<int> realUseFailureCount,
      Value<int?> nextReviewAt,
      Value<int> reviewIntervalIndex,
      Value<int?> lastTriggerAt,
      Value<int?> lastFailureAt,
      Value<String> queueState,
      Value<bool> userConfirmed,
      Value<String> notes,
    });

final class $$NarrationLearningItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationLearningItemsTable,
          NarrationLearningItem
        > {
  $$NarrationLearningItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $NarrationLearningSourcesTable,
    List<NarrationLearningSource>
  >
  _narrationLearningSourcesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationLearningSources,
        aliasName: $_aliasNameGenerator(
          db.narrationLearningItems.id,
          db.narrationLearningSources.learningItemId,
        ),
      );

  $$NarrationLearningSourcesTableProcessedTableManager
  get narrationLearningSourcesRefs {
    final manager = $$NarrationLearningSourcesTableTableManager(
      $_db,
      $_db.narrationLearningSources,
    ).filter((f) => f.learningItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationLearningSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NarrationReviewRecordsTable,
    List<NarrationReviewRecord>
  >
  _narrationReviewRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.narrationReviewRecords,
        aliasName: $_aliasNameGenerator(
          db.narrationLearningItems.id,
          db.narrationReviewRecords.learningItemId,
        ),
      );

  $$NarrationReviewRecordsTableProcessedTableManager
  get narrationReviewRecordsRefs {
    final manager = $$NarrationReviewRecordsTableTableManager(
      $_db,
      $_db.narrationReviewRecords,
    ).filter((f) => f.learningItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _narrationReviewRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NarrationLearningItemsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationLearningItemsTable> {
  $$NarrationLearningItemsTableFilterComposer({
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

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chinese => $composableBuilder(
    column: $table.chinese,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knowledgeLevel => $composableBuilder(
    column: $table.knowledgeLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reviewRequired => $composableBuilder(
    column: $table.reviewRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masteryState => $composableBuilder(
    column: $table.masteryState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewPassCount => $composableBuilder(
    column: $table.reviewPassCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recognitionPassed => $composableBuilder(
    column: $table.recognitionPassed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get applicationPassed => $composableBuilder(
    column: $table.applicationPassed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realUseSuccessCount => $composableBuilder(
    column: $table.realUseSuccessCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realUseFailureCount => $composableBuilder(
    column: $table.realUseFailureCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewIntervalIndex => $composableBuilder(
    column: $table.reviewIntervalIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTriggerAt => $composableBuilder(
    column: $table.lastTriggerAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queueState => $composableBuilder(
    column: $table.queueState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> narrationLearningSourcesRefs(
    Expression<bool> Function($$NarrationLearningSourcesTableFilterComposer f)
    f,
  ) {
    final $$NarrationLearningSourcesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationLearningSources,
          getReferencedColumn: (t) => t.learningItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningSourcesTableFilterComposer(
                $db: $db,
                $table: $db.narrationLearningSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> narrationReviewRecordsRefs(
    Expression<bool> Function($$NarrationReviewRecordsTableFilterComposer f) f,
  ) {
    final $$NarrationReviewRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationReviewRecords,
          getReferencedColumn: (t) => t.learningItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationReviewRecordsTableFilterComposer(
                $db: $db,
                $table: $db.narrationReviewRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NarrationLearningItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationLearningItemsTable> {
  $$NarrationLearningItemsTableOrderingComposer({
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

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stableKey => $composableBuilder(
    column: $table.stableKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chinese => $composableBuilder(
    column: $table.chinese,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knowledgeLevel => $composableBuilder(
    column: $table.knowledgeLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reviewRequired => $composableBuilder(
    column: $table.reviewRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masteryState => $composableBuilder(
    column: $table.masteryState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewPassCount => $composableBuilder(
    column: $table.reviewPassCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recognitionPassed => $composableBuilder(
    column: $table.recognitionPassed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get applicationPassed => $composableBuilder(
    column: $table.applicationPassed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realUseSuccessCount => $composableBuilder(
    column: $table.realUseSuccessCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realUseFailureCount => $composableBuilder(
    column: $table.realUseFailureCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewIntervalIndex => $composableBuilder(
    column: $table.reviewIntervalIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTriggerAt => $composableBuilder(
    column: $table.lastTriggerAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queueState => $composableBuilder(
    column: $table.queueState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NarrationLearningItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationLearningItemsTable> {
  $$NarrationLearningItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get stableKey =>
      $composableBuilder(column: $table.stableKey, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<String> get chinese =>
      $composableBuilder(column: $table.chinese, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classification => $composableBuilder(
    column: $table.classification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get knowledgeLevel => $composableBuilder(
    column: $table.knowledgeLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reviewRequired => $composableBuilder(
    column: $table.reviewRequired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get masteryState => $composableBuilder(
    column: $table.masteryState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewPassCount => $composableBuilder(
    column: $table.reviewPassCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get recognitionPassed => $composableBuilder(
    column: $table.recognitionPassed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get applicationPassed => $composableBuilder(
    column: $table.applicationPassed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realUseSuccessCount => $composableBuilder(
    column: $table.realUseSuccessCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realUseFailureCount => $composableBuilder(
    column: $table.realUseFailureCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewIntervalIndex => $composableBuilder(
    column: $table.reviewIntervalIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastTriggerAt => $composableBuilder(
    column: $table.lastTriggerAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get queueState => $composableBuilder(
    column: $table.queueState,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> narrationLearningSourcesRefs<T extends Object>(
    Expression<T> Function($$NarrationLearningSourcesTableAnnotationComposer a)
    f,
  ) {
    final $$NarrationLearningSourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationLearningSources,
          getReferencedColumn: (t) => t.learningItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningSourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationLearningSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> narrationReviewRecordsRefs<T extends Object>(
    Expression<T> Function($$NarrationReviewRecordsTableAnnotationComposer a) f,
  ) {
    final $$NarrationReviewRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.narrationReviewRecords,
          getReferencedColumn: (t) => t.learningItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationReviewRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationReviewRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NarrationLearningItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationLearningItemsTable,
          NarrationLearningItem,
          $$NarrationLearningItemsTableFilterComposer,
          $$NarrationLearningItemsTableOrderingComposer,
          $$NarrationLearningItemsTableAnnotationComposer,
          $$NarrationLearningItemsTableCreateCompanionBuilder,
          $$NarrationLearningItemsTableUpdateCompanionBuilder,
          (NarrationLearningItem, $$NarrationLearningItemsTableReferences),
          NarrationLearningItem,
          PrefetchHooks Function({
            bool narrationLearningSourcesRefs,
            bool narrationReviewRecordsRefs,
          })
        > {
  $$NarrationLearningItemsTableTableManager(
    _$AppDatabase db,
    $NarrationLearningItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationLearningItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationLearningItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationLearningItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> stableKey = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<String> chinese = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<String> knowledgeLevel = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<bool> reviewRequired = const Value.absent(),
                Value<int> firstSeenAt = const Value.absent(),
                Value<int> lastSeenAt = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<String> masteryState = const Value.absent(),
                Value<int> reviewPassCount = const Value.absent(),
                Value<bool> recognitionPassed = const Value.absent(),
                Value<bool> applicationPassed = const Value.absent(),
                Value<int> realUseSuccessCount = const Value.absent(),
                Value<int> realUseFailureCount = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int> reviewIntervalIndex = const Value.absent(),
                Value<int?> lastTriggerAt = const Value.absent(),
                Value<int?> lastFailureAt = const Value.absent(),
                Value<String> queueState = const Value.absent(),
                Value<bool> userConfirmed = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => NarrationLearningItemsCompanion(
                id: id,
                itemType: itemType,
                stableKey: stableKey,
                english: english,
                chinese: chinese,
                partOfSpeech: partOfSpeech,
                classification: classification,
                knowledgeLevel: knowledgeLevel,
                explanation: explanation,
                reviewRequired: reviewRequired,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                occurrenceCount: occurrenceCount,
                masteryState: masteryState,
                reviewPassCount: reviewPassCount,
                recognitionPassed: recognitionPassed,
                applicationPassed: applicationPassed,
                realUseSuccessCount: realUseSuccessCount,
                realUseFailureCount: realUseFailureCount,
                nextReviewAt: nextReviewAt,
                reviewIntervalIndex: reviewIntervalIndex,
                lastTriggerAt: lastTriggerAt,
                lastFailureAt: lastFailureAt,
                queueState: queueState,
                userConfirmed: userConfirmed,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemType,
                required String stableKey,
                required String english,
                required String chinese,
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> classification = const Value.absent(),
                Value<String> knowledgeLevel = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<bool> reviewRequired = const Value.absent(),
                required int firstSeenAt,
                required int lastSeenAt,
                Value<int> occurrenceCount = const Value.absent(),
                Value<String> masteryState = const Value.absent(),
                Value<int> reviewPassCount = const Value.absent(),
                Value<bool> recognitionPassed = const Value.absent(),
                Value<bool> applicationPassed = const Value.absent(),
                Value<int> realUseSuccessCount = const Value.absent(),
                Value<int> realUseFailureCount = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int> reviewIntervalIndex = const Value.absent(),
                Value<int?> lastTriggerAt = const Value.absent(),
                Value<int?> lastFailureAt = const Value.absent(),
                Value<String> queueState = const Value.absent(),
                Value<bool> userConfirmed = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => NarrationLearningItemsCompanion.insert(
                id: id,
                itemType: itemType,
                stableKey: stableKey,
                english: english,
                chinese: chinese,
                partOfSpeech: partOfSpeech,
                classification: classification,
                knowledgeLevel: knowledgeLevel,
                explanation: explanation,
                reviewRequired: reviewRequired,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                occurrenceCount: occurrenceCount,
                masteryState: masteryState,
                reviewPassCount: reviewPassCount,
                recognitionPassed: recognitionPassed,
                applicationPassed: applicationPassed,
                realUseSuccessCount: realUseSuccessCount,
                realUseFailureCount: realUseFailureCount,
                nextReviewAt: nextReviewAt,
                reviewIntervalIndex: reviewIntervalIndex,
                lastTriggerAt: lastTriggerAt,
                lastFailureAt: lastFailureAt,
                queueState: queueState,
                userConfirmed: userConfirmed,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationLearningItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                narrationLearningSourcesRefs = false,
                narrationReviewRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (narrationLearningSourcesRefs)
                      db.narrationLearningSources,
                    if (narrationReviewRecordsRefs) db.narrationReviewRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (narrationLearningSourcesRefs)
                        await $_getPrefetchedData<
                          NarrationLearningItem,
                          $NarrationLearningItemsTable,
                          NarrationLearningSource
                        >(
                          currentTable: table,
                          referencedTable:
                              $$NarrationLearningItemsTableReferences
                                  ._narrationLearningSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationLearningItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationLearningSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.learningItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (narrationReviewRecordsRefs)
                        await $_getPrefetchedData<
                          NarrationLearningItem,
                          $NarrationLearningItemsTable,
                          NarrationReviewRecord
                        >(
                          currentTable: table,
                          referencedTable:
                              $$NarrationLearningItemsTableReferences
                                  ._narrationReviewRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NarrationLearningItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).narrationReviewRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.learningItemId == item.id,
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

typedef $$NarrationLearningItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationLearningItemsTable,
      NarrationLearningItem,
      $$NarrationLearningItemsTableFilterComposer,
      $$NarrationLearningItemsTableOrderingComposer,
      $$NarrationLearningItemsTableAnnotationComposer,
      $$NarrationLearningItemsTableCreateCompanionBuilder,
      $$NarrationLearningItemsTableUpdateCompanionBuilder,
      (NarrationLearningItem, $$NarrationLearningItemsTableReferences),
      NarrationLearningItem,
      PrefetchHooks Function({
        bool narrationLearningSourcesRefs,
        bool narrationReviewRecordsRefs,
      })
    >;
typedef $$NarrationLearningSourcesTableCreateCompanionBuilder =
    NarrationLearningSourcesCompanion Function({
      Value<int> id,
      required int learningItemId,
      required int sessionId,
      required String sourceType,
      Value<String?> errorGrade,
      Value<String?> evidence,
      required int createdAt,
    });
typedef $$NarrationLearningSourcesTableUpdateCompanionBuilder =
    NarrationLearningSourcesCompanion Function({
      Value<int> id,
      Value<int> learningItemId,
      Value<int> sessionId,
      Value<String> sourceType,
      Value<String?> errorGrade,
      Value<String?> evidence,
      Value<int> createdAt,
    });

final class $$NarrationLearningSourcesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationLearningSourcesTable,
          NarrationLearningSource
        > {
  $$NarrationLearningSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NarrationLearningItemsTable _learningItemIdTable(_$AppDatabase db) =>
      db.narrationLearningItems.createAlias(
        $_aliasNameGenerator(
          db.narrationLearningSources.learningItemId,
          db.narrationLearningItems.id,
        ),
      );

  $$NarrationLearningItemsTableProcessedTableManager get learningItemId {
    final $_column = $_itemColumn<int>('learning_item_id')!;

    final manager = $$NarrationLearningItemsTableTableManager(
      $_db,
      $_db.narrationLearningItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_learningItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NarrationSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.narrationSessions.createAlias(
        $_aliasNameGenerator(
          db.narrationLearningSources.sessionId,
          db.narrationSessions.id,
        ),
      );

  $$NarrationSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$NarrationSessionsTableTableManager(
      $_db,
      $_db.narrationSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NarrationLearningSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationLearningSourcesTable> {
  $$NarrationLearningSourcesTableFilterComposer({
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

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorGrade => $composableBuilder(
    column: $table.errorGrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NarrationLearningItemsTableFilterComposer get learningItemId {
    final $$NarrationLearningItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.learningItemId,
          referencedTable: $db.narrationLearningItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningItemsTableFilterComposer(
                $db: $db,
                $table: $db.narrationLearningItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$NarrationSessionsTableFilterComposer get sessionId {
    final $$NarrationSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableFilterComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationLearningSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationLearningSourcesTable> {
  $$NarrationLearningSourcesTableOrderingComposer({
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

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorGrade => $composableBuilder(
    column: $table.errorGrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NarrationLearningItemsTableOrderingComposer get learningItemId {
    final $$NarrationLearningItemsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.learningItemId,
          referencedTable: $db.narrationLearningItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningItemsTableOrderingComposer(
                $db: $db,
                $table: $db.narrationLearningItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$NarrationSessionsTableOrderingComposer get sessionId {
    final $$NarrationSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationLearningSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationLearningSourcesTable> {
  $$NarrationLearningSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorGrade => $composableBuilder(
    column: $table.errorGrade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidence =>
      $composableBuilder(column: $table.evidence, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NarrationLearningItemsTableAnnotationComposer get learningItemId {
    final $$NarrationLearningItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.learningItemId,
          referencedTable: $db.narrationLearningItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationLearningItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$NarrationSessionsTableAnnotationComposer get sessionId {
    final $$NarrationSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.narrationSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationLearningSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationLearningSourcesTable,
          NarrationLearningSource,
          $$NarrationLearningSourcesTableFilterComposer,
          $$NarrationLearningSourcesTableOrderingComposer,
          $$NarrationLearningSourcesTableAnnotationComposer,
          $$NarrationLearningSourcesTableCreateCompanionBuilder,
          $$NarrationLearningSourcesTableUpdateCompanionBuilder,
          (NarrationLearningSource, $$NarrationLearningSourcesTableReferences),
          NarrationLearningSource,
          PrefetchHooks Function({bool learningItemId, bool sessionId})
        > {
  $$NarrationLearningSourcesTableTableManager(
    _$AppDatabase db,
    $NarrationLearningSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationLearningSourcesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationLearningSourcesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationLearningSourcesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> learningItemId = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String?> errorGrade = const Value.absent(),
                Value<String?> evidence = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => NarrationLearningSourcesCompanion(
                id: id,
                learningItemId: learningItemId,
                sessionId: sessionId,
                sourceType: sourceType,
                errorGrade: errorGrade,
                evidence: evidence,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int learningItemId,
                required int sessionId,
                required String sourceType,
                Value<String?> errorGrade = const Value.absent(),
                Value<String?> evidence = const Value.absent(),
                required int createdAt,
              }) => NarrationLearningSourcesCompanion.insert(
                id: id,
                learningItemId: learningItemId,
                sessionId: sessionId,
                sourceType: sourceType,
                errorGrade: errorGrade,
                evidence: evidence,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationLearningSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({learningItemId = false, sessionId = false}) {
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
                    if (learningItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.learningItemId,
                                referencedTable:
                                    $$NarrationLearningSourcesTableReferences
                                        ._learningItemIdTable(db),
                                referencedColumn:
                                    $$NarrationLearningSourcesTableReferences
                                        ._learningItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$NarrationLearningSourcesTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$NarrationLearningSourcesTableReferences
                                        ._sessionIdTable(db)
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

typedef $$NarrationLearningSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationLearningSourcesTable,
      NarrationLearningSource,
      $$NarrationLearningSourcesTableFilterComposer,
      $$NarrationLearningSourcesTableOrderingComposer,
      $$NarrationLearningSourcesTableAnnotationComposer,
      $$NarrationLearningSourcesTableCreateCompanionBuilder,
      $$NarrationLearningSourcesTableUpdateCompanionBuilder,
      (NarrationLearningSource, $$NarrationLearningSourcesTableReferences),
      NarrationLearningSource,
      PrefetchHooks Function({bool learningItemId, bool sessionId})
    >;
typedef $$NarrationReviewRecordsTableCreateCompanionBuilder =
    NarrationReviewRecordsCompanion Function({
      Value<int> id,
      required int learningItemId,
      required String layer,
      required String outcome,
      Value<bool> guided,
      Value<String?> answer,
      Value<String?> evidence,
      required int reviewedAt,
    });
typedef $$NarrationReviewRecordsTableUpdateCompanionBuilder =
    NarrationReviewRecordsCompanion Function({
      Value<int> id,
      Value<int> learningItemId,
      Value<String> layer,
      Value<String> outcome,
      Value<bool> guided,
      Value<String?> answer,
      Value<String?> evidence,
      Value<int> reviewedAt,
    });

final class $$NarrationReviewRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationReviewRecordsTable,
          NarrationReviewRecord
        > {
  $$NarrationReviewRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NarrationLearningItemsTable _learningItemIdTable(_$AppDatabase db) =>
      db.narrationLearningItems.createAlias(
        $_aliasNameGenerator(
          db.narrationReviewRecords.learningItemId,
          db.narrationLearningItems.id,
        ),
      );

  $$NarrationLearningItemsTableProcessedTableManager get learningItemId {
    final $_column = $_itemColumn<int>('learning_item_id')!;

    final manager = $$NarrationLearningItemsTableTableManager(
      $_db,
      $_db.narrationLearningItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_learningItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NarrationReviewRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationReviewRecordsTable> {
  $$NarrationReviewRecordsTableFilterComposer({
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

  ColumnFilters<String> get layer => $composableBuilder(
    column: $table.layer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get guided => $composableBuilder(
    column: $table.guided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NarrationLearningItemsTableFilterComposer get learningItemId {
    final $$NarrationLearningItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.learningItemId,
          referencedTable: $db.narrationLearningItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningItemsTableFilterComposer(
                $db: $db,
                $table: $db.narrationLearningItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationReviewRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationReviewRecordsTable> {
  $$NarrationReviewRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get layer => $composableBuilder(
    column: $table.layer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get guided => $composableBuilder(
    column: $table.guided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidence => $composableBuilder(
    column: $table.evidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NarrationLearningItemsTableOrderingComposer get learningItemId {
    final $$NarrationLearningItemsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.learningItemId,
          referencedTable: $db.narrationLearningItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningItemsTableOrderingComposer(
                $db: $db,
                $table: $db.narrationLearningItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationReviewRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationReviewRecordsTable> {
  $$NarrationReviewRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get layer =>
      $composableBuilder(column: $table.layer, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get guided =>
      $composableBuilder(column: $table.guided, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<String> get evidence =>
      $composableBuilder(column: $table.evidence, builder: (column) => column);

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$NarrationLearningItemsTableAnnotationComposer get learningItemId {
    final $$NarrationLearningItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.learningItemId,
          referencedTable: $db.narrationLearningItems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationLearningItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationLearningItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationReviewRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationReviewRecordsTable,
          NarrationReviewRecord,
          $$NarrationReviewRecordsTableFilterComposer,
          $$NarrationReviewRecordsTableOrderingComposer,
          $$NarrationReviewRecordsTableAnnotationComposer,
          $$NarrationReviewRecordsTableCreateCompanionBuilder,
          $$NarrationReviewRecordsTableUpdateCompanionBuilder,
          (NarrationReviewRecord, $$NarrationReviewRecordsTableReferences),
          NarrationReviewRecord,
          PrefetchHooks Function({bool learningItemId})
        > {
  $$NarrationReviewRecordsTableTableManager(
    _$AppDatabase db,
    $NarrationReviewRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationReviewRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationReviewRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationReviewRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> learningItemId = const Value.absent(),
                Value<String> layer = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<bool> guided = const Value.absent(),
                Value<String?> answer = const Value.absent(),
                Value<String?> evidence = const Value.absent(),
                Value<int> reviewedAt = const Value.absent(),
              }) => NarrationReviewRecordsCompanion(
                id: id,
                learningItemId: learningItemId,
                layer: layer,
                outcome: outcome,
                guided: guided,
                answer: answer,
                evidence: evidence,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int learningItemId,
                required String layer,
                required String outcome,
                Value<bool> guided = const Value.absent(),
                Value<String?> answer = const Value.absent(),
                Value<String?> evidence = const Value.absent(),
                required int reviewedAt,
              }) => NarrationReviewRecordsCompanion.insert(
                id: id,
                learningItemId: learningItemId,
                layer: layer,
                outcome: outcome,
                guided: guided,
                answer: answer,
                evidence: evidence,
                reviewedAt: reviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationReviewRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({learningItemId = false}) {
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
                    if (learningItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.learningItemId,
                                referencedTable:
                                    $$NarrationReviewRecordsTableReferences
                                        ._learningItemIdTable(db),
                                referencedColumn:
                                    $$NarrationReviewRecordsTableReferences
                                        ._learningItemIdTable(db)
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

typedef $$NarrationReviewRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationReviewRecordsTable,
      NarrationReviewRecord,
      $$NarrationReviewRecordsTableFilterComposer,
      $$NarrationReviewRecordsTableOrderingComposer,
      $$NarrationReviewRecordsTableAnnotationComposer,
      $$NarrationReviewRecordsTableCreateCompanionBuilder,
      $$NarrationReviewRecordsTableUpdateCompanionBuilder,
      (NarrationReviewRecord, $$NarrationReviewRecordsTableReferences),
      NarrationReviewRecord,
      PrefetchHooks Function({bool learningItemId})
    >;
typedef $$NarrationProgressRecordsTableCreateCompanionBuilder =
    NarrationProgressRecordsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int errorACount,
      required int errorBCount,
      required int errorCCount,
      required int collectedWordCount,
      required int coreKnowledgeCount,
      required int realUseSuccessCount,
      required int realUseFailureCount,
      required int englishWordCount,
      required int sentenceCount,
      required int chineseSubstituteCount,
      required double complexity,
      required int createdAt,
    });
typedef $$NarrationProgressRecordsTableUpdateCompanionBuilder =
    NarrationProgressRecordsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> errorACount,
      Value<int> errorBCount,
      Value<int> errorCCount,
      Value<int> collectedWordCount,
      Value<int> coreKnowledgeCount,
      Value<int> realUseSuccessCount,
      Value<int> realUseFailureCount,
      Value<int> englishWordCount,
      Value<int> sentenceCount,
      Value<int> chineseSubstituteCount,
      Value<double> complexity,
      Value<int> createdAt,
    });

final class $$NarrationProgressRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NarrationProgressRecordsTable,
          NarrationProgressRecord
        > {
  $$NarrationProgressRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NarrationSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.narrationSessions.createAlias(
        $_aliasNameGenerator(
          db.narrationProgressRecords.sessionId,
          db.narrationSessions.id,
        ),
      );

  $$NarrationSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$NarrationSessionsTableTableManager(
      $_db,
      $_db.narrationSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NarrationProgressRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationProgressRecordsTable> {
  $$NarrationProgressRecordsTableFilterComposer({
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

  ColumnFilters<int> get errorACount => $composableBuilder(
    column: $table.errorACount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorBCount => $composableBuilder(
    column: $table.errorBCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCCount => $composableBuilder(
    column: $table.errorCCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get collectedWordCount => $composableBuilder(
    column: $table.collectedWordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coreKnowledgeCount => $composableBuilder(
    column: $table.coreKnowledgeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realUseSuccessCount => $composableBuilder(
    column: $table.realUseSuccessCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get realUseFailureCount => $composableBuilder(
    column: $table.realUseFailureCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get englishWordCount => $composableBuilder(
    column: $table.englishWordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chineseSubstituteCount => $composableBuilder(
    column: $table.chineseSubstituteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get complexity => $composableBuilder(
    column: $table.complexity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NarrationSessionsTableFilterComposer get sessionId {
    final $$NarrationSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableFilterComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationProgressRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationProgressRecordsTable> {
  $$NarrationProgressRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get errorACount => $composableBuilder(
    column: $table.errorACount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorBCount => $composableBuilder(
    column: $table.errorBCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCCount => $composableBuilder(
    column: $table.errorCCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get collectedWordCount => $composableBuilder(
    column: $table.collectedWordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coreKnowledgeCount => $composableBuilder(
    column: $table.coreKnowledgeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realUseSuccessCount => $composableBuilder(
    column: $table.realUseSuccessCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get realUseFailureCount => $composableBuilder(
    column: $table.realUseFailureCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get englishWordCount => $composableBuilder(
    column: $table.englishWordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chineseSubstituteCount => $composableBuilder(
    column: $table.chineseSubstituteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get complexity => $composableBuilder(
    column: $table.complexity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NarrationSessionsTableOrderingComposer get sessionId {
    final $$NarrationSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.narrationSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NarrationSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.narrationSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NarrationProgressRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationProgressRecordsTable> {
  $$NarrationProgressRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get errorACount => $composableBuilder(
    column: $table.errorACount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorBCount => $composableBuilder(
    column: $table.errorBCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorCCount => $composableBuilder(
    column: $table.errorCCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get collectedWordCount => $composableBuilder(
    column: $table.collectedWordCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coreKnowledgeCount => $composableBuilder(
    column: $table.coreKnowledgeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realUseSuccessCount => $composableBuilder(
    column: $table.realUseSuccessCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get realUseFailureCount => $composableBuilder(
    column: $table.realUseFailureCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get englishWordCount => $composableBuilder(
    column: $table.englishWordCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chineseSubstituteCount => $composableBuilder(
    column: $table.chineseSubstituteCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get complexity => $composableBuilder(
    column: $table.complexity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NarrationSessionsTableAnnotationComposer get sessionId {
    final $$NarrationSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.narrationSessions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NarrationSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.narrationSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$NarrationProgressRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationProgressRecordsTable,
          NarrationProgressRecord,
          $$NarrationProgressRecordsTableFilterComposer,
          $$NarrationProgressRecordsTableOrderingComposer,
          $$NarrationProgressRecordsTableAnnotationComposer,
          $$NarrationProgressRecordsTableCreateCompanionBuilder,
          $$NarrationProgressRecordsTableUpdateCompanionBuilder,
          (NarrationProgressRecord, $$NarrationProgressRecordsTableReferences),
          NarrationProgressRecord,
          PrefetchHooks Function({bool sessionId})
        > {
  $$NarrationProgressRecordsTableTableManager(
    _$AppDatabase db,
    $NarrationProgressRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationProgressRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationProgressRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationProgressRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> errorACount = const Value.absent(),
                Value<int> errorBCount = const Value.absent(),
                Value<int> errorCCount = const Value.absent(),
                Value<int> collectedWordCount = const Value.absent(),
                Value<int> coreKnowledgeCount = const Value.absent(),
                Value<int> realUseSuccessCount = const Value.absent(),
                Value<int> realUseFailureCount = const Value.absent(),
                Value<int> englishWordCount = const Value.absent(),
                Value<int> sentenceCount = const Value.absent(),
                Value<int> chineseSubstituteCount = const Value.absent(),
                Value<double> complexity = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => NarrationProgressRecordsCompanion(
                id: id,
                sessionId: sessionId,
                errorACount: errorACount,
                errorBCount: errorBCount,
                errorCCount: errorCCount,
                collectedWordCount: collectedWordCount,
                coreKnowledgeCount: coreKnowledgeCount,
                realUseSuccessCount: realUseSuccessCount,
                realUseFailureCount: realUseFailureCount,
                englishWordCount: englishWordCount,
                sentenceCount: sentenceCount,
                chineseSubstituteCount: chineseSubstituteCount,
                complexity: complexity,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int errorACount,
                required int errorBCount,
                required int errorCCount,
                required int collectedWordCount,
                required int coreKnowledgeCount,
                required int realUseSuccessCount,
                required int realUseFailureCount,
                required int englishWordCount,
                required int sentenceCount,
                required int chineseSubstituteCount,
                required double complexity,
                required int createdAt,
              }) => NarrationProgressRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                errorACount: errorACount,
                errorBCount: errorBCount,
                errorCCount: errorCCount,
                collectedWordCount: collectedWordCount,
                coreKnowledgeCount: coreKnowledgeCount,
                realUseSuccessCount: realUseSuccessCount,
                realUseFailureCount: realUseFailureCount,
                englishWordCount: englishWordCount,
                sentenceCount: sentenceCount,
                chineseSubstituteCount: chineseSubstituteCount,
                complexity: complexity,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NarrationProgressRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                                    $$NarrationProgressRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$NarrationProgressRecordsTableReferences
                                        ._sessionIdTable(db)
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

typedef $$NarrationProgressRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationProgressRecordsTable,
      NarrationProgressRecord,
      $$NarrationProgressRecordsTableFilterComposer,
      $$NarrationProgressRecordsTableOrderingComposer,
      $$NarrationProgressRecordsTableAnnotationComposer,
      $$NarrationProgressRecordsTableCreateCompanionBuilder,
      $$NarrationProgressRecordsTableUpdateCompanionBuilder,
      (NarrationProgressRecord, $$NarrationProgressRecordsTableReferences),
      NarrationProgressRecord,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$NarrationConsentRecordsTableCreateCompanionBuilder =
    NarrationConsentRecordsCompanion Function({
      Value<int> id,
      required String consentType,
      required String policyVersion,
      required bool granted,
      required int createdAt,
      Value<int?> revokedAt,
    });
typedef $$NarrationConsentRecordsTableUpdateCompanionBuilder =
    NarrationConsentRecordsCompanion Function({
      Value<int> id,
      Value<String> consentType,
      Value<String> policyVersion,
      Value<bool> granted,
      Value<int> createdAt,
      Value<int?> revokedAt,
    });

class $$NarrationConsentRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationConsentRecordsTable> {
  $$NarrationConsentRecordsTableFilterComposer({
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

  ColumnFilters<String> get consentType => $composableBuilder(
    column: $table.consentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get granted => $composableBuilder(
    column: $table.granted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NarrationConsentRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationConsentRecordsTable> {
  $$NarrationConsentRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get consentType => $composableBuilder(
    column: $table.consentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get granted => $composableBuilder(
    column: $table.granted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NarrationConsentRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationConsentRecordsTable> {
  $$NarrationConsentRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get consentType => $composableBuilder(
    column: $table.consentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get granted =>
      $composableBuilder(column: $table.granted, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);
}

class $$NarrationConsentRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NarrationConsentRecordsTable,
          NarrationConsentRecord,
          $$NarrationConsentRecordsTableFilterComposer,
          $$NarrationConsentRecordsTableOrderingComposer,
          $$NarrationConsentRecordsTableAnnotationComposer,
          $$NarrationConsentRecordsTableCreateCompanionBuilder,
          $$NarrationConsentRecordsTableUpdateCompanionBuilder,
          (
            NarrationConsentRecord,
            BaseReferences<
              _$AppDatabase,
              $NarrationConsentRecordsTable,
              NarrationConsentRecord
            >,
          ),
          NarrationConsentRecord,
          PrefetchHooks Function()
        > {
  $$NarrationConsentRecordsTableTableManager(
    _$AppDatabase db,
    $NarrationConsentRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationConsentRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NarrationConsentRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NarrationConsentRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> consentType = const Value.absent(),
                Value<String> policyVersion = const Value.absent(),
                Value<bool> granted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> revokedAt = const Value.absent(),
              }) => NarrationConsentRecordsCompanion(
                id: id,
                consentType: consentType,
                policyVersion: policyVersion,
                granted: granted,
                createdAt: createdAt,
                revokedAt: revokedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String consentType,
                required String policyVersion,
                required bool granted,
                required int createdAt,
                Value<int?> revokedAt = const Value.absent(),
              }) => NarrationConsentRecordsCompanion.insert(
                id: id,
                consentType: consentType,
                policyVersion: policyVersion,
                granted: granted,
                createdAt: createdAt,
                revokedAt: revokedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NarrationConsentRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NarrationConsentRecordsTable,
      NarrationConsentRecord,
      $$NarrationConsentRecordsTableFilterComposer,
      $$NarrationConsentRecordsTableOrderingComposer,
      $$NarrationConsentRecordsTableAnnotationComposer,
      $$NarrationConsentRecordsTableCreateCompanionBuilder,
      $$NarrationConsentRecordsTableUpdateCompanionBuilder,
      (
        NarrationConsentRecord,
        BaseReferences<
          _$AppDatabase,
          $NarrationConsentRecordsTable,
          NarrationConsentRecord
        >,
      ),
      NarrationConsentRecord,
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
  $$LearningActivityRecordsTableTableManager get learningActivityRecords =>
      $$LearningActivityRecordsTableTableManager(
        _db,
        _db.learningActivityRecords,
      );
  $$LearningActivityListsTableTableManager get learningActivityLists =>
      $$LearningActivityListsTableTableManager(_db, _db.learningActivityLists);
  $$LearningActivityWordsTableTableManager get learningActivityWords =>
      $$LearningActivityWordsTableTableManager(_db, _db.learningActivityWords);
  $$TtsUsageRecordsTableTableManager get ttsUsageRecords =>
      $$TtsUsageRecordsTableTableManager(_db, _db.ttsUsageRecords);
  $$TtsCacheRecordsTableTableManager get ttsCacheRecords =>
      $$TtsCacheRecordsTableTableManager(_db, _db.ttsCacheRecords);
  $$NarrationSessionsTableTableManager get narrationSessions =>
      $$NarrationSessionsTableTableManager(_db, _db.narrationSessions);
  $$NarrationTranscriptionLogsTableTableManager
  get narrationTranscriptionLogs =>
      $$NarrationTranscriptionLogsTableTableManager(
        _db,
        _db.narrationTranscriptionLogs,
      );
  $$NarrationSelfCheckLogsTableTableManager get narrationSelfCheckLogs =>
      $$NarrationSelfCheckLogsTableTableManager(
        _db,
        _db.narrationSelfCheckLogs,
      );
  $$NarrationFeedbackLogsTableTableManager get narrationFeedbackLogs =>
      $$NarrationFeedbackLogsTableTableManager(_db, _db.narrationFeedbackLogs);
  $$NarrationLearningItemsTableTableManager get narrationLearningItems =>
      $$NarrationLearningItemsTableTableManager(
        _db,
        _db.narrationLearningItems,
      );
  $$NarrationLearningSourcesTableTableManager get narrationLearningSources =>
      $$NarrationLearningSourcesTableTableManager(
        _db,
        _db.narrationLearningSources,
      );
  $$NarrationReviewRecordsTableTableManager get narrationReviewRecords =>
      $$NarrationReviewRecordsTableTableManager(
        _db,
        _db.narrationReviewRecords,
      );
  $$NarrationProgressRecordsTableTableManager get narrationProgressRecords =>
      $$NarrationProgressRecordsTableTableManager(
        _db,
        _db.narrationProgressRecords,
      );
  $$NarrationConsentRecordsTableTableManager get narrationConsentRecords =>
      $$NarrationConsentRecordsTableTableManager(
        _db,
        _db.narrationConsentRecords,
      );
}
