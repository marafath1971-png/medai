import 'package:equatable/equatable.dart';

enum ProfileType { self, dependent, caregiver }

class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String name;
  final ProfileType profileType;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? medicalConditions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.profileType = ProfileType.dependent,
    this.dateOfBirth,
    this.gender,
    this.medicalConditions,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      profileType: ProfileType.values.firstWhere(
        (e) => e.name == (json['profileType'] as String? ?? 'dependent'),
        orElse: () => ProfileType.dependent,
      ),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      medicalConditions: json['medicalConditions'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
      'userId': userId,
      'name': name,
      'profileType': profileType.name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'medicalConditions': medicalConditions,
      'isActive': isActive,
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    ProfileType? profileType,
    DateTime? dateOfBirth,
    String? gender,
    String? medicalConditions,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileType: profileType ?? this.profileType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, profileType, isActive];
}
