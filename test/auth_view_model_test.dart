import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/ui/features/auth/view_models/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_database.dart';

void main() {
  test('login failure exposes error message', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final authRepository = AuthRepository(database);
    final viewModel = AuthViewModel(authRepository);
    addTearDown(viewModel.dispose);

    final success = await viewModel.login(
      email: 'missing@example.com',
      password: 'password123',
    );

    expect(success, isFalse);
    expect(viewModel.errorMessage, isNotNull);
  });
}
