class Book {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  final String content;
  final String genre;
  final bool isFavorite;
  final double progress;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.content,
    required this.genre,
    this.isFavorite = false,
    this.progress = 0.0,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      coverUrl: json['cover_url'] ?? '',
      content: json['content'] ?? '',
      genre: json['genre'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'content': content,
      'genre': genre,
      'is_favorite': isFavorite,
      'progress': progress,
    };
  }

  Book copyWith({bool? isFavorite, double? progress}) {
    return Book(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      content: content,
      genre: genre,
      isFavorite: isFavorite ?? this.isFavorite,
      progress: progress ?? this.progress,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }
}
