class DashboardData {
  final int expiredCount;
  final int expiringTodayCount;
  final int expiringTomorrowCount;
  final int expiringThisWeekCount;
  final int deliveredCount;

  const DashboardData({
    required this.expiredCount,
    required this.expiringTodayCount,
    required this.expiringTomorrowCount,
    required this.expiringThisWeekCount,
    required this.deliveredCount,
  });

  factory DashboardData.empty() {
    return const DashboardData(
      expiredCount: 0,
      expiringTodayCount: 0,
      expiringTomorrowCount: 0,
      expiringThisWeekCount: 0,
      deliveredCount: 0,
    );
  }
}
