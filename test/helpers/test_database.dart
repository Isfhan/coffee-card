import 'package:coffee_card/data/services/app_database.dart';
import 'package:drift/native.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
