import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

import 'package:vac/assets/data_classes/product.dart';
import 'package:vac/assets/data_classes/user.dart';
import 'package:vac/assets/data_classes/appointment.dart';
import 'package:vac/assets/dummy_data/pediatricians.dart';
import 'package:vac/assets/dummy_data/appointments.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  final Product product;

  const ScheduleAppointmentScreen({super.key, required this.product});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  // State variables
  Pediatrician? _selectedPediatrician;
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot; // Store the full DateTime of the slot
  List<Pediatrician> _availablePediatricians = [];
  List<DateTime> _availableTimeSlots = [];
  bool _isLoading = false;

  // Repositories
  final PediatriciansRepository _pediatriciansRepository =
      PediatriciansRepository();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  @override
  void initState() {
    super.initState();
    _loadAvailablePediatricians();
  }

  void _loadAvailablePediatricians() {
    final allPediatricians = _pediatriciansRepository.getPediatricians();
    // Filter pediatricians based on product's applicableDoctors (using specialty as proxy)
    setState(() {
      _availablePediatricians = allPediatricians
          .where(
              (ped) => widget.product.applicableDoctors.contains(ped.specialty))
          .toList();
      // If only one is available, pre-select them
      if (_availablePediatricians.length == 1) {
        _selectedPediatrician = _availablePediatricians.first;
      }
    });
  }

  // --- Date and Time Selection Logic ---

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: startOfToday, // Can't select past dates
      lastDate: today.add(const Duration(days: 180)), // Limit to 6 months ahead
      locale: const Locale('es', 'ES'), // Use Spanish locale
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot when date changes
        _availableTimeSlots =
            _generateAvailableTimeSlots(picked, _selectedPediatrician);
      });
    }
  }

  // SIMULATED time slots - Replace with real availability logic later
  List<DateTime> _generateAvailableTimeSlots(
      DateTime? date, Pediatrician? doctor) {
    if (date == null || doctor == null) {
      return []; // No slots if date or doctor isn't selected
    }

    List<DateTime> slots = [];
    // Example: Generate slots from 9 AM to 5 PM, every 30 minutes
    DateTime startTime =
        DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
    DateTime endTime =
        DateTime(date.year, date.month, date.day, 17, 0); // 5:00 PM

    while (startTime.isBefore(endTime)) {
      // Basic check: Don't add slots in the past (if selected date is today)
      if (startTime.isAfter(DateTime.now())) {
        // TODO: Add logic here to check against existing appointments for this doctor on this date
        slots.add(startTime);
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

  void _onPediatricianSelected(Pediatrician? pediatrician) {
    setState(() {
      _selectedPediatrician = pediatrician;
      _selectedTimeSlot = null; // Reset time slot when doctor changes
      _availableTimeSlots =
          _generateAvailableTimeSlots(_selectedDate, pediatrician);
    });
  }

  // --- Submission Logic ---
  Future<void> _submitAppointment() async {
    if (_selectedPediatrician == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determine appointment type based on product
      AppointmentType apptType;
      Duration duration;
      if (widget.product is Consultation) {
        apptType = AppointmentType.consultation;
        duration = (widget.product as Consultation).typicalDuration;
      } else if (widget.product is Package) {
        apptType = AppointmentType.packageApplication;
        // Estimate duration for package? Or set a default?
        duration = const Duration(minutes: 45); // Example duration
      } else {
        // Assume Vaccine or other product types
        apptType = AppointmentType.vaccination;
        duration = const Duration(minutes: 30); // Example duration
      }

      // Create the new Appointment object
      final newAppointment = Appointment(
        id: const Uuid().v4(), // Generate unique ID
        patientId: 'current_patient_id', // TODO: Get actual patient ID
        patientName: 'Paciente Ejemplo', // TODO: Get actual patient name
        doctorId: _selectedPediatrician!.id,
        doctorName: _selectedPediatrician!.displayName,
        doctorSpecialty: _selectedPediatrician!.specialty,
        dateTime: _selectedTimeSlot!, // Use the selected time slot
        duration: duration,
        locationId: _selectedPediatrician!.clinicLocationIds.isNotEmpty
            ? _selectedPediatrician!.clinicLocationIds
                .first // TODO: Allow selecting location if doctor has multiple
            : 'default_loc_id', // Fallback location ID
        locationName:
            'Clínica Ejemplo', // TODO: Get actual location name based on ID
        type: apptType,
        productIds: [widget.product.id], // Add the selected product ID
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        createdByUserId:
            'current_user_id', // TODO: Get actual logged-in user ID
        notes: null, // Add notes field later if needed
      );

      // Add to the dummy repository
      _appointmentRepository.addAppointment(newAppointment);

      // Show success and navigate back
      Fluttertoast.showToast(
          msg: '¡Cita agendada con éxito!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP, // Or BOTTOM, TOP
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 12, 95, 15),
          textColor: Colors.white,
          fontSize: 18.0);
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print('Error scheduling appointment: $e');
      Fluttertoast.showToast(
          msg: 'Error al agendar la cita: $e',
          toastLength: Toast.LENGTH_LONG, // Longer for errors
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } finally {
      if (mounted) {
        // Check if widget is still mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canSubmit = _selectedPediatrician != null &&
        _selectedDate != null &&
        _selectedTimeSlot != null &&
        !_isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Summary Card
            _buildProductSummaryCard(theme),
            const SizedBox(height: 24),

            // 2. Pediatrician Selection
            Text('Selecciona un Pediatra',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPediatricianDropdown(),
            const SizedBox(height: 24),

            // 3. Date Selection
            Text('Selecciona una Fecha',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDatePicker(context),
            const SizedBox(height: 24),

            // 4. Time Slot Selection (only if date and doctor are selected)
            if (_selectedDate != null && _selectedPediatrician != null) ...[
              Text('Selecciona una Hora',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTimeSlotDropdown(),
              const SizedBox(height: 32),
            ],

            // 5. Submit Button
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: canSubmit
                          ? _submitAppointment
                          : null, // Disable if not ready or loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Confirmar Cita'),
                    ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildProductSummaryCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.commonName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.description,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
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

  Widget _buildPediatricianDropdown() {
    if (_availablePediatricians.isEmpty) {
      return const Text(
        'No hay pediatras disponibles para este producto.',
        style: TextStyle(color: Colors.red),
      );
    }

    return DropdownButtonFormField<Pediatrician>(
      value: _selectedPediatrician,
      hint: const Text('Selecciona...'),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      items: _availablePediatricians.map((Pediatrician pediatrician) {
        return DropdownMenuItem<Pediatrician>(
          value: pediatrician,
          child: Text(pediatrician.displayName ?? 'Nombre Desconocido'),
        );
      }).toList(),
      onChanged: _onPediatricianSelected, // Use the dedicated handler
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha seleccionada',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDate == null
              ? 'Toca para seleccionar'
              : DateFormat.yMMMd('es_ES').format(_selectedDate!),
          style: TextStyle(
            color: _selectedDate == null ? Colors.grey[600] : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotDropdown() {
    if (_availableTimeSlots.isEmpty) {
      return const Text(
        'No hay horarios disponibles para esta fecha/doctor.',
        style: TextStyle(color: Colors.orange),
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
}
