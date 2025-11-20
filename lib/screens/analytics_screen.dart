import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/stat_card.dart';
import '../widgets/category_progress.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<CollectionProvider>();
    final myItems = provider.myItems;

    // Calculate stats
    final totalItems = myItems.length;
    final totalValue = provider.myItemsTotalValue;

    // Calculate category breakdown
    final categoryCounts = <String, int>{};
    for (final item in myItems) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }

    // Sort categories by count descending
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 3 or all if less than 3
    final topCategories = sortedCategories.take(3).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Аналітика', showBackButton: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Предметів у власності',
                            value: '$totalItems',
                            icon: Icons.inventory_2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Загальна вартість',
                            value: '₴${totalValue.toStringAsFixed(0)}',
                            icon: Icons.paid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha((0.3 * 255).toInt())
                              : Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Розподіл за категоріями',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (totalItems == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Немає даних для відображення',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          // Simple visual representation instead of interactive chart for now
                          // as we don't have a chart library installed/configured in the snippet
                          Container(
                            height: 20,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: theme.scaffoldBackgroundColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                                children: topCategories.map((entry) {
                                  final index = topCategories.indexOf(entry);
                                  final color = _getCategoryColor(index);
                                  final flex = (entry.value / totalItems * 100).round();
                                  return Expanded(
                                    flex: flex,
                                    child: Container(color: color),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...topCategories.map((entry) {
                            final index = topCategories.indexOf(entry);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CategoryProgress(
                                label: entry.key,
                                percent: entry.value / totalItems,
                                color: _getCategoryColor(index),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha((0.3 * 255).toInt())
                              : Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Рекомендації', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 16),
                        _buildTip(
                          context,
                          totalItems > 0
                              ? 'Ваша колекція росте!'
                              : 'Почніть додавати предмети!',
                          isDark
                              ? const Color(0xFF1A3C34)
                              : const Color(0xFFE8F5E8),
                          isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 12),
                        _buildTip(
                          context,
                          'Середня вартість: ₴${totalItems > 0 ? (totalValue / totalItems).toStringAsFixed(0) : "0"}',
                          isDark
                              ? const Color(0xFF3D2F1A)
                              : const Color(0xFFFFF3CD),
                          isDark
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFFFF9800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        activeTab: 'Аналітика',
        onTabSelected: (tab) {
          if (tab.contains("Колекція")) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (tab.contains("Чати")) {
            Navigator.pushReplacementNamed(context, '/chats');
          } else if (tab.contains("Профіль")) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFF9C27B0), // Purple
      Color(0xFFE91E63), // Pink
    ];
    return colors[index % colors.length];
  }

  Widget _buildTip(
    BuildContext context,
    String text,
    Color bg,
    Color dotColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
