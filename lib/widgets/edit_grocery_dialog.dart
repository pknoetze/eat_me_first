import 'package:flutter/material.dart';
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
  DateTime? _expiryDate;
  bool _delivered = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _expiryDate = widget.item.expiryDate;
    _delivered = widget.item.delivered;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!_delivered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only set expiry date for delivered items'),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter item name',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Delivered'),
            value: _delivered,
            onChanged: (value) {
              setState(() {
                _delivered = value;
                if (!value) {
                  // Clear expiry date when unmarking as delivered
                  _expiryDate = null;
                } else {
                  // Set expiry date to today when marking as delivered
                  _expiryDate = DateTime.now();
                }
              });
            },
          ),
          if (_delivered) ...[
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              return;
            }
            final updatedItem = GroceryItem(
              id: widget.item.id,
              name: _nameController.text,
              expiryDate: _delivered ? _expiryDate : null,
              delivered: _delivered,
            );
            Navigator.of(context).pop(updatedItem);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
