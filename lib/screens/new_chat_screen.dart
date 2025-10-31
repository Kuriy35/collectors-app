import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/user_search_card.dart';

class NewChatScreen extends StatelessWidget {
  final List<Map<String, dynamic>> users = [
    {
      'initials': 'МІ',
      'gradient': [Color(0xFFFF5722), Color(0xFFD84315)],
      'name': 'Марія Іванова',
      'bio': 'Колекціонерка марок з 2018',
    },
    {
      'initials': 'ПС',
      'gradient': [Color(0xFF607D8B), Color(0xFF455A64)],
      'name': 'Петро Сидоренко',
      'bio': 'Збираю фігурки супергероїв',
    },
    {
      'initials': 'ОК',
      'gradient': [Color(0xFF795548), Color(0xFF5D4037)],
      'name': 'Олександр Коваленко',
      'bio': 'Фанат вінілових платівок',
    },
  ];

  NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Новий чат', showBackButton: true),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                hintText: 'Пошук користувачів...',
                onChanged: null,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Рекомендовані користувачі',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, i) => UserSearchCard(
                  initials: users[i]['initials'],
                  gradient: users[i]['gradient'],
                  name: users[i]['name'],
                  bio: users[i]['bio'],
                  onTap: () => Navigator.pushNamed(context, '/chat-detail'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        activeTab: 'Чати',
        onTabSelected: (tab) {
          if (tab.contains("Колекція")) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (tab.contains("Аналітика")) {
            Navigator.pushReplacementNamed(context, '/analytics');
          } else if (tab.contains("Профіль")) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
