import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaq/assets/data_classes/child.dart';
import 'package:vaq/assets/data_classes/history.dart';
import 'package:vaq/assets/helpers/history.dart';

class ChildManagementScreen extends StatefulWidget {
  final Child child;

  const ChildManagementScreen({
    super.key,
    required this.child,
  });

  @override
  State<ChildManagementScreen> createState() => _ChildManagementScreenState();
}

class _ChildManagementScreenState extends State<ChildManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MedicalHistory? _medicalHistory;
  bool _isLoading = true;
  bool _isEditingBasicInfo = false;

  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.child.name;
    _selectedDate = widget.child.dateOfBirth;
    _selectedGender = widget.child.gender;
    _loadMedicalHistory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final doc = await _firestore
          .collection('medical_history')
          .doc(widget.child.id)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _medicalHistory = MedicalHistory.fromJson(doc.data()!, doc.id);
          _isLoading = false;
        });
      } else {
        setState(() {
          _medicalHistory = MedicalHistory(patientProfileId: widget.child.id);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading medical history: $e');
      setState(() {
        _medicalHistory = MedicalHistory(patientProfileId: widget.child.id);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBasicInfo() async {
    try {
      final updatedChild = widget.child.copyWith(
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDate ?? widget.child.dateOfBirth,
        gender: _selectedGender ?? widget.child.gender,
      );

      await _firestore
          .collection('children')
          .doc(widget.child.id)
          .update(updatedChild.toFirestore());

      setState(() {
        _isEditingBasicInfo = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información actualizada')),
        );
      }

      // Refresh parent screen if needed
      if (mounted) {
        Navigator.pop(context, updatedChild);
      }
    } catch (e) {
      print('Error saving child info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _saveMedicalHistory() async {
    try {
      if (_medicalHistory != null) {
        await _firestore
            .collection('medical_history')
            .doc(widget.child.id)
            .set(_medicalHistory!.toJson());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial médico guardado')),
          );
        }
      }
    } catch (e) {
      print('Error saving medical history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.child.dateOfBirth,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _genderToString(Gender? gender) {
    if (gender == null) return 'No especificado';
    switch (gender) {
      case Gender.male:
        return 'Masculino';
      case Gender.female:
        return 'Femenino';
      case Gender.other:
        return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = widget.child;

    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          if (_isEditingBasicInfo)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveBasicInfo,
              tooltip: 'Guardar',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditingBasicInfo = true;
                });
              },
              tooltip: 'Editar información básica',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.child_care,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Información Básica',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isEditingBasicInfo) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre completo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha de nacimiento',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : 'Seleccionar fecha',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Gender>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Género',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: Gender.male,
                                  child: Text('Masculino'),
                                ),
                                DropdownMenuItem(
                                  value: Gender.female,
                                  child: Text('Femenino'),
                                ),
                                DropdownMenuItem(
                                  value: Gender.other,
                                  child: Text('Otro'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ] else ...[
                            _buildInfoRow(
                              'Nombre',
                              child.name,
                              Icons.person_outline,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Fecha de nacimiento',
                              '${child.dateOfBirth.day}/${child.dateOfBirth.month}/${child.dateOfBirth.year}',
                              Icons.calendar_today_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Edad',
                              child.ageString,
                              Icons.cake_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Género',
                              _genderToString(child.gender),
                              Icons.transgender_outlined,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Allergies Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: theme.colorScheme.tertiary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Alergias',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _showAllergyDialog(),
                                tooltip: 'Agregar alergia',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_medicalHistory?.allergies.isEmpty ?? true)
                            Text(
                              'No hay alergias registradas',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          else
                            ...(_medicalHistory!.allergies.map((allergy) {
                              return ListTile(
                                leading: Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.tertiary,
                                ),
                                title: Text(allergy.substance),
                                subtitle: Text(
                                  'Reacción: ${allergy.reactionDescription}\nSeveridad: ${allergy.severity.toSpanish()}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeAllergy(allergy.id),
                                ),
                                isThreeLine: true,
                              );
                            })),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vaccines Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.vaccines_outlined,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Vacunas',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _showVaccineDialog(),
                                tooltip: 'Agregar vacuna',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_medicalHistory?.immunizationHistory.isEmpty ??
                              true)
                            Text(
                              'No hay vacunas registradas',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          else
                            ...(_medicalHistory!.immunizationHistory.map(
                                (vaccine) {
                              return ListTile(
                                leading: Icon(
                                  Icons.vaccines_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(vaccine.vaccineName),
                                subtitle: Text(
                                  'Fecha: ${formatDateTime(vaccine.dateAdministered)}\n${vaccine.doseNumber != null ? 'Dosis: ${vaccine.doseNumber}\n' : ''}Lugar: ${vaccine.administeringProviderOrLocation ?? 'N/A'}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeVaccine(vaccine.id),
                                ),
                                isThreeLine: true,
                              );
                            })),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showAllergyDialog() {
    final formKey = GlobalKey<FormState>();
    final substanceController = TextEditingController();
    final reactionController = TextEditingController();
    AllergyType selectedType = AllergyType.other;
    Severity selectedSeverity = Severity.mild;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Alergia'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: substanceController,
                    decoration: const InputDecoration(
                      labelText: 'Sustancia',
                      hintText: 'Ej: Penicilina, Maní',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reactionController,
                    decoration: const InputDecoration(
                      labelText: 'Reacción',
                      hintText: 'Ej: Urticaria, Dificultad para respirar',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AllergyType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: AllergyType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toSpanish()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Severity>(
                    value: selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severidad',
                      border: OutlineInputBorder(),
                    ),
                    items: Severity.values.map((severity) {
                      return DropdownMenuItem(
                        value: severity,
                        child: Text(severity.toSpanish()),
                      );
                    }).toList(),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final allergy = Allergy(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    substance: substanceController.text.trim(),
                    reactionDescription: reactionController.text.trim(),
                    type: selectedType,
                    severity: selectedSeverity,
                  );

                  setState(() {
                    if (_medicalHistory == null) {
                      _medicalHistory = MedicalHistory(
                        patientProfileId: widget.child.id,
                        allergies: [allergy],
                      );
                    } else {
                      _medicalHistory = _medicalHistory!.copyWith(
                        allergies: [..._medicalHistory!.allergies, allergy],
                      );
                    }
                  });

                  _saveMedicalHistory();
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeAllergy(String allergyId) {
    setState(() {
      if (_medicalHistory != null) {
        _medicalHistory = _medicalHistory!.copyWith(
          allergies: _medicalHistory!.allergies
              .where((a) => a.id != allergyId)
              .toList(),
        );
      }
    });
    _saveMedicalHistory();
  }

  void _showVaccineDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final reactionController = TextEditingController();
    DateTime? selectedDate;
    int? doseNumber;
    String? lotNumber;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Vacuna'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la vacuna',
                      hintText: 'Ej: DPT, MMR, Hepatitis B',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: widget.child.dateOfBirth,
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
                        labelText: 'Fecha de administración',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lugar/Proveedor',
                      hintText: 'Ej: Clínica XYZ, Dr. Pérez',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de dosis (opcional)',
                      hintText: 'Ej: 1, 2, 3',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        doseNumber = int.tryParse(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Número de lote (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      lotNumber = value.isEmpty ? null : value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reactionController,
                    decoration: const InputDecoration(
                      labelText: 'Reacción (opcional)',
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedDate != null) {
                  final vaccine = ImmunizationRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    vaccineName: nameController.text.trim(),
                    dateAdministered: selectedDate!,
                    administeringProviderOrLocation:
                        locationController.text.trim().isEmpty
                            ? null
                            : locationController.text.trim(),
                    doseNumber: doseNumber,
                    lotNumber: lotNumber,
                    reactionNotes: reactionController.text.trim().isEmpty
                        ? null
                        : reactionController.text.trim(),
                  );

                  setState(() {
                    if (_medicalHistory == null) {
                      _medicalHistory = MedicalHistory(
                        patientProfileId: widget.child.id,
                        immunizationHistory: [vaccine],
                      );
                    } else {
                      _medicalHistory = _medicalHistory!.copyWith(
                        immunizationHistory: [
                          ..._medicalHistory!.immunizationHistory,
                          vaccine
                        ],
                      );
                    }
                  });

                  _saveMedicalHistory();
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeVaccine(String vaccineId) {
    setState(() {
      if (_medicalHistory != null) {
        _medicalHistory = _medicalHistory!.copyWith(
          immunizationHistory: _medicalHistory!.immunizationHistory
              .where((v) => v.id != vaccineId)
              .toList(),
        );
      }
    });
    _saveMedicalHistory();
  }
}

