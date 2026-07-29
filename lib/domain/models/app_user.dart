class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  final int id;
  final String email;
  final String displayName;
  final DateTime createdAt;
}
