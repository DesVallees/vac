// lib/screens/schedule/schedule.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar specifics
import 'package:vac/assets/components/appointment_card.dart';
import 'package:vac/assets/data_classes/appointment.dart';
import 'package:vac/assets/dummy_data/appointments.dart';
import 'package:collection/collection.dart'; // Import for groupBy
import 'package:intl/intl.dart'; // <-- Add this line

// --- Schedule Widget (Now StatefulWidget) ---
class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  // State variables
  late final List<Appointment> _allAppointments;
  List<Appointment> _filteredAppointments = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Appointment>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Select today initially

    // 1. Load all appointments
    final AppointmentRepository appointmentRepository = AppointmentRepository();
    _allAppointments = appointmentRepository.getAppointments();

    // 2. Prepare events map for calendar markers
    _events = _groupAppointmentsByDate(_allAppointments);

    // 3. Apply initial filter based on the initially selected day
    _filterAppointmentsForSelectedDay();
  }

  // Helper to group appointments by date (ignoring time) for eventLoader
  Map<DateTime, List<Appointment>> _groupAppointmentsByDate(
      List<Appointment> appointments) {
    return groupBy(
      appointments,
      (Appointment appt) => DateTime.utc(
          appt.dateTime.year, appt.dateTime.month, appt.dateTime.day),
    );
  }

  // Helper to get events for a specific day (used by eventLoader)
  List<Appointment> _getEventsForDay(DateTime day) {
    // Normalize the day to UTC to match the keys in the _events map
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // Filter the appointments list based on the _selectedDay
  void _filterAppointmentsForSelectedDay() {
    if (_selectedDay == null) {
      // If no day is selected, maybe show all upcoming? Or none?
      // Let's show appointments on or after today if nothing is selected.
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      setState(() {
        _filteredAppointments = _allAppointments
            .where((appt) => !appt.dateTime
                .isBefore(startOfToday)) // On or after start of today
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // Sort them
      });
    } else {
      // Filter for appointments on or after the START of the selected day
      final startOfSelectedDay =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      setState(() {
        _filteredAppointments = _allAppointments
            .where((appt) => !appt.dateTime.isBefore(
                startOfSelectedDay)) // On or after start of selected day
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // Sort them
      });
    }
  }

  // Callback when a day is selected in the calendar
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // Update focused day as well
      });
      _filterAppointmentsForSelectedDay(); // Re-filter the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          const Text(
            'Agenda',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // --- Calendar Section ---
          _buildCalendarSection(), // Calendar now uses state variables
          const SizedBox(height: 30),

          // --- Appointments Section Header (Dynamic Title) ---
          Text(
            _selectedDay == null || isSameDay(_selectedDay, DateTime.now())
                ? 'Próximas Citas'
                : 'Citas desde ${DateFormat.yMMMd('es_ES').format(_selectedDay!)}', // Show selected date
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // --- Dynamic List of Appointments ---
          if (_filteredAppointments.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  _selectedDay == null
                      ? 'No tienes citas programadas.'
                      : 'No hay citas programadas para esta fecha o después.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredAppointments.length,
              itemBuilder: (context, index) {
                // Use the dynamically filtered list
                return AppointmentCard(
                    appointment: _filteredAppointments[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            ),

          const SizedBox(height: 40), // Padding at the bottom
        ],
      ),
    );
  }

  // Updated Calendar section builder to use state and add features
  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.only(
          bottom: 15, left: 5, right: 5), // Adjusted padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TableCalendar<Appointment>(
        // Specify the event type
        locale: 'es_ES', // Set locale for Spanish weekdays/months
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month, // Or CalendarFormat.week, etc.
        startingDayOfWeek: StartingDayOfWeek.monday, // Start week on Monday

        // --- Event Handling ---
        eventLoader: _getEventsForDay, // Function to load events for marking

        // --- Styling ---
        calendarStyle: CalendarStyle(
          // Highlight today
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          // Highlight selected day
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          // Style for the event markers (dots)
          markerDecoration: BoxDecoration(
            color: Colors.redAccent, // Color of the dots
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1, // Show only one dot even if multiple events
          markerSize: 5.0, // Size of the dots
          // Adjust marker position if needed
          // markersAlignment: Alignment.bottomCenter,
          // markersOffset: const PositionedOffset(bottom: 5),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, // Hide format button (Month/Week/2 Weeks)
          titleCentered: true,
          titleTextStyle:
              TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),

        // --- Callbacks ---
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here, but update the focused day
          // `TableCalendar` manages this internally for page navigation.
          // We update our state variable primarily for potential external use
          // or if we needed to fetch data based on the visible month.
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
