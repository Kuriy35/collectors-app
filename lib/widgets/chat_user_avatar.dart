import 'package:flutter/material.dart';
import 'online_indicator.dart';

class ChatUserAvatar extends StatelessWidget {
  final String initials;
  final List<Color> gradient;
  final bool isOnline;
  final double size;

  const ChatUserAvatar({
    super.key,
    required this.initials,
    required this.gradient,
    this.isOnline = false,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        OnlineIndicator(isOnline: isOnline),
      ],
    );
  }
}
