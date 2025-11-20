import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'chat_user_avatar.dart';

class UserSearchCard extends StatelessWidget {
  final String initials;
  final List<Color> gradient;
  final String name;
  final String bio;
  final String? photoUrl;
  final VoidCallback onTap;
  final VoidCallback onMessageTap;

  const UserSearchCard({
    super.key,
    required this.initials,
    required this.gradient,
    required this.name,
    required this.bio,
    this.photoUrl,
    required this.onTap,
    required this.onMessageTap,
  });



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
        onTap: onTap,
        child: Container(
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
              if (photoUrl != null && photoUrl!.isNotEmpty)
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ChatUserAvatar(
                        initials: initials,
                        gradient: gradient,
                        size: 48,
                      ),
                      errorWidget: (context, url, error) => ChatUserAvatar(
                        initials: initials,
                        gradient: gradient,
                        size: 48,
                      ),
                    ),
                  ),
                )
              else
                ChatUserAvatar(
                  initials: initials,
                  gradient: gradient,
                  size: 48,
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
                onPressed: onMessageTap,
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
        ),
      );
  }
}
