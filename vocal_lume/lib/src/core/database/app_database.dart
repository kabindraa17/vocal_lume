import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SubscribedFeeds, PlaybackProgressEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
