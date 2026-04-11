import 'package:equatable/equatable.dart';

class AdherenceStats extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final double adherenceScore;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int snoozedDoses;
  final int streakCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdherenceStats({
    required this.id,
    required this.userId,
    required this.date,
    required this.adherenceScore,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.snoozedDoses,
    required this.streakCount,
    this.createdAt,
    this.updatedAt,
  });

  double get percentage => totalDoses > 0 ? takenDoses / totalDoses : 0;

  bool get isPerfectDay => takenDoses == totalDoses;

  factory AdherenceStats.fromJson(Map<String, dynamic> json) {
    return AdherenceStats(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      adherenceScore: (json['adherenceScore'] as num).toDouble(),
      totalDoses: json['totalDoses'] as int,
      takenDoses: json['takenDoses'] as int,
      missedDoses: json['missedDoses'] as int,
      snoozedDoses: json['snoozedDoses'] as int,
      streakCount: json['streakCount'] as int,
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
      'date': date.toIso8601String(),
      'adherenceScore': adherenceScore,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
      'snoozedDoses': snoozedDoses,
      'streakCount': streakCount,
    };
  }

  @override
  List<Object?> get props => [id, userId, date, adherenceScore, streakCount];
}

class BodyImpact extends Equatable {
  final double score;
  final String summary;
  final List<String> factors;
  final DateTime? calculatedAt;

  const BodyImpact({
    required this.score,
    required this.summary,
    required this.factors,
    this.calculatedAt,
  });

  factory BodyImpact.fromJson(Map<String, dynamic> json) {
    return BodyImpact(
      score: (json['score'] as num).toDouble(),
      summary: json['summary'] as String,
      factors: (json['factors'] as List<dynamic>).cast<String>(),
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [score, summary, factors];
}

class AICoachInsights extends Equatable {
  final String title;
  final String message;
  final List<CoachRecommendation> recommendations;
  final DateTime? calculatedAt;

  const AICoachInsights({
    required this.title,
    required this.message,
    required this.recommendations,
    this.calculatedAt,
  });

  factory AICoachInsights.fromJson(Map<String, dynamic> json) {
    return AICoachInsights(
      title: json['title'] as String,
      message: json['message'] as String,
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map(
                (e) => CoachRecommendation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [title, message, recommendations];
}

class CoachRecommendation extends Equatable {
  final String title;
  final String description;
  final String priority;
  final String? actionType;

  const CoachRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    this.actionType,
  });

  factory CoachRecommendation.fromJson(Map<String, dynamic> json) {
    return CoachRecommendation(
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      actionType: json['actionType'] as String?,
    );
  }

  @override
  List<Object?> get props => [title, priority];
}
