import 'package:flutter/material.dart';

import 'controller/search_filter_controller.dart';
import 'models/filter_field.dart';
import 'models/search_filter_config.dart';


class FilterDrawer extends StatefulWidget {
  final SearchFilterController controller;

  final SearchFilterConfig config;

  const FilterDrawer({
    super.key,
    required this.controller,
    required this.config,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: SizedBox(
            width: size.width * .88,
            height: size.height,
            child: Column(
              children: [

                _buildHeader(),

                const Divider(height: 1),

                Expanded(
                  child: _buildBody(),
                ),

                const Divider(height: 1),

                _buildFooter(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  //------------------------------------------------------
  // HEADER
  //------------------------------------------------------

  Widget _buildHeader() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        16,
        20,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              widget.config.drawerTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
          ),

          IconButton(
            onPressed: (){

              widget.controller.cancel();

              Navigator.pop(context);

            },
            icon: const Icon(
              Icons.close,
            ),
          ),

        ],
      ),
    );
  }

  //------------------------------------------------------
  // BODY
  //------------------------------------------------------

  Widget _buildBody() {

    return ListView.separated(

      padding: const EdgeInsets.all(20),

      itemCount: widget.config.fields.length,

      separatorBuilder: (_,__){

        return const SizedBox(
          height: 18,
        );

      },

      itemBuilder: (_,index){

        final field = widget.config.fields[index];

        if(!field.visible){

          return const SizedBox.shrink();

        }

        return Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(

              field.label,

              style: Theme.of(context)
                  .textTheme
                  .titleSmall,

            ),

            const SizedBox(
              height: 8,
            ),

            _buildField(field),

          ],

        );

      },

    );

  }

  //------------------------------------------------------
  // FOOTER
  //------------------------------------------------------

  Widget _buildFooter() {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [

          Expanded(
            child: OutlinedButton(

              onPressed: (){

                widget.controller.resetFilters();

                setState(() {

                });

              },

              child: const Text(
                "Limpiar",
              ),

            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: FilledButton(

              onPressed: (){

                widget.controller.apply();

                Navigator.pop(context);

              },

              child: const Text(
                "Aplicar",
              ),

            ),
          ),

        ],
      ),
    );
  }

  //------------------------------------------------------
  // FACTORY
  //------------------------------------------------------

  Widget _buildField(FilterField field) {
    switch (field.type) {

      case FilterFieldType.dropdown:
        return DropdownButtonFormField(
          value: widget.controller.getValue(field.id),

          items: field.items.map<DropdownMenuItem>((item) {
            return DropdownMenuItem(
              value: item.value,
              child: Text(item.label),
            );
          }).toList(),

          onChanged: (value) {
            final selectedItem = field.items.firstWhere(
                  (e) => e.value == value,
            );

            widget.controller.setValue(
              field.id,
              value,
              selectedItem.label, // 👈 IMPORTANTE
            );

            setState(() {});
          },
        );

      default:
        return const SizedBox();
    }
  }


}