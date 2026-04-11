import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../models/medication.dart';
import '../api/api_client.dart';

class MedicationService {
  final ApiClient _apiClient = ApiClient();

  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;

  MedicationService._internal();

  Future<List<Medication>> getMedications() async {
    try {
      final response = await _apiClient.get(ApiConstants.medications);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final List<dynamic> meds = data['data'] ?? [];
        return meds.map((e) => Medication.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Medication> getMedication(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.medications}/$id');
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return Medication.fromJson(data['data']);
      }
      throw ApiException(message: data['message'] ?? 'Medication not found');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Medication> addMedication(Medication medication) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.medications,
        data: medication.toJson(),
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return Medication.fromJson(data['data']);
      }
      throw ApiException(
        message: data['message'] ?? 'Failed to add medication',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Medication> updateMedication(Medication medication) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.medications}/${medication.id}',
        data: medication.toJson(),
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return Medication.fromJson(data['data']);
      }
      throw ApiException(
        message: data['message'] ?? 'Failed to update medication',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.medications}/$id',
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw ApiException(
          message: data['message'] ?? 'Failed to delete medication',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updatePillCount(String id, int count) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.medications}/$id/count',
        data: {'pillCount': count},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PrescriptionScanResult> scanPrescription(File image) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'prescription_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiConstants.scanPrescription,
        formData: formData,
      );
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        return PrescriptionScanResult.fromJson(data['data']);
      }
      throw ApiException(
        message: data['message'] ?? 'Failed to scan prescription',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Medication>> getLowStockMedications() async {
    final meds = await getMedications();
    return meds.where((m) => m.isLowStock).toList();
  }
}

class PrescriptionScanResult {
  final String? name;
  final String? dosage;
  final String? frequency;
  final String? instructions;
  final double? confidence;
  final String? rawText;

  PrescriptionScanResult({
    this.name,
    this.dosage,
    this.frequency,
    this.instructions,
    this.confidence,
    this.rawText,
  });

  factory PrescriptionScanResult.fromJson(Map<String, dynamic> json) {
    return PrescriptionScanResult(
      name: json['name'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      instructions: json['instructions'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      rawText: json['rawText'] as String?,
    );
  }
}
