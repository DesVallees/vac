import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vac/assets/components/introduction_screen.dart';

class Introduction extends StatefulWidget {
  final VoidCallback? onDone;

  const Introduction({super.key, this.onDone});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final PageController _controller = PageController(); // Make final
  bool isLastPage = false;
  Color _backgroundColor = const Color.fromRGBO(240, 248, 255, 1.0);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page != null) {
        int currentPage = _controller.page!.round();
        // Check mounted before calling setState in listener
        if (mounted) {
          setState(() {
            _backgroundColor = _getBackgroundColor(currentPage);
          });
        }
      }
    });
  }

  // --- Function to call when intro is finished/skipped ---
  void _finishIntroduction(BuildContext context) {
    // Call the onDone callback passed from AuthWrapper
    widget.onDone?.call();
    // Calling widget.onDone?.call() will trigger a rebuild in AuthWrapper,
    // which will then show either LoginScreen or MyHomePage based on auth state.
  }

  Color _getBackgroundColor(int index) {
    switch (index) {
      case 0:
        return const Color.fromRGBO(240, 248, 255, 1.0);
      case 1:
        return const Color.fromRGBO(255, 239, 213, 1.0);
      case 2:
        return const Color.fromRGBO(245, 245, 220, 1.0);
      case 3:
        return const Color.fromRGBO(240, 255, 240, 1.0);
      case 4:
        return const Color.fromRGBO(255, 250, 240, 1.0);
      default:
        return const Color.fromRGBO(240, 248, 255, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
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
                      child: const Text('Omitir',
                          style: TextStyle(
                            color: Color.fromARGB(153, 71, 0, 150),
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
                        _backgroundColor = _getBackgroundColor(value);
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
