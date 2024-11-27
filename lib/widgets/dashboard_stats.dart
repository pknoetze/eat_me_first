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
              label: 'Delivered',
              value: stats.deliveredCount.toString(),
              icon: Icons.check_circle_outline_rounded,
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
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isActive ? color.withOpacity(0.1) : Colors.transparent;
    final foregroundColor = isActive ? color : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, color: foregroundColor),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foregroundColor,
                      ),
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
