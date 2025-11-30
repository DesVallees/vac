import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/history.dart';

class MedicalConditionsScreen extends StatefulWidget {
  final List<MedicalCondition> pastMedicalHistory;
  final List<MedicalCondition> chronicConditions;
  final List<MedicalCondition> mentalHealthConditions;
  final Function(
    List<MedicalCondition>,
    List<MedicalCondition>,
    List<MedicalCondition>,
  ) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MedicalConditionsScreen({
    super.key,
    required this.pastMedicalHistory,
    required this.chronicConditions,
    required this.mentalHealthConditions,
    required this.onUpdate,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<MedicalConditionsScreen> createState() =>
      _MedicalConditionsScreenState();
}

class _MedicalConditionsScreenState extends State<MedicalConditionsScreen> {
  late List<MedicalCondition> _pastMedicalHistory;
  late List<MedicalCondition> _chronicConditions;
  late List<MedicalCondition> _mentalHealthConditions;
  int _selectedTab = 0; // 0: Past, 1: Chronic, 2: Mental Health

  @override
  void initState() {
    super.initState();
    _pastMedicalHistory = List.from(widget.pastMedicalHistory);
    _chronicConditions = List.from(widget.chronicConditions);
    _mentalHealthConditions = List.from(widget.mentalHealthConditions);
  }

  void _updateData() {
    widget.onUpdate(
      _pastMedicalHistory,
      _chronicConditions,
      _mentalHealthConditions,
    );
  }

  List<MedicalCondition> _getCurrentList() {
    switch (_selectedTab) {
      case 0:
        return _pastMedicalHistory;
      case 1:
        return _chronicConditions;
      case 2:
        return _mentalHealthConditions;
      default:
        return _pastMedicalHistory;
    }
  }

  void _addToCurrentList(MedicalCondition condition) {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _pastMedicalHistory.add(condition);
          break;
        case 1:
          _chronicConditions.add(condition);
          break;
        case 2:
          _mentalHealthConditions.add(condition);
          break;
      }
    });
    _updateData();
  }

  void _removeFromCurrentList(int index) {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _pastMedicalHistory.removeAt(index);
          break;
        case 1:
          _chronicConditions.removeAt(index);
          break;
        case 2:
          _mentalHealthConditions.removeAt(index);
          break;
      }
    });
    _updateData();
  }

  void _updateInCurrentList(int index, MedicalCondition condition) {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _pastMedicalHistory[index] = condition;
          break;
        case 1:
          _chronicConditions[index] = condition;
          break;
        case 2:
          _mentalHealthConditions[index] = condition;
          break;
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
                  Icons.medical_services_outlined,
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
                      'Condiciones Médicas',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra tus condiciones médicas',
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

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab(theme, 0, 'Pasadas', Icons.history),
                ),
                Expanded(
                  child: _buildTab(theme, 1, 'Crónicas', Icons.schedule),
                ),
                Expanded(
                  child: _buildTab(
                      theme, 2, 'Salud Mental', Icons.psychology_outlined),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Add condition button
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showAddConditionDialog(context),
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
                        'Agregar condición',
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

          // Conditions list
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
                          'No hay condiciones registradas',
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
                      final condition = currentList[index];
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
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medical_information,
                              color: theme.colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            condition.conditionName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (condition.dateOfDiagnosis != null)
                                Text(
                                  'Diagnosticada: ${_formatDate(condition.dateOfDiagnosis!)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  _getStatusText(condition.status),
                                  style: theme.textTheme.labelSmall,
                                ),
                                backgroundColor:
                                    _getStatusColor(condition.status, theme),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              if (condition.notes != null &&
                                  condition.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  condition.notes!,
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
                                    _showEditConditionDialog(context, index),
                                iconSize: 20,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeFromCurrentList(index),
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

  Widget _buildTab(ThemeData theme, int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(ConditionStatus status) {
    switch (status) {
      case ConditionStatus.active:
        return 'Activa';
      case ConditionStatus.controlled:
        return 'Controlada';
      case ConditionStatus.inRemission:
        return 'En remisión';
      case ConditionStatus.resolved:
        return 'Resuelta';
      case ConditionStatus.unknown:
        return 'Desconocida';
    }
  }

  Color _getStatusColor(ConditionStatus status, ThemeData theme) {
    switch (status) {
      case ConditionStatus.active:
        return theme.colorScheme.errorContainer;
      case ConditionStatus.controlled:
        return theme.colorScheme.tertiaryContainer;
      case ConditionStatus.inRemission:
        return theme.colorScheme.secondaryContainer;
      case ConditionStatus.resolved:
        return theme.colorScheme.primaryContainer;
      case ConditionStatus.unknown:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  void _showAddConditionDialog(BuildContext context) {
    _showConditionDialog(context, null);
  }

  void _showEditConditionDialog(BuildContext context, int index) {
    _showConditionDialog(context, index);
  }

  void _showConditionDialog(BuildContext context, int? index) {
    final formKey = GlobalKey<FormState>();
    final currentList = _getCurrentList();
    final condition = index != null ? currentList[index] : null;

    final nameController = TextEditingController(
      text: condition?.conditionName ?? '',
    );
    final notesController = TextEditingController(
      text: condition?.notes ?? '',
    );
    DateTime? selectedDate = condition?.dateOfDiagnosis;
    ConditionStatus selectedStatus =
        condition?.status ?? ConditionStatus.unknown;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              index == null ? 'Agregar condición' : 'Editar condición'),
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
                      labelText: 'Nombre de la condición *',
                      hintText: 'Ej: Diabetes tipo 2',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre de la condición';
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
                        labelText: 'Fecha de diagnóstico',
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
                  DropdownButtonFormField<ConditionStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ConditionStatus.active,
                        child: Text('Activa'),
                      ),
                      DropdownMenuItem(
                        value: ConditionStatus.controlled,
                        child: Text('Controlada'),
                      ),
                      DropdownMenuItem(
                        value: ConditionStatus.inRemission,
                        child: Text('En remisión'),
                      ),
                      DropdownMenuItem(
                        value: ConditionStatus.resolved,
                        child: Text('Resuelta'),
                      ),
                      DropdownMenuItem(
                        value: ConditionStatus.unknown,
                        child: Text('Desconocida'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas adicionales',
                      hintText: 'Información adicional',
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
                  final newCondition = MedicalCondition(
                    id: condition?.id,
                    conditionName: nameController.text.trim(),
                    dateOfDiagnosis: selectedDate,
                    status: selectedStatus,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  if (index == null) {
                    _addToCurrentList(newCondition);
                  } else {
                    _updateInCurrentList(index, newCondition);
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

