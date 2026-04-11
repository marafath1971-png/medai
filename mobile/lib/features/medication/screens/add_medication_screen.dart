import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/medication.dart';
import '../../../services/api/medication_service.dart';

class AddMedicationScreen extends StatefulWidget {
  final String? medicationId;

  const AddMedicationScreen({super.key, this.medicationId});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _pillCountController = TextEditingController();
  final _refillThresholdController = TextEditingController(text: '10');

  String _frequency = 'once_daily';
  DoseForm _form = DoseForm.tablet;
  bool _isLoading = false;

  final Map<String, String> _frequencyOptions = {
    'once_daily': 'Once daily',
    'twice_daily': 'Twice daily',
    'three_times': 'Three times daily',
    'four_times': 'Four times daily',
    'as_needed': 'As needed',
    'weekly': 'Weekly',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _pillCountController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final medication = Medication(
        id: '',
        userId: '',
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequency,
        pillCount: int.tryParse(_pillCountController.text) ?? 0,
        refillThreshold: int.tryParse(_refillThresholdController.text) ?? 10,
        instructions: _instructionsController.text,
        startDate: DateTime.now(),
      );
      await MedicationService().addMedication(medication);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving medication: $e')));
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
      appBar: AppBar(
        title: Text(
          widget.medicationId == null ? 'Add Medication' : 'Edit Medication',
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medication Details',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      hintText: 'e.g., Metformin',
                      prefixIcon: Icon(Icons.medication),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      hintText: 'e.g., 500mg',
                      prefixIcon: Icon(Icons.science),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pillCountController,
                    decoration: const InputDecoration(
                      labelText: 'Pill Count',
                      hintText: 'Number of pills',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: _frequencyOptions.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _frequency = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<DoseForm>(
                    initialValue: _form,
                    decoration: const InputDecoration(
                      labelText: 'Form',
                      prefixIcon: Icon(Icons.medication),
                    ),
                    items: DoseForm.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.name[0].toUpperCase() + e.name.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _form = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Info',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      hintText: 'e.g., Take with food',
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
