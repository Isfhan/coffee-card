import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/ui/core/app_theme.dart';
import 'package:coffee_card/ui/features/auth/view_models/auth_view_model.dart';
import 'package:coffee_card/ui/features/cards/view_models/coffee_cards_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CoffeeCardApp extends StatelessWidget {
  const CoffeeCardApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coffee Card',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

class AppScope extends StatelessWidget {
  const AppScope({
    super.key,
    required this.authRepository,
    required this.cardRepository,
    required this.authViewModel,
    required this.router,
    required this.child,
  });

  final AuthRepository authRepository;
  final CoffeeCardRepository cardRepository;
  final AuthViewModel authViewModel;
  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>.value(value: authRepository),
        Provider<CoffeeCardRepository>.value(value: cardRepository),
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ChangeNotifierProvider(
          create: (context) =>
              CoffeeCardsViewModel(authRepository, cardRepository),
        ),
      ],
      child: child,
    );
  }
}
