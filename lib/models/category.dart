import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final Image image;
  final Color color;

  const Category({
    @required this.id,
    @required this.title,
    @required this.image,
    this.color = const Color.fromARGB(255, 186, 35, 35),
  });
}
