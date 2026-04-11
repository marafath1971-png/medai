import 'package:equatable/equatable.dart';

enum AuthProvider { email, google, apple }

class User extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool emailVerified;
  final bool twoFactorEnabled;
  final AuthProvider authProvider;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.emailVerified = false,
    this.twoFactorEnabled = false,
    this.authProvider = AuthProvider.email,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => [firstName, lastName].whereType<String>().join(' ');

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  bool get isComplete => firstName != null && lastName != null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      authProvider: AuthProvider.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['authProvider'] as String? ?? 'email').toLowerCase(),
        orElse: () => AuthProvider.email,
      ),
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'emailVerified': emailVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'authProvider': authProvider.name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? emailVerified,
    bool? twoFactorEnabled,
    AuthProvider? authProvider,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      emailVerified: emailVerified ?? this.emailVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      authProvider: authProvider ?? this.authProvider,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phone,
    emailVerified,
    twoFactorEnabled,
    authProvider,
    avatarUrl,
  ];
}
