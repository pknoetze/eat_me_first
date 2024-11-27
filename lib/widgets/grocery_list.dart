import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';
import '../widgets/edit_grocery_dialog.dart';

class GroceryList extends StatelessWidget {
  final List<GroceryItem> items;
  final Function(GroceryItem) onDelete;
  final Function(GroceryItem) onDeliveredToggle;
  final Function(GroceryItem) onItemUpdated;

  const GroceryList({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onDeliveredToggle,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No groceries yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some items to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        
        if (isLargeScreen) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildGroceryCard(context, items[index]),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => _buildGroceryItem(context, items[index]),
        );
      },
    );
  }

  Widget _buildGroceryCard(BuildContext context, GroceryItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final updatedItem = await showDialog<GroceryItem>(
            context: context,
            builder: (context) => EditGroceryDialog(item: item),
          );
          if (updatedItem != null) {
            onItemUpdated(updatedItem);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.expiryDate != null 
                        ? 'Expires: ${_formatDate(item.expiryDate!)}'
                        : 'No expiry date set',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.delivered)
                Icon(
                  Icons.check_circle,
                  color: Colors.green[400],
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      onDeliveredToggle(item);
                      break;
                    case 'delete':
                      onDelete(item);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          item.delivered ? Icons.remove_circle_outline : Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(item.delivered ? 'Mark as Not Delivered' : 'Mark as Delivered'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroceryItem(BuildContext context, GroceryItem item) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16.0),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Item'),
              content: Text('Are you sure you want to delete ${item.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        } else {
          onDeliveredToggle(item);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete(item);
        }
      },
      child: ListTile(
        title: Text(
          item.name,
        ),
        subtitle: Text(
          item.expiryDate != null 
            ? 'Expires: ${_formatDate(item.expiryDate!)}'
            : 'No expiry date set',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(
              item.delivered ? 0.5 : 0.7,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.delivered)
              const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () async {
          final updatedItem = await showDialog<GroceryItem>(
            context: context,
            builder: (context) => EditGroceryDialog(item: item),
          );
          if (updatedItem != null) {
            onItemUpdated(updatedItem);
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM y').format(date);
  }
}
