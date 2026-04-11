import 'package:equatable/equatable.dart';
import 'medication.dart';

class DoseLog extends Equatable {
  final String id;
  final String userId;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final IntakeStatus intakeStatus;
  final String? notes;
  final String? symptoms;
  final Medication? medication;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoseLog({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.intakeStatus = IntakeStatus.pending,
    this.notes,
    this.symptoms,
    this.medication,
    this.createdAt,
    this.updatedAt,
  });

  bool get isTaken => intakeStatus == IntakeStatus.taken;
  bool get isMissed => intakeStatus == IntakeStatus.missed;
  bool get isSnoozed => intakeStatus == IntakeStatus.snoozed;
  bool get isPending => intakeStatus == IntakeStatus.pending;

  bool get isOverdue {
    if (isTaken || isSnoozed) return false;
    return DateTime.now().isAfter(scheduledTime.add(const Duration(hours: 1)));
  }

  Duration? get takenDuration {
    if (takenTime == null) return null;
    return takenTime!.difference(scheduledTime);
  }

  bool get wasTakenOnTime {
    if (takenDuration == null) return false;
    return takenDuration!.inMinutes <= 30;
  }

  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      medicationId: json['medicationId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'] as String)
          : null,
      intakeStatus: IntakeStatus.values.firstWhere(
        (e) => e.name == (json['intakeStatus'] as String? ?? 'pending'),
        orElse: () => IntakeStatus.pending,
      ),
      notes: json['notes'] as String?,
      symptoms: json['symptoms'] as String?,
      medication: json['medication'] != null
          ? Medication.fromJson(json['medication'] as Map<String, dynamic>)
          : null,
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
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'intakeStatus': intakeStatus.name,
      'notes': notes,
      'symptoms': symptoms,
    };
  }

  DoseLog copyWith({
    String? id,
    String? userId,
    String? medicationId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    IntakeStatus? intakeStatus,
    String? notes,
    String? symptoms,
    Medication? medication,
  }) {
    return DoseLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      intakeStatus: intakeStatus ?? this.intakeStatus,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      medication: medication ?? this.medication,
    );
  }

  @override
  List<Object?> get props => [
    id,
    medicationId,
    scheduledTime,
    intakeStatus,
    takenTime,
  ];
}
