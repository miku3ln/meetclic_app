import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/business_data.dart';

class NewsBusinessSection extends StatelessWidget {
  final BusinessData businessManagementData;
  const NewsBusinessSection({super.key, required this.businessManagementData});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Noticias", style: TextStyle(fontSize: 20)),
    );
  }
}
