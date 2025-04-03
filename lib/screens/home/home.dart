import 'package:flutter/material.dart';
import 'package:vac/assets/components/product_card.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          const SizedBox(height: 30),

          SearchBar(),
          const SizedBox(height: 30),

          // Services
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceIcon(Icons.person, Colors.blue),
              _buildServiceIcon(Icons.local_hospital, Colors.orange),
              _buildServiceIcon(Icons.fact_check, Colors.teal),
              _buildServiceIcon(Icons.settings, Colors.red),
            ],
          ),
          const SizedBox(height: 20),

          // Banner
          _buildPromotionalBanner(),
          const SizedBox(height: 40),

          // Featured Products
          const Text(
            'Paquetes más vendidos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProductCard(
                imageUrl: 'lib/assets/images/medical_kit.png',
                productName: 'Kit Médico',
                productDescription: 'Comprensivo para uso doméstico.',
                productPrice: 49.99,
                backgroundColor: Color.fromARGB(255, 0, 233, 58),
              ),
              const SizedBox(height: 10),
              ProductCard(
                imageUrl: 'lib/assets/images/vaccine.png',
                productName: 'Vacuna X',
                productDescription: 'Vacuna indispensable para X.',
                productPrice: 29.99,
                backgroundColor: const Color.fromARGB(255, 34, 0, 255),
              )
            ],
          ),
          const SizedBox(height: 40),

          // Appointments
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, Color color) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: 30,
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(102, 0, 0, 0),
            blurRadius: 9,
            offset: Offset(3, 3),
          )
        ],
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Encuentra los Mejores Servicios Médicos en VAC+',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Te ofrecemos servicios y productos de la mejor calidad.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Image.asset(
            'lib/assets/images/home_banner.png',
            height: 80,
          ),
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
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  weekday,
                  style: TextStyle(color: Colors.white),
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

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Buscar...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[300],
        suffixIcon: Icon(Icons.tune),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '👋 ¡Hola,',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        const Text(
          'X!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('lib/assets/images/home_banner.webp'),
        ),
      ],
    );
  }
}
