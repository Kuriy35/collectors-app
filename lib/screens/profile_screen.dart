import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/custom_toast.dart';
import '../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  User? user;
  bool _isLoading = true;

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

  Future<void> _signOut() async {
    try {
      await _authRepo.signOut();
      if (mounted) {
        setState(() {
          user = null;
        });

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 235,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: ShapeDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 4,
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(48),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          user?.displayName ?? 'Користувач',
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
                          'Колекціонер монет',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStatsCard(),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildAboutCard(),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildEditProfileButton(),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSettingsCard(),
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

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Налаштування',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 18.72,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'Сповіщення',
            Icons.notifications,
            Color(0xFFE3F2FD),
          ),
          _buildDivider(),
          _buildSettingItem(
            'Темна тема',
            Icons.dark_mode,
            Color(0xFFF5F5F5),
            isToggle: true,
          ),
          _buildDivider(),
          _buildSettingItem(
            'Вийти з акаунту',
            Icons.logout,
            Color(0xFFFFEBEE),
            onTap: _signOut,
            isRed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика',
            style: TextStyle(
              color: Color(0xFF333333),
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
                '47',
                'Предметів',
                Color(0xFFE3F2FD),
                Icons.inventory_2,
              ),
              _buildStatItem('12', 'Чатів', Color(0xFFE8F5E8), Icons.chat),
              _buildStatItem(
                '₴2,340',
                'Вартість\nколекції',
                Color(0xFFF3E5F5),
                Icons.attach_money,
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
          child: Icon(icon, size: 24, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF333333),
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
            style: const TextStyle(
              color: Color(0xFF666666),
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

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Про мене',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 18.72,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Збираю монети України вже понад 5 років. Особливо цікавлять пам\'ятні та ювілейні випуски.',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontFamily: 'Roboto',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Перейти до редагування
      },
      child: Container(
        height: 48,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
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

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color bgColor, {
    bool isToggle = false,
    bool isRed = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                color: isRed ? Colors.red : Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isRed ? Colors.red : const Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
            const Spacer(),
            if (isToggle) Switch(value: false, onChanged: (_) {}),
            if (!isToggle && !isRed)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFCCCCCC),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF0F0F0),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
