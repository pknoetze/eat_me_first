import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 0)
class GroceryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  DateTime? expiryDate;

  @HiveField(3)
  bool trackingEnabled;

  GroceryItem({
    String? id,
    required this.name,
    this.expiryDate,
    this.trackingEnabled = false,
  }) : id = id ?? const Uuid().v4();

  void toggleTracking() {
    trackingEnabled = !trackingEnabled;
    if (trackingEnabled) {
      // When enabling tracking, set expiry date to today if not already set
      expiryDate ??= DateTime.now();
    } else {
      // When disabling tracking, clear the expiry date
      expiryDate = null;
    }
    save();
  }

  bool isExpired() {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.isBefore(today);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return -1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.difference(today).inDays;
  }

  String? get formattedExpiryDate {
    if (expiryDate == null) return null;
    return DateFormat('MMM d, y').format(expiryDate!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'trackingEnabled': trackingEnabled,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate'] as int)
          : null,
      trackingEnabled: json['trackingEnabled'] as bool,
    );
  }
}
