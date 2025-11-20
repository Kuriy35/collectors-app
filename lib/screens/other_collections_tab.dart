import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../widgets/collection_item.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/filter_chip_widget.dart';
import 'item_detail_screen.dart';
import 'other_user_profile_screen.dart';

class OtherCollectionsTab extends StatefulWidget {
  const OtherCollectionsTab({super.key});

  @override
  State<OtherCollectionsTab> createState() => _OtherCollectionsTabState();
}

class _OtherCollectionsTabState extends State<OtherCollectionsTab> {
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
    final filteredItems = _filterItems(provider.discoverItems);

    return Column(
      children: [
        _buildSearchAndFilters(theme, provider.discoverItems),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadDiscoverItems(),
            color: theme.primaryColor,
            child: provider.isLoading && provider.discoverItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null && provider.discoverItems.isEmpty
                ? ErrorStateWidget(
                    error: provider.error!,
                    onRetry: provider.loadDiscoverItems,
                  )
                : filteredItems.isEmpty
                ? const EmptyStateWidget(message: 'Нічого не знайдено')
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CollectionItemCard(
                          item: item,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(item: item),
                            ),
                          ),
                          onOwnerTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OtherUserProfileScreen(userId: item.ownerId),
                            ),
                          ),
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
                FilterChipWidget(
                  label: 'Категорія: $_selectedCategory',
                  onTap: () => _showCategoryPicker(theme, categories),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Стан: $_selectedCondition',
                  onTap: () => _showConditionPicker(theme, conditions),
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Ціна: $_priceRange',
                  onTap: () => _showPriceRangePicker(theme, priceRanges),
                ),
                const SizedBox(width: 8),
                if (_selectedCategory != 'Всі' ||
                    _selectedCondition != 'Всі' ||
                    _priceRange != 'Всі')
                  FilterChipWidget(
                    label: 'Очистити',
                    onTap: () {
                      setState(() {
                        // Only clear filters, not search text
                        _selectedCategory = 'Всі';
                        _selectedCondition = 'Всі';
                        _priceRange = 'Всі';
                      });
                    },
                    isClear: true,
                  ),
              ],
            ),
          ),
        ],
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


}
