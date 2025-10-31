import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/custom_button.dart';

class ChatsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chats = [
    {
      'initials': 'АМ',
      'gradient': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
      'name': 'Анна Мельник',
      'message': 'Цікава монета! Де знайшли?',
      'time': '14:32',
      'unread': 2,
      'online': true,
    },
    {
      'initials': 'ІК',
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
      'name': 'Ігор Коваль',
      'message': 'Дякую за пораду щодо марок',
      'time': '12:15',
      'unread': 0,
      'online': false,
    },
    {
      'initials': 'ОП',
      'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      'name': 'Олена Петренко',
      'message': 'Фото',
      'time': 'Вчора',
      'unread': 1,
      'online': true,
    },
  ];

  ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Чати', showBackButton: false),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                hintText: 'Пошук чатів...',
                onChanged: null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (ctx, i) => ChatListItem(
                  initials: chats[i]['initials'],
                  gradient: chats[i]['gradient'],
                  name: chats[i]['name'],
                  lastMessage: chats[i]['message'],
                  time: chats[i]['time'],
                  unread: chats[i]['unread'],
                  isOnline: chats[i]['online'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Новий чат',
                onPressed: () => Navigator.pushNamed(context, '/new-chat'),
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
