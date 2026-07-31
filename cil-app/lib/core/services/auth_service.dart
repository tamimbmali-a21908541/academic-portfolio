import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// User Model
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final bool isMember;
  final String? membershipType;
  final DateTime? memberSince;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.isMember = false,
    this.membershipType,
    this.memberSince,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photoUrl: json['photoUrl'],
      isMember: json['isMember'] ?? false,
      membershipType: json['membershipType'],
      memberSince: json['memberSince'] != null
          ? DateTime.tryParse(json['memberSince'])
          : null,
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'isMember': isMember,
      'membershipType': membershipType,
      'memberSince': memberSince?.toIso8601String(),
      'roles': roles,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    bool? isMember,
    String? membershipType,
    DateTime? memberSince,
    List<String>? roles,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      isMember: isMember ?? this.isMember,
      membershipType: membershipType ?? this.membershipType,
      memberSince: memberSince ?? this.memberSince,
      roles: roles ?? this.roles,
    );
  }
}

/// Auth Service
class AuthService {
  static const String _tokenKey = AppConstants.userTokenKey;

  /// Get current user (if logged in)
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null) return null;

    // In production, validate token with backend
    // For now, return a mock user if token exists
    return User(
      id: '1',
      name: 'Utilizador CIL',
      email: 'utilizador@cil.org.pt',
      isMember: true,
      membershipType: 'Associado',
      memberSince: DateTime(2020, 1, 1),
    );
  }

  /// Login with email and password
  Future<User?> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In production, make actual API call
    // For demo, accept any valid-looking credentials
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'demo_token_${DateTime.now().millisecondsSinceEpoch}');

      return User(
        id: '1',
        name: email.split('@').first,
        email: email,
        isMember: true,
        membershipType: 'Associado',
        memberSince: DateTime.now(),
      );
    }

    throw Exception('Credenciais inválidas');
  }

  /// Register new user
  Future<User?> register(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In production, make actual API call
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'demo_token_${DateTime.now().millisecondsSinceEpoch}');

      return User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        isMember: false,
      );
    }

    throw Exception('Dados de registo inválidos');
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // In production, send password reset email
    return email.isNotEmpty && email.contains('@');
  }

  /// Update user profile
  Future<User?> updateProfile(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    // In production, make actual API call
    return user;
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In production, check with backend
    return false;
  }

  /// Become a member
  Future<bool> becomeMember(Map<String, dynamic> membershipData) async {
    await Future.delayed(const Duration(seconds: 1));
    // In production, process membership application
    return true;
  }
}
