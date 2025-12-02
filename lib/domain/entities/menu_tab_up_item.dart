import 'package:flutter/material.dart';



class MenuTabUpItem {
  final int id;
  final String name;
  final String asset;
  final double number;
  final VoidCallback? onTap;
  MenuTabUpItem({
    required this.id,

    required this.name,
    required this.asset,
    required this.number,
     this.onTap,
  });
}