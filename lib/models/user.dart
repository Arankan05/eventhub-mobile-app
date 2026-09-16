enum UserRole { user, organizer }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      role: json['role'] == 'organizer' ? UserRole.organizer : UserRole.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role == UserRole.organizer ? 'organizer' : 'user',
    };
  }
}
