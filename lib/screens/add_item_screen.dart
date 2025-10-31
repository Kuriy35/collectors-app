import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_button.dart';
import '../providers/collection_provider.dart';
import '../models/collection_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Монети';
  String _condition = 'Відмінний стан';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Додати предмет', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CustomTextField(
                    label: 'Назва предмету',
                    hintText: 'Введіть назву',
                    icon: Icons.title,
                    controller: _titleCtrl,
                  ),
                  const SizedBox(height: 20),
                  CustomDropdown(
                    label: 'Категорія',
                    value: _category,
                    items: ['Монети', 'Марки', 'Фігурки'],
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  CustomDropdown(
                    label: 'Стан',
                    value: _condition,
                    items: [
                      'Відмінний стан',
                      'Добрий стан',
                      'Задовільний стан',
                    ],
                    onChanged: (v) => setState(() => _condition = v!),
                  ),
                  CustomTextField(
                    label: 'Вартість (₴)',
                    hintText: 'Введіть вартість',
                    icon: Icons.attach_money,
                    controller: _priceCtrl,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Опис', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _descCtrl,
                          maxLines: 4,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Додайте опис предмету',
                            hintStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Додати предмет',
                    onPressed: () {
                      if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
                        return;
                      }

                      final item = CollectionItem(
                        id: DateTime.now().toString(),
                        icon: _getIcon(_category),
                        iconBg: _getBgColor(_category),
                        iconColor: _getIconColor(_category),
                        title: _titleCtrl.text,
                        category: _category,
                        condition: _condition,
                        price: '${_priceCtrl.text} ₴',
                        description: _descCtrl.text,
                      );
                      context.read<CollectionProvider>().addItem(item);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
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
          }
        },
      ),
    );
  }

  String _getIcon(String cat) => cat == 'Монети'
      ? 'coin'
      : cat == 'Марки'
      ? 'stamp'
      : 'figure';
  Color _getBgColor(String cat) => cat == 'Монети'
      ? const Color(0xFFFFF3CD)
      : cat == 'Марки'
      ? const Color(0xFFD1ECF1)
      : const Color(0xFFE2E3FF);
  Color _getIconColor(String cat) => cat == 'Монети'
      ? const Color(0xFF856404)
      : cat == 'Марки'
      ? const Color(0xFF0C5460)
      : const Color(0xFF4C63D2);
}
