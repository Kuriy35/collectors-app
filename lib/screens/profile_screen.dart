import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/collection_repository.dart';
import '../models/collection_item.dart';
import '../providers/collection_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_toast.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  User? user;
  bool _isLoading = true;
  CollectionRepository? _collectionRepository;
  // Stream<UserProfile?>? _profileStream; // Removed local stream

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    user = FirebaseAuth.instance.currentUser;
    setState(() => _isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collectionRepository ??= context.read<CollectionRepository>();
    // _profileStream ??= _collectionRepository?.watchCurrentUserProfile(); // Removed local stream subscription
  }

  Future<void> _signOut() async {
    try {
      await _authRepo.signOut();
      if (mounted) {
        setState(() => user = null);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e, stackTrace) {
      debugPrint('SignOut error: $e\n$stackTrace');
      if (mounted) {
        CustomToast.showError(context, 'Помилка виходу: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final collectionProvider = context.watch<CollectionProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(theme, collectionProvider.userProfile),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStatsCard(
                      theme,
                      isDark,
                      itemsCount: collectionProvider.myItemsCount,
                      publicCount: collectionProvider.myItems
                          .where((item) => item.isPublic)
                          .length,
                      totalValue: collectionProvider.myItemsTotalValue,
                      isLoading: collectionProvider.isLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildAboutCard(
                        theme, isDark, collectionProvider.userProfile),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildEditProfileButton(theme, isDark),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSettingsCard(theme, isDark),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNav(
        activeTab: 'Профіль',
        onTabSelected: (tab) {
          if (tab.contains("Колекція")) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (tab.contains("Чати")) {
            Navigator.pushReplacementNamed(context, '/chats');
          } else if (tab.contains("Аналітика")) {
            Navigator.pushReplacementNamed(context, '/analytics');
          }
        },
      ),
    );
  }

  String _getInitials() {
    final name = user?.displayName ?? 'Користувач';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'К';
  }

  Widget _buildHeader(ThemeData theme, UserProfile? profile) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
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
              child: profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profile.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _headerInitials(),
                    )
                  : _headerInitials(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.displayName ?? user?.displayName ?? 'Користувач',
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
            profile?.collectionType?.isNotEmpty == true
                ? profile!.collectionType!
                : 'Любитель колекцій',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
          if (profile?.collectionType?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Тип колекції: ${profile!.collectionType}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
        _getInitials(),
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
    required int publicCount,
    required double totalValue,
    required bool isLoading,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF333333),
              fontSize: 18.72,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                isLoading ? '...' : itemsCount.toString(),
                'Предметів',
                theme.highlightColor,
                Icons.inventory_2,
                isDark,
              ),
              _buildStatItem(
                isLoading ? '...' : publicCount.toString(),
                'Публічних',
                theme.highlightColor,
                Icons.chat,
                isDark,
              ),
              _buildStatItem(
                isLoading ? '...' : _formatCurrency(totalValue),
                'Вартість\nколекції',
                theme.highlightColor,
                Icons.attach_money,
                isDark,
              ),
            ],
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

  Widget _buildAboutCard(ThemeData theme, bool isDark, UserProfile? profile) {
    return Container(
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
            profile?.bio?.isNotEmpty == true
                ? profile!.bio!
                : 'Додайте інформацію про себе, свої інтереси та напрямки колекціонування.',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF666666),
              fontSize: 16,
              fontFamily: 'Roboto',
              height: 1.6,
            ),
          ),
          if (profile?.collectionType?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.collections, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Тип колекції: ${profile!.collectionType}',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final profile = context.read<CollectionProvider>().userProfile;
        if (mounted && profile != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(profile: profile),
            ),
          );
        }
      },
      child: Container(
        height: 48,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withAlpha((0.9 * 255).toInt()),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Center(
          child: Text(
            'Редагувати профіль',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, bool isDark) {
    return Container(
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
        children: [
          Text(
            'Налаштування',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF333333),
              fontSize: 18.72,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'Сповіщення',
            Icons.notifications,
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE3F2FD),
            isDark,
          ),
          _buildDivider(isDark),
          _buildSettingItem(
            'Темна тема',
            Icons.dark_mode,
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
            isDark,
            isToggle: true,
            onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
          ),
          _buildDivider(isDark),
          _buildSettingItem(
            'Вийти з акаунту',
            Icons.logout,
            isDark ? const Color(0xFF4A1A1A) : const Color(0xFFFFEBEE),
            isDark,
            onTap: _signOut,
            isRed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color bgColor,
    bool isDark, {
    bool isToggle = false,
    bool isRed = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onChanged,
  }) {
    return GestureDetector(
      onTap: isToggle ? null : onTap,
      child: Container(
        height: 73,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isRed
                    ? Colors.red
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isRed
                    ? Colors.red
                    : (isDark ? Colors.white : const Color(0xFF333333)),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
            const Spacer(),
            if (isToggle)
              Switch(
                value: context.watch<ThemeProvider>().isDark,
                onChanged: onChanged,
              ),
            if (!isToggle && !isRed)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white60 : const Color(0xFFCCCCCC),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? const Color(0xFF333333) : const Color(0xFFF0F0F0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  String _formatCurrency(double value) {
    if (value == 0) return '₴0';
    final hasFraction = value % 1 != 0;
    return '₴${value.toStringAsFixed(hasFraction ? 2 : 0)}';
  }
}
