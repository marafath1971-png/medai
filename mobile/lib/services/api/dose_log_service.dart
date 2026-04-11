import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../models/dose_log.dart';
import '../../models/medication.dart';
import '../api/api_client.dart';

class DoseLogService {
  final ApiClient _apiClient = ApiClient();

  static final DoseLogService _instance = DoseLogService._internal();
  factory DoseLogService() => _instance;

  DoseLogService._internal();

  Future<List<DoseLog>> getDoseLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? medicationId,
    IntakeStatus? status,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (medicationId != null) queryParams['medicationId'] = medicationId;
      if (status != null) queryParams['status'] = status.name;

      final response = await _apiClient.get(
        ApiConstants.doseLogs,
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final List<dynamic> logs = data['data'] ?? [];
        return logs.map((e) => DoseLog.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<DoseLog>> getTodayLogs() async {
    try {
      final response = await _apiClient.get(ApiConstants.todayLogs);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final List<dynamic> logs = data['data'] ?? [];
        return logs.map((e) => DoseLog.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<DoseLog>> getLogHistory({
    int days = 30,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.logHistory,
        queryParameters: {'days': days, 'page': page, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final List<dynamic> logs = data['data'] ?? [];
        return logs.map((e) => DoseLog.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DoseLog> logDose({
    required String medicationId,
    required DateTime scheduledTime,
    required IntakeStatus status,
    String? notes,
    String? symptoms,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.doseLogs,
        data: {
          'medicationId': medicationId,
          'scheduledTime': scheduledTime.toIso8601String(),
          'intakeStatus': status.name,
          'notes': notes,
          'symptoms': symptoms,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return DoseLog.fromJson(data['data']);
      }
      throw ApiException(message: data['message'] ?? 'Failed to log dose');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DoseLog> updateDoseLog(
    String id, {
    IntakeStatus? status,
    String? notes,
    String? symptoms,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.doseLogs}/$id',
        data: {
          if (status != null) 'intakeStatus': status.name,
          'notes': notes,
          'symptoms': symptoms,
        },
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return DoseLog.fromJson(data['data']);
      }
      throw ApiException(
        message: data['message'] ?? 'Failed to update dose log',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteDoseLog(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.doseLogs}/$id');
      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw ApiException(
          message: data['message'] ?? 'Failed to delete dose log',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DoseLog> markAsTaken(String id, {String? notes}) async {
    return updateDoseLog(id, status: IntakeStatus.taken, notes: notes);
  }

  Future<DoseLog> markAsMissed(String id, {String? notes}) async {
    return updateDoseLog(id, status: IntakeStatus.missed, notes: notes);
  }

  Future<DoseLog> snoozeDose(String id, {Duration? duration}) async {
    return updateDoseLog(id, status: IntakeStatus.snoozed);
  }

  Map<DateTime, List<DoseLog>> groupLogsByDate(List<DoseLog> logs) {
    final Map<DateTime, List<DoseLog>> grouped = {};
    for (final log in logs) {
      final date = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(log);
    }
    return grouped;
  }

  Map<String, int> getStatusSummary(List<DoseLog> logs) {
    int taken = 0, missed = 0, snoozed = 0, pending = 0;
    for (final log in logs) {
      switch (log.intakeStatus) {
        case IntakeStatus.taken:
          taken++;
          break;
        case IntakeStatus.missed:
          missed++;
          break;
        case IntakeStatus.snoozed:
          snoozed++;
          break;
        case IntakeStatus.pending:
          pending++;
          break;
      }
    }
    return {
      'taken': taken,
      'missed': missed,
      'snoozed': snoozed,
      'pending': pending,
      'total': logs.length,
    };
  }
}
