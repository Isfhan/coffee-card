class CoffeeCard {
  const CoffeeCard({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final String imagePath;
  final int rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasImage => imagePath.isNotEmpty;
}
