import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';

class EditGroceryDialog extends StatefulWidget {
  final GroceryItem item;

  const EditGroceryDialog({
    super.key,
    required this.item,
  });

  @override
  State<EditGroceryDialog> createState() => _EditGroceryDialogState();
}

class _EditGroceryDialogState extends State<EditGroceryDialog> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  DateTime? _expiryDate;
  bool _trackingEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _expiryDate = widget.item.expiryDate;
    _trackingEnabled = widget.item.trackingEnabled;
  }

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
    return AlertDialog(
      title: const Text('Edit Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter item name',
                errorStyle: TextStyle(height: 0.8),
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Tracking'),
              subtitle: const Text('Track expiry date for this item'),
              value: _trackingEnabled,
              onChanged: (value) {
                setState(() {
                  _trackingEnabled = value;
                  if (!value) {
                    // Clear expiry date when disabling tracking
                    _expiryDate = null;
                  } else {
                    // Set expiry date to today when enabling tracking
                    _expiryDate = DateTime.now();
                  }
                });
              },
            ),
            if (_trackingEnabled) ...[
              const SizedBox(height: 8),
              const Text(
                'Set the date to either:\n'
                '• Product\'s expiry date (if available)\n'
                '• Delivery date\n'
                '• Any custom date\n'
                'Default is today\'s date',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(_expiryDate != null
                        ? 'Expiry: ${_formatDate(_expiryDate!)}'
                        : 'No expiry date set'),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                  if (_expiryDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _expiryDate = null;
                        });
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedItem = GroceryItem(
                id: widget.item.id,
                name: _nameController.text.trim(),
                expiryDate: _trackingEnabled ? _expiryDate : null,
                trackingEnabled: _trackingEnabled,
              );
              Navigator.of(context).pop(updatedItem);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
