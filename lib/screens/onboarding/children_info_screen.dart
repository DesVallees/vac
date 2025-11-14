import 'package:flutter/material.dart';
import 'package:vaq/assets/data_classes/child.dart';

class ChildrenInfoScreen extends StatefulWidget {
  final List<Child> children;
  final Function(Child) onAddChild;
  final Function(int) onRemoveChild;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const ChildrenInfoScreen({
    super.key,
    required this.children,
    required this.onAddChild,
    required this.onRemoveChild,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<ChildrenInfoScreen> createState() => _ChildrenInfoScreenState();
}

class _ChildrenInfoScreenState extends State<ChildrenInfoScreen> {
  bool _hasChildren = false;

  @override
  void initState() {
    super.initState();
    _hasChildren = widget.children.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Información de tus hijos',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Agrega la información de tus hijos para personalizar su experiencia',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Question about having children
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Tienes hijos?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _hasChildren = true;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _hasChildren
                                ? theme.colorScheme.primaryContainer
                                : null,
                            foregroundColor: _hasChildren
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            side: BorderSide(
                              color: _hasChildren
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Sí'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _hasChildren = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !_hasChildren
                                ? theme.colorScheme.primaryContainer
                                : null,
                            foregroundColor: !_hasChildren
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            side: BorderSide(
                              color: !_hasChildren
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('No'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Children list (if they have children)
          if (_hasChildren) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis hijos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FloatingActionButton.small(
                  onPressed: _showAddChildDialog,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.children.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.child_care_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No has agregado ningún hijo',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar uno',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.children.length,
                      itemBuilder: (context, index) {
                        final child = widget.children[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              child: Icon(
                                Icons.child_care,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            title: Text(
                              child.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${child.ageString}${child.gender != null ? ' • ${_genderToString(child.gender!)}' : ''}',
                            ),
                            trailing: IconButton(
                              onPressed: () => widget.onRemoveChild(index),
                              icon: const Icon(Icons.delete_outline),
                              color: theme.colorScheme.error,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care_outlined,
                      size: 64,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay hijos registrados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puedes agregar hijos más tarde desde tu perfil',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _genderToString(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Masculino';
      case Gender.female:
        return 'Femenino';
      case Gender.other:
        return 'Otro';
    }
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AddChildDialog(
        onAddChild: widget.onAddChild,
      ),
    );
  }
}

class AddChildDialog extends StatefulWidget {
  final Function(Child) onAddChild;

  const AddChildDialog({
    super.key,
    required this.onAddChild,
  });

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  Gender? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar hijo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Ej: María José',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date of birth
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Seleccionar fecha',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gender (optional)
              DropdownButtonFormField<Gender>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Género (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: Gender.male, child: Text('Masculino')),
                  DropdownMenuItem(
                      value: Gender.female, child: Text('Femenino')),
                  DropdownMenuItem(value: Gender.other, child: Text('Otro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveChild,
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveChild() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final child = Child(
        id: '', // Will be set when saving to Firestore
        parentId: '', // Will be set when saving to Firestore
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDate!,
        gender: _selectedGender,
        createdAt: DateTime.now(),
      );

      widget.onAddChild(child);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
        ),
      );
    }
  }
}
