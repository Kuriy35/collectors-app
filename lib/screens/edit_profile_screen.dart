import 'dart:typed_data';

import '../constants.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/collection_item.dart';
import '../repositories/collection_repository.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _displayNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();

  String? _collectionType;
  XFile? _newPhoto;
  Uint8List? _photoBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _displayNameCtrl.text = widget.profile.displayName;
    _bioCtrl.text = widget.profile.bio ?? '';
    _collectionType = widget.profile.collectionType;
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _newPhoto = file;
        _photoBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      CustomToast.showError(context, 'Не вдалося вибрати фото: $e');
    }
  }

  Future<void> _submit() async {
    if (_displayNameCtrl.text.trim().isEmpty) {
      CustomToast.showError(context, 'Введіть ім\'я');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repository = context.read<CollectionRepository>();
      final updatedProfile = widget.profile.copyWith(
        displayName: _displayNameCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        collectionType: _collectionType,
      );

      await repository.updateUserProfile(updatedProfile, _newPhoto);
      if (!mounted) return;
      CustomToast.showSuccess(context, 'Профіль оновлено');
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
            const CustomAppBar(title: 'Редагувати профіль', showBackButton: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPhotoPicker(theme),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Ім\'я',
                    hintText: 'Введіть ім\'я',
                    icon: Icons.person,
                    controller: _displayNameCtrl,
                  ),
                  const SizedBox(height: 20),
                  CustomDropdown(
                    label: 'Тип колекції',
                    value: _collectionType ?? 'Виберіть тип',
                    items: [
                      'Виберіть тип',
                      ...kCollectionTypes,
                    ],
                    onChanged: (v) {
                      setState(() {
                        _collectionType = v == 'Виберіть тип' ? null : v;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Про себе (біографія)',
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
                          controller: _bioCtrl,
                          maxLines: 5,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Додайте інформацію про себе',
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
                  _buildSubmitButton(theme),
                ],
              ),
            ),
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

  Widget _buildPhotoPicker(ThemeData theme) {
    final photoUrl = widget.profile.photoUrl;
    final hasNewPhoto = _photoBytes != null;
    final hasExistingPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: 120,
              height: 120,
              decoration: ShapeDecoration(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 4,
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(56),
                child: hasNewPhoto
                    ? Image.memory(
                        _photoBytes!,
                        fit: BoxFit.cover,
                      )
                    : hasExistingPhoto
                        ? CachedNetworkImage(
                            imageUrl: photoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => _buildPhotoPlaceholder(theme),
                          )
                        : _buildPhotoPlaceholder(theme),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Змінити фото'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(ThemeData theme) {
    return Container(
      color: theme.primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: 60,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Opacity(
      opacity: _isSubmitting ? 0.6 : 1.0,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isSubmitting ? 0 : 4,
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
                'Зберегти зміни',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

