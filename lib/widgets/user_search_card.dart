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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  bio,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
