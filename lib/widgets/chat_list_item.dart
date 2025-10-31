import 'package:flutter/material.dart';
import 'chat_user_avatar.dart';

class ChatListItem extends StatelessWidget {
  final String initials;
  final List<Color> gradient;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;

  const ChatListItem({
    super.key,
    required this.initials,
    required this.gradient,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.isOnline = false,
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
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          ChatUserAvatar(
            initials: initials,
            gradient: gradient,
            isOnline: isOnline,
          ),
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
                const SizedBox(height: 4),
                Text(
                  lastMessage,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF666666),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF999999),
                  fontSize: 12,
                ),
              ),
              if (unread > 0)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor, // використовуємо primary з теми
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
