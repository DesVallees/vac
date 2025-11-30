import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/history.dart';

class AllergiesScreen extends StatefulWidget {
  final List<Allergy> allergies;
  final Function(List<Allergy>) onUpdate;
  final VoidCallback onNext;

  const AllergiesScreen({
    super.key,
    required this.allergies,
    required this.onUpdate,
    required this.onNext,
  });

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  late List<Allergy> _allergies;

  @override
  void initState() {
    super.initState();
    _allergies = List.from(widget.allergies);
  }

  void _addAllergy(Allergy allergy) {
    setState(() {
      _allergies.add(allergy);
    });
    widget.onUpdate(_allergies);
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
    widget.onUpdate(_allergies);
  }

  void _updateAllergy(int index, Allergy allergy) {
    setState(() {
      _allergies[index] = allergy;
    });
    widget.onUpdate(_allergies);
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
                  Icons.warning_amber_rounded,
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
                      'Alergias',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Información importante para tu seguridad médica',
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

          // Add allergy button
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showAddAllergyDialog(context),
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
                        'Agregar alergia',
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

          // Allergies list
          Expanded(
            child: _allergies.isEmpty
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
                          'No tienes alergias registradas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Puedes agregarlas o continuar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _allergies.length,
                    itemBuilder: (context, index) {
                      final allergy = _allergies[index];
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
                              Icons.warning_rounded,
                              color: theme.colorScheme.onErrorContainer,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            allergy.substance,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _getAllergyTypeText(allergy.type),
                                style: theme.textTheme.bodySmall,
                              ),
                              if (allergy.reactionDescription.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  allergy.reactionDescription,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  _getSeverityText(allergy.severity),
                                  style: theme.textTheme.labelSmall,
                                ),
                                backgroundColor: _getSeverityColor(
                                    allergy.severity, theme),
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
                                    _showEditAllergyDialog(context, index),
                                iconSize: 20,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeAllergy(index),
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

          // Next button
          SizedBox(
            width: double.infinity,
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
    );
  }

  String _getAllergyTypeText(AllergyType type) {
    switch (type) {
      case AllergyType.medication:
        return 'Medicamento';
      case AllergyType.food:
        return 'Alimento';
      case AllergyType.environmental:
        return 'Ambiental';
      case AllergyType.other:
        return 'Otro';
    }
  }

  String _getSeverityText(Severity severity) {
    switch (severity) {
      case Severity.mild:
        return 'Leve';
      case Severity.moderate:
        return 'Moderada';
      case Severity.severe:
        return 'Severa';
      case Severity.unknown:
        return 'Desconocida';
    }
  }

  Color _getSeverityColor(Severity severity, ThemeData theme) {
    switch (severity) {
      case Severity.mild:
        return theme.colorScheme.secondaryContainer;
      case Severity.moderate:
        return theme.colorScheme.tertiaryContainer;
      case Severity.severe:
        return theme.colorScheme.errorContainer;
      case Severity.unknown:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  void _showAddAllergyDialog(BuildContext context) {
    _showAllergyDialog(context, null);
  }

  void _showEditAllergyDialog(BuildContext context, int index) {
    _showAllergyDialog(context, index);
  }

  void _showAllergyDialog(BuildContext context, int? index) {
    final formKey = GlobalKey<FormState>();
    final substanceController = TextEditingController(
      text: index != null ? _allergies[index].substance : '',
    );
    final reactionController = TextEditingController(
      text: index != null ? _allergies[index].reactionDescription : '',
    );
    AllergyType selectedType =
        index != null ? _allergies[index].type : AllergyType.other;
    Severity selectedSeverity =
        index != null ? _allergies[index].severity : Severity.unknown;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'Agregar alergia' : 'Editar alergia'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: substanceController,
                    decoration: const InputDecoration(
                      labelText: 'Sustancia *',
                      hintText: 'Ej: Penicilina, Maní, Polen',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre de la sustancia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AllergyType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de alergia',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AllergyType.medication,
                        child: Text('Medicamento'),
                      ),
                      DropdownMenuItem(
                        value: AllergyType.food,
                        child: Text('Alimento'),
                      ),
                      DropdownMenuItem(
                        value: AllergyType.environmental,
                        child: Text('Ambiental'),
                      ),
                      DropdownMenuItem(
                        value: AllergyType.other,
                        child: Text('Otro'),
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
                    controller: reactionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción de la reacción',
                      hintText: 'Describe cómo reaccionas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Severity>(
                    value: selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severidad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Severity.mild,
                        child: Text('Leve'),
                      ),
                      DropdownMenuItem(
                        value: Severity.moderate,
                        child: Text('Moderada'),
                      ),
                      DropdownMenuItem(
                        value: Severity.severe,
                        child: Text('Severa'),
                      ),
                      DropdownMenuItem(
                        value: Severity.unknown,
                        child: Text('Desconocida'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedSeverity = value;
                        });
                      }
                    },
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
                  final allergy = Allergy(
                    id: index != null ? _allergies[index].id : null,
                    substance: substanceController.text.trim(),
                    reactionDescription: reactionController.text.trim(),
                    type: selectedType,
                    severity: selectedSeverity,
                  );

                  if (index == null) {
                    _addAllergy(allergy);
                  } else {
                    _updateAllergy(index, allergy);
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

