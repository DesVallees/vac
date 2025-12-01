import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Términos y Condiciones de Uso – Vaq+',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'En Vaq+ trabajamos para cuidar tu salud y la de tu familia.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildHighlightPoint(
                            theme,
                            'Tus datos personales están protegidos y nunca serán compartidos con terceros.',
                          ),
                          const SizedBox(height: 8),
                          _buildHighlightPoint(
                            theme,
                            'Solo trabajamos con vacunas certificadas por INVIMA y aplicadas por médicos autorizados en puntos avalados por nosotros.',
                          ),
                          const SizedBox(height: 8),
                          _buildHighlightPoint(
                            theme,
                            'Puedes reagendar una cita una vez sin costo adicional.',
                          ),
                          const SizedBox(height: 8),
                          _buildHighlightPoint(
                            theme,
                            'Si no asistes por segunda vez, habrá un cargo administrativo de \$20.000 COP.',
                          ),
                          const SizedBox(height: 8),
                          _buildHighlightPoint(
                            theme,
                            'No hay devoluciones, pero tu compra te garantiza el derecho a recibir la vacuna dentro de un año.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Estos Términos y Condiciones explican tus derechos y obligaciones al usar Vaq+. Te invitamos a leerlos con atención.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Section 1
              _buildSection(
                theme,
                '1',
                'Identificación de la empresa',
                'La aplicación Vaq+ es operada por la sociedad LA COMARCA INMUNOBIOLOGÍA S.A.S., identificada con NIT 901.845.877-7, domiciliada en Chía, Cundinamarca, Colombia, correo electrónico de contacto: info@vaqmas.com',
              ),

              // Section 2
              _buildSection(
                theme,
                '2',
                'Objeto del servicio',
                'A través de Vaq+, el usuario puede:\n\n• Comprar vacunas certificadas por INVIMA.\n• Agendar citas para su aplicación en puntos autorizados.\n• Consultar su historial de vacunación registrado en la plataforma.',
              ),

              // Section 3
              _buildSection(
                theme,
                '3',
                'Condiciones de uso',
                '• Solo podrán registrarse usuarios mayores de 18 años.\n• Padres o tutores podrán agendar y comprar vacunas para menores de edad.\n• El uso de la aplicación para fines fraudulentos, reventa de servicios o cualquier conducta ilegal está estrictamente prohibido.\n• Vaq+ se reserva el derecho de suspender cuentas en caso de incumplimiento de estos Términos.',
              ),

              // Section 4
              _buildSection(
                theme,
                '4',
                'Agendamiento, cancelaciones y reprogramaciones',
                '• Una vez realizada la compra, no habrá devoluciones de dinero.\n• El usuario podrá reagendar una vez sin costo si no asiste a la cita inicial.\n• En caso de no asistir nuevamente, deberá pagar un cargo administrativo de \$20.000 COP para reagendar.\n• El derecho a la aplicación de la vacuna caduca al cumplirse un año desde la fecha de compra.',
              ),

              // Section 5
              _buildSection(
                theme,
                '5',
                'Responsabilidad médica y legal',
                '• Todas las vacunas serán aplicadas únicamente por médicos autorizados y en centros avalados por Vaq+.\n\n• Disclaimer médico: La aplicación no sustituye la consulta médica profesional. El usuario debe verificar previamente con su médico cualquier condición de salud especial.\n\n• Vaq+ limita su responsabilidad frente a efectos secundarios inherentes al uso de biológicos, los cuales están regulados y certificados por las autoridades de salud.',
              ),

              // Section 6
              _buildSection(
                theme,
                '6',
                'Privacidad y tratamiento de datos',
                '• Datos recopilados: nombre, edad, género, documento de identidad, correo electrónico, ubicación y datos de pago.\n• No se recopila historial médico completo.\n• Vaq+ no comparte datos con terceros.\n• Todos los datos están protegidos bajo protocolos de seguridad y encriptación.\n• El usuario tiene derecho a solicitar la actualización, corrección o eliminación de sus datos en cualquier momento, escribiendo a info@vaqmas.com.\n• Vaq+ garantiza la confidencialidad, seguridad y uso responsable de la información personal, en cumplimiento de la Ley 1581 de 2012 y demás normas de protección de datos vigentes en Colombia.',
              ),

              // Section 7
              _buildSection(
                theme,
                '7',
                'Propiedad intelectual',
                '• La marca Vaq+ se encuentra registrada.\n• El contenido, diseño, código y funcionamiento de la aplicación son propiedad exclusiva de LA COMARCA INMUNOBIOLOGÍA S.A.S.\n• Queda prohibido el uso, reproducción, distribución o explotación no autorizada de la marca, la app o su contenido.',
              ),

              // Section 8
              _buildSection(
                theme,
                '8',
                'Jurisdicción y resolución de conflictos',
                '• Estos Términos se rigen por las leyes de la República de Colombia.\n• Cualquier controversia será resuelta inicialmente mediante arbitraje en derecho, de acuerdo con la normativa colombiana aplicable.',
              ),

              // Section 9
              _buildSection(
                theme,
                '9',
                'Modificaciones de los Términos y Condiciones',
                '• Vaq+ podrá modificar en cualquier momento los presentes Términos y Condiciones.\n• El usuario será notificado previamente mediante la aplicación o correo electrónico.\n• El uso continuado de la aplicación implica la aceptación de dichas modificaciones.',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightPoint(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 20,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String number,
    String title,
    String content,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

