class Note {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final int? categoryId;
  final String? categoryName;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.categoryId,
    this.categoryName,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      categoryId: json['category_id'],
      categoryName:
          json['categories'] != null ? json['categories']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'category_id': categoryId,
    };
  }
}
