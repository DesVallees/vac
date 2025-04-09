import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:vac/assets/data_classes/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  // Helper function to determine card color based on type or status
  Color _getAppointmentColor() {
    // Example logic: Customize as needed
    switch (appointment.type) {
      case AppointmentType.vaccination:
        return Colors.teal;
      case AppointmentType.consultation:
        return Colors.blue;
      case AppointmentType.packageApplication:
        return Colors.orange;
      case AppointmentType.checkup:
        return Colors.purple;
      case AppointmentType.followUp:
        return Colors.green;
      default:
        return Colors.grey; // Default color
    }

    // Based on status:
    // switch (appointment.status) {
    //   case AppointmentStatus.scheduled: return Colors.blue;
    //   case AppointmentStatus.completed: return Colors.green;
    //   case AppointmentStatus.cancelledByUser: return Colors.red;
    // }
  }

  // Helper function to get a display string for the appointment type/products
  String _getAppointmentTypeText() {
    if (appointment.productIds.isNotEmpty) {
      // If specific products are linked, indicate that
      // You could fetch product names here if needed, but keep it simple for the card
      if (appointment.type == AppointmentType.packageApplication) {
        return 'Aplicación Paquete'; // Or fetch package name
      }
      return 'Vacunación/Producto(s)'; // Generic for products
    }
    // Otherwise, use the enum type
    switch (appointment.type) {
      case AppointmentType.consultation:
        return 'Consulta';
      case AppointmentType.checkup:
        return 'Chequeo';
      case AppointmentType.followUp:
        return 'Seguimiento';
      default:
        // Fallback for types without specific products but not covered above
        return appointment.type.toString().split('.').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = _getAppointmentColor();
    final String day = DateFormat('d', 'es_ES').format(appointment.dateTime);
    final String weekday = DateFormat('E', 'es_ES')
        .format(appointment.dateTime)
        .toUpperCase(); // e.g., MAR
    final String time =
        DateFormat.jm().format(appointment.dateTime); // e.g., 9:30 AM

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.15), // Slightly less opaque
        borderRadius: BorderRadius.circular(15), // Consistent radius
      ),
      child: Row(
        children: [
          // Date Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  weekday,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Details Section
          Expanded(
            // Allow text to wrap if needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time, // Formatted time
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  appointment.doctorName ??
                      'Doctor No Especificado', // Use doctorName from appointment
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500), // Slightly adjusted style
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  _getAppointmentTypeText(), // Use helper for type text
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Add an icon or indicator based on status
          Icon(
            appointment.status == AppointmentStatus.completed
                ? Icons.check_circle
                : Icons.hourglass_top,
            color: cardColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
