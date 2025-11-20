import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              message,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
