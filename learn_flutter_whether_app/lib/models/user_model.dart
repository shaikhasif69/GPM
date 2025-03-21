class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> favoriteDays;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.favoriteDays = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> favDays = [];
    if (json['favoriteDays'] != null) {
      favDays = List<String>.from(
        (json['favoriteDays'] ?? []).map((item) => item?.toString() ?? '')
      );
    }
    
    return User(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      favoriteDays: favDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'favoriteDays': favoriteDays,
    };
  }
}