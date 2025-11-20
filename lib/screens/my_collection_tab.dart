import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../widgets/collection_item.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_toast.dart';
import 'edit_item_screen.dart';
import 'item_detail_screen.dart';

class MyCollectionTab extends StatefulWidget {
  const MyCollectionTab({super.key});

  @override
  State<MyCollectionTab> createState() => _MyCollectionTabState();
}

class _MyCollectionTabState extends State<MyCollectionTab> {
  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Всі';
  String _selectedCondition = 'Всі';
  String _priceRange = 'Всі';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<CollectionItem> _filterItems(List<CollectionItem> items) {
    return items.where((item) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            item.title.toLowerCase().contains(_searchQuery) ||
            (item.description?.toLowerCase().contains(_searchQuery) ?? false) ||
            item.category.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      // Category filter
      if (_selectedCategory != 'Всі' && item.category != _selectedCategory) {
        return false;
      }

      // Condition filter
      if (_selectedCondition != 'Всі' && item.condition != _selectedCondition) {
        return false;
      }

      // Price range filter
      if (_priceRange != 'Всі') {
        switch (_priceRange) {
          case 'До 100₴':
            if (item.price >= 100) return false;
            break;
          case '100₴ - 500₴':
            if (item.price < 100 || item.price >= 500) return false;
            break;
          case '500₴ - 1000₴':
            if (item.price < 500 || item.price >= 1000) return false;
            break;
          case 'Від 1000₴':
            if (item.price < 1000) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final theme = Theme.of(context);
    final filteredItems = _filterItems(provider.myItems);

    return Column(
      children: [
        _buildSearchAndFilters(theme, provider.myItems),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.refreshMyItems(),
            color: theme.primaryColor,
            child: provider.isLoading && provider.myItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null && provider.myItems.isEmpty
                ? _buildErrorState(
                    context,
                    provider,
                    onRetry: provider.loadMyItems,
                  )
                : filteredItems.isEmpty
                ? _buildEmptyState(theme, 'Нічого не знайдено')
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildItemCardWithActions(
                          context,
                          theme,
                          item,
                          provider,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme, List<CollectionItem> items) {
    final categories = [
      'Всі',
      ...items.map((e) => e.category).toSet().toList()..sort(),
    ];
    final conditions = [
      'Всі',
      'Відмінний стан',
      'Добрий стан',
      'Задовільний стан',
    ];
    final priceRanges = [
      'Всі',
      'До 100₴',
      '100₴ - 500₴',
      '500₴ - 1000₴',
      'Від 1000₴',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          CustomSearchBar(
            hintText: 'Пошук...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  theme,
                  'Категорія: $_selectedCategory',
                  () => _showCategoryPicker(theme, categories),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  theme,
                  'Стан: $_selectedCondition',
                  () => _showConditionPicker(theme, conditions),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  theme,
                  'Ціна: $_priceRange',
                  () => _showPriceRangePicker(theme, priceRanges),
                ),
                const SizedBox(width: 8),
                if (_searchQuery.isNotEmpty ||
                    _selectedCategory != 'Всі' ||
                    _selectedCondition != 'Всі' ||
                    _priceRange != 'Всі')
                  _buildFilterChip(theme, 'Очистити', () {
                    setState(() {
                      _searchController.clear();
                      _selectedCategory = 'Всі';
                      _selectedCondition = 'Всі';
                      _priceRange = 'Всі';
                    });
                  }, isClear: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    VoidCallback onTap, {
    bool isClear = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isClear ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isClear ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isClear ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(ThemeData theme, List<String> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) {
            return ListTile(
              title: Text(cat),
              trailing: _selectedCategory == cat
                  ? Icon(Icons.check, color: theme.primaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showConditionPicker(ThemeData theme, List<String> conditions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: conditions.map((condition) {
            return ListTile(
              title: Text(condition),
              trailing: _selectedCondition == condition
                  ? Icon(Icons.check, color: theme.primaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCondition = condition;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPriceRangePicker(ThemeData theme, List<String> priceRanges) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: priceRanges.map((range) {
            return ListTile(
              title: Text(range),
              trailing: _priceRange == range
                  ? Icon(Icons.check, color: theme.primaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _priceRange = range;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemCardWithActions(
    BuildContext context,
    ThemeData theme,
    CollectionItem item,
    CollectionProvider provider,
  ) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Видалити предмет?'),
            content: Text('Ви впевнені, що хочете видалити "${item.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Видалити'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // 1. Remove locally immediately
          provider.deleteItemLocally(item);

          // 2. Trigger background delete (fire and forget from UI perspective)
          // Use the parent context (MyCollectionTab's context) for the toast
          // We must ensure we don't await here to block the UI dismissal
          provider.deleteItem(context, item.id, item.imageUrls);

          // 3. Return true to dismiss the widget from the tree
          return true;
        }
        return false;
      },
      child: Stack(
        children: [
          CollectionItemCard(
            item: item,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
            ),
            onOwnerTap: () {
              // Navigate to own profile tab
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditItemScreen(item: item),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog(context, item, provider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Редагувати'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Видалити', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CollectionItem item,
    CollectionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити предмет?'),
        content: Text('Ви впевнені, що хочете видалити "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context); // Close dialog first
                provider.deleteItemLocally(item); // Remove locally
                await provider.deleteItem(context, item.id, item.imageUrls); // Background delete with toast
              } catch (e) {
                // Error handled in provider
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    CollectionProvider provider, {
    required VoidCallback onRetry,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                provider.error ?? 'Помилка завантаження',
                style: TextStyle(color: Colors.red.shade400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Спробувати ще'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              message,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
