import 'package:flutter/material.dart';
import '../widgets/collection_item.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../services/crashlytics_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF5F5F5),
            child: SafeArea(
              child: Column(
                children: [
                  const CustomAppBar(
                    title: 'Моя колекція',
                    showBackButton: false,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const CustomSearchBar(
                          hintText: 'Пошук предметів...',
                          onChanged: print,
                        ),
                        const SizedBox(height: 16),
                        _buildFiltersRow(),
                        const SizedBox(height: 24),
                        CollectionItem(
                          icon: '🪙',
                          iconBg: const Color(0xFFFFF3CD),
                          iconColor: const Color(0xFF856404),
                          title: 'Монета 1 гривня 2015',
                          category: 'Монети',
                          condition: 'Відмінний стан',
                          price: '150 ₴',
                        ),
                        const SizedBox(height: 12),
                        CollectionItem(
                          icon: '📮',
                          iconBg: const Color(0xFFD1ECF1),
                          iconColor: const Color(0xFF0C5460),
                          title: 'Марка "Квіти України"',
                          category: 'Марки',
                          condition: 'Новий стан',
                          price: '45 ₴',
                        ),
                        const SizedBox(height: 12),
                        CollectionItem(
                          icon: '🎮',
                          iconBg: const Color(0xFFE2E3FF),
                          iconColor: const Color(0xFF4C63D2),
                          title: 'Фігурка Бетмена',
                          category: 'Фігурки',
                          condition: 'Добрий стан',
                          price: '320 ₴',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned(bottom: 16, right: 16, child: _buildAddItemButton()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CrashlyticsService.throwTestCrash(),
        backgroundColor: Colors.red,
        child: Icon(Icons.bug_report),
      ),
      bottomNavigationBar: CustomBottomNav(
        activeTab: 'Колекція',
        onTabSelected: (tab) {
          if (tab.contains("Профіль")) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterItem('Всі', active: true),
          const SizedBox(width: 8),
          _buildFilterItem('🪙 Монети'),
          const SizedBox(width: 8),
          _buildFilterItem('📮 Марки'),
          const SizedBox(width: 8),
          _buildFilterItem('🎮 Фігурки'),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2196F3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: active ? const Color(0x4C2196F3) : Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF666666),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget _buildAddItemButton() {
  //   return Container(
  //     width: 56,
  //     height: 56,
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: const [BoxShadow(color: Color(0x662196F3), blurRadius: 12)],
  //     ),
  //     child: const Center(
  //       child: Text('+', style: TextStyle(fontSize: 24, color: Colors.white)),
  //     ),
  //   );
  // }
}
