import 'package:flutter/material.dart';
import 'chat_user_avatar.dart';

class UserSearchCard extends StatelessWidget {
  final String initials;
  final List<Color> gradient;
  final String name;
  final String bio;
  final VoidCallback onTap;

  const UserSearchCard({
    super.key,
    required this.initials,
    required this.gradient,
    required this.name,
    required this.bio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFF0F0F0),
          ),
        ),
      ),
      child: Row(
        children: [
          ChatUserAvatar(initials: initials, gradient: gradient),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF333333),
                  ),
                ),
                Text(
                  bio,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Написати',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
