import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> messages = [
    {
      'text': 'Привіт! Бачила твою колекцію монет',
      'isMe': false,
      'time': '14:30',
    },
    {
      'text': 'Привіт! Дякую, намагаюся збирати українські монети',
      'isMe': true,
      'time': '14:31',
    },
    {
      'text': 'Цікава монета 1 гривня 2015! Де знайшли?',
      'isMe': false,
      'time': '14:32',
    },
  ];

  ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Анна Мельник', showBackButton: true),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: messages.length,
                itemBuilder: (ctx, i) => MessageBubble(
                  text: messages[i]['text'],
                  isMe: messages[i]['isMe'],
                  time: messages[i]['time'],
                ),
              ),
            ),
            _buildInput(theme),
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

  Widget _buildInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Введіть повідомлення...',
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.primaryColor,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
