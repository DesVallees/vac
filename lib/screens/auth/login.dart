import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vaq/screens/auth/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Login Logic ---
  Future<void> _loginUser() async {
    final theme = Theme.of(context);
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to sign in
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If successful, the AuthWrapper will handle navigation.
    } on FirebaseAuthException catch (e) {
      String message;
      // Handle specific Firebase Auth errors
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo no es válido.';
      } else if (e.code == 'user-disabled') {
        message = 'Este usuario ha sido deshabilitado.';
      } else {
        message = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
        print('Login Error Code: ${e.code}'); // Log unexpected codes
        print('Login Error Message: ${e.message}');
      }
      // Show error message using Fluttertoast
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          fontSize: 16.0);
    } catch (e) {
      // Handle other potential errors
      print('Generic Login Error: $e');
      Fluttertoast.showToast(
          msg: 'Ocurrió un error. Por favor, inténtalo de nuevo.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          fontSize: 16.0);
    } finally {
      // Hide loading indicator only if the widget is still mounted
      if (mounted) {
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
              key: _formKey, // Assign the form key
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo (Optional)
                  Image.asset(
                    'lib/assets/images/logo.png', // Adjust path if needed
                    height: 80,
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'Bienvenido de Nuevo',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      hintText: 'tu@correo.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu correo.';
                      }
                      // Basic email format check
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Ingresa un correo válido.';
                      }
                      return null; // Return null if valid
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Hide password
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: '********',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña.';
                      }
                      // Add minimum length check
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null; // Return null if valid
                    },
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : _loginUser, // Disable if loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 20),

                  // Link to Sign Up Screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes una cuenta?'),
                      TextButton(
                        onPressed: () {
                          // Navigate to SignupScreen (replace)
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const SignupScreen()),
                          // );

                          // Navigate to SignupScreen (allowing going back)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Forgot Password Link
                  // TextButton(
                  //   onPressed: () { /* TODO: Implement Forgot Password */ },
                  //   child: Text('¿Olvidaste tu contraseña?'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
