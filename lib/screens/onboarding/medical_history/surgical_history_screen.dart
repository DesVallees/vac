import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/history.dart';

class SurgicalHistoryScreen extends StatefulWidget {
  final List<Surgery> surgicalHistory;
  final List<Hospitalization> hospitalizations;
  final Function(List<Surgery>, List<Hospitalization>) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const SurgicalHistoryScreen({
    super.key,
    required this.surgicalHistory,
    required this.hospitalizations,
    required this.onUpdate,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<SurgicalHistoryScreen> createState() => _SurgicalHistoryScreenState();
}

class _SurgicalHistoryScreenState extends State<SurgicalHistoryScreen> {
  late List<Surgery> _surgicalHistory;
  late List<Hospitalization> _hospitalizations;
  bool _showSurgeries = true;

  @override
  void initState() {
    super.initState();
    _surgicalHistory = List.from(widget.surgicalHistory);
    _hospitalizations = List.from(widget.hospitalizations);
  }

  void _updateData() {
    widget.onUpdate(_surgicalHistory, _hospitalizations);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Icons.healing_outlined,
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
                      'Cirugías y Hospitalizaciones',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra tu historial quirúrgico',
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
                    'Cirugías',
                    Icons.healing,
                    _surgicalHistory.length,
                  ),
                ),
                Expanded(
                  child: _buildToggleButton(
                    theme,
                    false,
                    'Hospitalizaciones',
                    Icons.local_hospital,
                    _hospitalizations.length,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Add button
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showAddDialog(context),
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
                        _showSurgeries
                            ? 'Agregar cirugía'
                            : 'Agregar hospitalización',
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

          // List
          Expanded(
            child: _showSurgeries
                ? _buildSurgeriesList(theme)
                : _buildHospitalizationsList(theme),
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
    bool isSurgery,
    String label,
    IconData icon,
    int count,
  ) {
    final isSelected = _showSurgeries == isSurgery;
    return InkWell(
      onTap: () {
        setState(() {
          _showSurgeries = isSurgery;
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

  Widget _buildSurgeriesList(ThemeData theme) {
    if (_surgicalHistory.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.healing_outlined,
        'No hay cirugías registradas',
      );
    }

    return ListView.builder(
      itemCount: _surgicalHistory.length,
      itemBuilder: (context, index) {
        final surgery = _surgicalHistory[index];
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
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.healing,
                color: theme.colorScheme.onErrorContainer,
                size: 24,
              ),
            ),
            title: Text(
              surgery.procedureName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (surgery.dateOfSurgery != null)
                  Text(
                    'Fecha: ${_formatDate(surgery.dateOfSurgery!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (surgery.hospitalOrClinic != null)
                  Text(
                    'Hospital: ${surgery.hospitalOrClinic}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (surgery.notes != null && surgery.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    surgery.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditSurgeryDialog(context, index),
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _surgicalHistory.removeAt(index);
                      _updateData();
                    });
                  },
                  iconSize: 20,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHospitalizationsList(ThemeData theme) {
    if (_hospitalizations.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.local_hospital_outlined,
        'No hay hospitalizaciones registradas',
      );
    }

    return ListView.builder(
      itemCount: _hospitalizations.length,
      itemBuilder: (context, index) {
        final hospitalization = _hospitalizations[index];
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
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_hospital,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            title: Text(
              hospitalization.reasonForAdmission,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (hospitalization.admissionDate != null)
                  Text(
                    'Ingreso: ${_formatDate(hospitalization.admissionDate!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (hospitalization.dischargeDate != null)
                  Text(
                    'Alta: ${_formatDate(hospitalization.dischargeDate!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (hospitalization.hospitalName != null)
                  Text(
                    'Hospital: ${hospitalization.hospitalName}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (hospitalization.notes != null &&
                    hospitalization.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    hospitalization.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      _showEditHospitalizationDialog(context, index),
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _hospitalizations.removeAt(index);
                      _updateData();
                    });
                  },
                  iconSize: 20,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddDialog(BuildContext context) {
    if (_showSurgeries) {
      _showSurgeryDialog(context, null);
    } else {
      _showHospitalizationDialog(context, null);
    }
  }

  void _showEditSurgeryDialog(BuildContext context, int index) {
    _showSurgeryDialog(context, index);
  }

  void _showSurgeryDialog(BuildContext context, int? index) {
    final formKey = GlobalKey<FormState>();
    final surgery = index != null ? _surgicalHistory[index] : null;

    final procedureController = TextEditingController(
      text: surgery?.procedureName ?? '',
    );
    final hospitalController = TextEditingController(
      text: surgery?.hospitalOrClinic ?? '',
    );
    final surgeonController = TextEditingController(
      text: surgery?.surgeonName ?? '',
    );
    final notesController = TextEditingController(
      text: surgery?.notes ?? '',
    );
    DateTime? selectedDate = surgery?.dateOfSurgery;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'Agregar cirugía' : 'Editar cirugía'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: procedureController,
                    decoration: const InputDecoration(
                      labelText: 'Procedimiento *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el procedimiento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de cirugía',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        selectedDate != null
                            ? _formatDate(selectedDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital o clínica',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: surgeonController,
                    decoration: const InputDecoration(
                      labelText: 'Cirujano',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                  final newSurgery = Surgery(
                    id: surgery?.id,
                    procedureName: procedureController.text.trim(),
                    dateOfSurgery: selectedDate,
                    hospitalOrClinic: hospitalController.text.trim().isEmpty
                        ? null
                        : hospitalController.text.trim(),
                    surgeonName: surgeonController.text.trim().isEmpty
                        ? null
                        : surgeonController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  setState(() {
                    if (index == null) {
                      _surgicalHistory.add(newSurgery);
                    } else {
                      _surgicalHistory[index] = newSurgery;
                    }
                    _updateData();
                  });

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

  void _showEditHospitalizationDialog(BuildContext context, int index) {
    _showHospitalizationDialog(context, index);
  }

  void _showHospitalizationDialog(BuildContext context, int? index) {
    final formKey = GlobalKey<FormState>();
    final hospitalization =
        index != null ? _hospitalizations[index] : null;

    final reasonController = TextEditingController(
      text: hospitalization?.reasonForAdmission ?? '',
    );
    final hospitalController = TextEditingController(
      text: hospitalization?.hospitalName ?? '',
    );
    final notesController = TextEditingController(
      text: hospitalization?.notes ?? '',
    );
    DateTime? admissionDate = hospitalization?.admissionDate;
    DateTime? dischargeDate = hospitalization?.dischargeDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null
              ? 'Agregar hospitalización'
              : 'Editar hospitalización'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Razón de admisión *',
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
                        initialDate: admissionDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          admissionDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de ingreso',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        admissionDate != null
                            ? _formatDate(admissionDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dischargeDate ??
                            admissionDate ??
                            DateTime.now(),
                        firstDate: admissionDate ?? DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          dischargeDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de alta',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dischargeDate != null
                            ? _formatDate(dischargeDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                  final newHospitalization = Hospitalization(
                    id: hospitalization?.id,
                    reasonForAdmission: reasonController.text.trim(),
                    admissionDate: admissionDate,
                    dischargeDate: dischargeDate,
                    hospitalName: hospitalController.text.trim().isEmpty
                        ? null
                        : hospitalController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  setState(() {
                    if (index == null) {
                      _hospitalizations.add(newHospitalization);
                    } else {
                      _hospitalizations[index] = newHospitalization;
                    }
                    _updateData();
                  });

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

