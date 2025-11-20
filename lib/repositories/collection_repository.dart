import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/collection_item.dart';

class CollectionRepository {
  CollectionRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    Uuid? uuid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _uuid = uuid ?? const Uuid();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('collection_items');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<List<CollectionItem>> getMyItems({String? userId}) {
    final uid = userId ?? currentUser?.uid;
    if (uid == null) {
      return const Stream<List<CollectionItem>>.empty();
    }

    return _itemsCollection
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(CollectionItem.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<CollectionItem>> getPublicItems() {
    return _itemsCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(CollectionItem.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<CollectionItem>> getDiscoverItems() {
    final user = currentUser;
    if (user == null) {
      return const Stream<List<CollectionItem>>.empty();
    }

    return _itemsCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(CollectionItem.fromFirestore)
              .where((item) => item.ownerId != user.uid)
              .toList(growable: false),
        );
  }

  Future<void> addItem({
    required String title,
    required String category,
    required String condition,
    required double price,
    String? description,
    required List<XFile> images,
    bool isPublic = true,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    final ownerName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Колекціонер');

    final imageUrls = await _uploadImages(user.uid, images);

    await _itemsCollection.add({
      'title': title,
      'category': category,
      'condition': condition,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'ownerId': user.uid,
      'ownerName': ownerName,
      'isPublic': isPublic,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String itemId,
    String? title,
    String? category,
    String? condition,
    double? price,
    String? description,
    bool? isPublic,
    List<XFile>? newImages,
    List<String>? preservedUrls,
    List<String>? removedImageUrls,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    final docRef = _itemsCollection.doc(itemId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Предмет не знайдено');
    }

    final data = snapshot.data();
    if (data?['ownerId'] != user.uid) {
      throw Exception('Немає прав для редагування цього предмету');
    }

    if (removedImageUrls != null && removedImageUrls.isNotEmpty) {
      for (final url in removedImageUrls) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
        } catch (e) {
          debugPrint('Не вдалося видалити файл $url: $e');
        }
      }
    }

    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (category != null) updates['category'] = category;
    if (condition != null) updates['condition'] = condition;
    if (price != null) updates['price'] = price;
    if (description != null) updates['description'] = description;
    if (isPublic != null) updates['isPublic'] = isPublic;

    if (newImages != null && newImages.isNotEmpty) {
      final uploaded = await _uploadImages(user.uid, newImages);
      updates['imageUrls'] = [...?preservedUrls, ...uploaded];
    } else if (preservedUrls != null) {
      updates['imageUrls'] = preservedUrls;
    }

    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.update(updates);
    }
  }

  Future<void> deleteItem(String itemId, List<String> imageUrls) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    final docRef = _itemsCollection.doc(itemId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Предмет не знайдено');
    }

    final data = snapshot.data();
    if (data?['ownerId'] != user.uid) {
      throw Exception('Немає прав для видалення');
    }

    await docRef.delete();

    for (final url in imageUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (e) {
        debugPrint('Не вдалося видалити файл $url: $e');
      }
    }
  }

  Future<List<String>> _uploadImages(String userId, List<XFile> images) async {
    if (images.isEmpty) return <String>[];

    final List<String> urls = [];
    for (final image in images) {
      final ref = _storage.ref('items/$userId/${_uuid.v4()}');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final bytes = await image.readAsBytes();
      await ref.putData(bytes, metadata);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<UserProfile?> ensureCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final docRef = _userDoc(user.uid);
    final existing = await docRef.get();
    if (existing.exists) {
      return UserProfile.fromFirestore(existing);
    }

    final profile = UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Колекціонер',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      bio: null,
      collectionType: null,
      joinedAt: DateTime.now(),
    );

    await docRef.set({
      ...profile.toFirestore(),
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final snapshot = await docRef.get();
    return snapshot.exists ? UserProfile.fromFirestore(snapshot) : profile;
  }

  Stream<UserProfile?> watchCurrentUserProfile() {
    final user = currentUser;
    if (user == null) {
      return const Stream<UserProfile?>.empty();
    }

    ensureCurrentUserProfile();
    return _userDoc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromFirestore(snapshot);
    });
  }

  Future<void> updateUserProfile(
    UserProfile updatedUser,
    XFile? newPhoto,
  ) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    if (user.uid != updatedUser.uid) {
      throw Exception('Немає прав для редагування профілю');
    }

    String? photoUrl = updatedUser.photoUrl;
    if (newPhoto != null) {
      final ref = _storage.ref('profile/${user.uid}/photo.jpg');
      final bytes = await newPhoto.readAsBytes();
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(bytes, metadata);
      photoUrl = await ref.getDownloadURL();
    }

    final profileData = updatedUser.copyWith(photoUrl: photoUrl).toFirestore();
    profileData['photoUrl'] = photoUrl;

    await _userDoc(user.uid).set(profileData, SetOptions(merge: true));

    if (user.displayName != updatedUser.displayName ||
        user.photoURL != photoUrl) {
      await user.updateProfile(
        displayName: updatedUser.displayName,
        photoURL: photoUrl,
      );
      await user.reload();
    }
  }

  Stream<List<CollectionItem>> getUserPublicItems(String userId) {
    return _itemsCollection
        .where('ownerId', isEqualTo: userId)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(CollectionItem.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<UserProfile> getUserProfile(String userId) async {
    final docRef = _userDoc(userId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception('Користувач не знайдено');
    }

    final itemsSnapshot = await _itemsCollection
        .where('ownerId', isEqualTo: userId)
        .where('isPublic', isEqualTo: true)
        .get();

    final items = itemsSnapshot.docs
        .map(CollectionItem.fromFirestore)
        .toList(growable: false);

    final totalItems = items.length;
    final totalValue = items.fold<double>(
      0,
      (total, item) => total + item.price,
    );

    final profile = UserProfile.fromFirestore(snapshot);
    return profile.copyWith(totalItems: totalItems, totalValue: totalValue);
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    final user = currentUser;
    if (user == null || query.trim().isEmpty) {
      return [];
    }

    final searchTerm = query.trim().toLowerCase();

    final snapshot = await _firestore.collection('users').limit(100).get();

    final results = snapshot.docs
        .map((doc) => UserProfile.fromFirestore(doc))
        .where((profile) {
          if (profile.uid == user.uid) return false;
          
          final name = profile.displayName.toLowerCase();
          final type = profile.collectionType?.toLowerCase() ?? '';
          
          return name.contains(searchTerm) || type.contains(searchTerm);
        })
        .toList();

    return results;
  }
}
