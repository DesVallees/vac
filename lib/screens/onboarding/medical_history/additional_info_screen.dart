import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/history.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final String? bloodType;
  final bool? isOrganDonor;
  final ObGynHistory? obGynHistory;
  final Function(String?, bool?, ObGynHistory?) onUpdate;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const AdditionalInfoScreen({
    super.key,
    required this.bloodType,
    required this.isOrganDonor,
    required this.obGynHistory,
    required this.onUpdate,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  String? _selectedBloodType;
  bool? _isOrganDonor;
  ObGynHistory? _obGynHistory;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBloodType = widget.bloodType;
    _isOrganDonor = widget.isOrganDonor;
    _obGynHistory = widget.obGynHistory;
  }

  void _updateData() {
    widget.onUpdate(_selectedBloodType, _isOrganDonor, _obGynHistory);
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
                  Icons.info_outline,
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
                      'Información Adicional',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Últimos detalles para completar tu perfil',
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
                  // Blood Type
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
                          Row(
                            children: [
                              Icon(
                                Icons.bloodtype,
                                color: theme.colorScheme.error,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tipo de Sangre',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _bloodTypes.map((type) {
                              final isSelected = _selectedBloodType == type;
                              return FilterChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedBloodType = selected ? type : null;
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

                  // Organ Donor
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
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_outline,
                                color: theme.colorScheme.error,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Donante de Órganos',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isOrganDonor = true;
                                      _updateData();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _isOrganDonor == true
                                        ? theme.colorScheme.primaryContainer
                                        : null,
                                    foregroundColor: _isOrganDonor == true
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                    side: BorderSide(
                                      color: _isOrganDonor == true
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Sí'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isOrganDonor = false;
                                      _updateData();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _isOrganDonor == false
                                        ? theme.colorScheme.primaryContainer
                                        : null,
                                    foregroundColor: _isOrganDonor == false
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                    side: BorderSide(
                                      color: _isOrganDonor == false
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('No'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ObGyn History (optional, could be conditional based on gender)
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
                          Row(
                            children: [
                              Icon(
                                Icons.female,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Historial Ginecológico (Opcional)',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Esta sección es opcional y solo para personas que necesitan registrar información ginecológica',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _showObGynDialog(context),
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(
                              _obGynHistory != null
                                  ? 'Editar información'
                                  : 'Agregar información',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Finalizar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showObGynDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final ageOfMenarcheController = TextEditingController(
      text: _obGynHistory?.ageOfMenarche?.toString() ?? '',
    );
    final cycleDetailsController = TextEditingController(
      text: _obGynHistory?.cycleDetails ?? '',
    );
    final pregnanciesController = TextEditingController(
      text: _obGynHistory?.numberOfPregnancies?.toString() ?? '',
    );
    final liveBirthsController = TextEditingController(
      text: _obGynHistory?.numberOfLiveBirths?.toString() ?? '',
    );
    final pregnancyNotesController = TextEditingController(
      text: _obGynHistory?.pregnancyHistoryNotes ?? '',
    );
    final gynecologicalConditionsController = TextEditingController(
      text: _obGynHistory?.gynecologicalConditions?.join(', ') ?? '',
    );

    DateTime? lastMenstrualPeriod = _obGynHistory?.lastMenstrualPeriod;
    DateTime? lastPapSmear = _obGynHistory?.lastPapSmearDate;
    DateTime? lastMammogram = _obGynHistory?.lastMammogramDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Historial Ginecológico'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: ageOfMenarcheController,
                    decoration: const InputDecoration(
                      labelText: 'Edad de menarquia',
                      hintText: 'Edad en años',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: lastMenstrualPeriod ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          lastMenstrualPeriod = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Último período menstrual',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        lastMenstrualPeriod != null
                            ? '${lastMenstrualPeriod!.day}/${lastMenstrualPeriod!.month}/${lastMenstrualPeriod!.year}'
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cycleDetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Detalles del ciclo',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: pregnanciesController,
                    decoration: const InputDecoration(
                      labelText: 'Número de embarazos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: liveBirthsController,
                    decoration: const InputDecoration(
                      labelText: 'Número de partos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: pregnancyNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas sobre embarazos',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: gynecologicalConditionsController,
                    decoration: const InputDecoration(
                      labelText: 'Condiciones ginecológicas',
                      hintText: 'Separadas por comas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: lastPapSmear ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          lastPapSmear = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Última citología',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        lastPapSmear != null
                            ? '${lastPapSmear!.day}/${lastPapSmear!.month}/${lastPapSmear!.year}'
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: lastMammogram ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          lastMammogram = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Última mamografía',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        lastMammogram != null
                            ? '${lastMammogram!.day}/${lastMammogram!.month}/${lastMammogram!.year}'
                            : 'Seleccionar fecha',
                      ),
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
                final conditions = gynecologicalConditionsController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                setState(() {
                  _obGynHistory = ObGynHistory(
                    ageOfMenarche: ageOfMenarcheController.text.trim().isEmpty
                        ? null
                        : int.tryParse(ageOfMenarcheController.text.trim()),
                    lastMenstrualPeriod: lastMenstrualPeriod,
                    cycleDetails: cycleDetailsController.text.trim().isEmpty
                        ? null
                        : cycleDetailsController.text.trim(),
                    numberOfPregnancies:
                        pregnanciesController.text.trim().isEmpty
                            ? null
                            : int.tryParse(pregnanciesController.text.trim()),
                    numberOfLiveBirths: liveBirthsController.text.trim().isEmpty
                        ? null
                        : int.tryParse(liveBirthsController.text.trim()),
                    pregnancyHistoryNotes:
                        pregnancyNotesController.text.trim().isEmpty
                            ? null
                            : pregnancyNotesController.text.trim(),
                    gynecologicalConditions:
                        conditions.isEmpty ? null : conditions,
                    lastPapSmearDate: lastPapSmear,
                    lastMammogramDate: lastMammogram,
                  );
                  _updateData();
                });

                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

