import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vaq/assets/components/introduction_screen.dart';

class Introduction extends StatefulWidget {
  final VoidCallback? onDone;

  const Introduction({super.key, this.onDone});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final PageController _controller = PageController(); // Make final
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
  }

  // --- Function to call when intro is finished/skipped ---
  void _finishIntroduction(BuildContext context) {
    // Call the onDone callback passed from AuthWrapper
    widget.onDone?.call();
    // Calling widget.onDone?.call() will trigger a rebuild in AuthWrapper,
    // which will then show either LoginScreen or MyHomePage based on auth state.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('lib/assets/images/logo.png', width: 50),
                    TextButton(
                      onPressed: () {
                        // Call the finish function when skipping
                        _finishIntroduction(context);
                      },
                      child: Text('Omitir',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (value) {
                      setState(() {
                        isLastPage = value == 4;
                      });
                    },
                    children: const [
                      One(),
                      Two(),
                      Three(),
                      Four(),
                      Five(),
                    ],
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 5, // Match number of pages
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      // Call the finish function when done
                      _finishIntroduction(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(isLastPage ? 'Hecho' : 'Siguiente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class One extends StatelessWidget {
  const One({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroductionScreen(
      title: 'VAQ+',
      imagePath: 'lib/assets/images/home_banner.png',
      subtitle: 'La Mejor Asistencia Médica',
      description: 'Obtén servicios médicos especiales para ti las 24 horas.',
    );
  }
}

class Two extends StatelessWidget {
  const Two({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroductionScreen(
      title: 'Gestión de Vacunas',
      imagePath: 'lib/assets/images/vacunas.png',
      subtitle: 'Nunca Pierdas una Dosis',
      description:
          'Administra las vacunas de toda tu familia, agenda citas, y mantente al día con los recordatorios automáticos.',
    );
  }
}

class Three extends StatelessWidget {
  const Three({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroductionScreen(
      title: 'Registros Médicos',
      imagePath: 'lib/assets/images/historial_medico.png',
      subtitle: 'Toda tu Historia Médica en un Solo Lugar',
      description:
          'Guarda y consulta tus registros médicos de manera segura y accesible desde cualquier lugar.',
    );
  }
}

class Four extends StatelessWidget {
  const Four({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroductionScreen(
      title: 'Soporte al Instante',
      imagePath: 'lib/assets/images/servicio_al_cliente.png',
      subtitle: 'Siempre Aquí para Ayudarte',
      description:
          'Contacta a nuestro equipo de soporte en cualquier momento para resolver dudas o recibir asistencia.',
    );
  }
}

class Five extends StatelessWidget {
  const Five({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroductionScreen(
      title: 'Métodos de Pago Seguros',
      imagePath: 'lib/assets/images/pagos_seguros.png',
      subtitle: 'Fácil y Rápido',
      description:
          'Añade y gestiona tus métodos de pago preferidos para realizar compras de manera segura y sin complicaciones.',
    );
  }
}
