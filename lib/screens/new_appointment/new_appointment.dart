import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:firebase_auth/firebase_auth.dart';

import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/data_classes/appointment.dart';
import 'package:vaq/assets/data_classes/location.dart';
import 'package:vaq/services/dynamic_location_repository.dart';
import 'package:vaq/services/dynamic_appointment_repository.dart';
import 'package:vaq/services/dynamic_product_repository.dart';
import 'package:vaq/screens/payment/payment_form.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vaq/assets/helpers/holidays.dart';
import 'package:vaq/providers/bottom_navigation_bar_provider.dart';

enum PaymentMethod { inPerson, payNow }

class ScheduleAppointmentScreen extends StatefulWidget {
  // Make product optional
  final Product? product;

  // Update constructor
  const ScheduleAppointmentScreen({super.key, this.product});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  // State variables
  Product?
      _selectedProduct; // Holds the product being scheduled (either initial or selected)
  Location? _selectedLocation;
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot; // Store the full DateTime of the slot
  List<Location> _availableLocations = [];
  List<DateTime> _availableTimeSlots = [];
  List<Consultation> _availableConsultations = []; // List for product selection
  bool _isLoading = false;
  bool _isProductSelectionMode =
      false; // Flag to know if we need to select a product
  PaymentMethod _paymentMethod = PaymentMethod.inPerson;

  // Repositories
  final DynamicAppointmentRepository _appointmentRepository =
      DynamicAppointmentRepository();
  final DynamicProductRepository _productRepository =
      DynamicProductRepository();
  final DynamicLocationRepository _locationRepository =
      DynamicLocationRepository();

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.product; // Initialize with the passed product
    _isProductSelectionMode = widget.product == null; // Set mode based on input

    if (_isProductSelectionMode) {
      _loadAvailableConsultations(); // Load consultations if no product was passed
    } else {
      _loadAvailableLocations(); // Load locations if a product was passed
    }
  }

  // Load consultation products if none was provided initially
  Future<void> _loadAvailableConsultations() async {
    try {
      final allProducts = await _productRepository.getProducts();
      setState(() {
        _availableConsultations =
            allProducts.whereType<Consultation>().toList();
        // Reset other selections when entering product selection mode
        _selectedLocation = null;
        _selectedDate = null;
        _selectedTimeSlot = null;
        _availableLocations = [];
        _availableTimeSlots = [];
      });
    } catch (e) {
      print('Error loading consultations: $e');
    }
  }

  // Load locations based on the _selectedProduct
  Future<void> _loadAvailableLocations() async {
    try {
      final locations = await _locationRepository.getLocations();
      setState(() {
        _availableLocations = locations;
        _selectedLocation = null;
        _selectedDate = null;
        _selectedTimeSlot = null;
        _availableTimeSlots = [];
      });
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  // --- Date and Time Selection Logic ---

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final holidays = ColombianHolidays.getHolidays(year: today.year);

    // Helper function to check if a date is selectable
    bool isDateSelectable(DateTime date) {
      // Only Monday–Friday and not a holiday
      if (date.weekday < DateTime.monday || date.weekday > DateTime.friday) {
        return false;
      }
      final normalized = DateTime.utc(date.year, date.month, date.day);
      return !holidays.contains(normalized);
    }

    // Find a valid initial date
    DateTime initialDate = today;
    if (_selectedDate != null && isDateSelectable(_selectedDate!)) {
      initialDate = _selectedDate!;
    } else {
      // Find the next valid date starting from today
      while (!isDateSelectable(initialDate)) {
        initialDate = initialDate.add(const Duration(days: 1));
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startOfToday,
      lastDate: today.add(const Duration(days: 180)),
      locale: const Locale('es', 'ES'),
      selectableDayPredicate: isDateSelectable,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
        _availableTimeSlots =
            _generateAvailableTimeSlots(picked, _selectedLocation);
      });
    }
  }

  // SIMULATED time slots - Replace with real availability logic later
  List<DateTime> _generateAvailableTimeSlots(
      DateTime? date, Location? location) {
    if (date == null || location == null) {
      return []; // No slots if date or location isn't selected
    }

    List<DateTime> slots = [];
    // Example: Generate slots from 9 AM to 6 PM (exclusive), every 30 minutes
    DateTime startTime =
        DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
    DateTime endTime =
        DateTime(date.year, date.month, date.day, 18, 0); // 6:00 PM (exclusive)

    // TODO: Get actual booked appointments for this location on this date
    final bookedSlots = <DateTime>[]; // Placeholder

    while (startTime.isBefore(endTime)) {
      // Skip 13:00 and 13:30
      if (startTime.hour == 13) {
        startTime = startTime.add(const Duration(minutes: 30));
        continue;
      }
      // Basic check: Don't add slots in the past (if selected date is today)
      final now = DateTime.now();
      if (startTime.isAfter(now)) {
        // Check if this slot is already booked (compare year, month, day, hour, minute)
        bool isBooked = bookedSlots.any((booked) =>
            booked.year == startTime.year &&
            booked.month == startTime.month &&
            booked.day == startTime.day &&
            booked.hour == startTime.hour &&
            booked.minute == startTime.minute);

        if (!isBooked) {
          slots.add(startTime);
        }
      }
      startTime =
          startTime.add(const Duration(minutes: 30)); // Increment by 30 mins
    }
    return slots;
  }

  void _onTimeSlotSelected(DateTime? timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  // Handler for when a product is selected from the dropdown
  void _onProductSelected(Product? product) {
    if (product != null && product != _selectedProduct) {
      setState(() {
        _selectedProduct = product;
        // Reset subsequent selections and load locations for the new product
        _selectedLocation = null;
        _selectedDate = null;
        _selectedTimeSlot = null;
        _availableLocations = [];
        _availableTimeSlots = [];
        _loadAvailableLocations(); // Load locations for the newly selected product
      });
    }
  }

  void _onLocationSelected(Location? location) {
    if (location != _selectedLocation) {
      setState(() {
        _selectedLocation = location;
        _selectedTimeSlot = null;
        _availableTimeSlots =
            _generateAvailableTimeSlots(_selectedDate, location);
      });
    }
  }

  // --- Submission Logic ---
  Future<void> _submitAppointment() async {
    // Add check for _selectedProduct
    if (_selectedProduct == null ||
        _selectedLocation == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Por favor completa todos los campos.'),
            backgroundColor: Theme.of(context).colorScheme.tertiary),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      // Determine appointment type based on the selected product
      AppointmentType apptType;
      Duration duration;
      if (_selectedProduct! is Consultation) {
        apptType = AppointmentType.consultation;
        duration = (_selectedProduct! as Consultation).typicalDuration;
      } else if (_selectedProduct! is DoseBundle) {
        apptType = AppointmentType.packageApplication;
        duration = const Duration(minutes: 45);
      } else {
        apptType = AppointmentType.vaccination;
        duration = const Duration(minutes: 30);
      }

      // Determine payment status based on payment method
      PaymentStatus paymentStatus;
      if (_paymentMethod == PaymentMethod.inPerson) {
        paymentStatus = PaymentStatus.none;
      } else {
        paymentStatus = PaymentStatus.pending;
      }

      // Create the new Appointment object
      final newAppointment = Appointment(
        id: const Uuid().v4(),
        patientId: user.uid,
        patientName: (user.displayName?.trim().isNotEmpty == true
                ? user.displayName
                : null) ??
            (user.email?.trim().isNotEmpty == true ? user.email : null) ??
            'Paciente desconocido',
        doctorId: 'placeholder_doctor_id',
        doctorName: null,
        doctorSpecialty: null,
        dateTime: _selectedTimeSlot!,
        duration: duration,
        locationId: _selectedLocation!.id,
        locationName: _selectedLocation!.name,
        locationAddress: _selectedLocation!.address,
        type: apptType,
        productIds: [_selectedProduct!.id],
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        createdByUserId: user.uid,
        notes: null,
        paymentStatus: paymentStatus,
      );

      // Handle payment if payNow is selected
      if (_paymentMethod == PaymentMethod.payNow) {
        try {
          // Calculate amount (using product price or default)
          final amountCOP = _selectedProduct!.price ?? 0.0;

          // Navigate to payment form BEFORE creating the appointment
          if (!mounted) return;
          final paymentResult = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentFormScreen(
                appointment: newAppointment,
                amount: amountCOP,
              ),
            ),
          );

          // Only create appointment if payment was successful
          if (paymentResult == true && mounted) {
            // Create the appointment after successful payment
            await _appointmentRepository.createAppointment(newAppointment);
            
            Fluttertoast.showToast(
              msg: '¡Cita agendada y pago realizado con éxito!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
            
            // Navigate to appointments screen
            Navigator.of(context).popUntil((route) => route.isFirst);
            Provider.of<BottomNavigationBarProvider>(context, listen: false)
                .navigateTo(2);
          } else {
            // User cancelled payment - don't create appointment, just return to scheduling screen
            // No need to do anything, just stay on the scheduling screen
            return;
          }
        } catch (paymentError) {
          print('Payment error: $paymentError');
          // If there's an error, don't create the appointment
          // User can try again
          return;
        }
      } else {
        // In-person payment - create appointment immediately
        await _appointmentRepository.createAppointment(newAppointment);
        
        if (mounted) {
          Fluttertoast.showToast(
              msg: '¡Cita agendada con éxito!',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18.0);
          
          // Navigate to appointments screen
          Navigator.of(context).popUntil((route) => route.isFirst);
          Provider.of<BottomNavigationBarProvider>(context, listen: false)
              .navigateTo(2);
        }
      }
    } catch (e) {
      print('Error scheduling appointment: $e');
      if (mounted) {
        Fluttertoast.showToast(
            msg: 'Error al agendar la cita: $e',
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError,
            fontSize: 16.0);
      }
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
    // Update canSubmit check
    final bool canSubmit = _selectedProduct != null &&
        _selectedLocation != null &&
        _selectedDate != null &&
        _selectedTimeSlot != null &&
        !_isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isProductSelectionMode
            ? 'Seleccionar Consulta'
            : 'Agendar Cita'), // Dynamic title
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Conditionally show Product Selection OR Product Summary ---
            if (_isProductSelectionMode) ...[
              Text('Selecciona un Tipo de Consulta',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildProductDropdown(), // Show dropdown to select product
              const SizedBox(height: 24),
            ] else if (_selectedProduct != null) ...[
              // Show summary only if a product is selected (and not in selection mode)
              _buildProductSummaryCard(theme),
              const SizedBox(height: 24),
            ],

            // --- Show scheduling steps only if a product is selected ---
            if (_selectedProduct != null) ...[
              // 2. Punto de Vacunación Selection
              Text('Selecciona un punto de vacunación',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildLocationDropdown(),
              const SizedBox(height: 24),

              // 3. Date Selection
              Text('Selecciona una Fecha',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDatePicker(context),
              const SizedBox(height: 24),

              // 4. Time Slot Selection (only if date and doctor are selected)
              if (_selectedDate != null && _selectedLocation != null) ...[
                Text('Selecciona una Hora',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTimeSlotDropdown(),
                const SizedBox(height: 32),
              ],

              // 5. Payment Method Selection (only if time slot is selected)
              if (_selectedTimeSlot != null) ...[
                Text('Método de Pago',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildPaymentMethodSection(),
                const SizedBox(height: 32),
              ],

              // 6. Submit Button
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: canSubmit
                            ? _submitAppointment
                            : null, // Disable if not ready or loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Confirmar Cita'),
                      ),
              ),
            ] else if (_isProductSelectionMode) ...[
              // Optional: Message if no product is selected yet
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Text(
                    'Por favor, selecciona un tipo de consulta para continuar.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Widget to select a Consultation product
  Widget _buildProductDropdown() {
    if (_availableConsultations.isEmpty) {
      return Text(
        'No hay consultas disponibles para agendar.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return DropdownButtonFormField<Product>(
      value: _selectedProduct, // Use _selectedProduct here
      hint: const Text('Selecciona consulta...'),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      items: _availableConsultations.map((Consultation consultation) {
        return DropdownMenuItem<Product>(
          value: consultation,
          child: Text(consultation.name), // Display consultation name
        );
      }).toList(),
      onChanged: _onProductSelected, // Use the dedicated handler
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildProductSummaryCard(ThemeData theme) {
    // Add null check for safety, though it shouldn't be called if null
    if (_selectedProduct == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedProduct!.name, // Use _selectedProduct!
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedProduct!.commonName, // Use _selectedProduct!
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedProduct!.description, // Use _selectedProduct!
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                // Use _selectedProduct!
                '\$${_selectedProduct!.price?.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    if (_selectedProduct == null) {
      return Text(
        'Selecciona un producto primero.',
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }
    if (_availableLocations.isEmpty) {
      return Text(
        'No hay puntos de vacunación disponibles.',
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      );
    }

    return DropdownButtonFormField<Location>(
      value: _selectedLocation,
      hint: const Text('Selecciona punto...'),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      items: _availableLocations.map((Location location) {
        return DropdownMenuItem<Location>(
          value: location,
          child: Text(location.name),
        );
      }).toList(),
      onChanged: _onLocationSelected,
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      // Disable tap if location isn't selected yet
      onTap: _selectedLocation != null ? () => _selectDate(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha seleccionada',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: const Icon(Icons.calendar_today),
          // Dim the field if disabled
          filled: _selectedLocation == null,
          fillColor: _selectedLocation == null
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Colors.transparent,
        ),
        child: Text(
          _selectedLocation == null
              ? 'Selecciona un punto de vacunación primero'
              : _selectedDate == null
                  ? 'Toca para seleccionar'
                  : DateFormat.yMMMd('es_ES').format(_selectedDate!),
          style: TextStyle(
            color: _selectedDate == null || _selectedLocation == null
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotDropdown() {
    if (_availableTimeSlots.isEmpty) {
      return Text(
        'No hay horarios disponibles para esta fecha/punto.',
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      );
    }
    return DropdownButtonFormField<DateTime>(
      value: _selectedTimeSlot,
      hint: const Text('Selecciona hora...'),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      items: _availableTimeSlots.map((DateTime timeSlot) {
        return DropdownMenuItem<DateTime>(
          value: timeSlot,
          child: Text(DateFormat.jm('es_ES')
              .format(timeSlot)), // Format time e.g., 9:30 AM
        );
      }).toList(),
      onChanged: _onTimeSlotSelected, // Use the dedicated handler
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      children: [
        RadioListTile<PaymentMethod>(
          title: const Text('Pagar en la clínica'),
          value: PaymentMethod.inPerson,
          groupValue: _paymentMethod,
          onChanged: (PaymentMethod? value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        RadioListTile<PaymentMethod>(
          title: const Text('Pagar ahora'),
          value: PaymentMethod.payNow,
          groupValue: _paymentMethod,
          onChanged: (PaymentMethod? value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        // Collapsible section for payNow
        if (_paymentMethod == PaymentMethod.payNow) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pagarás ahora de forma segura sin salir de la app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
