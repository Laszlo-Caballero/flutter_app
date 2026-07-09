class User {
  final int userId;
  final String username;
  final String email;
  final String role;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class AuthData {
  final String accessToken;
  final User user;

  AuthData({required this.accessToken, required this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
