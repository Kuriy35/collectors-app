import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.photoUrl,
    required this.displayName,
    this.collectionType,
    required this.initialsWidget,
  });

  final String? photoUrl;
  final String displayName;
  final String? collectionType;
  final Widget initialsWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha((0.25 * 255).toInt()),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 4,
                color: Colors.white.withAlpha((0.3 * 255).toInt()),
              ),
              borderRadius: BorderRadius.circular(48),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => initialsWidget,
                    errorWidget: (_, __, ___) => initialsWidget,
                  )
                : initialsWidget,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Любитель колекцій',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
        if (collectionType?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            'Тип колекції: $collectionType',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
