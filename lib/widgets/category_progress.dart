import 'package:flutter/material.dart';

class CategoryProgress extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const CategoryProgress({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '${(percent * 100).toInt()}%',
          style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
        ),
      ],
    );
  }
}
