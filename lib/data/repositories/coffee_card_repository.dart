import 'package:coffee_card/data/services/app_database.dart';
import 'package:coffee_card/data/services/image_storage_service.dart';
import 'package:coffee_card/domain/models/coffee_card.dart' as domain;
import 'package:drift/drift.dart';

class CoffeeCardRepository {
  CoffeeCardRepository(this._database, this._imageStorage);

  final AppDatabase _database;
  final ImageStorageService _imageStorage;

  Future<List<domain.CoffeeCard>> getCardsForUser(int userId) async {
    final rows =
        await (_database.select(_database.coffeeCards)
              ..where((card) => card.userId.equals(userId))
              ..orderBy([(card) => OrderingTerm.desc(card.updatedAt)]))
            .get();
    return rows.map(_mapCard).toList();
  }

  Future<domain.CoffeeCard?> getCard({
    required int cardId,
    required int userId,
  }) async {
    final row =
        await (_database.select(_database.coffeeCards)..where(
              (card) => card.id.equals(cardId) & card.userId.equals(userId),
            ))
            .getSingleOrNull();
    return row == null ? null : _mapCard(row);
  }

  Future<domain.CoffeeCard> createCard({
    required int userId,
    required String title,
    required String description,
    required int rating,
    String? sourceImagePath,
  }) async {
    _validateCardInput(title: title, description: description, rating: rating);

    final storedImagePath = await _persistImage(sourceImagePath);
    final now = DateTime.now();

    final id = await _database
        .into(_database.coffeeCards)
        .insert(
          CoffeeCardsCompanion.insert(
            userId: userId,
            title: title.trim(),
            description: description.trim(),
            imagePath: storedImagePath,
            rating: Value(rating),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    final created = await getCard(cardId: id, userId: userId);
    return created!;
  }

  Future<domain.CoffeeCard> updateCard({
    required int cardId,
    required int userId,
    required String title,
    required String description,
    required int rating,
    String? sourceImagePath,
    bool removeImage = false,
  }) async {
    _validateCardInput(title: title, description: description, rating: rating);

    final existing = await getCard(cardId: cardId, userId: userId);
    if (existing == null) {
      throw StateError('Coffee card not found.');
    }

    var imagePath = existing.imagePath;
    if (removeImage) {
      await _imageStorage.deleteImageIfExists(existing.imagePath);
      imagePath = '';
    } else if (sourceImagePath != null && sourceImagePath.isNotEmpty) {
      await _imageStorage.deleteImageIfExists(existing.imagePath);
      imagePath = await _persistImage(sourceImagePath);
    }

    final now = DateTime.now();
    await (_database.update(
          _database.coffeeCards,
        )..where((card) => card.id.equals(cardId) & card.userId.equals(userId)))
        .write(
          CoffeeCardsCompanion(
            title: Value(title.trim()),
            description: Value(description.trim()),
            imagePath: Value(imagePath),
            rating: Value(rating),
            updatedAt: Value(now),
          ),
        );

    final updated = await getCard(cardId: cardId, userId: userId);
    return updated!;
  }

  Future<void> deleteCard({required int cardId, required int userId}) async {
    final existing = await getCard(cardId: cardId, userId: userId);
    if (existing == null) {
      return;
    }

    await _imageStorage.deleteImageIfExists(existing.imagePath);
    await (_database.delete(
          _database.coffeeCards,
        )..where((card) => card.id.equals(cardId) & card.userId.equals(userId)))
        .go();
  }

  Future<String> _persistImage(String? sourceImagePath) async {
    if (sourceImagePath == null || sourceImagePath.isEmpty) {
      return '';
    }
    return _imageStorage.saveImageFromPath(sourceImagePath);
  }

  void _validateCardInput({
    required String title,
    required String description,
    required int rating,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title is required.');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError('Description is required.');
    }
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5.');
    }
  }

  domain.CoffeeCard _mapCard(CoffeeCard row) {
    return domain.CoffeeCard(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      imagePath: row.imagePath,
      rating: row.rating,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
