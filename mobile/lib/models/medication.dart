import 'package:equatable/equatable.dart';

enum DoseForm { tablet, capsule, liquid, injection, topical, inhaler, other }

enum IntakeStatus { pending, taken, missed, snoozed }

class Medication extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? genericName;
  final String dosage;
  final DoseForm form;
  final String frequency;
  final int pillCount;
  final int refillThreshold;
  final String? instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Medication({
    required this.id,
    required this.userId,
    required this.name,
    this.genericName,
    required this.dosage,
    this.form = DoseForm.tablet,
    required this.frequency,
    this.pillCount = 0,
    this.refillThreshold = 7,
    this.instructions,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLowStock => pillCount <= refillThreshold;

  int get daysRemaining {
    final freq = frequency.toLowerCase();
    if (freq.contains('once') || freq.contains('1')) {
      return pillCount;
    } else if (freq.contains('twice') || freq.contains('2')) {
      return pillCount ~/ 2;
    } else if (freq.contains('three') || freq.contains('3')) {
      return pillCount ~/ 3;
    } else if (freq.contains('four') || freq.contains('4')) {
      return pillCount ~/ 4;
    }
    return pillCount;
  }

  String get formDisplayName {
    switch (form) {
      case DoseForm.tablet:
        return 'Tablet';
      case DoseForm.capsule:
        return 'Capsule';
      case DoseForm.liquid:
        return 'Liquid';
      case DoseForm.injection:
        return 'Injection';
      case DoseForm.topical:
        return 'Topical';
      case DoseForm.inhaler:
        return 'Inhaler';
      case DoseForm.other:
        return 'Other';
    }
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String?,
      dosage: json['dosage'] as String,
      form: DoseForm.values.firstWhere(
        (e) => e.name == (json['form'] as String? ?? 'tablet'),
        orElse: () => DoseForm.tablet,
      ),
      frequency: json['frequency'] as String,
      pillCount: json['pillCount'] as int? ?? 0,
      refillThreshold: json['refillThreshold'] as int? ?? 7,
      instructions: json['instructions'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
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
      'genericName': genericName,
      'dosage': dosage,
      'form': form.name,
      'frequency': frequency,
      'pillCount': pillCount,
      'refillThreshold': refillThreshold,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? genericName,
    String? dosage,
    DoseForm? form,
    String? frequency,
    int? pillCount,
    int? refillThreshold,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      pillCount: pillCount ?? this.pillCount,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    form,
    frequency,
    pillCount,
    isActive,
  ];
}
