import 'package:flutter/material.dart';

import '../../helpers/more_navigation.dart';
import '../../models/more_item_model.dart';

class MoreItemTileMolecule extends StatelessWidget {
  final MoreItemModel item;

  const MoreItemTileMolecule({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      subtitle: Text(item.description),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => MoreNavigation.handleItemTap(context, item.id),
    );
  }
}
