import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/domain/auth_exception.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authRepository) {
    _authRepository.addListener(_onAuthChanged);
  }

  final AuthRepository _authRepository;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isInitializing => _authRepository.isInitializing;

  bool get isAuthenticated => _authRepository.isAuthenticated;

  bool get isSubmitting => _isSubmitting;

  String? get errorMessage => _errorMessage;

  Future<bool> login({required String email, required String password}) async {
    return _runAuthAction(() async {
      await _authRepository.login(email: email, password: password);
    });
  }

  Future<bool> register({
    required String email,
    required String displayName,
    required String password,
    required String confirmPassword,
  }) async {
    return _runAuthAction(() async {
      await _authRepository.register(
        email: email,
        displayName: displayName,
        password: password,
        confirmPassword: confirmPassword,
      );
    });
  }

  Future<void> logout() => _authRepository.logout();

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _onAuthChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
