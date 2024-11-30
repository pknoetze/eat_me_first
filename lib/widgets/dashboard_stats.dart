import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/filter_option.dart';

class DashboardStats extends StatelessWidget {
  final DashboardData stats;
  final FilterOption? activeFilter;
  final Function(FilterOption?) onFilterChanged;

  const DashboardStats({
    Key? key,
    required this.stats,
    required this.activeFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useGrid = constraints.maxWidth > 700;
          
          final statCards = [
            _StatCard(
              label: 'Expired',
              value: stats.expiredCount.toString(),
              icon: Icons.warning_rounded,
              isActive: activeFilter == FilterOption.expired,
              onTap: () => _handleFilterTap(FilterOption.expired),
              color: theme.colorScheme.error,
            ),
            _StatCard(
              label: 'Today',
              value: stats.expiringTodayCount.toString(),
              icon: Icons.today_rounded,
              isActive: activeFilter == FilterOption.today,
              onTap: () => _handleFilterTap(FilterOption.today),
              color: theme.colorScheme.primary,
            ),
            _StatCard(
              label: 'Tomorrow',
              value: stats.expiringTomorrowCount.toString(),
              icon: Icons.event_rounded,
              isActive: activeFilter == FilterOption.tomorrow,
              onTap: () => _handleFilterTap(FilterOption.tomorrow),
              color: theme.colorScheme.secondary,
            ),
            _StatCard(
              label: 'This Week',
              value: stats.expiringThisWeekCount.toString(),
              icon: Icons.date_range_rounded,
              isActive: activeFilter == FilterOption.thisWeek,
              onTap: () => _handleFilterTap(FilterOption.thisWeek),
              color: theme.colorScheme.tertiary,
            ),
            _StatCard(
              label: 'Tracked Items',
              value: stats.deliveredCount.toString(),
              icon: Icons.track_changes,
              isActive: activeFilter == FilterOption.delivered,
              onTap: () => _handleFilterTap(FilterOption.delivered),
              color: theme.colorScheme.primary,
            ),
          ];

          if (useGrid) {
            return GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: statCards,
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statCards.map((card) => Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: card,
              )).toList(),
            ),
          );
        },
      ),
    );
  }

  void _handleFilterTap(FilterOption filter) {
    if (activeFilter == filter) {
      onFilterChanged(null);
    } else {
      onFilterChanged(filter);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive 
          ? Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : color.withOpacity(0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,  
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
