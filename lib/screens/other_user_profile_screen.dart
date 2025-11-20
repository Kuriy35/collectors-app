import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/collection_item.dart';
import 'item_detail_screen.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _error = null;
    });

    try {
      final provider = context.read<CollectionProvider>();
      final profile = await provider.getUserProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatCurrency(double? value) {
    if (value == null || value == 0) return '₴0';
    final hasFraction = value % 1 != 0;
    return '₴${value.toStringAsFixed(hasFraction ? 2 : 0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Профіль', showBackButton: true),
            Expanded(
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(theme)
                      : _profile == null
                          ? _buildEmptyState(theme)
                          : _buildProfileContent(context, theme, isDark),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        activeTab: 'Колекція',
        onTabSelected: (tab) {
          if (tab.contains("Чати")) {
            Navigator.pushReplacementNamed(context, '/chats');
          } else if (tab.contains("Аналітика")) {
            Navigator.pushReplacementNamed(context, '/analytics');
          } else if (tab.contains("Профіль")) {
            Navigator.pushReplacementNamed(context, '/profile');
          } else if (tab.contains("Колекція")) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final provider = context.watch<CollectionProvider>();

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: theme.primaryColor,
      child: ListView(
        children: [
          _buildHeader(theme, isDark),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildStatsCard(
              theme,
              isDark,
              itemsCount: _profile!.totalItems ?? 0,
              totalValue: _profile!.totalValue ?? 0,
            ),
          ),
          const SizedBox(height: 16),
          if (_profile!.bio != null && _profile!.bio!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildAboutCard(theme, isDark),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildItemsSection(context, theme, provider),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      height: 235,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withAlpha((0.8 * 255).toInt()),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              child: _profile!.photoUrl != null && _profile!.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _profile!.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _headerInitials(),
                      errorWidget: (_, __, ___) => _headerInitials(),
                    )
                  : _headerInitials(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Любитель колекцій',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          if (_profile!.collectionType?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Тип колекції: ${_profile!.collectionType}',
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
      ),
    );
  }

  Widget _headerInitials() {
    return Center(
      child: Text(
        _getInitials(_profile?.displayName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    ThemeData theme,
    bool isDark, {
    required int itemsCount,
    required double totalValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.3 * 255).toInt())
                : Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            itemsCount.toString(),
            'Предметів',
            theme.highlightColor,
            Icons.inventory_2,
            isDark,
          ),
          _buildStatItem(
            _formatCurrency(totalValue),
            'Вартість\nколекції',
            theme.highlightColor,
            Icons.attach_money,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color bgColor,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF333333),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 34,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF666666),
              fontSize: 14,
              fontFamily: 'Roboto',
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.3 * 255).toInt())
                : Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Про мене',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF333333),
              fontSize: 18.72,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.bio!,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF666666),
              fontSize: 16,
              fontFamily: 'Roboto',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(
    BuildContext context,
    ThemeData theme,
    CollectionProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Публічні предмети',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<CollectionItem>>(
          stream: provider.getUserPublicItems(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Помилка: ${snapshot.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Немає публічних предметів',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CollectionItemCard(
                    item: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailScreen(item: item),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Помилка завантаження',
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Спробувати ще'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        'Профіль не знайдено',
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
    );
  }
}

