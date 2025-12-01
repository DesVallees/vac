import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vaq/providers/cart_provider.dart';
import 'package:vaq/assets/data_classes/product.dart';
import 'package:vaq/assets/data_classes/location.dart';
import 'package:vaq/services/dynamic_location_repository.dart';
import 'package:vaq/services/dynamic_appointment_repository.dart';
import 'package:vaq/services/image_service.dart';
import 'package:vaq/assets/helpers/holidays.dart';
import 'package:vaq/screens/cart/checkout.dart';
import 'package:vaq/providers/bottom_navigation_bar_provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final DynamicLocationRepository _locationRepository =
      DynamicLocationRepository();
  final DynamicAppointmentRepository _appointmentRepository =
      DynamicAppointmentRepository();

  String? _expandedItemId; // Track which item's appointment section is expanded
  Map<String, Location?> _selectedLocations = {}; // location per cart item
  Map<String, DateTime?> _selectedDates = {}; // date per cart item
  Map<String, DateTime?> _selectedTimeSlots = {}; // time slot per cart item
  Map<String, List<DateTime>> _availableTimeSlots = {}; // available slots per cart item
  Map<String, bool> _loadingTimeSlots = {}; // loading state per cart item
  Map<String, List<Location>> _availableLocations = {}; // locations per cart item
  bool _isValidatingAppointments = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _validateAppointmentsOnEntry();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _locationRepository.getLocations();
      setState(() {
        // Store locations for all items (same locations for all)
        for (final itemId in context.read<CartProvider>().items.map((i) => i.cartItemId)) {
          _availableLocations[itemId] = locations;
        }
      });
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  Future<void> _validateAppointmentsOnEntry() async {
    final cartProvider = context.read<CartProvider>();
    setState(() {
      _isValidatingAppointments = true;
    });

    await cartProvider.validateAllAppointments();

    if (mounted) {
      setState(() {
        _isValidatingAppointments = false;
      });
    }
  }

  Future<void> _loadAvailableTimeSlots(String cartItemId, DateTime date, Location location, Product product) async {
    setState(() {
      _loadingTimeSlots[cartItemId] = true;
      _availableTimeSlots[cartItemId] = [];
    });

    try {
      final bookedSlots = await _appointmentRepository
          .getBookedAppointmentsForLocationAndDate(location.id, date);

      // Generate all possible time slots (9 AM to 6 PM, every 30 minutes)
      final List<DateTime> allSlots = [];
      DateTime startTime = DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
      final DateTime endTime = DateTime(date.year, date.month, date.day, 18, 0); // 6:00 PM

      final now = DateTime.now();

      while (startTime.isBefore(endTime)) {
        // Skip lunch break (13:00 and 13:30)
        if (startTime.hour == 13) {
          startTime = startTime.add(const Duration(minutes: 30));
          continue;
        }
        // Don't add slots in the past
        if (startTime.isAfter(now)) {
          allSlots.add(startTime);
        }
        startTime = startTime.add(const Duration(minutes: 30));
      }

      // Determine duration based on product type
      Duration slotDuration = const Duration(minutes: 30);
      if (product is Consultation) {
        slotDuration = product.typicalDuration;
      }

      // Filter out conflicting slots
      final List<DateTime> availableSlots = [];
      for (final slot in allSlots) {
        bool isAvailable = true;
        final slotEnd = slot.add(slotDuration);

        for (final bookedSlot in bookedSlots) {
          final bookedStart = bookedSlot.dateTime;
          final bookedEnd = bookedSlot.endTime;

          if (slot.isBefore(bookedEnd) && slotEnd.isAfter(bookedStart)) {
            isAvailable = false;
            break;
          }
        }

        if (isAvailable) {
          availableSlots.add(slot);
        }
      }

      if (mounted) {
        setState(() {
          _availableTimeSlots[cartItemId] = availableSlots;
          _loadingTimeSlots[cartItemId] = false;
          
          // Verify the currently selected time slot still exists in available slots
          final currentSelectedSlot = _selectedTimeSlots[cartItemId];
          if (currentSelectedSlot != null) {
            // Check if the selected slot exists in the available slots
            final slotExists = availableSlots.any((slot) =>
                slot.year == currentSelectedSlot.year &&
                slot.month == currentSelectedSlot.month &&
                slot.day == currentSelectedSlot.day &&
                slot.hour == currentSelectedSlot.hour &&
                slot.minute == currentSelectedSlot.minute);
            
            if (!slotExists) {
              // Slot no longer available, clear selection
              _selectedTimeSlots[cartItemId] = null;
            } else {
              // Find and set the exact matching slot from the list
              final matchingSlot = availableSlots.firstWhere((slot) =>
                  slot.year == currentSelectedSlot.year &&
                  slot.month == currentSelectedSlot.month &&
                  slot.day == currentSelectedSlot.day &&
                  slot.hour == currentSelectedSlot.hour &&
                  slot.minute == currentSelectedSlot.minute);
              _selectedTimeSlots[cartItemId] = matchingSlot;
            }
          }
        });
      }
    } catch (e) {
      print('Error loading time slots: $e');
      if (mounted) {
        setState(() {
          _availableTimeSlots[cartItemId] = [];
          _loadingTimeSlots[cartItemId] = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, String cartItemId, Product product) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final holidays = ColombianHolidays.getHolidays(year: today.year);

    bool isDateSelectable(DateTime date) {
      if (date.weekday < DateTime.monday || date.weekday > DateTime.friday) {
        return false;
      }
      final normalized = DateTime.utc(date.year, date.month, date.day);
      return !holidays.contains(normalized);
    }

    DateTime initialDate = today;
    if (_selectedDates[cartItemId] != null && isDateSelectable(_selectedDates[cartItemId]!)) {
      initialDate = _selectedDates[cartItemId]!;
    } else {
      while (!isDateSelectable(initialDate)) {
        initialDate = initialDate.add(const Duration(days: 1));
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startOfToday,
      lastDate: today.add(const Duration(days: 180)),
      locale: const Locale('es', 'ES'),
      selectableDayPredicate: isDateSelectable,
    );

    if (picked != null) {
      setState(() {
        _selectedDates[cartItemId] = picked;
        _selectedTimeSlots[cartItemId] = null;
      });

      final location = _selectedLocations[cartItemId];
      if (location != null) {
        _loadAvailableTimeSlots(cartItemId, picked, location, product);
      }
    }
  }

  void _onLocationSelected(String cartItemId, Location? location, Product product) {
    setState(() {
      _selectedLocations[cartItemId] = location;
      _selectedTimeSlots[cartItemId] = null;
    });

    final date = _selectedDates[cartItemId];
    if (date != null && location != null) {
      _loadAvailableTimeSlots(cartItemId, date, location, product);
    }
  }

  void _onTimeSlotSelected(String cartItemId, DateTime? timeSlot) {
    setState(() {
      _selectedTimeSlots[cartItemId] = timeSlot;
    });
  }

  void _confirmAppointment(String cartItemId) {
    final location = _selectedLocations[cartItemId];
    final timeSlot = _selectedTimeSlots[cartItemId];

    if (location == null || timeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos.'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      return;
    }

    final cartProvider = context.read<CartProvider>();
    cartProvider.setAppointmentForItem(
      cartItemId,
      timeSlot,
      location.id,
      location.name,
    );

    setState(() {
      _expandedItemId = null;
      _selectedLocations[cartItemId] = null;
      _selectedDates[cartItemId] = null;
      _selectedTimeSlots[cartItemId] = null;
    });
  }

  void _cancelAppointmentScheduling(String cartItemId) {
    setState(() {
      _expandedItemId = null;
      _selectedLocations[cartItemId] = null;
      _selectedDates[cartItemId] = null;
      _selectedTimeSlots[cartItemId] = null;
    });
  }

  void _toggleExpanded(String cartItemId) {
    setState(() {
      if (_expandedItemId == cartItemId) {
        _expandedItemId = null;
      } else {
        _expandedItemId = cartItemId;
      }
    });

    // Load locations if not already loaded for this item
    if (!_availableLocations.containsKey(cartItemId) || _availableLocations[cartItemId]!.isEmpty) {
      _locationRepository.getLocations().then((locations) {
        if (mounted) {
          setState(() {
            _availableLocations[cartItemId] = locations;
          });
        }
      });
    }
  }

  /// Expand appointment section and pre-populate with existing appointment details
  void _toggleExpandedWithExistingAppointment(String cartItemId, CartItem item) {
    setState(() {
      if (_expandedItemId == cartItemId) {
        // Collapse if already expanded
        _expandedItemId = null;
        _selectedLocations[cartItemId] = null;
        _selectedDates[cartItemId] = null;
        _selectedTimeSlots[cartItemId] = null;
      } else {
        // Expand
        _expandedItemId = cartItemId;
        
        // Pre-populate with existing appointment details
        if (item.appointmentDate != null) {
          final appointmentDate = item.appointmentDate!;
          _selectedDates[cartItemId] = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
          );
          // Normalize time slot to hours and minutes only (remove seconds/milliseconds)
          _selectedTimeSlots[cartItemId] = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
            appointmentDate.hour,
            appointmentDate.minute,
          );
        }
      }
    });

    // Load locations if not already loaded
    if (!_availableLocations.containsKey(cartItemId) || _availableLocations[cartItemId]!.isEmpty) {
      _locationRepository.getLocations().then((locations) {
        if (mounted) {
          setState(() {
            _availableLocations[cartItemId] = locations;
            
            // Pre-select the location if it exists
            if (item.locationId != null && locations.isNotEmpty) {
              try {
                final location = locations.firstWhere(
                  (loc) => loc.id == item.locationId,
                );
                _selectedLocations[cartItemId] = location;
                
                // Load time slots if date is already set
                if (_selectedDates[cartItemId] != null) {
                  _loadAvailableTimeSlots(
                    cartItemId,
                    _selectedDates[cartItemId]!,
                    location,
                    item.product,
                  );
                }
              } catch (e) {
                // Location not found, select first available
                if (locations.isNotEmpty) {
                  _selectedLocations[cartItemId] = locations.first;
                  if (_selectedDates[cartItemId] != null) {
                    _loadAvailableTimeSlots(
                      cartItemId,
                      _selectedDates[cartItemId]!,
                      locations.first,
                      item.product,
                    );
                  }
                }
              }
            }
          });
        }
      });
    } else {
      // Locations already loaded, pre-select the location
      final locations = _availableLocations[cartItemId]!;
      if (item.locationId != null && locations.isNotEmpty) {
        try {
          final location = locations.firstWhere(
            (loc) => loc.id == item.locationId,
          );
          _selectedLocations[cartItemId] = location;
          
          // Load time slots if date is already set
          if (_selectedDates[cartItemId] != null) {
            _loadAvailableTimeSlots(
              cartItemId,
              _selectedDates[cartItemId]!,
              location,
              item.product,
            );
          }
        } catch (e) {
          // Location not found, select first available
          if (locations.isNotEmpty) {
            _selectedLocations[cartItemId] = locations.first;
            if (_selectedDates[cartItemId] != null) {
              _loadAvailableTimeSlots(
                cartItemId,
                _selectedDates[cartItemId]!,
                locations.first,
                item.product,
              );
            }
          }
        }
      }
    }
  }

  String _getProductType(Product product) {
    if (product is Vaccine) return 'vaccine';
    if (product is DoseBundle) return 'bundle';
    if (product is Consultation) return 'consultation';
    return 'default';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final items = cartProvider.items;

        if (items.isEmpty) {
          return _buildEmptyState();
        }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_cart,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Carrito',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${items.length} ${items.length == 1 ? 'producto' : 'productos'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (_isValidatingAppointments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Verificando disponibilidad de citas...',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Product cards
                        ...items.map((item) => _buildProductCard(context, item, cartProvider)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
              // Checkout button
              _buildCheckoutSection(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega productos desde la tienda',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BottomNavigationBarProvider>().navigateTo(0);
              },
              icon: const Icon(Icons.store),
              label: const Text('Explorar Tienda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, CartItem item, CartProvider cartProvider) {
    final theme = Theme.of(context);
    final isExpanded = _expandedItemId == item.cartItemId;
    final hasAppointment = item.appointmentDate != null;
    final isUnavailable = item.isAvailable == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isUnavailable
            ? Border.all(color: theme.colorScheme.error, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageService.getNetworkImage(
                    fileName: item.product.imageUrl,
                    type: _getProductType(item.product),
                    fit: BoxFit.cover,
                    fallbackSize: 60.0,
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.commonName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                                locale: 'es_CO', symbol: '\$', decimalDigits: 0)
                            .format(item.product.price ?? 0),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Quantity controls
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (item.quantity > 1) {
                                cartProvider.updateQuantity(item.cartItemId, item.quantity - 1);
                              } else {
                                cartProvider.removeFromCart(item.cartItemId);
                              }
                            },
                            iconSize: 20,
                          ),
                          Text(
                            '${item.quantity}',
                            style: theme.textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              cartProvider.updateQuantity(item.cartItemId, item.quantity + 1);
                            },
                            iconSize: 20,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: theme.colorScheme.error,
                            onPressed: () {
                              cartProvider.removeFromCart(item.cartItemId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Appointment section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnavailable
                  ? theme.colorScheme.errorContainer.withOpacity(0.3)
                  : hasAppointment
                      ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                      : null,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUnavailable) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta cita ya no está disponible. Por favor, reagenda.',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (hasAppointment && !isUnavailable)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cita: ${DateFormat('d MMMM, y', 'es_ES').format(item.appointmentDate!)} ${DateFormat.jm('es_ES').format(item.appointmentDate!)} - ${item.locationName}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _toggleExpandedWithExistingAppointment(item.cartItemId, item);
                        },
                        child: const Text('Modificar'),
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () => _toggleExpanded(item.cartItemId),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Escoger fecha y hora'),
                  ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildAppointmentSchedulingSection(item),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSchedulingSection(CartItem item) {
    final theme = Theme.of(context);
    final locations = _availableLocations[item.cartItemId] ?? [];
    final selectedLocation = _selectedLocations[item.cartItemId];
    final selectedDate = _selectedDates[item.cartItemId];
    final selectedTimeSlot = _selectedTimeSlots[item.cartItemId];
    final availableSlots = _availableTimeSlots[item.cartItemId] ?? [];
    final isLoading = _loadingTimeSlots[item.cartItemId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location selector
        Text(
          'Selecciona un punto de vacunación',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Location>(
          value: selectedLocation,
          hint: const Text('Selecciona una clínica...'),
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
          items: locations.map((location) {
            return DropdownMenuItem<Location>(
              value: location,
              child: Text(location.name),
            );
          }).toList(),
          onChanged: (location) => _onLocationSelected(item.cartItemId, location, item.product),
        ),
        const SizedBox(height: 16),
        // Date selector
        Text(
          'Selecciona una Fecha',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, item.cartItemId, item.product),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? DateFormat('EEEE, d MMMM y', 'es_ES').format(selectedDate)
                      : 'Selecciona una fecha...',
                  style: TextStyle(
                    color: selectedDate != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedDate != null && selectedLocation != null) ...[
          const SizedBox(height: 16),
          // Time slot selector
          Text(
            'Selecciona una Hora',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cargando horarios disponibles...',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else if (availableSlots.isEmpty)
            Text(
              'No hay horarios disponibles para esta fecha.',
              style: TextStyle(color: theme.colorScheme.tertiary),
            )
          else
            DropdownButtonFormField<DateTime>(
              value: selectedTimeSlot,
              hint: const Text('Selecciona hora...'),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              items: availableSlots.map((timeSlot) {
                return DropdownMenuItem<DateTime>(
                  value: timeSlot,
                  child: Text(DateFormat.jm('es_ES').format(timeSlot)),
                );
              }).toList(),
              onChanged: (timeSlot) => _onTimeSlotSelected(item.cartItemId, timeSlot),
            ),
        ],
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelAppointmentScheduling(item.cartItemId),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmAppointment(item.cartItemId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cartProvider) {
    final itemsWithAppointments = cartProvider.getItemsWithAppointments();
    final total = cartProvider.getTotalForItemsWithAppointments();
    final canCheckout = itemsWithAppointments.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
                    .format(total),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (!canCheckout)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Agenda al menos una cita para proceder al pago',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canCheckout
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Checkout(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Proceder al Pago'),
            ),
          ),
        ],
      ),
    );
  }
}

