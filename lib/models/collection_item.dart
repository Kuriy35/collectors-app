import 'package:flutter/material.dart';

class CollectionItem {
  final String id;
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String category;
  final String condition;
  final String price;
  final String? description;

  CollectionItem({
    required this.id,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'icon': icon,
    'iconBg': iconBg.toARGB32(),
    'iconColor': iconColor.toARGB32(),
    'title': title,
    'category': category,
    'condition': condition,
    'price': price,
    'description': description,
  };

  factory CollectionItem.fromJson(Map<String, dynamic> json) => CollectionItem(
    id: json['id'],
    icon: json['icon'],
    iconBg: Color(json['iconBg']),
    iconColor: Color(json['iconColor']),
    title: json['title'],
    category: json['category'],
    condition: json['condition'],
    price: json['price'],
    description: json['description'],
  );
}
