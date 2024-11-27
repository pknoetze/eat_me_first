import 'package:flutter/material.dart';
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
  DateTime? _expiryDate;
  bool _delivered = false;

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
      title: const Text('Add Grocery Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              hintText: 'Enter item name',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
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
                      ? 'Expiry: ${_expiryDate!.year}-${_expiryDate!.month}-${_expiryDate!.day}'
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
            final item = GroceryItem(
              name: _nameController.text,
              expiryDate: _delivered ? _expiryDate : null,
              delivered: _delivered,
            );
            widget.onAdd(item);
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
