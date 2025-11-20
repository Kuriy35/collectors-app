import 'dart:typed_data';

import '../constants.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/collection_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';
import '../widgets/custom_image_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _SelectedImage {
  _SelectedImage({required this.file, required this.bytes});

  final XFile file;
  final Uint8List bytes;
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _category = 'Монети';
  String _condition = 'Відмінний стан';
  bool _isPublic = true;
  bool _isFormValid = false;
  bool _isSubmitting = false;

  List<_SelectedImage> _images = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_checkFormValidity);
    _priceCtrl.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_checkFormValidity);
    _priceCtrl.removeListener(_checkFormValidity);
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    final titleValid = _titleCtrl.text.trim().isNotEmpty;
    final priceText = _priceCtrl.text.trim().replaceAll(',', '.');
    final priceValid =
        double.tryParse(priceText) != null && double.parse(priceText) > 0;

    setState(() {
      _isFormValid = titleValid && priceValid;
    });
  }

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (!mounted || files.isEmpty) return;

      final bytes = await Future.wait(files.map((f) => f.readAsBytes()));
      setState(() {
        _images = [
          ..._images,
          for (var i = 0; i < files.length; i++)
            _SelectedImage(file: files[i], bytes: bytes[i]),
        ];
      });
    } catch (e) {
      if (!mounted) return;
      CustomToast.showError(context, 'Не вдалося вибрати фото: $e');
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid || _isSubmitting) return;

    final price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.'));
    if (price == null || price <= 0) {
      CustomToast.showError(context, 'Вкажіть коректну вартість');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await context.read<CollectionProvider>().addItem(
        title: _titleCtrl.text.trim(),
        category: _category,
        condition: _condition,
        price: price,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        images: _images.map((img) => img.file).toList(),
        isPublic: _isPublic,
      );
      if (!mounted) return;
      CustomToast.showSuccess(context, 'Предмет додано');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CustomToast.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
            const CustomAppBar(title: 'Додати предмет', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CustomTextField(
                    label: 'Назва предмету *',
                    hintText: 'Введіть назву',
                    icon: Icons.title,
                    controller: _titleCtrl,
                  ),
                  const SizedBox(height: 20),

                  CustomDropdown(
                    label: 'Категорія',
                    value: _category,
                    items: kCollectionTypes,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Вартість (₴) *',
                    hintText: 'Тільки цифри, > 0',
                    icon: Icons.attach_money,
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildImagePicker(theme),
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Опис (необов’язково)',
                        style: theme.textTheme.titleMedium,
                      ),
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
                  const SizedBox(height: 32),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Зробити предмет публічним'),
                    subtitle: const Text(
                      'Інші користувачі зможуть бачити цей предмет у стрічці',
                    ),
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                  ),
                  const SizedBox(height: 16),

                  _buildSubmitButton(theme),
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

  Widget _buildImagePicker(ThemeData theme) {
    return CustomImagePicker(
      newImageBytes: _images.map((i) => i.bytes).toList(),
      onPickImages: _pickImages,
      onRemoveNewImage: (index) {
        setState(() {
          _images = List.from(_images)..removeAt(index);
        });
      },
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    final isEnabled = _isFormValid && !_isSubmitting;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: ElevatedButton(
        onPressed: isEnabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 4 : 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Додати предмет',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
