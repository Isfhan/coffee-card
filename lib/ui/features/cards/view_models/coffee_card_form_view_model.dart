import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/domain/models/coffee_card.dart';
import 'package:flutter/foundation.dart';

class CoffeeCardFormViewModel extends ChangeNotifier {
  CoffeeCardFormViewModel(
    this._authRepository,
    this._cardRepository, {
    this.cardId,
  });

  final AuthRepository _authRepository;
  final CoffeeCardRepository _cardRepository;
  final int? cardId;

  CoffeeCard? _existing;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  String? _pickedImagePath;
  bool _removeImage = false;

  bool get isEdit => cardId != null;

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;

  String get initialTitle => _existing?.title ?? '';

  String get initialDescription => _existing?.description ?? '';

  int get initialRating => _existing?.rating ?? 3;

  String? get existingImagePath => _existing?.imagePath;

  String? get previewImagePath {
    if (_removeImage) {
      return null;
    }
    if (_pickedImagePath != null && _pickedImagePath!.isNotEmpty) {
      return _pickedImagePath;
    }
    if (_existing != null && _existing!.hasImage) {
      return _existing!.imagePath;
    }
    return null;
  }

  Future<void> load() async {
    if (cardId == null) {
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _existing = await _cardRepository.getCard(
        cardId: cardId!,
        userId: user.id,
      );
      if (_existing == null) {
        _errorMessage = 'Coffee card not found.';
      }
    } catch (_) {
      _errorMessage = 'Could not load this coffee card.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPickedImage(String? path) {
    _pickedImagePath = path;
    _removeImage = false;
    notifyListeners();
  }

  void clearImage() {
    _pickedImagePath = null;
    _removeImage = true;
    notifyListeners();
  }

  Future<bool> submit({
    required String title,
    required String description,
    required int rating,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      _errorMessage = 'You must be signed in.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isEdit) {
        await _cardRepository.updateCard(
          cardId: cardId!,
          userId: user.id,
          title: title,
          description: description,
          rating: rating,
          sourceImagePath: _pickedImagePath,
          removeImage: _removeImage,
        );
      } else {
        await _cardRepository.createCard(
          userId: user.id,
          title: title,
          description: description,
          rating: rating,
          sourceImagePath: _pickedImagePath,
        );
      }
      return true;
    } on ArgumentError catch (error) {
      _errorMessage = error.message?.toString() ?? 'Invalid card details.';
      return false;
    } catch (_) {
      _errorMessage = 'Could not save this coffee card.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
