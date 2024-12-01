import 'package:hive/hive.dart';
import '../models/grocery_item.dart';

class GroceryService {
  static const String _boxName = 'grocery_items';
  Box<GroceryItem>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) {
      return;
    }
    
    try {
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<GroceryItem>(_boxName);
      } else {
        _box = await Hive.openBox<GroceryItem>(_boxName);
      }
    } catch (e) {
      print('Error initializing grocery box: $e');
      rethrow;
    }
  }

  Box<GroceryItem> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('GroceryService not initialized or box is closed. Call init() first.');
    }
    return _box!;
  }

  List<GroceryItem> getAllItems() {
    return box.values.toList();
  }

  Future<void> addItem(GroceryItem item) async {
    await box.put(item.id, item);
  }

  Future<void> updateItem(GroceryItem item) async {
    await box.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  Future<void> toggleDeliveryStatus(GroceryItem item) async {
    item.toggleTracking();
    await updateItem(item);
  }

  Future<void> clear() async {
    await box.clear();
  }

  void dispose() {
    if (_box != null && _box!.isOpen) {
      _box!.close();
      _box = null;
    }
  }
}
