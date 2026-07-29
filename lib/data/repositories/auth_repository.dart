import 'package:bcrypt/bcrypt.dart';
import 'package:coffee_card/data/services/app_database.dart';
import 'package:coffee_card/domain/auth_exception.dart';
import 'package:coffee_card/domain/models/app_user.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository(this._database);

  final AppDatabase _database;

  AppUser? _currentUser;
  bool _isInitializing = true;

  AppUser? get currentUser => _currentUser;

  bool get isInitializing => _isInitializing;

  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    final session = await (_database.select(
      _database.appSessions,
    )..where((row) => row.id.equals(1))).getSingleOrNull();

    if (session != null) {
      _currentUser = await _loadUser(session.userId);
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<AppUser> register({
    required String email,
    required String displayName,
    required String password,
    required String confirmPassword,
  }) async {
    _validateRegistration(
      email: email,
      displayName: displayName,
      password: password,
      confirmPassword: confirmPassword,
    );

    final normalizedEmail = _normalizeEmail(email);
    final existing = await (_database.select(
      _database.users,
    )..where((user) => user.email.equals(normalizedEmail))).getSingleOrNull();
    if (existing != null) {
      throw const AuthDuplicateEmailException();
    }

    final userId = await _database
        .into(_database.users)
        .insert(
          UsersCompanion.insert(
            email: normalizedEmail,
            displayName: displayName.trim(),
            passwordHash: BCrypt.hashpw(password, BCrypt.gensalt()),
          ),
        );

    await _persistSession(userId);
    _currentUser = await _loadUser(userId);
    notifyListeners();
    return _currentUser!;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthValidationException('Email and password are required.');
    }

    final normalizedEmail = _normalizeEmail(email);
    final row = await (_database.select(
      _database.users,
    )..where((user) => user.email.equals(normalizedEmail))).getSingleOrNull();

    if (row == null || !BCrypt.checkpw(password, row.passwordHash)) {
      throw const AuthCredentialsException('Invalid email or password.');
    }

    await _persistSession(row.id);
    _currentUser = _mapUser(row);
    notifyListeners();
    return _currentUser!;
  }

  Future<void> logout() async {
    await (_database.delete(
      _database.appSessions,
    )..where((row) => row.id.equals(1))).go();
    _currentUser = null;
    notifyListeners();
  }

  Future<AppUser?> _loadUser(int userId) async {
    final row = await (_database.select(
      _database.users,
    )..where((user) => user.id.equals(userId))).getSingleOrNull();
    return row == null ? null : _mapUser(row);
  }

  Future<void> _persistSession(int userId) async {
    await _database
        .into(_database.appSessions)
        .insertOnConflictUpdate(
          AppSessionsCompanion.insert(id: const Value(1), userId: userId),
        );
  }

  AppUser _mapUser(User row) {
    return AppUser(
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      createdAt: row.createdAt,
    );
  }

  void _validateRegistration({
    required String email,
    required String displayName,
    required String password,
    required String confirmPassword,
  }) {
    if (email.trim().isEmpty) {
      throw const AuthValidationException('Email is required.');
    }
    if (!_isValidEmail(email)) {
      throw const AuthValidationException('Enter a valid email address.');
    }
    if (displayName.trim().isEmpty) {
      throw const AuthValidationException('Display name is required.');
    }
    if (password.length < 8) {
      throw const AuthValidationException(
        'Password must be at least 8 characters.',
      );
    }
    if (password != confirmPassword) {
      throw const AuthValidationException('Passwords do not match.');
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  bool _isValidEmail(String email) {
    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return pattern.hasMatch(email.trim());
  }
}
