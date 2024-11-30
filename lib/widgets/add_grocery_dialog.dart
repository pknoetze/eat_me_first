import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import
import '../models/grocery_item.dart';

class AddGroceryDialog extends StatefulWidget {
  final Function(GroceryItem) onAdd;

  const AddGroceryDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddGroceryDialog> createState() => _AddGroceryDialogState();
}

class _AddGroceryDialogState extends State<AddGroceryDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _expiryDate;
  bool _trackingEnabled = false;

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMM y').format(date);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!_trackingEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only set expiry date when tracking is enabled'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Item',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Item Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                    errorStyle: const TextStyle(height: 0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Tracking Switch
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text('Track Expiry Date'),
                    value: _trackingEnabled,
                    onChanged: (value) {
                      setState(() {
                        _trackingEnabled = value;
                        if (!value) {
                          _expiryDate = null;
                        } else {
                          _expiryDate = DateTime.now();
                        }
                      });
                    },
                  ),
                ),
                
                // Date Selection Section
                if (_trackingEnabled) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Expiry Date',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _expiryDate != null
                                  ? _formatDate(_expiryDate!)
                                  : 'Select date',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          if (_expiryDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _expiryDate = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Set to product expiry date or delivery date',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final item = GroceryItem(
                            name: _nameController.text.trim(),
                            expiryDate: _trackingEnabled ? _expiryDate : null,
                            trackingEnabled: _trackingEnabled,
                          );
                          widget.onAdd(item);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
