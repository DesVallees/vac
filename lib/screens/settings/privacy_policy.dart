import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
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
                          Icons.privacy_tip_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Política de Privacidad – Vaq+',
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
                      child: Text(
                        'En Vaq+, operada por LA COMARCA INMUNOBIOLOGÍA S.A.S. (NIT 901.845.877-7), respetamos y protegemos la privacidad de nuestros usuarios. Esta política explica cómo recopilamos, usamos, almacenamos y protegemos tu información personal, así como los derechos que tienes sobre ella.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section 1
              _buildSection(
                theme,
                '1',
                'Introducción',
                'En Vaq+, operada por LA COMARCA INMUNOBIOLOGÍA S.A.S. (NIT 901.845.877-7), respetamos y protegemos la privacidad de nuestros usuarios. Esta política explica cómo recopilamos, usamos, almacenamos y protegemos tu información personal, así como los derechos que tienes sobre ella.',
              ),

              // Section 2
              _buildSection(
                theme,
                '2',
                'Datos que recopilamos',
                'Al registrarte o utilizar nuestros servicios, recopilamos los siguientes datos:\n\n• Nombre completo.\n• Edad y género.\n• Número de identificación (cédula, tarjeta de identidad, registro civil o pasaporte).\n• Correo electrónico.\n• Ubicación (ciudad/municipio y dirección para agendamiento).\n• Datos de pago (procesados a través de plataformas seguras).\n• Información sobre vacunas compradas y aplicadas.\n\nNo recopilamos tu historial médico completo, solo los datos necesarios para la prestación del servicio.',
              ),

              // Section 3
              _buildSection(
                theme,
                '3',
                'Finalidad del tratamiento de datos',
                'Tus datos serán utilizados únicamente para:\n\n• Procesar la compra de vacunas y agendar citas.\n• Mantener actualizado tu historial de vacunación en la app.\n• Enviarte recordatorios de citas y notificaciones relacionadas con tu proceso de vacunación.\n• Ofrecerte recomendaciones personalizadas de vacunas de acuerdo con tu edad y la de tus familiares registrados, facilitando una experiencia más clara, útil y ajustada a las necesidades de tu núcleo familiar.\n• Garantizar el cumplimiento de requisitos legales y regulatorios en materia de salud.\n• Atender solicitudes, quejas o reclamos que realices.',
              ),

              // Section 4
              _buildSection(
                theme,
                '4',
                'Confidencialidad y seguridad de la información',
                '• Vaq+ implementa medidas técnicas y organizativas para garantizar la seguridad de tus datos, incluyendo encriptación y protocolos de acceso restringido.\n\n• Cumplimos con la Ley 1581 de 2012 y el Decreto 1377 de 2013 sobre protección de datos personales en Colombia.\n\n• La información de cadena de frío y trazabilidad de las vacunas es controlada estrictamente para asegurar calidad y confianza.\n\n• Tus datos no se venden ni se comparten con terceros bajo ninguna circunstancia.\n\n• La información recopilada también nos permite ofrecer orientación preventiva y sugerencias de vacunación basadas en tu perfil familiar, para acompañarte en el cuidado integral de tu salud y la de tus seres queridos.',
              ),

              // Section 5
              _buildSection(
                theme,
                '5',
                'Derechos del titular de los datos',
                'De acuerdo con la Ley 1581 de 2012, como usuario de Vaq+ tienes derecho a:\n\n• Acceder a tus datos personales almacenados en nuestra base de datos.\n• Solicitar la corrección, actualización o eliminación de tus datos.\n• Revocar la autorización para el tratamiento de tus datos, siempre que no exista un deber legal o contractual que lo impida.\n• Ser informado sobre el uso que se le da a tu información personal.',
              ),

              // Section 6
              _buildSection(
                theme,
                '6',
                'Procedimiento para ejercer tus derechos',
                'Puedes ejercer tus derechos enviando una solicitud al correo info@vaqmas.com, indicando:\n\n• Tu nombre completo.\n• Número de identificación.\n• Petición específica (acceso, corrección, actualización, eliminación o revocatoria).\n\nEl área responsable de la atención de consultas y reclamos responderá en un plazo máximo de 15 días hábiles.',
              ),

              // Section 7
              _buildSection(
                theme,
                '7',
                'Conservación de la información',
                '• Tus datos se conservarán mientras tengas una cuenta activa en Vaq+ o mientras sean necesarios para cumplir con obligaciones legales y sanitarias.\n\n• Una vez eliminada tu cuenta, la información será bloqueada y posteriormente suprimida de manera segura, salvo cuando la ley exija su conservación.',
              ),

              // Section 8
              _buildSection(
                theme,
                '8',
                'Modificaciones a la Política de Privacidad',
                'Vaq+ podrá modificar esta Política en cualquier momento. Cualquier cambio será notificado oportunamente en la aplicación o a través de correo electrónico.',
              ),

              // Section 9
              _buildSection(
                theme,
                '9',
                'Aceptación',
                'Al registrarte y usar la aplicación Vaq+, aceptas los términos de esta Política de Privacidad.',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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

