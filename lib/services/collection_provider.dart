import 'package:flutter/material.dart';
import '../models/collection_item.dart';
import '../services/local_storage_service.dart';

class CollectionProvider extends ChangeNotifier {
  List<CollectionItemData> _items = [];
  List<CollectionItemData> get items => _items;

  Future<void> loadItems() async {
    _items = await LocalStorageService.loadItems();
    if (_items.isEmpty) {
      _items = _getHardcodedItems();
      await LocalStorageService.saveItems(_items);
    }
    notifyListeners();
  }

  void addItem(CollectionItemData item) {
    _items.add(item);
    LocalStorageService.saveItems(_items);
    notifyListeners();
  }

  List<CollectionItemData> _getHardcodedItems() {
    return [
      CollectionItemData(
        id: '1',
        icon: 'coin',
        iconBg: const Color(0xFFFFF3CD),
        iconColor: const Color(0xFF856404),
        title: 'Монета 1 гривня 2015',
        category: 'Монети',
        condition: 'Відмінний стан',
        price: '150 ₴',
      ),
      CollectionItemData(
        id: '2',
        icon: 'stamp',
        iconBg: const Color(0xFFD1ECF1),
        iconColor: const Color(0xFF0C5460),
        title: 'Марка "Квіти України"',
        category: 'Марки',
        condition: 'Новий стан',
        price: '45 ₴',
      ),
      CollectionItemData(
        id: '3',
        icon: 'figure',
        iconBg: const Color(0xFFE2E3FF),
        iconColor: const Color(0xFF4C63D2),
        title: 'Фігурка Бетмена',
        category: 'Фігурки',
        condition: 'Добрий стан',
        price: '320 ₴',
      ),
    ];
  }
}
