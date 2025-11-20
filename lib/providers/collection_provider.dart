import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_toast.dart';
import '../models/collection_item.dart';
import '../repositories/collection_repository.dart';

class CollectionProvider extends ChangeNotifier {
  CollectionProvider(this._repository) {
    _initAuthListener();
  }

  final CollectionRepository _repository;
  StreamSubscription<User?>? _authSubscription;

  List<CollectionItem> _myItems = [];
  List<CollectionItem> _publicItems = [];
  List<CollectionItem> _discoverItems = [];
  UserProfile? _userProfile;
  bool _isLoadingMy = false;
  bool _isLoadingPublic = false;
  bool _isLoadingDiscover = false;
  bool _isMutating = false;
  String? _error;

  StreamSubscription<List<CollectionItem>>? _myItemsSub;
  StreamSubscription<List<CollectionItem>>? _publicItemsSub;
  StreamSubscription<List<CollectionItem>>? _discoverItemsSub;
  StreamSubscription<UserProfile?>? _profileSubscription;

  List<CollectionItem> get myItems => List.unmodifiable(_myItems);
  List<CollectionItem> get publicItems => List.unmodifiable(_publicItems);
  List<CollectionItem> get discoverItems => List.unmodifiable(_discoverItems);
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoadingMy || _isLoadingPublic || _isLoadingDiscover || _isMutating;
  String? get error => _error;
  double get myItemsTotalValue =>
      _myItems.fold<double>(0, (sum, item) => sum + item.price);
  int get myItemsCount => _myItems.length;

  bool _disposed = false;

  void _initAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (_disposed) return;
      _resetState();
      if (user != null) {
        _initialize(userId: user.uid);
        loadMyItems(userId: user.uid);
        loadPublicItems();
        _subscribeToProfile();
        // loadDiscoverItems(); // If needed
      }
    });
  }

  void _resetState() {
    _myItemsSub?.cancel();
    _publicItemsSub?.cancel();
    _discoverItemsSub?.cancel();
    _profileSubscription?.cancel();
    _myItemsSub = null;
    _publicItemsSub = null;
    _discoverItemsSub = null;
    _profileSubscription = null;

    _myItems = [];
    _publicItems = [];
    _discoverItems = [];
    _userProfile = null;
    _error = null;
    _isLoadingMy = false;
    _isLoadingPublic = false;
    _isLoadingDiscover = false;
  }

  Future<void> _initialize({String? userId}) async {
    await Future.wait([
      loadMyItems(userId: userId),
      loadPublicItems(),
      loadDiscoverItems(),
    ]);
  }

  Future<void> loadMyItems({String? userId}) async {
    _myItemsSub?.cancel();

    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _myItems = [];
      notifyListeners();
      return;
    }

    final completer = Completer<void>();
    _isLoadingMy = true;
    notifyListeners();

    _myItemsSub = _repository.getMyItems(userId: uid).listen(
      (items) {
        _myItems = items;
        _isLoadingMy = false;
        _error = null;
        if (!completer.isCompleted) completer.complete();
        notifyListeners();
      },
      onError: (error) {
        _isLoadingMy = false;
        _error = 'Не вдалося завантажити ваші предмети';
        debugPrint('CollectionProvider.loadMyItems error: $error');
        if (!completer.isCompleted) completer.completeError(error);
        notifyListeners();
      },
    );

    return completer.future;
  }

  Future<void> refreshMyItems() => loadMyItems();

  Future<void> loadPublicItems() async {
    _publicItemsSub?.cancel();

    final completer = Completer<void>();
    _isLoadingPublic = true;
    notifyListeners();

    _publicItemsSub = _repository.getPublicItems().listen(
      (items) {
        _publicItems = items;
        _isLoadingPublic = false;
        _error = null;
        if (!completer.isCompleted) completer.complete();
        notifyListeners();
      },
      onError: (error) {
        _isLoadingPublic = false;
        _error = 'Не вдалося завантажити публічні предмети';
        debugPrint('CollectionProvider.loadPublicItems error: $error');
        if (!completer.isCompleted) completer.completeError(error);
        notifyListeners();
      },
    );

    return completer.future;
  }

  Future<void> loadDiscoverItems() async {
    _discoverItemsSub?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _discoverItems = [];
      notifyListeners();
      return;
    }

    final completer = Completer<void>();
    _isLoadingDiscover = true;
    notifyListeners();

    _discoverItemsSub = _repository.getDiscoverItems().listen(
      (items) {
        _discoverItems = items;
        _isLoadingDiscover = false;
        _error = null;
        if (!completer.isCompleted) completer.complete();
        notifyListeners();
      },
      onError: (error) {
        _isLoadingDiscover = false;
        _error = 'Не вдалося завантажити предмети для перегляду';
        debugPrint('CollectionProvider.loadDiscoverItems error: $error');
        if (!completer.isCompleted) completer.completeError(error);
        notifyListeners();
      },
    );

    return completer.future;
  }

  void _subscribeToProfile() {
    _profileSubscription?.cancel();
    _profileSubscription = _repository.watchCurrentUserProfile().listen(
      (profile) {
        _userProfile = profile;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error listening to profile: $e');
      },
    );
  }

  Future<void> refreshAll() async {
    await Future.wait([loadMyItems(), loadPublicItems(), loadDiscoverItems()]);
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
    _isMutating = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.addItem(
        title: title,
        category: category,
        condition: condition,
        price: price,
        description: description,
        images: images,
        isPublic: isPublic,
      );
    } catch (e, stackTrace) {
      debugPrint('CollectionProvider.addItem error: $e\n$stackTrace');
      _error = 'Не вдалося додати предмет';
      rethrow;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
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
    _isMutating = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateItem(
        itemId: itemId,
        title: title,
        category: category,
        condition: condition,
        price: price,
        description: description,
        isPublic: isPublic,
        newImages: newImages,
        preservedUrls: preservedUrls,
        removedImageUrls: removedImageUrls,
      );
    } catch (e, stackTrace) {
      debugPrint('CollectionProvider.updateItem error: $e\n$stackTrace');
      _error = 'Не вдалося оновити предмет';
      rethrow;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  void deleteItemLocally(CollectionItem item) {
    _myItems = List.from(_myItems)..removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  Future<void> deleteItem(BuildContext context, String itemId, List<String> imageUrls) async {
    // Background delete - no loading state to avoid blocking UI
    try {
      await _repository.deleteItem(itemId, imageUrls);
      if (context.mounted) {
        CustomToast.showSuccess(context, 'Предмет видалено');
      }
    } catch (e) {
      debugPrint('CollectionProvider.deleteItem error: $e');
      if (context.mounted) {
        CustomToast.showError(context, 'Не вдалося видалити предмет: $e');
      }
      // Optionally reload items if delete failed to restore state
      loadMyItems();
    }
  }

  Stream<List<CollectionItem>> getUserPublicItems(String userId) {
    return _repository.getUserPublicItems(userId);
  }

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      return await _repository.getUserProfile(userId);
    } catch (e) {
      debugPrint('CollectionProvider.getUserProfile error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _myItemsSub?.cancel();
    _publicItemsSub?.cancel();
    _discoverItemsSub?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
