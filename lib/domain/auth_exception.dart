sealed class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AuthValidationException extends AuthException {
  const AuthValidationException(super.message);
}

final class AuthCredentialsException extends AuthException {
  const AuthCredentialsException(super.message);
}

final class AuthDuplicateEmailException extends AuthException {
  const AuthDuplicateEmailException()
    : super('An account with this email already exists.');
}
