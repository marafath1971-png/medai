import 'package:hive_flutter/hive_flutter.dart';
import '../../models/medication.dart';
import '../../models/dose_log.dart';

class OfflineStorage {
  static const String medicationBox = 'medications';
  static const String doseLogBox = 'doseLogs';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(DoseLogAdapter());

    await Hive.openBox<Medication>(medicationBox);
    await Hive.openBox<DoseLog>(doseLogBox);
    await Hive.openBox(settingsBox);
  }

  static Box<Medication> get medicationBoxInstance =>
      Hive.box<Medication>(medicationBox);

  static Box<DoseLog> get doseLogBoxInstance => Hive.box<DoseLog>(doseLogBox);

  static Box get settingsBoxInstance => Hive.box(settingsBox);

  static Future<void> saveMedications(List<Medication> medications) async {
    final box = medicationBoxInstance;
    await box.clear();
    for (var med in medications) {
      await box.put(med.id, med);
    }
  }

  static List<Medication> getMedications() {
    return medicationBoxInstance.values.toList();
  }

  static Future<void> addMedication(Medication medication) async {
    await medicationBoxInstance.put(medication.id, medication);
  }

  static Future<void> updateMedication(Medication medication) async {
    await medicationBoxInstance.put(medication.id, medication);
  }

  static Future<void> deleteMedication(String id) async {
    await medicationBoxInstance.delete(id);
  }

  static Future<void> saveDoseLogs(List<DoseLog> logs) async {
    final box = doseLogBoxInstance;
    await box.clear();
    for (var log in logs) {
      await box.put(log.id, log);
    }
  }

  static List<DoseLog> getDoseLogs() {
    return doseLogBoxInstance.values.toList();
  }

  static Future<void> addDoseLog(DoseLog log) async {
    await doseLogBoxInstance.put(log.id, log);
  }

  static Future<void> updateDoseLog(DoseLog log) async {
    await doseLogBoxInstance.put(log.id, log);
  }

  static Future<void> deleteDoseLog(String id) async {
    await doseLogBoxInstance.delete(id);
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBoxInstance.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBoxInstance.get(key, defaultValue: defaultValue);
  }

  static bool get isOfflineMode =>
      getSetting('offline_mode', defaultValue: false) as bool;

  static Future<void> setOfflineMode(bool value) async {
    await saveSetting('offline_mode', value);
  }

  static DateTime? get lastSyncTime {
    final timestamp = getSetting('last_sync');
    if (timestamp != null) {
      return DateTime.parse(timestamp as String);
    }
    return null;
  }

  static Future<void> updateLastSync() async {
    await saveSetting('last_sync', DateTime.now().toIso8601String());
  }

  static Future<void> clearAll() async {
    await medicationBoxInstance.clear();
    await doseLogBoxInstance.clear();
    await settingsBoxInstance.clear();
  }
}

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 0;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      genericName: fields[3] as String?,
      dosage: fields[4] as String,
      form: DoseForm.values[fields[5] as int],
      frequency: fields[6] as String,
      pillCount: fields[7] as int,
      refillThreshold: fields[8] as int,
      instructions: fields[9] as String?,
      startDate: DateTime.parse(fields[10] as String),
      endDate: fields[11] != null ? DateTime.parse(fields[11] as String) : null,
      isActive: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.genericName)
      ..writeByte(4)
      ..write(obj.dosage)
      ..writeByte(5)
      ..write(obj.form.index)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.pillCount)
      ..writeByte(8)
      ..write(obj.refillThreshold)
      ..writeByte(9)
      ..write(obj.instructions)
      ..writeByte(10)
      ..write(obj.startDate.toIso8601String())
      ..writeByte(11)
      ..write(obj.endDate?.toIso8601String())
      ..writeByte(12)
      ..write(obj.isActive);
  }
}

class DoseLogAdapter extends TypeAdapter<DoseLog> {
  @override
  final int typeId = 1;

  @override
  DoseLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseLog(
      id: fields[0] as String,
      userId: fields[1] as String,
      medicationId: fields[2] as String,
      scheduledTime: DateTime.parse(fields[3] as String),
      takenTime: fields[4] != null ? DateTime.parse(fields[4] as String) : null,
      intakeStatus: IntakeStatus.values[fields[5] as int],
      notes: fields[6] as String?,
      symptoms: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DoseLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.medicationId)
      ..writeByte(3)
      ..write(obj.scheduledTime.toIso8601String())
      ..writeByte(4)
      ..write(obj.takenTime?.toIso8601String())
      ..writeByte(5)
      ..write(obj.intakeStatus.index)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.symptoms);
  }
}
