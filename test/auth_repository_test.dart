import 'package:coffee_card/data/services/app_database.dart';
import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/domain/auth_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late AuthRepository repository;

  setUp(() {
    database = createTestDatabase();
    repository = AuthRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('register creates user and session', () async {
    await repository.initialize();

    final user = await repository.register(
      email: 'Brewer@Example.com',
      displayName: 'Brewer',
      password: 'password123',
      confirmPassword: 'password123',
    );

    expect(user.email, 'brewer@example.com');
    expect(repository.isAuthenticated, isTrue);

    final restoredRepository = AuthRepository(database);
    await restoredRepository.initialize();
    expect(restoredRepository.currentUser?.id, user.id);
  });

  test('register rejects duplicate email', () async {
    await repository.register(
      email: 'brewer@example.com',
      displayName: 'Brewer',
      password: 'password123',
      confirmPassword: 'password123',
    );

    expect(
      () => repository.register(
        email: 'brewer@example.com',
        displayName: 'Other',
        password: 'password123',
        confirmPassword: 'password123',
      ),
      throwsA(isA<AuthDuplicateEmailException>()),
    );
  });

  test('login validates credentials', () async {
    await repository.register(
      email: 'brewer@example.com',
      displayName: 'Brewer',
      password: 'password123',
      confirmPassword: 'password123',
    );
    await repository.logout();

    final user = await repository.login(
      email: 'brewer@example.com',
      password: 'password123',
    );
    expect(user.displayName, 'Brewer');

    await repository.logout();
    expect(
      () => repository.login(
        email: 'brewer@example.com',
        password: 'wrong-password',
      ),
      throwsA(isA<AuthCredentialsException>()),
    );
  });

  test('register validates password length', () async {
    expect(
      () => repository.register(
        email: 'brewer@example.com',
        displayName: 'Brewer',
        password: 'short',
        confirmPassword: 'short',
      ),
      throwsA(isA<AuthValidationException>()),
    );
  });
}
