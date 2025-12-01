import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? _expandedIndex;

  final List<FAQItem> _faqs = [
    FAQItem(
      category: 'Carrito y Compras',
      question: '¿Cómo agrego productos al carrito?',
      answer:
          'Puedes agregar productos al carrito desde la tienda tocando el ícono de carrito en cualquier producto, o desde la página de detalles del producto usando el botón "Agregar al Carrito". Los programas de vacunación completos no pueden agregarse directamente, pero puedes agregar los paquetes individuales que los componen.',
    ),
    FAQItem(
      category: 'Carrito y Compras',
      question: '¿Puedo agregar programas de vacunación completos al carrito?',
      answer:
          'No, los programas de vacunación completos no se pueden agregar directamente al carrito. Sin embargo, puedes agregar los paquetes individuales (bundles) que forman parte de estos programas desde la página de detalles del programa.',
    ),
    FAQItem(
      category: 'Carrito y Compras',
      question: '¿Cómo agendo citas para los productos en mi carrito?',
      answer:
          'En la pantalla del carrito, cada producto tiene un botón "Escoger fecha y hora". Al tocarlo, puedes seleccionar la clínica, la fecha y la hora para cada producto. Debes agendar al menos una cita para poder proceder al pago.',
    ),
    FAQItem(
      category: 'Carrito y Compras',
      question: '¿Puedo modificar una cita que ya agendé en el carrito?',
      answer:
          'Sí, si un producto ya tiene una cita agendada, verás un botón "Modificar" que te permite cambiar la clínica, fecha u hora. Si la cita ya no está disponible, verás una advertencia y podrás reagendarla.',
    ),
    FAQItem(
      category: 'Carrito y Compras',
      question: '¿Cómo funciona el pago?',
      answer:
          'Puedes elegir entre dos opciones de pago:\n\n• Pagar Ahora: Realiza el pago con tarjeta de crédito o débito directamente desde la app.\n• Pagar en Clínica: Pagarás cuando recibas el servicio en la clínica.\n\nSolo puedes pagar por los productos que tienen una cita agendada.',
    ),
    FAQItem(
      category: 'Agendamiento',
      question: '¿Qué horarios están disponibles para agendar?',
      answer:
          'Las citas están disponibles de lunes a viernes, de 9:00 AM a 6:00 PM, con intervalos de 30 minutos. No hay citas durante el horario de almuerzo (1:00 PM - 1:30 PM). Las citas solo pueden agendarse en días hábiles (no festivos).',
    ),
    FAQItem(
      category: 'Agendamiento',
      question: '¿Puedo reagendar una cita?',
      answer:
          'Sí, puedes reagendar una cita una vez sin costo adicional si no puedes asistir a la cita inicial. Si no asistes por segunda vez, se aplicará un cargo administrativo de \$20.000 COP para reagendar.',
    ),
    FAQItem(
      category: 'Agendamiento',
      question: '¿Qué pasa si no asisto a mi cita?',
      answer:
          'Si no asistes a tu cita por primera vez, puedes reagendarla sin costo. Si no asistes nuevamente, deberás pagar un cargo administrativo de \$20.000 COP para reagendar. Recuerda que tu derecho a la aplicación de la vacuna caduca al cumplirse un año desde la fecha de compra.',
    ),
    FAQItem(
      category: 'Productos',
      question: '¿Las vacunas están certificadas?',
      answer:
          'Sí, todas las vacunas disponibles en Vaq+ están certificadas por INVIMA (Instituto Nacional de Vigilancia de Medicamentos y Alimentos) y solo trabajamos con vacunas aplicadas por médicos autorizados en puntos de vacunación avalados por nosotros.',
    ),
    FAQItem(
      category: 'Productos',
      question: '¿Qué tipos de productos puedo comprar?',
      answer:
          'Puedes comprar:\n\n• Vacunas individuales\n• Paquetes de vacunas (bundles) para etapas específicas\n• Consultas médicas\n\nLos programas de vacunación completos se muestran para información, pero debes agregar los paquetes individuales al carrito.',
    ),
    FAQItem(
      category: 'Productos',
      question: '¿Puedo comprar vacunas para mis hijos?',
      answer:
          'Sí, si eres padre o tutor, puedes agregar perfiles de menores de edad en tu cuenta y comprar vacunas para ellos. Las recomendaciones de vacunas se ajustarán automáticamente según la edad de cada niño.',
    ),
    FAQItem(
      category: 'Reembolsos y Devoluciones',
      question: '¿Puedo devolver una compra?',
      answer:
          'No hay devoluciones de dinero una vez realizada la compra. Sin embargo, tu compra te garantiza el derecho a recibir la vacuna dentro de un año desde la fecha de compra.',
    ),
    FAQItem(
      category: 'Reembolsos y Devoluciones',
      question: '¿Cuánto tiempo tengo para usar mi compra?',
      answer:
          'Tu compra te garantiza el derecho a recibir la vacuna dentro de un año desde la fecha de compra. Después de ese período, el derecho caduca.',
    ),
    FAQItem(
      category: 'Cuenta y Perfil',
      question: '¿Cómo agrego un hijo a mi perfil?',
      answer:
          'Ve a tu perfil, desplázate hasta la sección de niños y toca el botón para agregar un nuevo hijo. Necesitarás proporcionar información como nombre, fecha de nacimiento y otros datos relevantes.',
    ),
    FAQItem(
      category: 'Cuenta y Perfil',
      question: '¿Para qué sirven las recomendaciones personalizadas?',
      answer:
          'Las recomendaciones personalizadas te muestran vacunas y programas adecuados para cada hijo basándose en su edad, alergias registradas y vacunas previas. Esto facilita encontrar las vacunas más apropiadas para cada miembro de tu familia.',
    ),
    FAQItem(
      category: 'Seguridad y Privacidad',
      question: '¿Mis datos están seguros?',
      answer:
          'Sí, tus datos personales están protegidos y nunca serán compartidos con terceros. Utilizamos encriptación y protocolos de seguridad para proteger tu información. Puedes revisar nuestra Política de Privacidad completa en la sección de Configuración.',
    ),
    FAQItem(
      category: 'Seguridad y Privacidad',
      question: '¿Cómo puedo eliminar mis datos?',
      answer:
          'Puedes solicitar la eliminación de tus datos en cualquier momento enviando un correo a info@vaqmas.com con tu nombre completo, número de identificación y la petición específica. Responderemos en un plazo máximo de 15 días hábiles.',
    ),
    FAQItem(
      category: 'Problemas Técnicos',
      question: 'Mi carrito se vació al cerrar la app',
      answer:
          'Los productos en tu carrito se guardan automáticamente. Si no aparecen, verifica que hayas iniciado sesión correctamente. Si el problema persiste, contacta a soporte.',
    ),
    FAQItem(
      category: 'Problemas Técnicos',
      question: 'Una cita que agendé ya no está disponible',
      answer:
          'Si una cita ya no está disponible (porque alguien más la reservó), verás una advertencia en tu carrito. Puedes usar el botón "Modificar" para reagendarla con una nueva fecha y hora disponible.',
    ),
    FAQItem(
      category: 'Problemas Técnicos',
      question: '¿Qué hago si tengo problemas con el pago?',
      answer:
          'Si experimentas problemas durante el proceso de pago, verifica tu conexión a internet y los datos de tu tarjeta. Si el problema persiste, contacta a soporte técnico o escribe a info@vaqmas.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = _faqs.map((faq) => faq.category).toSet().toList();
    categories.sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes'),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: categories.length,
          itemBuilder: (context, categoryIndex) {
            final category = categories[categoryIndex];
            final categoryFAQs = _faqs.where((faq) => faq.category == category).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 16,
                    top: categoryIndex > 0 ? 24 : 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // FAQ items in this category
                ...categoryFAQs.asMap().entries.map((entry) {
                  final index = _faqs.indexOf(entry.value);
                  final faq = entry.value;
                  final isExpanded = _expandedIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        leading: Icon(
                          Icons.help_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          faq.question,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: theme.colorScheme.primary,
                        ),
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _expandedIndex = expanded ? index : null;
                          });
                        },
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                faq.answer,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FAQItem {
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

