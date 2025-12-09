// presentation/pages/more_page/widgets/organisms/more_sections_list_organism.dart

import 'package:flutter/material.dart';

import '../../models/more_section_model.dart';
import '../molecules/more_item_tile_molecule.dart';
import '../molecules/more_section_header_molecule.dart';

class MoreSectionsListOrganism extends StatelessWidget {
  final List<MoreSectionModel> sections;
  final ScrollController? scrollController;
  final double bottomExtraSpace;

  const MoreSectionsListOrganism({
    super.key,
    required this.sections,
    this.scrollController,
    this.bottomExtraSpace = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
        for (final section in sections) ...[
          MoreSectionHeaderMolecule(title: section.title),
          ...section.items.map((item) => MoreItemTileMolecule(item: item)),
          const Divider(height: 32, thickness: 8, color: Color(0xFFF3F3F3)),
        ],
        if (bottomExtraSpace > 0) SizedBox(height: bottomExtraSpace),
      ],
    );
  }
}
