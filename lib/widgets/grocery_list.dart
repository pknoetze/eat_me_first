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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.green[200]
                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No groceries yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some items to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
    final isExpired = item.trackingEnabled && item.isExpired();
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isExpired ? BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ) : BorderSide.none,
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
              if (isExpired)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.warning_rounded,
                    color: theme.colorScheme.error,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isExpired ? theme.colorScheme.error : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.expiryDate != null 
                        ? '${isExpired ? "Expired" : "Expires"}: ${_formatDate(item.expiryDate!)}'
                        : 'Expiry tracking disabled',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isExpired 
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.trackingEnabled && !isExpired)
                Icon(
                  Icons.track_changes,
                  color: Colors.green[400],
                ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, 
                  color: isExpired ? theme.colorScheme.error : null
                ),
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
                          item.trackingEnabled ? Icons.notifications_off : Icons.notifications,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(item.trackingEnabled ? 'Disable Tracking' : 'Enable Tracking'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
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
    final isExpired = item.trackingEnabled && item.isExpired();
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16.0),
        child: const Icon(Icons.track_changes, color: Colors.white),
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
      child: Container(
        decoration: BoxDecoration(
          border: isExpired ? Border(
            left: BorderSide(
              color: theme.colorScheme.error,
              width: 4,
            ),
          ) : null,
        ),
        child: ListTile(
          leading: isExpired 
            ? Icon(
                Icons.warning_rounded,
                color: theme.colorScheme.error,
              )
            : null,
          title: Text(
            item.name,
            style: TextStyle(
              color: isExpired ? theme.colorScheme.error : null,
            ),
          ),
          subtitle: Text(
            item.expiryDate != null 
              ? '${isExpired ? "Expired" : "Expires"}: ${_formatDate(item.expiryDate!)}'
              : 'Expiry tracking disabled',
            style: TextStyle(
              color: isExpired 
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.trackingEnabled && !isExpired)
                const Icon(Icons.track_changes, color: Colors.green),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isExpired ? theme.colorScheme.error : null,
              ),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMM y').format(date);
  }
}
