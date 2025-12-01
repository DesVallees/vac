import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final theme = Theme.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if new password and confirmation match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: 'Las contraseñas nuevas no coinciden.',
        backgroundColor: theme.colorScheme.error,
        textColor: theme.colorScheme.onError,
      );
      return;
    }

    // Check if new password is different from current
    if (_currentPasswordController.text == _newPasswordController.text) {
      Fluttertoast.showToast(
        msg: 'La nueva contraseña debe ser diferente a la actual.',
        backgroundColor: theme.colorScheme.tertiary,
        textColor: theme.colorScheme.onTertiary,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado.');
      }

      // If user signed in with email/password, we need to re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      // Re-authenticate user
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Contraseña actualizada exitosamente',
          backgroundColor: theme.colorScheme.secondary,
          textColor: theme.colorScheme.onSecondary,
          toastLength: Toast.LENGTH_SHORT,
        );

        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password') {
        message = 'La contraseña actual es incorrecta.';
      } else if (e.code == 'weak-password') {
        message = 'La nueva contraseña es muy débil. Debe tener al menos 6 caracteres.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Por seguridad, inicia sesión nuevamente antes de cambiar tu contraseña.';
      } else {
        message = 'Error al cambiar la contraseña: ${e.message ?? 'Error desconocido'}';
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Ocurrió un error. Por favor, inténtalo de nuevo.',
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
        );
      }
      print('Error changing password: $e');
    } finally {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cambiar Contraseña',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Para cambiar tu contraseña, ingresa tu contraseña actual y luego la nueva contraseña que deseas usar.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Current Password Field
                Text(
                  'Contraseña Actual',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu contraseña actual',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // New Password Field
                Text(
                  'Nueva Contraseña',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Mínimo 6 caracteres',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una nueva contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Confirm Password Field
                Text(
                  'Confirmar Nueva Contraseña',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirma tu nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu nueva contraseña';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Security Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Por seguridad, necesitamos verificar tu contraseña actual antes de cambiarla.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Cambiando contraseña...'),
                            ],
                          )
                        : const Text('Cambiar Contraseña'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

