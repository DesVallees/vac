import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:vaq/assets/data_classes/appointment.dart';

/// Result of a payment operation
class PaymentResult {
  final bool success;
  final String? refPayco;
  final String? transactionId;
  final String? message;
  final Map<String, dynamic>? data;

  PaymentResult({
    required this.success,
    this.refPayco,
    this.transactionId,
    this.message,
    this.data,
  });
}

class PaymentService {
  static const String _baseUrl =
      'https://us-central1-vac-plus.cloudfunctions.net';
  static const String _chargeEndpoint = '/chargeAppointment';

  /// Processes direct payment for an appointment
  ///
  /// [context] - BuildContext for UI operations
  /// [appointment] - The appointment to be paid for
  /// [amountCOP] - Amount in Colombian Pesos
  /// [cardData] - Card information for payment
  /// [customerData] - Customer information
  static Future<void> processPayment(
    BuildContext context,
    Appointment appointment,
    double amountCOP,
    Map<String, String> cardData,
    Map<String, String> customerData,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Prepare payment request
      final paymentRequest = {
        'appointmentId': appointment.id,
        'customer': {
          'name': customerData['name'] ?? '',
          'last_name': customerData['lastName'] ?? '',
          'email': customerData['email'] ?? user.email ?? '',
          'doc_type': customerData['docType'] ?? 'CC',
          'doc_number': customerData['docNumber'] ?? '',
          'phone': customerData['phone'] ?? '',
          'city': customerData['city'] ?? 'Bogotá',
          'address': customerData['address'] ?? 'N/A',
        },
        'card': {
          'number': cardData['number'] ?? '',
          'exp_month': cardData['expMonth'] ?? '',
          'exp_year': cardData['expYear'] ?? '',
          'cvc': cardData['cvc'] ?? '',
        },
        'amount': amountCOP,
        'description': _getPaymentDescription(appointment),
      };

      // Call backend to process payment
      final response = await http.post(
        Uri.parse('$_baseUrl$_chargeEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentRequest),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Pago exitoso
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Pago realizado con éxito! Referencia: ${responseData['refPayco']}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Mensaje en español al usuario
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error en el pago: ${responseData['error'] ?? 'El proceso de pago falló'}',
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Reintentar pago',
                  textColor: Colors.white,
                  onPressed: () => processPayment(
                      context, appointment, amountCOP, cardData, customerData),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
          throw Exception('Error en el pago ${jsonEncode(responseData)}');
        }
      } else {
        // Log completo en consola
        print(
            'Error HTTP ${response.statusCode}: ${jsonEncode(response.body)}');

        // Mensaje en español al usuario
        throw Exception(
            'Error en la comunicación con el servidor. Intente de nuevo.');
      }
    } catch (e) {
      // Log detallado
      print('Excepción durante el pago: ${e.toString()}');

      // Solo mensaje en español al usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Ocurrió un error durante el pago. Intente nuevamente.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar pago',
              textColor: Colors.white,
              onPressed: () => processPayment(
                  context, appointment, amountCOP, cardData, customerData),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    }
  }

  /// Generates a payment description for the appointment
  static String _getPaymentDescription(Appointment appointment) {
    return 'Cita médica - ${appointment.locationName}';
  }
}
