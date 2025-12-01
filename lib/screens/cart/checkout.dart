import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:vaq/providers/cart_provider.dart';
import 'package:vaq/assets/data_classes/appointment.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/services/dynamic_appointment_repository.dart';
import 'package:vaq/screens/payment/payment_form.dart';

enum PaymentMethod { inPerson, payNow }

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final DynamicAppointmentRepository _appointmentRepository =
      DynamicAppointmentRepository();
  bool _isValidating = true;
  bool _isProcessing = false;
  PaymentMethod _paymentMethod = PaymentMethod.inPerson;
  Map<String, bool> _availabilityStatus = {}; // cartItemId -> isAvailable

  @override
  void initState() {
    super.initState();
    _validateAppointments();
  }

  Future<void> _validateAppointments() async {
    setState(() {
      _isValidating = true;
    });

    final cartProvider = context.read<CartProvider>();
    final items = cartProvider.getItemsWithAppointments();
    
    // Validate each appointment
    for (final item in items) {
      final isAvailable = await cartProvider.validateAppointmentAvailability(item.cartItemId);
      _availabilityStatus[item.cartItemId] = isAvailable;
    }

    if (mounted) {
      setState(() {
        _isValidating = false;
      });

      // Show dialog if any appointments are unavailable
      final unavailableItems = items.where((item) => _availabilityStatus[item.cartItemId] == false).toList();
      if (unavailableItems.isNotEmpty) {
        _showUnavailableAppointmentsDialog(unavailableItems);
      }
    }
  }

  void _showUnavailableAppointmentsDialog(List<CartItem> unavailableItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Citas No Disponibles'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Las siguientes citas ya no están disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...unavailableItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.commonName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (item.appointmentDate != null)
                            Text(
                              '${DateFormat('d MMMM, y', 'es_ES').format(item.appointmentDate!)} ${DateFormat.jm('es_ES').format(item.appointmentDate!)} - ${item.locationName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showItemRescheduleDialog(CartItem item) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.product.commonName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.appointmentDate != null)
              Text(
                'Cita actual: ${DateFormat('d MMMM, y', 'es_ES').format(item.appointmentDate!)} ${DateFormat.jm('es_ES').format(item.appointmentDate!)} - ${item.locationName}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('remove'),
            child: const Text('Eliminar del Carrito'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('reschedule'),
            child: const Text('Reagendar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (result == 'remove') {
      context.read<CartProvider>().removeFromCart(item.cartItemId);
      _validateAppointments();
    } else if (result == 'reschedule') {
      // Navigate back to cart and expand the item for rescheduling
      context.read<CartProvider>().clearAppointmentForItem(item.cartItemId);
      Navigator.of(context).pop();
    }
  }

  Future<bool> _validateBeforePayment() async {
    final cartProvider = context.read<CartProvider>();
    final items = cartProvider.getItemsWithAppointments();
    
    // Re-validate all appointments
    bool allAvailable = true;
    List<CartItem> unavailableItems = [];

    for (final item in items) {
      final isAvailable = await cartProvider.validateAppointmentAvailability(item.cartItemId);
      if (!isAvailable) {
        allAvailable = false;
        unavailableItems.add(item);
      }
    }

    if (!allAvailable) {
      // Show reschedule dialog
      final shouldContinue = await _showPrePaymentValidationDialog(unavailableItems);
      if (!shouldContinue) {
        return false;
      }
      // Re-validate again after user actions
      return _validateBeforePayment();
    }

    return true;
  }

  Future<bool> _showPrePaymentValidationDialog(List<CartItem> unavailableItems) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Citas No Disponibles'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Las siguientes citas ya no están disponibles antes de procesar el pago:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...unavailableItems.map((item) => InkWell(
                      onTap: () {
                        Navigator.of(context).pop(false);
                        _showItemRescheduleDialog(item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.commonName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (item.appointmentDate != null)
                              Text(
                                '${DateFormat('d MMMM, y', 'es_ES').format(item.appointmentDate!)} ${DateFormat.jm('es_ES').format(item.appointmentDate!)} - ${item.locationName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            Text(
                              'Toca para reagendar o eliminar',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _processPayment() async {
    if (!await _validateBeforePayment()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final cartProvider = context.read<CartProvider>();
      final items = cartProvider.getItemsWithAppointments();
      final total = cartProvider.getTotalForItemsWithAppointments();

      if (_paymentMethod == PaymentMethod.payNow) {
        // Create a temporary appointment for payment (we'll create real ones after)
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Usuario no autenticado');
        }

        // Create a combined appointment for payment processing
        // Use the first item's appointment details
        if (items.isEmpty) {
          throw Exception('No hay items para pagar');
        }

        final firstItem = items.first;
        final duration = cartProvider.getDurationForProduct(firstItem.product);

        final tempAppointment = Appointment(
          id: const Uuid().v4(),
          patientId: user.uid,
          patientName: user.displayName ?? user.email ?? 'Paciente',
          doctorId: 'placeholder_doctor_id',
          dateTime: firstItem.appointmentDate!,
          duration: duration,
          locationId: firstItem.locationId!,
          locationName: firstItem.locationName!,
          locationAddress: null,
          type: _getAppointmentType(firstItem.product),
          productIds: items.map((item) => item.product.id).toList(),
          status: AppointmentStatus.scheduled,
          createdAt: DateTime.now(),
          createdByUserId: user.uid,
          paymentStatus: PaymentStatus.pending,
        );

        // Navigate to payment form
        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentFormScreen(
              appointment: tempAppointment,
              amount: total,
            ),
          ),
        );

        if (paymentResult == true && mounted) {
          // Payment successful, create appointments
          await _createAppointments(items, PaymentStatus.paid);
        } else {
          // Payment cancelled or failed
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
          return;
        }
      } else {
        // Pay at clinic - create appointments without payment
        await _createAppointments(items, PaymentStatus.none);
      }
    } catch (e) {
      print('Error processing payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pago: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _createAppointments(List<CartItem> items, PaymentStatus paymentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final cartProvider = context.read<CartProvider>();

    try {
      // Create appointment for each item
      for (final item in items) {
        for (int i = 0; i < item.quantity; i++) {
          final duration = cartProvider.getDurationForProduct(item.product);
          
          // Verify slot is still available
          final isAvailable = await _appointmentRepository.isTimeSlotAvailable(
            item.locationId!,
            item.appointmentDate!,
            duration,
          );

          if (!isAvailable) {
            // Skip this item if not available
            continue;
          }

          final appointment = Appointment(
            id: const Uuid().v4(),
            patientId: user.uid,
            patientName: user.displayName ?? user.email ?? 'Paciente',
            doctorId: 'placeholder_doctor_id',
            dateTime: item.appointmentDate!,
            duration: duration,
            locationId: item.locationId!,
            locationName: item.locationName!,
            locationAddress: null,
            type: _getAppointmentType(item.product),
            productIds: [item.product.id],
            status: AppointmentStatus.scheduled,
            createdAt: DateTime.now(),
            createdByUserId: user.uid,
            paymentStatus: paymentStatus,
          );

          await _appointmentRepository.createAppointment(appointment);
        }
      }

      // Remove items with appointments from cart
      cartProvider.removeItemsWithAppointments();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Pago realizado exitosamente! Tus citas han sido agendadas.'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 90, // Space above bottom navigation bar
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navigate back to cart
        Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/cart');
      }
    } catch (e) {
      print('Error creating appointments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear las citas: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 20,
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      rethrow;
    }
  }

  AppointmentType _getAppointmentType(Product product) {
    if (product is Consultation) {
      return AppointmentType.consultation;
    } else if (product is DoseBundle) {
      return AppointmentType.packageApplication;
    } else {
      return AppointmentType.vaccination;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isValidating
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final items = cartProvider.getItemsWithAppointments();
                final total = cartProvider.getTotalForItemsWithAppointments();
                final unavailableItems =
                    items.where((item) => _availabilityStatus[item.cartItemId] == false).toList();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Warning for unavailable items
                            if (unavailableItems.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Algunas citas no están disponibles',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onErrorContainer,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Revisa las citas antes de proceder al pago',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onErrorContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Summary title
                            Text(
                              'Resumen de Compra',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Items list
                            ...items.map((item) => _buildItemSummaryCard(item)),
                            const SizedBox(height: 20),
                            // Total
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'es_CO', symbol: '\$', decimalDigits: 0)
                                        .format(total),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Payment method selection
                            Text(
                              'Método de Pago',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentMethodSection(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    // Payment button
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isProcessing
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
                                    Text('Procesando...'),
                                  ],
                                )
                              : Text(_paymentMethod == PaymentMethod.payNow
                                  ? 'Pagar \$${NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0).format(total).replaceAll('\$', '').replaceAll(',', '')}'
                                  : 'Confirmar y Agendar'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildItemSummaryCard(CartItem item) {
    final isUnavailable = _availabilityStatus[item.cartItemId] == false;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isUnavailable
            ? Border.all(color: theme.colorScheme.error, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.commonName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (item.appointmentDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${DateFormat('d MMMM, y', 'es_ES').format(item.appointmentDate!)} ${DateFormat.jm('es_ES').format(item.appointmentDate!)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.locationName ?? '',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
                    .format((item.product.price ?? 0) * item.quantity),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (isUnavailable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta cita ya no está disponible',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showItemRescheduleDialog(item),
                  child: const Text('Reagendar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      children: [
        RadioListTile<PaymentMethod>(
          title: const Text('Pagar en Clínica'),
          subtitle: const Text('Pagarás cuando recibas el servicio'),
          value: PaymentMethod.inPerson,
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
        RadioListTile<PaymentMethod>(
          title: const Text('Pagar Ahora'),
          subtitle: const Text('Paga con tarjeta de crédito o débito'),
          value: PaymentMethod.payNow,
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
      ],
    );
  }
}

