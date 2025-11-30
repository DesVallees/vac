import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaq/assets/data_classes/user.dart';
import 'package:vaq/assets/data_classes/child.dart';
import 'package:vaq/services/user_data.dart';
import 'package:vaq/screens/profile/child_management_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingChildren = false;
  List<Child> _children = [];

  // Controllers for text fields
  late TextEditingController _displayNameController;
  late TextEditingController _phoneNumberController;
  // Add controllers for other fields if needed (e.g., bio for Pediatrician)
  // late TextEditingController _bioController;

  User? _currentUser; // To store the initial user data

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newUser = context.watch<User?>();
    if (newUser != null && newUser != _currentUser) {
      _currentUser = newUser;
      _displayNameController.text = newUser.displayName ?? '';
      _phoneNumberController.text = newUser.phoneNumber ?? '';

      // Load children if user is NormalUser
      if (newUser is NormalUser) {
        _loadChildren();
      }
    }
  }

  Future<void> _loadChildren() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoadingChildren = true;
    });

    try {
      final userDataService = context.read<UserDataService>();
      final children = await userDataService.loadChildren(_currentUser!.id);

      if (mounted) {
        setState(() {
          _children = children;
          _isLoadingChildren = false;
        });
      }
    } catch (e) {
      print('Error loading children: $e');
      if (mounted) {
        setState(() {
          _isLoadingChildren = false;
        });
      }
    }
  }

  Future<void> _showAddChildDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    DateTime? selectedDate;
    Gender? selectedGender;

    final result = await showDialog<Child>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar hijo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Ej: María José',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 18)),
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
                        labelText: 'Fecha de nacimiento',
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
                  DropdownButtonFormField<Gender>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Género (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: Gender.male, child: Text('Masculino')),
                      DropdownMenuItem(
                          value: Gender.female, child: Text('Femenino')),
                      DropdownMenuItem(
                          value: Gender.other, child: Text('Otro')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedGender = value;
                      });
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
                if (formKey.currentState!.validate() && selectedDate != null) {
                  final child = Child(
                    id: '',
                    parentId: _currentUser!.id,
                    name: nameController.text.trim(),
                    dateOfBirth: selectedDate!,
                    gender: selectedGender,
                    createdAt: DateTime.now(),
                  );
                  Navigator.pop(context, child);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        final userDataService = context.read<UserDataService>();
        await userDataService.saveChild(result);

        // Reload children list
        await _loadChildren();

        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Hijo agregado con éxito',
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
          );
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Error al agregar hijo: $e',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError,
          );
        }
      }
    }
  }

  Future<void> _deleteChild(Child child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hijo'),
        content: Text(
            '¿Estás seguro de que deseas eliminar a ${child.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final userDataService = context.read<UserDataService>();
        await userDataService.deleteChild(child.id, _currentUser!.id);

        await _loadChildren();

        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Hijo eliminado',
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
          );
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Error al eliminar: $e',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError,
          );
        }
      }
    }
  }

  String _genderToString(Gender? gender) {
    if (gender == null) return '';
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
  void dispose() {
    // Dispose controllers when the widget is removed
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    // _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final theme = Theme.of(context);

    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if validation fails
    }

    if (_currentUser == null) {
      Fluttertoast.showToast(
          msg: 'Error: No se pudo obtener la información del usuario.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Prepare the data map with only the fields that changed or need updating
    // Always include fields you allow editing.
    Map<String, dynamic> updatedData = {
      'displayName': _displayNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      // Add other fields as needed
      // if (_currentUser is Pediatrician) 'bio': _bioController.text.trim(),
    };

    try {
      // Get the UserDataService instance
      final userDataService = context.read<UserDataService>();
      await userDataService.updateUserData(_currentUser!.id, updatedData);

      // Show success message
      Fluttertoast.showToast(
        msg: 'Perfil actualizado con éxito',
        backgroundColor: theme.colorScheme.primary,
        textColor: theme.colorScheme.onPrimary,
      );

      // Navigate back to the profile screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving profile: $e');
      Fluttertoast.showToast(
        msg: 'Error al actualizar el perfil: ${e.toString()}',
        backgroundColor: theme.colorScheme.error,
        textColor: theme.colorScheme.onError,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      // Ensure isLoading is set to false even if errors occur
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUser = _currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          // Save button in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3)))
                : IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: _saveProfile,
                    tooltip: 'Guardar Cambios',
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Avatar (Non-editable for now) ---
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                backgroundImage: (currentUser.photoUrl != null &&
                        currentUser.photoUrl!.isNotEmpty)
                    ? NetworkImage(currentUser.photoUrl!)
                    : const AssetImage('lib/assets/images/default_avatar.png')
                        as ImageProvider,
                // TODO: Add button/icon overlay to change photo later
              ),
              // TextButton(onPressed: () { /* TODO: Implement image picker */ }, child: Text('Cambiar Foto')),
              const SizedBox(height: 30),

              // --- Display Name Field ---
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Tu nombre y apellido',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Phone Number Field ---
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Número de Teléfono',
                  hintText: 'Ej: 3001234567',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                // Optional: Add validation for phone number format
                // validator: (value) { ... }
              ),
              const SizedBox(height: 20),

              // Children Management Section (only for NormalUser)
              if (_currentUser is NormalUser) ...[
                const Divider(height: 40),
                Row(
                  children: [
                    Icon(
                      Icons.child_care_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mis Hijos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _showAddChildDialog,
                      tooltip: 'Agregar hijo',
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoadingChildren)
                  const Center(child: CircularProgressIndicator())
                else if (_children.isEmpty)
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.child_care_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No has agregado ningún hijo',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar uno',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...(_children.map((child) => Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Icon(
                              Icons.child_care,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          title: Text(
                            child.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${child.ageString}${child.gender != null ? ' • ${_genderToString(child.gender)}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final result = await Navigator.push<Child>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChildManagementScreen(
                                        child: child,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    await _loadChildren();
                                  }
                                },
                                tooltip: 'Editar información',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteChild(child),
                                tooltip: 'Eliminar',
                                color: theme.colorScheme.error,
                              ),
                            ],
                          ),
                          isThreeLine: false,
                          onTap: () async {
                            final result = await Navigator.push<Child>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildManagementScreen(
                                  child: child,
                                ),
                              ),
                            );
                            if (result != null) {
                              await _loadChildren();
                            }
                          },
                        ),
                      ))),
                const SizedBox(height: 20),
                const Divider(height: 40),
              ],

              // Example for Pediatrician Bio
              // if (_currentUser is Pediatrician) ...[
              //   TextFormField(
              //     controller: _bioController,
              //     decoration: InputDecoration(
              //       labelText: 'Biografía Corta',
              //       hintText: 'Describe tu experiencia y enfoque',
              //       prefixIcon: const Icon(Icons.description_outlined),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     maxLines: 3,
              //     // Optional: Add validation
              //   ),
              //   const SizedBox(height: 20),
              // ],

              // --- Save Button (Alternative placement at bottom) ---
              // Consider removing if using AppBar action
              /*
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: theme.onPrimary,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Guardando...' : 'Guardar Cambios'),
                  onPressed: _isLoading ? null : _saveProfile, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              */
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
