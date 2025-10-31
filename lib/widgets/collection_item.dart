import 'package:flutter/material.dart';
import 'custom_badge.dart';

class CollectionItem extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String category;
  final String condition;
  final String price;
  final VoidCallback? onTap; // ✅ НОВИЙ параметр

  const CollectionItem({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    this.onTap, // ✅ Опціональний
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () {}, // ✅ Використовуємо callback
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(fontSize: 32, color: iconColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color.fromARGB(255, 226, 225, 225)
                            : const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CustomBadge(text: category),
                        const SizedBox(width: 8),
                        CustomBadge(text: condition),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
