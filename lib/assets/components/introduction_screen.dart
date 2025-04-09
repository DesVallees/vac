import 'package:flutter/material.dart';

class IntroductionScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final String subtitle;
  final String description;

  const IntroductionScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.teal,
              decoration: TextDecoration.none,
              height: 1.2,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Image.asset(
            imagePath,
            height: 300,
          ),
          const SizedBox(height: 32),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: Color.fromARGB(255, 74, 74, 74),
                decoration: TextDecoration.none, // Sin subrayado
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
