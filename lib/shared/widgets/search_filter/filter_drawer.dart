import 'package:flutter/material.dart';

import '../../theme/configuration/app_theme_tokens.dart';
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
  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final size = MediaQuery.of(context).size;

    final drawerWidth = size.width > 500
        ? 430.0
        : size.width * .92;

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: size.height,
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadow,
                  blurRadius: 30,
                  offset: const Offset(-8, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
              child: Column(
                children: [

                  _buildHeader(),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: tokens.border,
                  ),

                  Expanded(
                    child: Container(
                      color: tokens.background,
                      child: _buildBody(),
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: tokens.border,
                  ),

                  _buildFooter(),

                ],
              ),
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
    final tokens = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        20,
        20,
      ),
      color: tokens.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tokens.selectedBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: tokens.primary,
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.config.drawerTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Selecciona los criterios para filtrar la información.",
                  style: TextStyle(
                    fontSize: 13,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                widget.controller.cancel();
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: tokens.textSecondary,
                ),
              ),
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
    final tokens = AppThemeTokens.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        24,
      ),
      itemCount: widget.config.fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (_, index) {
        final field = widget.config.fields[index];

        if (!field.visible) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: tokens.border,
            ),
            boxShadow: [
              BoxShadow(
                color: tokens.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// LABEL
              Row(
                children: [
                  if (field.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        field.icon,
                        size: 20,
                        color: tokens.primary,
                      ),
                    ),

                  Expanded(
                    child: Text(
                      field.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                field.hint ?? "Seleccione una opción",
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              _buildField(field),
            ],
          ),
        );
      },
    );
  }

  //------------------------------------------------------
  // FOOTER
  //------------------------------------------------------

  Widget _buildFooter() {
    final tokens = AppThemeTokens.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24,
        ),
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(
            top: BorderSide(
              color: tokens.border,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  widget.controller.apply();
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.buttonPrimaryBackground,
                  foregroundColor: tokens.buttonPrimaryForeground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  "Aplicar filtros",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  widget.controller.resetFilters();
                  setState(() {});
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: tokens.textSecondary,
                ),
                label: Text(
                  "Limpiar filtros",
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //------------------------------------------------------
  // FACTORY
  //------------------------------------------------------

  Widget _buildField(FilterField field) {
    switch (field.type) {
      case FilterFieldType.text:
        return _buildTextField(field);

      case FilterFieldType.dropdown:
        return _buildDropdown(field);

      case FilterFieldType.multiSelect:
        return _buildMultiSelect(field);

      case FilterFieldType.checkbox:
        return _buildCheckbox(field);

      case FilterFieldType.radio:
        return _buildRadio(field);

      case FilterFieldType.switchField:
        return _buildSwitch(field);

      case FilterFieldType.date:
        return _buildDate(field);

      case FilterFieldType.dateRange:
        return _buildDateRange(field);

      case FilterFieldType.number:
        return _buildNumber(field);

      case FilterFieldType.numberRange:
        return _buildNumberRange(field);
    }
  }
  Widget _buildNumberRange(FilterField field) {
    final tokens = AppThemeTokens.of(context);

    final RangeValues values =
        widget.controller.getValue<RangeValues>(field.id) ??
            RangeValues(
              (field.minValue as double?) ?? 0,
              (field.maxValue as double?) ?? 100,
            );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tokens.border,
        ),
      ),
      child: Column(
        children: [

          Row(
            children: [

              Text(
                values.start.toStringAsFixed(0),
                style: TextStyle(
                  color: tokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Text(
                values.end.toStringAsFixed(0),
                style: TextStyle(
                  color: tokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: tokens.primary,
              inactiveTrackColor: tokens.border,
              thumbColor: tokens.primary,
              overlayColor: tokens.primary.withOpacity(.15),
              trackHeight: 4,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 9,
              ),
            ),
            child: RangeSlider(
              min: (field.minValue as double?) ?? 0,
              max: (field.maxValue as double?) ?? 100,
              values: values,
              divisions: 20,
              labels: RangeLabels(
                values.start.toStringAsFixed(0),
                values.end.toStringAsFixed(0),
              ),
              onChanged: (newValues) {

                widget.controller.setValue(
                  field.id,
                  newValues,
                  "${newValues.start.toStringAsFixed(0)} - ${newValues.end.toStringAsFixed(0)}",
                );

                setState(() {});
              },
            ),
          ),

        ],
      ),
    );
  }
  Widget _buildTextField(FilterField field){
    return TextFormField(
      decoration: _inputDecoration(field),
    );
  }
  Widget _buildNumber(FilterField field){
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(field),
    );
  }
  Widget _buildDate(FilterField field) {
    final tokens = AppThemeTokens.of(context);

    final DateTime? value =
    widget.controller.getValue<DateTime>(field.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {

        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (date == null) return;

        widget.controller.setValue(
          field.id,
          date,
          "${date.day}/${date.month}/${date.year}",
        );

        setState(() {});
      },
      child: IgnorePointer(
        child: TextFormField(
          controller: TextEditingController(
            text: value == null
                ? ""
                : "${value.day}/${value.month}/${value.year}",
          ),
          decoration: _inputDecoration(field).copyWith(
            suffixIcon: Icon(
              Icons.calendar_month_rounded,
              color: tokens.primary,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDateRange(FilterField field){
    final tokens = AppThemeTokens.of(context);

    final DateTime? value = widget.controller.getValue<DateTime>(field.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {

        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (date == null) return;

        widget.controller.setValue<DateTime>(
          field.id,
          date,
          "${date.day}/${date.month}/${date.year}",
        );

        setState(() {});
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: tokens.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [

            Icon(
              Icons.calendar_today_rounded,
              color: tokens.primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                value == null
                    ? (field.hint ?? "Seleccione una fecha")
                    : "${value.day}/${value.month}/${value.year}",
              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildSwitch(FilterField field){

    return SwitchListTile.adaptive(

      value: widget.controller.getValue(field.id) ?? false,

      contentPadding: EdgeInsets.zero,

      title: Text(field.label),

      onChanged: (value){

        widget.controller.setValue(
          field.id,
          value,
          value ? "Sí" : "No",
        );

        setState(() {});
      },
    );

  }
  Widget _buildCheckbox(FilterField field){

    return CheckboxListTile(

      value: widget.controller.getValue(field.id) ?? false,

      contentPadding: EdgeInsets.zero,

      title: Text(field.label),

      onChanged: (value){

        widget.controller.setValue(
          field.id,
          value,
          value == true ? "Sí" : "No",
        );

        setState(() {});
      },
    );

  }
  Widget _buildRadio(FilterField field){

    final value = widget.controller.getValue(field.id);

    return Column(

      children: field.items.map((item){

        return RadioListTile(

          value: item.value,

          groupValue: value,

          title: Text(item.label),

          onChanged: (v){

            widget.controller.setValue(
              field.id,
              v,
              item.label,
            );

            setState(() {});
          },

        );

      }).toList(),

    );

  }
  Widget _buildMultiSelect(FilterField field){

    final values = widget.controller.getValue<List>(field.id) ?? [];

    return Column(

      children: field.items.map((item){

        final selected = values.contains(item.value);

        return CheckboxListTile(

          value: selected,

          title: Text(item.label),

          contentPadding: EdgeInsets.zero,

          onChanged: (checked){

            final newValues = List.of(values);

            if(checked==true){

              newValues.add(item.value);

            }else{

              newValues.remove(item.value);

            }

            widget.controller.setValue(
              field.id,
              newValues,
              "${newValues.length} seleccionados",
            );

            setState((){});

          },

        );

      }).toList(),

    );

  }
  InputDecoration _inputDecoration(FilterField field) {
    final tokens = AppThemeTokens.of(context);

    return InputDecoration(
      hintText: field.hint ?? field.placeholder,
      filled: true,
      fillColor: tokens.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: tokens.primary,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
  Widget _buildDropdown(FilterField field){
    final tokens = AppThemeTokens.of(context);

    return DropdownButtonFormField(
      value: widget.controller.getValue(field.id),
      isExpanded: true,
      borderRadius: BorderRadius.circular(16),
      dropdownColor: tokens.surface,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: tokens.iconMuted,
      ),
      style: TextStyle(
        color: tokens.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: field.hint ?? "Seleccione una opción",
        hintStyle: TextStyle(
          color: tokens.textSecondary,
        ),
        filled: true,
        fillColor: tokens.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: tokens.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: tokens.primary,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      items: field.items.map<DropdownMenuItem>((item) {
        return DropdownMenuItem(
          value: item.value,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 18,
                  color: item.color ?? tokens.primary,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        final selectedItem = field.items.firstWhere(
              (e) => e.value == value,
        );

        widget.controller.setValue(
          field.id,
          value,
          selectedItem.label,
        );

        setState(() {});
      },
    );
  }
}