import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionItem {
  CollectionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    required this.ownerId,
    required this.ownerName,
    required this.imageUrls,
    required this.isPublic,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String title;
  final String category;
  final String condition;
  final double price;
  final String? description;
  final List<String> imageUrls;
  final String ownerId;
  final String ownerName;
  final bool isPublic;
  final DateTime createdAt;

  factory CollectionItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};

    return CollectionItem(
      id: snapshot.id,
      title: data['title'] as String? ?? 'Без назви',
      category: data['category'] as String? ?? 'Невідомо',
      condition: data['condition'] as String? ?? 'Невідомо',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      description: data['description'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? 'Колекціонер',
      isPublic: data['isPublic'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'condition': condition,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class UserProfile {
  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.collectionType,
    required this.joinedAt,
    this.totalItems,
    this.totalValue,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? collectionType;
  final DateTime joinedAt;
  final int? totalItems;
  final double? totalValue;

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return UserProfile(
      uid: snapshot.id,
      displayName: data['displayName'] as String? ?? 'Колекціонер',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      collectionType: data['collectionType'] as String?,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalItems: (data['totalItems'] as num?)?.toInt(),
      totalValue: (data['totalValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'collectionType': collectionType,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? bio,
    String? collectionType,
    DateTime? joinedAt,
    int? totalItems,
    double? totalValue,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      collectionType: collectionType ?? this.collectionType,
      joinedAt: joinedAt ?? this.joinedAt,
      totalItems: totalItems ?? this.totalItems,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}
