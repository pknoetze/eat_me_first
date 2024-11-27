import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../models/dashboard_data.dart';
import '../models/filter_option.dart';
import '../models/sort_option.dart';
import '../services/grocery_service.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/grocery_list.dart';
import '../widgets/add_grocery_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GroceryService _groceryService = GroceryService();
  List<GroceryItem> _items = [];
  List<GroceryItem> _filteredItems = [];
  DashboardData _stats = DashboardData.empty();
  FilterOption? _activeFilter;
  SortOption _currentSort = SortOption.expiryDate;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _groceryService.init();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _items = _groceryService.getAllItems();
      _stats = _calculateStats();
      _filteredItems = _getFilteredItems();
    });
  }

  DashboardData _calculateStats() {
    int expired = 0;
    int expiringToday = 0;
    int expiringTomorrow = 0;
    int expiringThisWeek = 0;
    int tracked = 0;

    for (final item in _items) {
      if (item.trackingEnabled) {
        tracked++;
      }
      
      // Skip items without expiry dates
      if (item.expiryDate == null) {
        continue;
      }

      if (item.isExpired()) {
        expired++;
        continue;
      }

      final daysUntilExpiry = item.daysUntilExpiry;
      if (daysUntilExpiry == 0) {
        expiringToday++;
      } else if (daysUntilExpiry == 1) {
        expiringTomorrow++;
      } else if (daysUntilExpiry <= 7 && daysUntilExpiry > 1) {
        expiringThisWeek++;
      }
    }

    return DashboardData(
      expiredCount: expired,
      expiringTodayCount: expiringToday,
      expiringTomorrowCount: expiringTomorrow,
      expiringThisWeekCount: expiringThisWeek,
      deliveredCount: tracked,
    );
  }

  List<GroceryItem> _getFilteredItems() {
    List<GroceryItem> filtered = List.from(_items);

    // Apply filter
    if (_activeFilter != null) {
      filtered = filtered.where((item) {
        switch (_activeFilter!) {
          case FilterOption.expired:
            return item.isExpired();
          case FilterOption.today:
            return item.expiryDate != null && item.daysUntilExpiry == 0;
          case FilterOption.tomorrow:
            return item.expiryDate != null && item.daysUntilExpiry == 1;
          case FilterOption.thisWeek:
            return item.expiryDate != null && item.daysUntilExpiry > 1 && item.daysUntilExpiry <= 7;
          case FilterOption.delivered:
            return item.trackingEnabled;
        }
      }).toList();
    }

    // Apply sort
    filtered.sort((a, b) {
      int compare;
      switch (_currentSort) {
        case SortOption.name:
          compare = a.name.compareTo(b.name);
          break;
        case SortOption.expiryDate:
          if (a.expiryDate == null && b.expiryDate == null) {
            compare = 0;
          } else if (a.expiryDate == null) {
            compare = 1;
          } else if (b.expiryDate == null) {
            compare = -1;
          } else {
            compare = a.expiryDate!.compareTo(b.expiryDate!);
          }
          break;
      }
      return _sortAscending ? compare : -compare;
    });

    return filtered;
  }

  void _applyFilter(FilterOption? filter) {
    setState(() {
      _activeFilter = filter;
      _filteredItems = _getFilteredItems();
    });
  }

  void _changeSortOption(SortOption option) {
    setState(() {
      if (_currentSort == option) {
        _sortAscending = !_sortAscending;
      } else {
        _currentSort = option;
        _sortAscending = true;
      }
      _filteredItems = _getFilteredItems();
    });
  }

  Future<void> _addItem(GroceryItem item) async {
    await _groceryService.addItem(item);
    _refreshData();
  }

  Future<void> _deleteItem(GroceryItem item) async {
    await _groceryService.deleteItem(item.id);
    _refreshData();
  }

  Future<void> _toggleDelivered(GroceryItem item) async {
    await _groceryService.toggleDeliveryStatus(item);
    _refreshData();
  }

  Future<void> _updateItem(GroceryItem item) async {
    await _groceryService.updateItem(item);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eat Me First'),
        elevation: 0,
        actions: [
          PopupMenuButton<SortOption>(
            icon: Icon(
              Icons.sort,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Sort items',
            initialValue: _currentSort,
            onSelected: _changeSortOption,
            itemBuilder: (context) => [
              for (final option in SortOption.values)
                PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        _currentSort == option
                            ? _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward
                            : Icons.sort,
                        size: 20,
                        color: _currentSort == option
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(option.label),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddGroceryDialog(
              onAdd: _addItem,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
              child: DashboardStats(
                stats: _stats,
                activeFilter: _activeFilter,
                onFilterChanged: _applyFilter,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 24.0 : 16.0,
                ),
                child: GroceryList(
                  items: _filteredItems,
                  onDelete: _deleteItem,
                  onDeliveredToggle: _toggleDelivered,
                  onItemUpdated: _updateItem,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
