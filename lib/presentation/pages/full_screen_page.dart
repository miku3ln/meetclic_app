import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/presentation/filters/widgets/atoms/custom_switch_tile.dart';
import 'package:meetclic_app/presentation/filters/widgets/custom_filter_group.dart';
import 'package:meetclic_app/presentation/filters/widgets/custom_section_title.dart';
import 'package:meetclic_app/presentation/filters/widgets/custom_slider.dart';
import 'package:meetclic_app/presentation/filters/widgets/molecules/custom_radio_list.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';

class FullScreenPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const FullScreenPage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  double price = 2000;
  double discount = 58;
  bool showOnlyAvailable = false;
  String? selectedWarranty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PRICE RANGE
              const CustomSectionTitle(title: 'Price Range'),
              CustomSlider(
                min: 1299,
                max: 3999,
                initial: price,
                onChanged: (val) => setState(() => price = val),
              ),

              const SizedBox(height: 12),

              /// DISCOUNT
              const CustomSectionTitle(title: 'Discount'),
              CustomSlider(
                min: 0,
                max: 100,
                initial: discount,
                suffix: '%',
                onChanged: (val) => setState(() => discount = val),
              ),

              const SizedBox(height: 16),

              /// BRAND GROUP
              const CustomFilterGroup(
                title: 'Brand',
                options: [
                  'Philips',
                  'Sony',
                  'JBL',
                  'Headphones',
                  'Sennheiser',
                  'Motorola',
                  'Zebronics',
                  'iBall',
                  'Signature',
                  'Generic',
                ],
              ),

              const SizedBox(height: 16),

              /// FEATURES GROUP
              const CustomFilterGroup(
                title: 'Features',
                options: [
                  'Wireless',
                  'Noise Cancelling',
                  'Sports',
                  'With Microphone',
                  'Tangle Free Cord',
                ],
              ),

              const SizedBox(height: 16),

              /// CONNECTIVITY GROUP
              const CustomFilterGroup(
                title: 'Connectivity Technology',
                options: [
                  'Wired-3.5 MM Single Pin',
                  'Bluetooth Wireless',
                  'Wired USB',
                ],
              ),

              const SizedBox(height: 16),

              /// AVAILABILITY (SWITCH)
              const CustomSectionTitle(title: 'Availability'),
              CustomSwitchTile(
                label: 'Show Only Available',
                value: showOnlyAvailable,
                onChanged: (val) => setState(() => showOnlyAvailable = val),
              ),

              const SizedBox(height: 16),

              /// WARRANTY (RADIO)
              const CustomSectionTitle(title: 'Warranty'),
              CustomRadioList(
                options: ['6 Months', '1 Year', '2 Years'],
                selected: selectedWarranty,
                onChanged: (val) => setState(() => selectedWarranty = val),
                label: '',
              ),

              /*
              CustomCheckboxList(
                options: ['6 Months', '1 Year', '2 Years'],
                selected: selectedWarranty,
                onChanged: (val) => setState(() => null), label: '',
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
