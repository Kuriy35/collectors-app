import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/collection_item.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../providers/collection_provider.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Всі';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final theme = Theme.of(context);

    // Фільтрація
    final filteredItems = _selectedCategory == 'Всі'
        ? provider.items
        : provider.items.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const CustomAppBar(
                  title: 'Моя колекція',
                  showBackButton: false,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh, // Pull to Refresh
                    color: theme.primaryColor,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const CustomSearchBar(
                          hintText: 'Пошук...',
                          onChanged: null,
                        ),
                        const SizedBox(height: 16),
                        _buildFiltersRow(theme),
                        const SizedBox(height: 24),

                        // === СТАНИ ===
                        if (provider.status == CollectionStatus.loading) ...[
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 16),
                        ] else if (provider.status ==
                            CollectionStatus.error) ...[
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider.errorMessage ?? 'Помилка',
                                  style: TextStyle(color: Colors.red.shade400),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: provider.refresh,
                                  child: const Text('Спробувати ще'),
                                ),
                              ],
                            ),
                          ),
                        ] else if (filteredItems.isEmpty) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                _selectedCategory == 'Всі'
                                    ? 'Колекція порожня'
                                    : 'Немає предметів у "$_selectedCategory"',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          ...filteredItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CollectionItem(
                                icon: item.icon,
                                iconBg: item.iconBg,
                                iconColor: item.iconColor,
                                title: item.title,
                                category: item.category,
                                condition: item.condition,
                                price: item.price,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ItemDetailScreen(item: item),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/add-item'),
              child: _buildAddItemButton(theme),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        activeTab: 'Колекція',
        onTabSelected: (tab) {
          if (tab.contains("Чати")) {
            Navigator.pushReplacementNamed(context, '/chats');
          } else if (tab.contains("Аналітика")) {
            Navigator.pushReplacementNamed(context, '/analytics');
          } else if (tab.contains("Профіль")) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildFiltersRow(ThemeData theme) {
    final categories = ['Всі', 'Монети', 'Марки', 'Фігурки'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isActive = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? theme.primaryColor : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          // ignore: deprecated_member_use
                          ? theme.primaryColor.withOpacity(0.3)
                          // ignore: deprecated_member_use
                          : Colors.black.withOpacity(0.1),
                      blurRadius: isActive ? 6 : 3,
                    ),
                  ],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddItemButton(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 3),
        ],
      ),
      child: const Center(
        child: Text('+', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
