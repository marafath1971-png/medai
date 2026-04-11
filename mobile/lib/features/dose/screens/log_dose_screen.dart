import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/medication.dart';

import '../../../services/api/medication_service.dart';
import '../../../services/api/dose_log_service.dart';

class LogDoseScreen extends StatefulWidget {
  final String? medicationId;

  const LogDoseScreen({super.key, this.medicationId});

  @override
  State<LogDoseScreen> createState() => _LogDoseScreenState();
}

class _LogDoseScreenState extends State<LogDoseScreen> {
  List<Medication> _medications = [];
  Medication? _selectedMedication;
  bool _isLoading = false;
  String _status = 'taken';

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    try {
      final meds = await MedicationService().getMedications();
      setState(() {
        _medications = meds.where((m) => m.isActive).toList();
        if (widget.medicationId != null) {
          _selectedMedication = _medications.firstWhere(
            (m) => m.id == widget.medicationId,
            orElse: () => _medications.first,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logDose() async {
    if (_selectedMedication == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final intakeStatus = _status == 'taken'
          ? IntakeStatus.taken
          : _status == 'missed'
          ? IntakeStatus.missed
          : IntakeStatus.snoozed;

      await DoseLogService().logDose(
        medicationId: _selectedMedication!.id,
        scheduledTime: now,
        status: intakeStatus,
      );

      if (_selectedMedication!.pillCount > 0) {
        await MedicationService().updatePillCount(
          _selectedMedication!.id,
          _selectedMedication!.pillCount - 1,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _status == 'taken'
                  ? 'Dose logged successfully'
                  : _status == 'snoozed'
                  ? 'Dose snoozed'
                  : 'Dose marked as missed',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging dose: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Dose')),
      body: _isLoading && _medications.isEmpty
          ? const LoadingWidget(message: 'Loading medications...')
          : _medications.isEmpty
          ? EmptyStateWidget(
              icon: Icons.medication,
              title: 'No medications yet',
              subtitle: 'Add a medication to start logging doses',
              action: ElevatedButton.icon(
                onPressed: () => context.push('/medication/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Medication'),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Medication',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        ..._medications.map((med) => _buildMedicationTile(med)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusOption(
                          'taken',
                          'Taken',
                          Icons.check_circle,
                          AppColors.success,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusOption(
                          'snoozed',
                          'Snooze',
                          Icons.snooze,
                          AppColors.snoozed,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusOption(
                          'missed',
                          'Missed',
                          Icons.cancel,
                          AppColors.missed,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedMedication == null || _isLoading
                        ? null
                        : _logDose,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Log Dose'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMedicationTile(Medication med) {
    final isSelected = _selectedMedication?.id == med.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.medication_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(med.name),
        subtitle: Text('${med.dosage} - ${med.pillCount} pills left'),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: () => setState(() => _selectedMedication = med),
      ),
    );
  }

  Widget _buildStatusOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _status == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _status = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? color.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? color : AppColors.mutedForeground),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? color : AppColors.mutedForeground,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
