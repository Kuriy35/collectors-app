import 'package:flutter/material.dart';
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
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Предметів у власності',
                          value: '47',
                          icon: Icons.inventory_2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Загальна вартість',
                          value: '₴2,340',
                          icon: Icons.paid,
                        ),
                      ),
                    ],
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
                              // ignore: deprecated_member_use
                              ? Colors.black.withOpacity(0.3)
                              // ignore: deprecated_member_use
                              : Colors.black.withOpacity(0.1),
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
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Інтерактивна діаграма',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CategoryProgress(
                          label: 'Монети',
                          percent: 0.60,
                          color: const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 16),
                        CategoryProgress(
                          label: 'Марки',
                          percent: 0.25,
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 16),
                        CategoryProgress(
                          label: 'Фігурки',
                          percent: 0.15,
                          color: const Color(0xFFFF9800),
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
                              // ignore: deprecated_member_use
                              ? Colors.black.withOpacity(0.3)
                              // ignore: deprecated_member_use
                              : Colors.black.withOpacity(0.1),
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
                          'Ваша колекція збалансована',
                          isDark
                              ? const Color(0xFF1A3C34) // темний зелений фон
                              : const Color(0xFFE8F5E8),
                          isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 12),
                        _buildTip(
                          context,
                          'Додайте більше марок',
                          isDark
                              ? const Color(0xFF1A2A44)
                              : const Color(0xFFE3F2FD),
                          isDark
                              ? const Color(0xFF64B5F6)
                              : const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 12),
                        _buildTip(
                          context,
                          'Середня вартість: ₴50',
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

  // Оновлений _buildTip — тепер приймає context і isDark
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
