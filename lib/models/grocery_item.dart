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
  bool delivered;

  GroceryItem({
    String? id,
    required this.name,
    this.expiryDate,
    this.delivered = false,
  }) : id = id ?? const Uuid().v4();

  void toggleDelivered() {
    delivered = !delivered;
    if (delivered) {
      // When marking as delivered, set expiry date to today if not already set
      expiryDate ??= DateTime.now();
    } else {
      // When unmarking as delivered, clear the expiry date
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
      'delivered': delivered,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate'] as int)
          : null,
      delivered: json['delivered'] as bool,
    );
  }
}
