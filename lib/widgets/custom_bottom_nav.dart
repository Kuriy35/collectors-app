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
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            label: 'Колекція',
            icon: Icons.archive,
            isActive: activeTab == 'Колекція',
            onTap: () => onTabSelected?.call('Колекція'),
          ),
          _buildNavItem(
            label: 'Чати',
            icon: Icons.message,
            isActive: activeTab == 'Чати',
            onTap: () => onTabSelected?.call('Чати'),
          ),
          _buildNavItem(
            label: 'Аналітика',
            icon: Icons.trending_up,
            isActive: activeTab == 'Аналітика',
            onTap: () => onTabSelected?.call('Аналітика'),
          ),
          _buildNavItem(
            label: 'Профіль',
            icon: Icons.person,
            isActive: activeTab == 'Профіль',
            onTap: () => onTabSelected?.call('Профіль'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return Expanded(
      // ← ВАЖЛИВО!
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? const Color(0xFF2196F3)
                  : const Color(0xFF757575),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
