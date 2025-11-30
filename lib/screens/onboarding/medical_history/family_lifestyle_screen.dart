import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/history.dart';

class FamilyLifestyleScreen extends StatefulWidget {
  final List<FamilyMemberHistory> familyHistory;
  final TobaccoStatus tobaccoUse;
  final String? alcoholUseDetails;
  final String? recreationalDrugUseDetails;
  final String? occupation;
  final String? exerciseHabits;
  final String? dietSummary;
  final Function(
    List<FamilyMemberHistory>,
    TobaccoStatus,
    String?,
    String?,
    String?,
    String?,
    String?,
  ) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const FamilyLifestyleScreen({
    super.key,
    required this.familyHistory,
    required this.tobaccoUse,
    required this.alcoholUseDetails,
    required this.recreationalDrugUseDetails,
    required this.occupation,
    required this.exerciseHabits,
    required this.dietSummary,
    required this.onUpdate,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<FamilyLifestyleScreen> createState() => _FamilyLifestyleScreenState();
}

class _FamilyLifestyleScreenState extends State<FamilyLifestyleScreen> {
  late List<FamilyMemberHistory> _familyHistory;
  late TobaccoStatus _tobaccoUse;
  late TextEditingController _alcoholController;
  late TextEditingController _drugsController;
  late TextEditingController _occupationController;
  late TextEditingController _exerciseController;
  late TextEditingController _dietController;

  @override
  void initState() {
    super.initState();
    _familyHistory = List.from(widget.familyHistory);
    _tobaccoUse = widget.tobaccoUse;
    _alcoholController = TextEditingController(
      text: widget.alcoholUseDetails ?? '',
    );
    _drugsController = TextEditingController(
      text: widget.recreationalDrugUseDetails ?? '',
    );
    _occupationController = TextEditingController(
      text: widget.occupation ?? '',
    );
    _exerciseController = TextEditingController(
      text: widget.exerciseHabits ?? '',
    );
    _dietController = TextEditingController(
      text: widget.dietSummary ?? '',
    );
  }

  @override
  void dispose() {
    _alcoholController.dispose();
    _drugsController.dispose();
    _occupationController.dispose();
    _exerciseController.dispose();
    _dietController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onUpdate(
      _familyHistory,
      _tobaccoUse,
      _alcoholController.text.trim().isEmpty
          ? null
          : _alcoholController.text.trim(),
      _drugsController.text.trim().isEmpty
          ? null
          : _drugsController.text.trim(),
      _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      _exerciseController.text.trim().isEmpty
          ? null
          : _exerciseController.text.trim(),
      _dietController.text.trim().isEmpty ? null : _dietController.text.trim(),
    );
  }

  void _addFamilyHistory(FamilyMemberHistory history) {
    setState(() {
      _familyHistory.add(history);
      _updateData();
    });
  }

  void _removeFamilyHistory(int index) {
    setState(() {
      _familyHistory.removeAt(index);
      _updateData();
    });
  }

  void _updateFamilyHistory(int index, FamilyMemberHistory history) {
    setState(() {
      _familyHistory[index] = history;
      _updateData();
    });
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
                  Icons.family_restroom,
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
                      'Historial Familiar y Estilo de Vida',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Información importante para tu salud',
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

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Family History Section
                  Text(
                    'Historial Familiar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => _showAddFamilyHistoryDialog(context),
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
                                'Agregar historial familiar',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_familyHistory.isNotEmpty)
                    ..._familyHistory.asMap().entries.map((entry) {
                      final index = entry.key;
                      final history = entry.value;
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
                              Icons.people,
                              color: theme.colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            _getRelationshipText(history.relationship),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                history.condition,
                                style: theme.textTheme.bodyMedium,
                              ),
                              if (history.ageOfOnset != null)
                                Text(
                                  'Edad de inicio: ${history.ageOfOnset} años',
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeFamilyHistory(index),
                            iconSize: 20,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 32),

                  // Lifestyle Section
                  Text(
                    'Estilo de Vida',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tobacco
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uso de tabaco',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: TobaccoStatus.values.map((status) {
                              final isSelected = _tobaccoUse == status;
                              return FilterChip(
                                label: Text(_getTobaccoStatusText(status)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _tobaccoUse = status;
                                    _updateData();
                                  });
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Alcohol
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consumo de alcohol',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _alcoholController,
                            decoration: const InputDecoration(
                              hintText: 'Describe tu consumo de alcohol',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            onChanged: (_) => _updateData(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Drugs
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uso de drogas recreativas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _drugsController,
                            decoration: const InputDecoration(
                              hintText: 'Describe tu uso de drogas recreativas',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            onChanged: (_) => _updateData(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Occupation
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ocupación',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _occupationController,
                            decoration: const InputDecoration(
                              hintText: 'Tu ocupación o trabajo',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _updateData(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Exercise
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hábitos de ejercicio',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _exerciseController,
                            decoration: const InputDecoration(
                              hintText: 'Describe tus hábitos de ejercicio',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (_) => _updateData(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Diet
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dieta',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _dietController,
                            decoration: const InputDecoration(
                              hintText: 'Describe tu dieta o alimentación',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (_) => _updateData(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

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

  String _getRelationshipText(Relationship relationship) {
    switch (relationship) {
      case Relationship.mother:
        return 'Madre';
      case Relationship.father:
        return 'Padre';
      case Relationship.sibling:
        return 'Hermano/a';
      case Relationship.child:
        return 'Hijo/a';
      case Relationship.grandparent:
        return 'Abuelo/a';
      case Relationship.aunt:
        return 'Tía';
      case Relationship.uncle:
        return 'Tío';
      case Relationship.other:
        return 'Otro';
      case Relationship.unknown:
        return 'Desconocido';
    }
  }

  String _getTobaccoStatusText(TobaccoStatus status) {
    switch (status) {
      case TobaccoStatus.currentSmoker:
        return 'Fumador actual';
      case TobaccoStatus.formerSmoker:
        return 'Ex fumador';
      case TobaccoStatus.neverSmoked:
        return 'Nunca fumó';
      case TobaccoStatus.unknown:
        return 'No especificado';
    }
  }

  void _showAddFamilyHistoryDialog(BuildContext context) {
    _showFamilyHistoryDialog(context, null);
  }

  void _showEditFamilyHistoryDialog(BuildContext context, int index) {
    _showFamilyHistoryDialog(context, index);
  }

  void _showFamilyHistoryDialog(BuildContext context, int? index) {
    final formKey = GlobalKey<FormState>();
    final history = index != null ? _familyHistory[index] : null;

    final conditionController = TextEditingController(
      text: history?.condition ?? '',
    );
    final notesController = TextEditingController(
      text: history?.notes ?? '',
    );
    final ageOfOnsetController = TextEditingController(
      text: history?.ageOfOnset?.toString() ?? '',
    );
    final ageAtDeathController = TextEditingController(
      text: history?.ageAtDeath?.toString() ?? '',
    );

    Relationship selectedRelationship =
        history?.relationship ?? Relationship.unknown;
    bool isDeceased = history?.isDeceased ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null
              ? 'Agregar historial familiar'
              : 'Editar historial familiar'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Relationship>(
                    value: selectedRelationship,
                    decoration: const InputDecoration(
                      labelText: 'Parentesco *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Relationship.mother,
                        child: Text('Madre'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.father,
                        child: Text('Padre'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.sibling,
                        child: Text('Hermano/a'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.child,
                        child: Text('Hijo/a'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.grandparent,
                        child: Text('Abuelo/a'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.aunt,
                        child: Text('Tía'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.uncle,
                        child: Text('Tío'),
                      ),
                      DropdownMenuItem(
                        value: Relationship.other,
                        child: Text('Otro'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRelationship = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: conditionController,
                    decoration: const InputDecoration(
                      labelText: 'Condición médica *',
                      hintText: 'Ej: Diabetes, Hipertensión',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa la condición';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ageOfOnsetController,
                    decoration: const InputDecoration(
                      labelText: 'Edad de inicio',
                      hintText: 'Edad en años',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Fallecido'),
                    value: isDeceased,
                    onChanged: (value) {
                      setDialogState(() {
                        isDeceased = value ?? false;
                        if (!isDeceased) {
                          ageAtDeathController.clear();
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (isDeceased) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ageAtDeathController,
                      decoration: const InputDecoration(
                        labelText: 'Edad al fallecer',
                        hintText: 'Edad en años',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas adicionales',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                  final newHistory = FamilyMemberHistory(
                    id: history?.id,
                    relationship: selectedRelationship,
                    condition: conditionController.text.trim(),
                    ageOfOnset: ageOfOnsetController.text.trim().isEmpty
                        ? null
                        : int.tryParse(ageOfOnsetController.text.trim()),
                    isDeceased: isDeceased,
                    ageAtDeath: isDeceased &&
                            ageAtDeathController.text.trim().isNotEmpty
                        ? int.tryParse(ageAtDeathController.text.trim())
                        : null,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  if (index == null) {
                    _addFamilyHistory(newHistory);
                  } else {
                    _updateFamilyHistory(index, newHistory);
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

