import 'dart:io';

import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/data/services/app_database.dart';
import 'package:coffee_card/data/services/image_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late Directory tempDir;
  late ImageStorageService imageStorage;
  late AuthRepository authRepository;
  late CoffeeCardRepository cardRepository;

  setUp(() async {
    database = createTestDatabase();
    tempDir = await Directory.systemTemp.createTemp('coffee_card_test');
    imageStorage = _TestImageStorageService(tempDir);
    await imageStorage.ensureInitialized();
    authRepository = AuthRepository(database);
    cardRepository = CoffeeCardRepository(database, imageStorage);
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('cards are isolated per user', () async {
    final userA = await authRepository.register(
      email: 'a@example.com',
      displayName: 'User A',
      password: 'password123',
      confirmPassword: 'password123',
    );
    await cardRepository.createCard(
      userId: userA.id,
      title: 'A Brew',
      description: 'Smooth',
      rating: 4,
    );
    await authRepository.logout();

    final userB = await authRepository.register(
      email: 'b@example.com',
      displayName: 'User B',
      password: 'password123',
      confirmPassword: 'password123',
    );

    final userBCards = await cardRepository.getCardsForUser(userB.id);
    expect(userBCards, isEmpty);

    final userACards = await cardRepository.getCardsForUser(userA.id);
    expect(userACards, hasLength(1));
    expect(userACards.first.title, 'A Brew');
  });

  test('create update and delete card', () async {
    final user = await authRepository.register(
      email: 'brewer@example.com',
      displayName: 'Brewer',
      password: 'password123',
      confirmPassword: 'password123',
    );

    final imageFile = File(p.join(tempDir.path, 'source.jpg'));
    await imageFile.writeAsBytes([1, 2, 3, 4]);

    final created = await cardRepository.createCard(
      userId: user.id,
      title: 'Morning Cup',
      description: 'Chocolate notes',
      rating: 5,
      sourceImagePath: imageFile.path,
    );

    expect(created.hasImage, isTrue);

    final updated = await cardRepository.updateCard(
      cardId: created.id,
      userId: user.id,
      title: 'Updated Cup',
      description: 'Fruity finish',
      rating: 3,
    );
    expect(updated.title, 'Updated Cup');
    expect(updated.rating, 3);

    await cardRepository.deleteCard(cardId: created.id, userId: user.id);
    final cards = await cardRepository.getCardsForUser(user.id);
    expect(cards, isEmpty);
  });
}

class _TestImageStorageService extends ImageStorageService {
  _TestImageStorageService(this._directory);

  final Directory _directory;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<String> saveImageFromPath(String sourcePath) async {
    final fileName = p.basename(sourcePath);
    final destination = File(p.join(_directory.path, fileName));
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  @override
  Future<void> deleteImageIfExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
