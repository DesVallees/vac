import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/history.dart';

class MedicationsScreen extends StatefulWidget {
  final List<Medication> currentMedications;
  final List<Medication> pastMedications;
  final Function(List<Medication>, List<Medication>) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MedicationsScreen({
    super.key,
    required this.currentMedications,
    required this.pastMedications,
    required this.onUpdate,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late List<Medication> _currentMedications;
  late List<Medication> _pastMedications;
  bool _showCurrent = true;

  @override
  void initState() {
    super.initState();
    _currentMedications = List.from(widget.currentMedications);
    _pastMedications = List.from(widget.pastMedications);
  }

  void _updateData() {
    widget.onUpdate(_currentMedications, _pastMedications);
  }

  List<Medication> _getCurrentList() {
    return _showCurrent ? _currentMedications : _pastMedications;
  }

  void _addMedication(Medication medication) {
    setState(() {
      if (medication.isCurrent) {
        _currentMedications.add(medication);
      } else {
        _pastMedications.add(medication);
      }
    });
    _updateData();
  }

  void _removeMedication(int index) {
    setState(() {
      if (_showCurrent) {
        _currentMedications.removeAt(index);
      } else {
        _pastMedications.removeAt(index);
      }
    });
    _updateData();
  }

  void _updateMedication(int index, Medication medication) {
    setState(() {
      // If status changed, move between lists
      if (_showCurrent && !medication.isCurrent) {
        _currentMedications.removeAt(index);
        _pastMedications.add(medication);
      } else if (!_showCurrent && medication.isCurrent) {
        _pastMedications.removeAt(index);
        _currentMedications.add(medication);
      } else {
        if (_showCurrent) {
          _currentMedications[index] = medication;
        } else {
          _pastMedications[index] = medication;
        }
      }
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentList = _getCurrentList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicamentos',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra tus medicamentos actuales y pasados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Toggle buttons
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    theme,
                    true,
                    'Actuales',
                    Icons.check_circle_outline,
                    _currentMedications.length,
                  ),
                ),
                Expanded(
                  child: _buildToggleButton(
                    theme,
                    false,
                    'Pasados',
                    Icons.history,
                    _pastMedications.length,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Add medication button
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showAddMedicationDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Agregar medicamento',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Medications list
          Expanded(
            child: currentList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay medicamentos registrados',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final medication = currentList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getMedicationIcon(medication.type),
                              color: theme.colorScheme.onTertiaryContainer,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            medication.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (medication.dosage != null)
                                Text(
                                  'Dosis: ${medication.dosage}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              if (medication.frequency != null)
                                Text(
                                  'Frecuencia: ${medication.frequency}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Razón: ${medication.reasonForTaking}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  _getMedicationTypeText(medication.type),
                                  style: theme.textTheme.labelSmall,
                                ),
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () =>
                                    _showEditMedicationDialog(context, index),
                                iconSize: 20,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeMedication(index),
                                iconSize: 20,
                                color: theme.colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    ThemeData theme,
    bool isCurrent,
    String label,
    IconData icon,
    int count,
  ) {
    final isSelected = _showCurrent == isCurrent;
    return InkWell(
      onTap: () {
        setState(() {
          _showCurrent = isCurrent;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMedicationIcon(MedicationType type) {
    switch (type) {
      case MedicationType.prescription:
        return Icons.medication;
      case MedicationType.overTheCounter:
        return Icons.local_pharmacy;
      case MedicationType.supplement:
        return Icons.science;
      case MedicationType.vitamin:
        return Icons.sanitizer;
    }
  }

  String _getMedicationTypeText(MedicationType type) {
    switch (type) {
      case MedicationType.prescription:
        return 'Receta';
      case MedicationType.overTheCounter:
        return 'Sin receta';
      case MedicationType.supplement:
        return 'Suplemento';
      case MedicationType.vitamin:
        return 'Vitamina';
    }
  }

  void _showAddMedicationDialog(BuildContext context) {
    _showMedicationDialog(context, null);
  }

  void _showEditMedicationDialog(BuildContext context, int index) {
    _showMedicationDialog(context, index);
  }

  void _showMedicationDialog(BuildContext context, int? index) {
    final formKey = GlobalKey<FormState>();
    final currentList = _getCurrentList();
    final medication = index != null ? currentList[index] : null;

    final nameController = TextEditingController(
      text: medication?.name ?? '',
    );
    final dosageController = TextEditingController(
      text: medication?.dosage ?? '',
    );
    final frequencyController = TextEditingController(
      text: medication?.frequency ?? '',
    );
    final routeController = TextEditingController(
      text: medication?.route ?? '',
    );
    final reasonController = TextEditingController(
      text: medication?.reasonForTaking ?? '',
    );
    final doctorController = TextEditingController(
      text: medication?.prescribingDoctor ?? '',
    );

    MedicationType selectedType =
        medication?.type ?? MedicationType.prescription;
    DateTime? startDate = medication?.startDate;
    DateTime? endDate = medication?.endDate;
    bool isCurrent = medication?.isCurrent ?? _showCurrent;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              index == null ? 'Agregar medicamento' : 'Editar medicamento'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del medicamento *',
                      hintText: 'Ej: Paracetamol',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre del medicamento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MedicationType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: MedicationType.prescription,
                        child: Text('Receta médica'),
                      ),
                      DropdownMenuItem(
                        value: MedicationType.overTheCounter,
                        child: Text('Sin receta'),
                      ),
                      DropdownMenuItem(
                        value: MedicationType.supplement,
                        child: Text('Suplemento'),
                      ),
                      DropdownMenuItem(
                        value: MedicationType.vitamin,
                        child: Text('Vitamina'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosis',
                      hintText: 'Ej: 500mg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: frequencyController,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia',
                      hintText: 'Ej: Cada 8 horas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: routeController,
                    decoration: const InputDecoration(
                      labelText: 'Vía de administración',
                      hintText: 'Ej: Oral, Tópico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Razón para tomar *',
                      hintText: 'Ej: Dolor de cabeza',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa la razón';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          startDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de inicio',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        startDate != null
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Medicamento actual'),
                    value: isCurrent,
                    onChanged: (value) {
                      setDialogState(() {
                        isCurrent = value ?? false;
                        if (isCurrent) {
                          endDate = null;
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!isCurrent) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            endDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de finalización',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          endDate != null
                              ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                              : 'Seleccionar fecha',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: doctorController,
                    decoration: const InputDecoration(
                      labelText: 'Médico que lo recetó',
                      hintText: 'Nombre del médico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newMedication = Medication(
                    id: medication?.id,
                    name: nameController.text.trim(),
                    dosage: dosageController.text.trim().isEmpty
                        ? null
                        : dosageController.text.trim(),
                    frequency: frequencyController.text.trim().isEmpty
                        ? null
                        : frequencyController.text.trim(),
                    route: routeController.text.trim().isEmpty
                        ? null
                        : routeController.text.trim(),
                    reasonForTaking: reasonController.text.trim(),
                    type: selectedType,
                    startDate: startDate,
                    endDate: isCurrent ? null : endDate,
                    prescribingDoctor: doctorController.text.trim().isEmpty
                        ? null
                        : doctorController.text.trim(),
                  );

                  if (index == null) {
                    _addMedication(newMedication);
                  } else {
                    _updateMedication(index, newMedication);
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(index == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

