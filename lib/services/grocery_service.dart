import 'package:hive/hive.dart';
import '../models/grocery_item.dart';

class GroceryService {
  static const String _boxName = 'grocery_items';
  late Box<GroceryItem> _box;

  Future<void> init() async {
    print('Got object store box in database $_boxName.');
    _box = await Hive.openBox<GroceryItem>(_boxName);
  }

  List<GroceryItem> getAllItems() {
    return _box.values.toList();
  }

  Future<void> addItem(GroceryItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> updateItem(GroceryItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleDeliveryStatus(GroceryItem item) async {
    item.toggleTracking();
    await updateItem(item);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  void dispose() {
    _box.close();
  }
}
