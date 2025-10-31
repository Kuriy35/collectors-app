import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  final bool isOnline;

  const OnlineIndicator({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (!isOnline) return const SizedBox();
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}
