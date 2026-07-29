import 'package:coffee_card/app.dart';
import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/data/services/image_storage_service.dart';
import 'package:coffee_card/routing/app_router.dart';
import 'package:coffee_card/ui/features/auth/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_database.dart';

void main() {
  testWidgets('shows login screen when signed out', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final imageStorage = ImageStorageService();
    final authRepository = AuthRepository(database);
    final cardRepository = CoffeeCardRepository(database, imageStorage);
    await authRepository.initialize();

    final authViewModel = AuthViewModel(authRepository);
    final router = createAppRouter(authViewModel: authViewModel);

    await tester.pumpWidget(
      AppScope(
        authRepository: authRepository,
        cardRepository: cardRepository,
        authViewModel: authViewModel,
        router: router,
        child: CoffeeCardApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
  });

  testWidgets('register navigates to home', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final imageStorage = ImageStorageService();
    final authRepository = AuthRepository(database);
    final cardRepository = CoffeeCardRepository(database, imageStorage);
    await authRepository.initialize();

    final authViewModel = AuthViewModel(authRepository);
    final router = createAppRouter(authViewModel: authViewModel);

    await tester.pumpWidget(
      AppScope(
        authRepository: authRepository,
        cardRepository: cardRepository,
        authViewModel: authViewModel,
        router: router,
        child: CoffeeCardApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('register_name')), 'Brewer');
    await tester.enterText(
      find.byKey(const Key('register_email')),
      'brewer@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm_password')),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('My Coffee Cards'), findsOneWidget);
    expect(find.text('Hello, Brewer'), findsOneWidget);
  });
}
