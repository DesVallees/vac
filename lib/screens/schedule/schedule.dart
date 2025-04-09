import 'package:flutter/material.dart';
import 'package:vac/assets/components/calendar.dart';

class Schedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agenda',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildCalendarSection(),
          const SizedBox(height: 30),
          const Text(
            'Próximas Citas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildAppointmentCard(
              '12', 'Mar', '9:30 AM', 'Dr. Freddy', 'Vacuna X', Colors.teal),
          const SizedBox(height: 20),
          _buildAppointmentCard('13', 'Mie', '2:00 PM', 'Dra. Constanza',
              'Vacuna Y', Colors.orange),
          const SizedBox(height: 20),
          _buildAppointmentCard(
              '14', 'Jue', '12:30 PM', 'Dra. Martha', 'Vacuna Z', Colors.red),
          const SizedBox(height: 20),
          _buildAppointmentCard(
              '15', 'Vie', '4:00 PM', 'Dr. Juan', 'Vacuna W', Colors.blue),
          const SizedBox(height: 20),
          _buildAppointmentCard(
              '16', 'Sab', '10:00 AM', 'Dra. Ana', 'Vacuna V', Colors.purple),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calendario',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Calendar(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(String day, String weekday, String time,
      String doctor, String type, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  weekday,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                doctor,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(type),
            ],
          ),
        ],
      ),
    );
  }
}
