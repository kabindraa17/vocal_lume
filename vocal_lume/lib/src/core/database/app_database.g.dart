// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscribedFeedsTable extends SubscribedFeeds
    with TableInfo<$SubscribedFeedsTable, SubscribedFeed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscribedFeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscribedAtMeta = const VerificationMeta(
    'subscribedAt',
  );
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
    'subscribed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    feedId,
    title,
    author,
    artworkUrl,
    subscribedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscribed_feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscribedFeed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
        _subscribedAtMeta,
        subscribedAt.isAcceptableOrUnknown(
          data['subscribed_at']!,
          _subscribedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedId};
  @override
  SubscribedFeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscribedFeed(
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      subscribedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribed_at'],
      )!,
    );
  }

  @override
  $SubscribedFeedsTable createAlias(String alias) {
    return $SubscribedFeedsTable(attachedDatabase, alias);
  }
}

class SubscribedFeed extends DataClass implements Insertable<SubscribedFeed> {
  final int feedId;
  final String title;
  final String? author;
  final String? artworkUrl;
  final DateTime subscribedAt;
  const SubscribedFeed({
    required this.feedId,
    required this.title,
    this.author,
    this.artworkUrl,
    required this.subscribedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_id'] = Variable<int>(feedId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    return map;
  }

  SubscribedFeedsCompanion toCompanion(bool nullToAbsent) {
    return SubscribedFeedsCompanion(
      feedId: Value(feedId),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      subscribedAt: Value(subscribedAt),
    );
  }

  factory SubscribedFeed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscribedFeed(
      feedId: serializer.fromJson<int>(json['feedId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedId': serializer.toJson<int>(feedId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
    };
  }

  SubscribedFeed copyWith({
    int? feedId,
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> artworkUrl = const Value.absent(),
    DateTime? subscribedAt,
  }) => SubscribedFeed(
    feedId: feedId ?? this.feedId,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    subscribedAt: subscribedAt ?? this.subscribedAt,
  );
  SubscribedFeed copyWithCompanion(SubscribedFeedsCompanion data) {
    return SubscribedFeed(
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscribedFeed(')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('subscribedAt: $subscribedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(feedId, title, author, artworkUrl, subscribedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscribedFeed &&
          other.feedId == this.feedId &&
          other.title == this.title &&
          other.author == this.author &&
          other.artworkUrl == this.artworkUrl &&
          other.subscribedAt == this.subscribedAt);
}

class SubscribedFeedsCompanion extends UpdateCompanion<SubscribedFeed> {
  final Value<int> feedId;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> artworkUrl;
  final Value<DateTime> subscribedAt;
  const SubscribedFeedsCompanion({
    this.feedId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.subscribedAt = const Value.absent(),
  });
  SubscribedFeedsCompanion.insert({
    this.feedId = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    required DateTime subscribedAt,
  }) : title = Value(title),
       subscribedAt = Value(subscribedAt);
  static Insertable<SubscribedFeed> custom({
    Expression<int>? feedId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? artworkUrl,
    Expression<DateTime>? subscribedAt,
  }) {
    return RawValuesInsertable({
      if (feedId != null) 'feed_id': feedId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
    });
  }

  SubscribedFeedsCompanion copyWith({
    Value<int>? feedId,
    Value<String>? title,
    Value<String?>? author,
    Value<String?>? artworkUrl,
    Value<DateTime>? subscribedAt,
  }) {
    return SubscribedFeedsCompanion(
      feedId: feedId ?? this.feedId,
      title: title ?? this.title,
      author: author ?? this.author,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      subscribedAt: subscribedAt ?? this.subscribedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscribedFeedsCompanion(')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('subscribedAt: $subscribedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaybackProgressEntriesTable extends PlaybackProgressEntries
    with TableInfo<$PlaybackProgressEntriesTable, PlaybackProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeTitleMeta = const VerificationMeta(
    'episodeTitle',
  );
  @override
  late final GeneratedColumn<String> episodeTitle = GeneratedColumn<String>(
    'episode_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedTitleMeta = const VerificationMeta(
    'feedTitle',
  );
  @override
  late final GeneratedColumn<String> feedTitle = GeneratedColumn<String>(
    'feed_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    episodeId,
    feedId,
    episodeTitle,
    feedTitle,
    artworkUrl,
    positionMs,
    durationMs,
    isCompleted,
    lastPlayedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('episode_title')) {
      context.handle(
        _episodeTitleMeta,
        episodeTitle.isAcceptableOrUnknown(
          data['episode_title']!,
          _episodeTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeTitleMeta);
    }
    if (data.containsKey('feed_title')) {
      context.handle(
        _feedTitleMeta,
        feedTitle.isAcceptableOrUnknown(data['feed_title']!, _feedTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_feedTitleMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPlayedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  PlaybackProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackProgressEntry(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      )!,
      episodeTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_title'],
      )!,
      feedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_title'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      )!,
    );
  }

  @override
  $PlaybackProgressEntriesTable createAlias(String alias) {
    return $PlaybackProgressEntriesTable(attachedDatabase, alias);
  }
}

class PlaybackProgressEntry extends DataClass
    implements Insertable<PlaybackProgressEntry> {
  final int episodeId;
  final int feedId;
  final String episodeTitle;
  final String feedTitle;
  final String? artworkUrl;
  final int positionMs;
  final int durationMs;
  final bool isCompleted;
  final DateTime lastPlayedAt;
  const PlaybackProgressEntry({
    required this.episodeId,
    required this.feedId,
    required this.episodeTitle,
    required this.feedTitle,
    this.artworkUrl,
    required this.positionMs,
    required this.durationMs,
    required this.isCompleted,
    required this.lastPlayedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['feed_id'] = Variable<int>(feedId);
    map['episode_title'] = Variable<String>(episodeTitle);
    map['feed_title'] = Variable<String>(feedTitle);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    return map;
  }

  PlaybackProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackProgressEntriesCompanion(
      episodeId: Value(episodeId),
      feedId: Value(feedId),
      episodeTitle: Value(episodeTitle),
      feedTitle: Value(feedTitle),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      isCompleted: Value(isCompleted),
      lastPlayedAt: Value(lastPlayedAt),
    );
  }

  factory PlaybackProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackProgressEntry(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      feedId: serializer.fromJson<int>(json['feedId']),
      episodeTitle: serializer.fromJson<String>(json['episodeTitle']),
      feedTitle: serializer.fromJson<String>(json['feedTitle']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastPlayedAt: serializer.fromJson<DateTime>(json['lastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'feedId': serializer.toJson<int>(feedId),
      'episodeTitle': serializer.toJson<String>(episodeTitle),
      'feedTitle': serializer.toJson<String>(feedTitle),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastPlayedAt': serializer.toJson<DateTime>(lastPlayedAt),
    };
  }

  PlaybackProgressEntry copyWith({
    int? episodeId,
    int? feedId,
    String? episodeTitle,
    String? feedTitle,
    Value<String?> artworkUrl = const Value.absent(),
    int? positionMs,
    int? durationMs,
    bool? isCompleted,
    DateTime? lastPlayedAt,
  }) => PlaybackProgressEntry(
    episodeId: episodeId ?? this.episodeId,
    feedId: feedId ?? this.feedId,
    episodeTitle: episodeTitle ?? this.episodeTitle,
    feedTitle: feedTitle ?? this.feedTitle,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    isCompleted: isCompleted ?? this.isCompleted,
    lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
  );
  PlaybackProgressEntry copyWithCompanion(
    PlaybackProgressEntriesCompanion data,
  ) {
    return PlaybackProgressEntry(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      episodeTitle: data.episodeTitle.present
          ? data.episodeTitle.value
          : this.episodeTitle,
      feedTitle: data.feedTitle.present ? data.feedTitle.value : this.feedTitle,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackProgressEntry(')
          ..write('episodeId: $episodeId, ')
          ..write('feedId: $feedId, ')
          ..write('episodeTitle: $episodeTitle, ')
          ..write('feedTitle: $feedTitle, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    episodeId,
    feedId,
    episodeTitle,
    feedTitle,
    artworkUrl,
    positionMs,
    durationMs,
    isCompleted,
    lastPlayedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackProgressEntry &&
          other.episodeId == this.episodeId &&
          other.feedId == this.feedId &&
          other.episodeTitle == this.episodeTitle &&
          other.feedTitle == this.feedTitle &&
          other.artworkUrl == this.artworkUrl &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.isCompleted == this.isCompleted &&
          other.lastPlayedAt == this.lastPlayedAt);
}

class PlaybackProgressEntriesCompanion
    extends UpdateCompanion<PlaybackProgressEntry> {
  final Value<int> episodeId;
  final Value<int> feedId;
  final Value<String> episodeTitle;
  final Value<String> feedTitle;
  final Value<String?> artworkUrl;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<bool> isCompleted;
  final Value<DateTime> lastPlayedAt;
  const PlaybackProgressEntriesCompanion({
    this.episodeId = const Value.absent(),
    this.feedId = const Value.absent(),
    this.episodeTitle = const Value.absent(),
    this.feedTitle = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
  });
  PlaybackProgressEntriesCompanion.insert({
    this.episodeId = const Value.absent(),
    required int feedId,
    required String episodeTitle,
    required String feedTitle,
    this.artworkUrl = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime lastPlayedAt,
  }) : feedId = Value(feedId),
       episodeTitle = Value(episodeTitle),
       feedTitle = Value(feedTitle),
       lastPlayedAt = Value(lastPlayedAt);
  static Insertable<PlaybackProgressEntry> custom({
    Expression<int>? episodeId,
    Expression<int>? feedId,
    Expression<String>? episodeTitle,
    Expression<String>? feedTitle,
    Expression<String>? artworkUrl,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<bool>? isCompleted,
    Expression<DateTime>? lastPlayedAt,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (feedId != null) 'feed_id': feedId,
      if (episodeTitle != null) 'episode_title': episodeTitle,
      if (feedTitle != null) 'feed_title': feedTitle,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
    });
  }

  PlaybackProgressEntriesCompanion copyWith({
    Value<int>? episodeId,
    Value<int>? feedId,
    Value<String>? episodeTitle,
    Value<String>? feedTitle,
    Value<String?>? artworkUrl,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<bool>? isCompleted,
    Value<DateTime>? lastPlayedAt,
  }) {
    return PlaybackProgressEntriesCompanion(
      episodeId: episodeId ?? this.episodeId,
      feedId: feedId ?? this.feedId,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      feedTitle: feedTitle ?? this.feedTitle,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      isCompleted: isCompleted ?? this.isCompleted,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (episodeTitle.present) {
      map['episode_title'] = Variable<String>(episodeTitle.value);
    }
    if (feedTitle.present) {
      map['feed_title'] = Variable<String>(feedTitle.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackProgressEntriesCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('feedId: $feedId, ')
          ..write('episodeTitle: $episodeTitle, ')
          ..write('feedTitle: $feedTitle, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadedEpisodesTable extends DownloadedEpisodes
    with TableInfo<$DownloadedEpisodesTable, DownloadedEpisode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedEpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeTitleMeta = const VerificationMeta(
    'episodeTitle',
  );
  @override
  late final GeneratedColumn<String> episodeTitle = GeneratedColumn<String>(
    'episode_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedTitleMeta = const VerificationMeta(
    'feedTitle',
  );
  @override
  late final GeneratedColumn<String> feedTitle = GeneratedColumn<String>(
    'feed_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enclosureUrlMeta = const VerificationMeta(
    'enclosureUrl',
  );
  @override
  late final GeneratedColumn<String> enclosureUrl = GeneratedColumn<String>(
    'enclosure_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
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
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    episodeId,
    feedId,
    episodeTitle,
    feedTitle,
    artworkUrl,
    enclosureUrl,
    localPath,
    taskId,
    status,
    progress,
    fileSizeBytes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedEpisode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('episode_title')) {
      context.handle(
        _episodeTitleMeta,
        episodeTitle.isAcceptableOrUnknown(
          data['episode_title']!,
          _episodeTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeTitleMeta);
    }
    if (data.containsKey('feed_title')) {
      context.handle(
        _feedTitleMeta,
        feedTitle.isAcceptableOrUnknown(data['feed_title']!, _feedTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_feedTitleMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('enclosure_url')) {
      context.handle(
        _enclosureUrlMeta,
        enclosureUrl.isAcceptableOrUnknown(
          data['enclosure_url']!,
          _enclosureUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enclosureUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
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
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
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
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  DownloadedEpisode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedEpisode(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      )!,
      episodeTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_title'],
      )!,
      feedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_title'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      ),
      enclosureUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enclosure_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadedEpisodesTable createAlias(String alias) {
    return $DownloadedEpisodesTable(attachedDatabase, alias);
  }
}

class DownloadedEpisode extends DataClass
    implements Insertable<DownloadedEpisode> {
  final int episodeId;
  final int feedId;
  final String episodeTitle;
  final String feedTitle;
  final String? artworkUrl;
  final String enclosureUrl;
  final String? localPath;
  final String? taskId;

  /// queued | downloading | paused | completed | failed
  final String status;
  final double progress;
  final int? fileSizeBytes;
  final DateTime updatedAt;
  const DownloadedEpisode({
    required this.episodeId,
    required this.feedId,
    required this.episodeTitle,
    required this.feedTitle,
    this.artworkUrl,
    required this.enclosureUrl,
    this.localPath,
    this.taskId,
    required this.status,
    required this.progress,
    this.fileSizeBytes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['feed_id'] = Variable<int>(feedId);
    map['episode_title'] = Variable<String>(episodeTitle);
    map['feed_title'] = Variable<String>(feedTitle);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['enclosure_url'] = Variable<String>(enclosureUrl);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadedEpisodesCompanion toCompanion(bool nullToAbsent) {
    return DownloadedEpisodesCompanion(
      episodeId: Value(episodeId),
      feedId: Value(feedId),
      episodeTitle: Value(episodeTitle),
      feedTitle: Value(feedTitle),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      enclosureUrl: Value(enclosureUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      status: Value(status),
      progress: Value(progress),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadedEpisode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedEpisode(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      feedId: serializer.fromJson<int>(json['feedId']),
      episodeTitle: serializer.fromJson<String>(json['episodeTitle']),
      feedTitle: serializer.fromJson<String>(json['feedTitle']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      enclosureUrl: serializer.fromJson<String>(json['enclosureUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'feedId': serializer.toJson<int>(feedId),
      'episodeTitle': serializer.toJson<String>(episodeTitle),
      'feedTitle': serializer.toJson<String>(feedTitle),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'enclosureUrl': serializer.toJson<String>(enclosureUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'taskId': serializer.toJson<String?>(taskId),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadedEpisode copyWith({
    int? episodeId,
    int? feedId,
    String? episodeTitle,
    String? feedTitle,
    Value<String?> artworkUrl = const Value.absent(),
    String? enclosureUrl,
    Value<String?> localPath = const Value.absent(),
    Value<String?> taskId = const Value.absent(),
    String? status,
    double? progress,
    Value<int?> fileSizeBytes = const Value.absent(),
    DateTime? updatedAt,
  }) => DownloadedEpisode(
    episodeId: episodeId ?? this.episodeId,
    feedId: feedId ?? this.feedId,
    episodeTitle: episodeTitle ?? this.episodeTitle,
    feedTitle: feedTitle ?? this.feedTitle,
    artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
    enclosureUrl: enclosureUrl ?? this.enclosureUrl,
    localPath: localPath.present ? localPath.value : this.localPath,
    taskId: taskId.present ? taskId.value : this.taskId,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    fileSizeBytes: fileSizeBytes.present
        ? fileSizeBytes.value
        : this.fileSizeBytes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadedEpisode copyWithCompanion(DownloadedEpisodesCompanion data) {
    return DownloadedEpisode(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      episodeTitle: data.episodeTitle.present
          ? data.episodeTitle.value
          : this.episodeTitle,
      feedTitle: data.feedTitle.present ? data.feedTitle.value : this.feedTitle,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      enclosureUrl: data.enclosureUrl.present
          ? data.enclosureUrl.value
          : this.enclosureUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedEpisode(')
          ..write('episodeId: $episodeId, ')
          ..write('feedId: $feedId, ')
          ..write('episodeTitle: $episodeTitle, ')
          ..write('feedTitle: $feedTitle, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('enclosureUrl: $enclosureUrl, ')
          ..write('localPath: $localPath, ')
          ..write('taskId: $taskId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    episodeId,
    feedId,
    episodeTitle,
    feedTitle,
    artworkUrl,
    enclosureUrl,
    localPath,
    taskId,
    status,
    progress,
    fileSizeBytes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedEpisode &&
          other.episodeId == this.episodeId &&
          other.feedId == this.feedId &&
          other.episodeTitle == this.episodeTitle &&
          other.feedTitle == this.feedTitle &&
          other.artworkUrl == this.artworkUrl &&
          other.enclosureUrl == this.enclosureUrl &&
          other.localPath == this.localPath &&
          other.taskId == this.taskId &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.updatedAt == this.updatedAt);
}

class DownloadedEpisodesCompanion extends UpdateCompanion<DownloadedEpisode> {
  final Value<int> episodeId;
  final Value<int> feedId;
  final Value<String> episodeTitle;
  final Value<String> feedTitle;
  final Value<String?> artworkUrl;
  final Value<String> enclosureUrl;
  final Value<String?> localPath;
  final Value<String?> taskId;
  final Value<String> status;
  final Value<double> progress;
  final Value<int?> fileSizeBytes;
  final Value<DateTime> updatedAt;
  const DownloadedEpisodesCompanion({
    this.episodeId = const Value.absent(),
    this.feedId = const Value.absent(),
    this.episodeTitle = const Value.absent(),
    this.feedTitle = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.enclosureUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.taskId = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadedEpisodesCompanion.insert({
    this.episodeId = const Value.absent(),
    required int feedId,
    required String episodeTitle,
    required String feedTitle,
    this.artworkUrl = const Value.absent(),
    required String enclosureUrl,
    this.localPath = const Value.absent(),
    this.taskId = const Value.absent(),
    required String status,
    this.progress = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    required DateTime updatedAt,
  }) : feedId = Value(feedId),
       episodeTitle = Value(episodeTitle),
       feedTitle = Value(feedTitle),
       enclosureUrl = Value(enclosureUrl),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadedEpisode> custom({
    Expression<int>? episodeId,
    Expression<int>? feedId,
    Expression<String>? episodeTitle,
    Expression<String>? feedTitle,
    Expression<String>? artworkUrl,
    Expression<String>? enclosureUrl,
    Expression<String>? localPath,
    Expression<String>? taskId,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<int>? fileSizeBytes,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (feedId != null) 'feed_id': feedId,
      if (episodeTitle != null) 'episode_title': episodeTitle,
      if (feedTitle != null) 'feed_title': feedTitle,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (enclosureUrl != null) 'enclosure_url': enclosureUrl,
      if (localPath != null) 'local_path': localPath,
      if (taskId != null) 'task_id': taskId,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadedEpisodesCompanion copyWith({
    Value<int>? episodeId,
    Value<int>? feedId,
    Value<String>? episodeTitle,
    Value<String>? feedTitle,
    Value<String?>? artworkUrl,
    Value<String>? enclosureUrl,
    Value<String?>? localPath,
    Value<String?>? taskId,
    Value<String>? status,
    Value<double>? progress,
    Value<int?>? fileSizeBytes,
    Value<DateTime>? updatedAt,
  }) {
    return DownloadedEpisodesCompanion(
      episodeId: episodeId ?? this.episodeId,
      feedId: feedId ?? this.feedId,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      feedTitle: feedTitle ?? this.feedTitle,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      enclosureUrl: enclosureUrl ?? this.enclosureUrl,
      localPath: localPath ?? this.localPath,
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (episodeTitle.present) {
      map['episode_title'] = Variable<String>(episodeTitle.value);
    }
    if (feedTitle.present) {
      map['feed_title'] = Variable<String>(feedTitle.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (enclosureUrl.present) {
      map['enclosure_url'] = Variable<String>(enclosureUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedEpisodesCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('feedId: $feedId, ')
          ..write('episodeTitle: $episodeTitle, ')
          ..write('feedTitle: $feedTitle, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('enclosureUrl: $enclosureUrl, ')
          ..write('localPath: $localPath, ')
          ..write('taskId: $taskId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscribedFeedsTable subscribedFeeds = $SubscribedFeedsTable(
    this,
  );
  late final $PlaybackProgressEntriesTable playbackProgressEntries =
      $PlaybackProgressEntriesTable(this);
  late final $DownloadedEpisodesTable downloadedEpisodes =
      $DownloadedEpisodesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subscribedFeeds,
    playbackProgressEntries,
    downloadedEpisodes,
  ];
}

typedef $$SubscribedFeedsTableCreateCompanionBuilder =
    SubscribedFeedsCompanion Function({
      Value<int> feedId,
      required String title,
      Value<String?> author,
      Value<String?> artworkUrl,
      required DateTime subscribedAt,
    });
typedef $$SubscribedFeedsTableUpdateCompanionBuilder =
    SubscribedFeedsCompanion Function({
      Value<int> feedId,
      Value<String> title,
      Value<String?> author,
      Value<String?> artworkUrl,
      Value<DateTime> subscribedAt,
    });

class $$SubscribedFeedsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscribedFeedsTable> {
  $$SubscribedFeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscribedFeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscribedFeedsTable> {
  $$SubscribedFeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscribedFeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscribedFeedsTable> {
  $$SubscribedFeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => column,
  );
}

class $$SubscribedFeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscribedFeedsTable,
          SubscribedFeed,
          $$SubscribedFeedsTableFilterComposer,
          $$SubscribedFeedsTableOrderingComposer,
          $$SubscribedFeedsTableAnnotationComposer,
          $$SubscribedFeedsTableCreateCompanionBuilder,
          $$SubscribedFeedsTableUpdateCompanionBuilder,
          (
            SubscribedFeed,
            BaseReferences<
              _$AppDatabase,
              $SubscribedFeedsTable,
              SubscribedFeed
            >,
          ),
          SubscribedFeed,
          PrefetchHooks Function()
        > {
  $$SubscribedFeedsTableTableManager(
    _$AppDatabase db,
    $SubscribedFeedsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscribedFeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscribedFeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscribedFeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> feedId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<DateTime> subscribedAt = const Value.absent(),
              }) => SubscribedFeedsCompanion(
                feedId: feedId,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                subscribedAt: subscribedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> feedId = const Value.absent(),
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                required DateTime subscribedAt,
              }) => SubscribedFeedsCompanion.insert(
                feedId: feedId,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                subscribedAt: subscribedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscribedFeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscribedFeedsTable,
      SubscribedFeed,
      $$SubscribedFeedsTableFilterComposer,
      $$SubscribedFeedsTableOrderingComposer,
      $$SubscribedFeedsTableAnnotationComposer,
      $$SubscribedFeedsTableCreateCompanionBuilder,
      $$SubscribedFeedsTableUpdateCompanionBuilder,
      (
        SubscribedFeed,
        BaseReferences<_$AppDatabase, $SubscribedFeedsTable, SubscribedFeed>,
      ),
      SubscribedFeed,
      PrefetchHooks Function()
    >;
typedef $$PlaybackProgressEntriesTableCreateCompanionBuilder =
    PlaybackProgressEntriesCompanion Function({
      Value<int> episodeId,
      required int feedId,
      required String episodeTitle,
      required String feedTitle,
      Value<String?> artworkUrl,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> isCompleted,
      required DateTime lastPlayedAt,
    });
typedef $$PlaybackProgressEntriesTableUpdateCompanionBuilder =
    PlaybackProgressEntriesCompanion Function({
      Value<int> episodeId,
      Value<int> feedId,
      Value<String> episodeTitle,
      Value<String> feedTitle,
      Value<String?> artworkUrl,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> isCompleted,
      Value<DateTime> lastPlayedAt,
    });

class $$PlaybackProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackProgressEntriesTable> {
  $$PlaybackProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedTitle => $composableBuilder(
    column: $table.feedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackProgressEntriesTable> {
  $$PlaybackProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedTitle => $composableBuilder(
    column: $table.feedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackProgressEntriesTable> {
  $$PlaybackProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<int> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedTitle =>
      $composableBuilder(column: $table.feedTitle, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );
}

class $$PlaybackProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackProgressEntriesTable,
          PlaybackProgressEntry,
          $$PlaybackProgressEntriesTableFilterComposer,
          $$PlaybackProgressEntriesTableOrderingComposer,
          $$PlaybackProgressEntriesTableAnnotationComposer,
          $$PlaybackProgressEntriesTableCreateCompanionBuilder,
          $$PlaybackProgressEntriesTableUpdateCompanionBuilder,
          (
            PlaybackProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $PlaybackProgressEntriesTable,
              PlaybackProgressEntry
            >,
          ),
          PlaybackProgressEntry,
          PrefetchHooks Function()
        > {
  $$PlaybackProgressEntriesTableTableManager(
    _$AppDatabase db,
    $PlaybackProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackProgressEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlaybackProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<int> feedId = const Value.absent(),
                Value<String> episodeTitle = const Value.absent(),
                Value<String> feedTitle = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> lastPlayedAt = const Value.absent(),
              }) => PlaybackProgressEntriesCompanion(
                episodeId: episodeId,
                feedId: feedId,
                episodeTitle: episodeTitle,
                feedTitle: feedTitle,
                artworkUrl: artworkUrl,
                positionMs: positionMs,
                durationMs: durationMs,
                isCompleted: isCompleted,
                lastPlayedAt: lastPlayedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required int feedId,
                required String episodeTitle,
                required String feedTitle,
                Value<String?> artworkUrl = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime lastPlayedAt,
              }) => PlaybackProgressEntriesCompanion.insert(
                episodeId: episodeId,
                feedId: feedId,
                episodeTitle: episodeTitle,
                feedTitle: feedTitle,
                artworkUrl: artworkUrl,
                positionMs: positionMs,
                durationMs: durationMs,
                isCompleted: isCompleted,
                lastPlayedAt: lastPlayedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackProgressEntriesTable,
      PlaybackProgressEntry,
      $$PlaybackProgressEntriesTableFilterComposer,
      $$PlaybackProgressEntriesTableOrderingComposer,
      $$PlaybackProgressEntriesTableAnnotationComposer,
      $$PlaybackProgressEntriesTableCreateCompanionBuilder,
      $$PlaybackProgressEntriesTableUpdateCompanionBuilder,
      (
        PlaybackProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $PlaybackProgressEntriesTable,
          PlaybackProgressEntry
        >,
      ),
      PlaybackProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$DownloadedEpisodesTableCreateCompanionBuilder =
    DownloadedEpisodesCompanion Function({
      Value<int> episodeId,
      required int feedId,
      required String episodeTitle,
      required String feedTitle,
      Value<String?> artworkUrl,
      required String enclosureUrl,
      Value<String?> localPath,
      Value<String?> taskId,
      required String status,
      Value<double> progress,
      Value<int?> fileSizeBytes,
      required DateTime updatedAt,
    });
typedef $$DownloadedEpisodesTableUpdateCompanionBuilder =
    DownloadedEpisodesCompanion Function({
      Value<int> episodeId,
      Value<int> feedId,
      Value<String> episodeTitle,
      Value<String> feedTitle,
      Value<String?> artworkUrl,
      Value<String> enclosureUrl,
      Value<String?> localPath,
      Value<String?> taskId,
      Value<String> status,
      Value<double> progress,
      Value<int?> fileSizeBytes,
      Value<DateTime> updatedAt,
    });

class $$DownloadedEpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedEpisodesTable> {
  $$DownloadedEpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedTitle => $composableBuilder(
    column: $table.feedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enclosureUrl => $composableBuilder(
    column: $table.enclosureUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedEpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedEpisodesTable> {
  $$DownloadedEpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedTitle => $composableBuilder(
    column: $table.feedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enclosureUrl => $composableBuilder(
    column: $table.enclosureUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedEpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedEpisodesTable> {
  $$DownloadedEpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<int> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedTitle =>
      $composableBuilder(column: $table.feedTitle, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enclosureUrl => $composableBuilder(
    column: $table.enclosureUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadedEpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedEpisodesTable,
          DownloadedEpisode,
          $$DownloadedEpisodesTableFilterComposer,
          $$DownloadedEpisodesTableOrderingComposer,
          $$DownloadedEpisodesTableAnnotationComposer,
          $$DownloadedEpisodesTableCreateCompanionBuilder,
          $$DownloadedEpisodesTableUpdateCompanionBuilder,
          (
            DownloadedEpisode,
            BaseReferences<
              _$AppDatabase,
              $DownloadedEpisodesTable,
              DownloadedEpisode
            >,
          ),
          DownloadedEpisode,
          PrefetchHooks Function()
        > {
  $$DownloadedEpisodesTableTableManager(
    _$AppDatabase db,
    $DownloadedEpisodesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedEpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedEpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedEpisodesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<int> feedId = const Value.absent(),
                Value<String> episodeTitle = const Value.absent(),
                Value<String> feedTitle = const Value.absent(),
                Value<String?> artworkUrl = const Value.absent(),
                Value<String> enclosureUrl = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadedEpisodesCompanion(
                episodeId: episodeId,
                feedId: feedId,
                episodeTitle: episodeTitle,
                feedTitle: feedTitle,
                artworkUrl: artworkUrl,
                enclosureUrl: enclosureUrl,
                localPath: localPath,
                taskId: taskId,
                status: status,
                progress: progress,
                fileSizeBytes: fileSizeBytes,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required int feedId,
                required String episodeTitle,
                required String feedTitle,
                Value<String?> artworkUrl = const Value.absent(),
                required String enclosureUrl,
                Value<String?> localPath = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                required String status,
                Value<double> progress = const Value.absent(),
                Value<int?> fileSizeBytes = const Value.absent(),
                required DateTime updatedAt,
              }) => DownloadedEpisodesCompanion.insert(
                episodeId: episodeId,
                feedId: feedId,
                episodeTitle: episodeTitle,
                feedTitle: feedTitle,
                artworkUrl: artworkUrl,
                enclosureUrl: enclosureUrl,
                localPath: localPath,
                taskId: taskId,
                status: status,
                progress: progress,
                fileSizeBytes: fileSizeBytes,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedEpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedEpisodesTable,
      DownloadedEpisode,
      $$DownloadedEpisodesTableFilterComposer,
      $$DownloadedEpisodesTableOrderingComposer,
      $$DownloadedEpisodesTableAnnotationComposer,
      $$DownloadedEpisodesTableCreateCompanionBuilder,
      $$DownloadedEpisodesTableUpdateCompanionBuilder,
      (
        DownloadedEpisode,
        BaseReferences<
          _$AppDatabase,
          $DownloadedEpisodesTable,
          DownloadedEpisode
        >,
      ),
      DownloadedEpisode,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscribedFeedsTableTableManager get subscribedFeeds =>
      $$SubscribedFeedsTableTableManager(_db, _db.subscribedFeeds);
  $$PlaybackProgressEntriesTableTableManager get playbackProgressEntries =>
      $$PlaybackProgressEntriesTableTableManager(
        _db,
        _db.playbackProgressEntries,
      );
  $$DownloadedEpisodesTableTableManager get downloadedEpisodes =>
      $$DownloadedEpisodesTableTableManager(_db, _db.downloadedEpisodes);
}
