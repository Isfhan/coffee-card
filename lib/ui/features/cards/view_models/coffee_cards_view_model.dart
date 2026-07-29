import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/data/repositories/coffee_card_repository.dart';
import 'package:coffee_card/domain/models/coffee_card.dart';
import 'package:flutter/foundation.dart';

class CoffeeCardsViewModel extends ChangeNotifier {
  CoffeeCardsViewModel(this._authRepository, this._cardRepository) {
    _authRepository.addListener(_onAuthChanged);
  }

  final AuthRepository _authRepository;
  final CoffeeCardRepository _cardRepository;

  List<CoffeeCard> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CoffeeCard> get cards => List.unmodifiable(_cards);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadCards() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      _cards = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _cardRepository.getCardsForUser(user.id);
    } catch (_) {
      _errorMessage = 'Could not load your coffee cards.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCard(int cardId) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _cardRepository.deleteCard(cardId: cardId, userId: user.id);
      _cards = _cards.where((card) => card.id != cardId).toList();
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Could not delete this card.';
      notifyListeners();
      return false;
    }
  }

  void _onAuthChanged() {
    if (!_authRepository.isAuthenticated) {
      _cards = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
