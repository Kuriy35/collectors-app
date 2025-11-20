import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/collection_item.dart';
import 'custom_badge.dart';

class CollectionItemCard extends StatelessWidget {
  const CollectionItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onOwnerTap,
  });

  final CollectionItem item;
  final VoidCallback? onTap;
  final VoidCallback? onOwnerTap;

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _ItemThumbnail(
                imageUrl: item.imageUrls.isNotEmpty
                    ? item.imageUrls.first
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color.fromARGB(255, 226, 225, 225)
                            : const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        CustomBadge(text: item.category),
                        CustomBadge(text: item.condition),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildOwnerRow(context, theme, item),
                    const SizedBox(height: 8),
                    Text(
                      _formatPrice(item.price),
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

  String _formatPrice(double price) {
    if (price % 1 == 0) {
      return '₴${price.toStringAsFixed(0)}';
    }
    return '₴${price.toStringAsFixed(2)}';
  }

  Widget _buildOwnerRow(BuildContext context, ThemeData theme, CollectionItem item) {
    return GestureDetector(
      onTap: onOwnerTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: item.ownerId.isNotEmpty
                ? null
                : null, // We'll fetch owner photo from profile in OtherUserProfileScreen
            child: item.ownerId.isNotEmpty
                ? Text(
                    item.ownerName.isNotEmpty ? item.ownerName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.ownerName,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.8,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl == null
            ? Icon(Icons.camera_alt_outlined, color: theme.primaryColor)
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  color: theme.colorScheme.error,
                ),
              ),
      ),
    );
  }
}
