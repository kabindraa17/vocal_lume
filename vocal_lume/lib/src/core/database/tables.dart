import 'package:drift/drift.dart';

class SubscribedFeeds extends Table {
  IntColumn get feedId => integer()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get artworkUrl => text().nullable()();
  DateTimeColumn get subscribedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {feedId};
}

class PlaybackProgressEntries extends Table {
  IntColumn get episodeId => integer()();
  IntColumn get feedId => integer()();
  TextColumn get episodeTitle => text()();
  TextColumn get feedTitle => text()();
  TextColumn get artworkUrl => text().nullable()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastPlayedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}
