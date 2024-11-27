enum FilterOption {
  expired,
  today,
  tomorrow,
  thisWeek,
  delivered;

  String get label {
    switch (this) {
      case FilterOption.expired:
        return 'Expired';
      case FilterOption.today:
        return 'Expires Today';
      case FilterOption.tomorrow:
        return 'Expires Tomorrow';
      case FilterOption.thisWeek:
        return 'Expires This Week';
      case FilterOption.delivered:
        return 'Delivered';
    }
  }
}
