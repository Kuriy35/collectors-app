import 'package:flutter/material.dart';
import '../models/collection_item.dart';

class ItemDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.iconBg,
                      item.iconBg.withAlpha((0.8 * 255).toInt()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha((0.4 * 255).toInt())
                          : Colors.black.withAlpha((0.15 * 255).toInt()),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: const TextStyle(fontSize: 72, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              item.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              item.price,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConditionColor(
                  theme,
                  item.condition,
                  isDark,
                ).withAlpha((0.15 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getConditionColor(theme, item.condition, isDark),
                  width: 1.5,
                ),
              ),
              child: Text(
                item.condition,
                style: TextStyle(
                  color: _getConditionColor(theme, item.condition, isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildInfoRow(
              context,
              icon: Icons.category,
              label: 'Категорія',
              value: item.category,
            ),

            const SizedBox(height: 16),

            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                'Опис',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  item.description!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF555555),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Редагування ще не реалізовано'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Редагувати предмет'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF666666),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(ThemeData theme, String condition, bool isDark) {
    switch (condition.toLowerCase()) {
      case 'новий':
        return const Color(0xFF4CAF50);
      case 'добрий':
        return const Color(0xFF8BC34A);
      case 'задовільний':
        return const Color(0xFFFF9800);
      case 'поганий':
        return const Color(0xFFF44336);
      default:
        return theme.primaryColor;
    }
  }
}
