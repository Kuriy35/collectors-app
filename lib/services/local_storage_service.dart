import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/collection_item.dart';

class LocalStorageService {
  static const String _key = 'collection_items';

  static Future<void> saveItems(List<CollectionItemData> items) async {
    final prefs = await SharedPreferences.getInstance();
    final json = items.map((i) => i.toJson()).toList();
    await prefs.setString(_key, jsonEncode(json));
  }

  static Future<List<CollectionItemData>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => CollectionItemData.fromJson(e)).toList();
  }
}
