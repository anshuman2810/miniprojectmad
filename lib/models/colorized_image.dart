class ColorizedImage {
  final int? id;
  final String originalPath;
  final String colorizedPath;
  final DateTime createdAt;

  ColorizedImage({
    this.id,
    required this.originalPath,
    required this.colorizedPath,
    required this.createdAt,
  });

  factory ColorizedImage.fromMap(Map<String, dynamic> map) {
    return ColorizedImage(
      id: map['id'],
      originalPath: map['originalPath'],
      colorizedPath: map['colorizedPath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalPath': originalPath,
      'colorizedPath': colorizedPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}