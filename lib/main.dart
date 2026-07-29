import 'package:coffee_card/app.dart';
import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/data/services/app_database.dart';
import 'package:coffee_card/data/services/image_storage_service.dart';
import 'package:coffee_card/routing/app_router.dart';
import 'package:coffee_card/ui/features/auth/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.open();
  final imageStorage = ImageStorageService();
  await imageStorage.ensureInitialized();

  final authRepository = AuthRepository(database);
  final cardRepository = CoffeeCardRepository(database, imageStorage);
  await authRepository.initialize();

  final authViewModel = AuthViewModel(authRepository);
  final router = createAppRouter(authViewModel: authViewModel);

  runApp(
    AppScope(
      authRepository: authRepository,
      cardRepository: cardRepository,
      authViewModel: authViewModel,
      router: router,
      child: CoffeeCardApp(router: router),
    ),
  );
}
