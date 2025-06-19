import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:vaq/assets/data_classes/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  // Helper function to determine card color based on type or status
  Color _getAppointmentColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Example logic: Customize as needed
    switch (appointment.type) {
      case AppointmentType.vaccination:
        return colorScheme.primary;
      case AppointmentType.consultation:
        return colorScheme.secondary;
      case AppointmentType.packageApplication:
        return colorScheme.primary;
      case AppointmentType.checkup:
        return colorScheme.tertiary;
      case AppointmentType.followUp:
        return colorScheme.secondary;
      default:
        return colorScheme.primary; // Default color
    }

    // Based on status:
    // switch (appointment.status) {
    //   case AppointmentStatus.scheduled:
    //     return colorScheme.primary;
    //   case AppointmentStatus.completed:
    //     return colorScheme.secondary;
    //   case AppointmentStatus.cancelledByUser:
    //     return colorScheme.error;
    //   case AppointmentStatus.cancelledByClinic:
    //     return colorScheme.error;
    //   case AppointmentStatus.noShow:
    //     return colorScheme.error;
    //   case AppointmentStatus.pending:
    //     return colorScheme.tertiary;
    //   case AppointmentStatus.rescheduled:
    //     return colorScheme.tertiary;
    //   default:
    //     return colorScheme.primary;
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
    final Color cardColor = _getAppointmentColor(context);
    final String day = DateFormat('d', 'es_ES').format(appointment.dateTime);
    final String weekday = DateFormat('MMM', 'es_ES')
        .format(appointment.dateTime)
        .toUpperCase(); // e.g., ENE
    final String time =
        DateFormat.jm().format(appointment.dateTime); // e.g., 9:30 AM
    final colorScheme = Theme.of(context).colorScheme;

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
                  style: TextStyle(
                      fontSize: 22,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  weekday,
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 12),
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
                  appointment.locationName,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500), // Slightly adjusted style
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  _getAppointmentTypeText(), // Use helper for type text
                  style: TextStyle(
                      fontSize: 14, color: colorScheme.onSurfaceVariant),
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
