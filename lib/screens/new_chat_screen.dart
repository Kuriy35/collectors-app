import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection_item.dart';
import '../repositories/collection_repository.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/user_search_card.dart';
import 'chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _error = '';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final repository = context.read<CollectionRepository>();
      final results = await repository.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Помилка пошуку: $e';
          _isLoading = false;
        });
      }
    }
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                hintText: 'Пошук користувачів...',
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 24),
            if (_searchResults.isNotEmpty || _isLoading || _error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Результати пошуку',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Text(_error,
                              style: TextStyle(color: theme.colorScheme.error)))
                      : _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isEmpty
                                    ? 'Введіть ім\'я або тип колекції'
                                    : 'Користувачів не знайдено',
                                style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (ctx, i) {
                                final user = _searchResults[i];
                                return UserSearchCard(
                                  initials: _getInitials(user.displayName),
                                  gradient: _getGradient(user.uid),
                                  name: user.displayName,
                                  bio: user.collectionType ??
                                      user.bio ??
                                      'Колекціонер',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatDetailScreen(
                                          userName: user.displayName,
                                          userImage: user.photoUrl,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  List<Color> _getGradient(String uid) {
    final hash = uid.hashCode;
    final colors = [
      [const Color(0xFFFF5722), const Color(0xFFD84315)],
      [const Color(0xFF2196F3), const Color(0xFF1976D2)],
      [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
      [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      [const Color(0xFF607D8B), const Color(0xFF455A64)],
    ];
    return colors[hash.abs() % colors.length];
  }
}
