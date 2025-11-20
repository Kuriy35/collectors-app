import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/collection_item.dart';
import 'edit_item_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final CollectionItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  CollectionItem get item => widget.item;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOwner = item.ownerId == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (isOwner)
            IconButton(
              icon: Icon(Icons.edit, color: theme.primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditItemScreen(item: item),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(isDark),
            const SizedBox(height: 32),

            Text(
              item.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _formatPrice(item.price),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConditionColor(
                  theme,
                  item.condition,
                  isDark,
                ).withAlpha((0.15 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getConditionColor(theme, item.condition, isDark),
                  width: 1.5,
                ),
              ),
              child: Text(
                item.condition,
                style: TextStyle(
                  color: _getConditionColor(theme, item.condition, isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildInfoRow(
              context,
              icon: Icons.category,
              label: 'Категорія',
              value: item.category,
            ),

            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'Власник',
              value: item.ownerName,
            ),

            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.public,
              label: 'Статус',
              value: item.isPublic ? 'Публічний' : 'Приватний',
            ),

            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Опис',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  item.description!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white70 : const Color(0xFF555555),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF666666),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(ThemeData theme, String condition, bool isDark) {
    switch (condition.toLowerCase()) {
      case 'новий':
        return const Color(0xFF4CAF50);
      case 'добрий':
        return const Color(0xFF8BC34A);
      case 'задовільний':
        return const Color(0xFFFF9800);
      case 'поганий':
        return const Color(0xFFF44336);
      default:
        return theme.primaryColor;
    }
  }

  Widget _buildImageCarousel(bool isDark) {
    final theme = Theme.of(context);
    if (item.imageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          size: 48,
          color: theme.primaryColor,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: PageView.builder(
              controller: _pageController,
              itemCount: item.imageUrls.length,
              onPageChanged: (value) => setState(() => _currentPage = value),
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: item.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: isDark ? Colors.black12 : Colors.white10,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (item.imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              item.imageUrls.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.primaryColor
                      : theme.primaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatPrice(double value) {
    if (value == 0) return '₴0';
    final hasFraction = value % 1 != 0;
    return '₴${value.toStringAsFixed(hasFraction ? 2 : 0)}';
  }
}
