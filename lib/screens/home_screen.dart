import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import 'my_collection_tab.dart';
import 'other_collections_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const CustomAppBar(title: 'Колекція', showBackButton: false),
                TabBar(
                  controller: _tabController,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                  indicatorColor: theme.primaryColor,
                  tabs: const [
                    Tab(text: 'Моя колекція'),
                    Tab(text: 'Інші колекції'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const MyCollectionTab(),
                      const OtherCollectionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/add-item'),
              child: _buildAddItemButton(theme),
            ),
          ),
        ],
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
          }
        },
      ),
    );
  }

  Widget _buildAddItemButton(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withAlpha((0.8 * 255).toInt()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withAlpha((0.4 * 255).toInt()),
            blurRadius: 3,
          ),
        ],
      ),
      child: const Center(
        child: Text('+', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
