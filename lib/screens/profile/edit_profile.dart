import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaq/assets/data_classes/user.dart';
import 'package:vaq/services/user_data.dart'; // Import your service
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
