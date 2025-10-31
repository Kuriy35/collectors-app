import 'package:flutter/material.dart';
import '../models/collection_item.dart';
import '../services/local_storage_service.dart';

enum CollectionStatus { initial, loading, loaded, error }

class CollectionProvider extends ChangeNotifier {
  List<CollectionItem> _items = [];
  CollectionStatus _status = CollectionStatus.initial;
  String? _errorMessage;

  List<CollectionItem> get items => _items;
  CollectionStatus get status => _status;
  String? get errorMessage => _errorMessage;

  CollectionProvider() {
    loadItems(); // Автозавантаження при створенні
  }

  Future<void> loadItems() async {
    if (_status == CollectionStatus.loading) return;

    _status = CollectionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Імітація затримки мережі
      await Future.delayed(const Duration(milliseconds: 800));

      final savedItems = await LocalStorageService.loadItems();
      if (savedItems.isEmpty) {
        // Якщо порожньо — додаємо hardcoded
        _items = _getHardcodedItems();
        await LocalStorageService.saveItems(_items);
      } else {
        _items = savedItems;
      }
      throw _status = CollectionStatus.loaded;
    } catch (e) {
      _status = CollectionStatus.error;
      _errorMessage = 'Не вдалося завантажити колекцію';
      debugPrint('Collection error: $e');
    } finally {
      notifyListeners();
    }
  }

  // Pull to Refresh
  Future<void> refresh() async {
    await loadItems();
  }

  // Додавання нового предмету
  Future<void> addItem(CollectionItem item) async {
    _items.add(item);
    await LocalStorageService.saveItems(_items);
    notifyListeners();
  }

  // Hardcoded дані
  List<CollectionItem> _getHardcodedItems() {
    return [
      CollectionItem(
        id: '1',
        icon: 'C',
        iconBg: Colors.purple.shade100,
        iconColor: Colors.purple.shade700,
        title: 'Римська монета',
        category: 'Монети',
        condition: 'Добрий',
        price: '₴450',
        description: 'Старовинна монета з Риму, 2 ст. н.е.',
      ),
      CollectionItem(
        id: '2',
        icon: 'S',
        iconBg: Colors.green.shade100,
        iconColor: Colors.green.shade700,
        title: 'Марка "Київська Русь"',
        category: 'Марки',
        condition: 'Новий',
        price: '₴120',
        description: 'Рідкісна поштова марка 1992 року.',
      ),
      CollectionItem(
        id: '3',
        icon: 'F',
        iconBg: Colors.orange.shade100,
        iconColor: Colors.orange.shade700,
        title: 'Фігурка "Дракон"',
        category: 'Фігурки',
        condition: 'Задовільний',
        price: '₴890',
        description: 'Керамічна фігурка ручної роботи.',
      ),
    ];
  }
}
