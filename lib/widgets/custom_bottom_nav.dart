import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String>? onTabSelected;

  const CustomBottomNav({
    super.key,
    required this.activeTab,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('Колекція', Icons.archive, theme),
          _buildNavItem('Чати', Icons.message, theme),
          _buildNavItem('Аналітика', Icons.trending_up, theme),
          _buildNavItem('Профіль', Icons.person, theme),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, ThemeData theme) {
    final isActive = activeTab == label;
    final color = isActive
        ? theme.primaryColor
        : (theme.brightness == Brightness.dark
              ? Colors.white70
              : const Color(0xFF757575));

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected?.call(label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
