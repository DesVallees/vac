import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vaq/assets/data_classes/user.dart'
    as user_classes; // Import User classes

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // --- Signup Logic ---
  Future<void> _signupUser() async {
    final theme = Theme.of(context);
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(
          msg: 'Las contraseñas no coinciden.',
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError);
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });
    bool signupFullySuccessful = false; // Flag to track full success

    try {
      // 1. Create user with Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // 2. Create user document in Firestore
      if (user != null) {
        final newUser = user_classes.NormalUser(
          // Create a NormalUser by default
          id: user.uid,
          email: user.email!,
          displayName: _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : null, // Use display name if provided
          createdAt: DateTime.now(),
          isAdmin: false, // New users are not admins
        );

        try {
          await _firestore
              .collection('users')
              .doc(user.uid) // Use Auth UID as Firestore document ID
              .set(newUser.toFirestore()); // Use the method from the User class

          print('Firestore user document created successfully!');
          signupFullySuccessful = true; // Mark full success

          // Check if widget is still mounted
          if (mounted) {
            Navigator.pop(context); // Dismiss the signup screen
          }

          // Success! AuthWrapper will handle navigation.
        } catch (firestoreError) {
          print('Error creating Firestore user document: $firestoreError');
          Fluttertoast.showToast(
              msg: 'Error al guardar datos de usuario. Intenta iniciar sesión.',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: theme.colorScheme.error);
        }
      } else {
        throw Exception(
            'Usuario de Firebase no encontrado después de la creación.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ya existe una cuenta con ese correo.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo no es válido.';
      } else {
        message = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
        print('Signup Error Code: ${e.code}');
        print('Signup Error Message: ${e.message}');
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          fontSize: 16.0);
    } catch (e) {
      print('Generic Signup Error: $e');
      Fluttertoast.showToast(
          msg: 'Ocurrió un error. Por favor, inténtalo de nuevo.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          fontSize: 16.0);
    } finally {
      // Only stop loading if the process wasn't fully successful OR if still mounted
      // If fully successful, the pop might happen before this runs.
      if (!signupFullySuccessful && mounted) {
        setState(() {
          _isLoading = false;
        });
      } else if (mounted && _isLoading) {
        // If somehow still loading after success/pop, ensure it stops
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset('lib/assets/images/logo.png', height: 80),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Crea tu Cuenta',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Completa los datos para registrarte',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 40),

                  // Display Name Field (Optional)
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre Completo (Opcional)',
                      hintText: 'Tu Nombre',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      hintText: 'tu@correo.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu correo.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Ingresa un correo válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Mínimo 6 caracteres',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una contraseña.';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      hintText: 'Repite la contraseña',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirma tu contraseña.';
                      }
                      // The actual match check happens in _signupUser
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Signup Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signupUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 3))
                        : const Text('Registrarse'),
                  ),
                  const SizedBox(height: 20),

                  // Link back to Login Screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes una cuenta?'),
                      TextButton(
                        onPressed: () {
                          // Navigate back to LoginScreen
                          // Navigator.pushReplacement(
                          //   // Use pushReplacement
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const LoginScreen()),
                          // );
                          Navigator.pop(context); // Use pop
                        },
                        child: Text(
                          'Inicia Sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
