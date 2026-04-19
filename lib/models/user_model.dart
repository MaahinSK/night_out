class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> favorites;
  final DateTime? createdAt;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.favorites = const [],
    this.createdAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      favorites: List<String>.from(json['favorites'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'favorites': favorites,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
}