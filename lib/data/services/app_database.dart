import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get email => text().withLength(min: 3, max: 255).unique()();

  TextColumn get displayName => text().withLength(min: 1, max: 100)();

  TextColumn get passwordHash => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class CoffeeCards extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().withLength(min: 1, max: 2000)();

  TextColumn get imagePath => text()();

  IntColumn get rating => integer().withDefault(const Constant(3))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSessions extends Table {
  IntColumn get id => integer()();

  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, CoffeeCards, AppSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static Future<AppDatabase> open({String name = 'coffee_card_db'}) async {
    return AppDatabase(driftDatabase(name: name));
  }
}
