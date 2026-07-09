import 'package:flutter/material.dart';

import '../../../../../../../../shared/widgets/search_filter/models/filter_field.dart';
import '../../../../../../../../shared/widgets/search_filter/models/filter_item.dart';
import '../../../../../../../../shared/widgets/search_filter/models/search_filter_config.dart';

final configFilters = SearchFilterConfig(
  hint: "Buscar artículos",
  drawerTitle: "Filtros",
  fields: [
    FilterField<String>(
      id: "code",
      label: "Código",
      hint: "Ingrese un código",
      type: FilterFieldType.text,
    ),

    //-----------------------------------------
    // DROPDOWN
    //-----------------------------------------

    FilterField<String>(
      id: "status",
      label: "Estado",
      hint: "Seleccione un estado",
      type: FilterFieldType.dropdown,
      items: [

        FilterItem(
          id: "1",
          label: "Activo",
          value: "ACTIVE",
          icon: Icons.check_circle_rounded,
        ),

        FilterItem(
          id: "2",
          label: "Inactivo",
          value: "INACTIVE",
          icon: Icons.cancel_rounded,
        ),

      ],
    ),

    //-----------------------------------------
    // MULTI SELECT
    //-----------------------------------------

    FilterField<int>(
      id: "category",
      label: "Categorías",
      type: FilterFieldType.multiSelect,
      multiple: true,
      items: [

        FilterItem(
          id: "1",
          label: "Menú",
          value: 1,
          icon: Icons.restaurant_menu_rounded,
        ),

        FilterItem(
          id: "2",
          label: "Materia Prima",
          value: 2,
          icon: Icons.inventory_2_rounded,
        ),

        FilterItem(
          id: "3",
          label: "Bebidas",
          value: 3,
          icon: Icons.local_bar_rounded,
        ),

      ],
    ),

    //-----------------------------------------
    // CHECKBOX
    //-----------------------------------------

    FilterField<bool>(
      id: "favorite",
      label: "Solo favoritos",
      type: FilterFieldType.checkbox,
      defaultValue: false,
    ),

    //-----------------------------------------
    // RADIO
    //-----------------------------------------

    FilterField<String>(
      id: "stock",
      label: "Disponibilidad",
      type: FilterFieldType.radio,
      items: [

        FilterItem(
          id: "1",
          label: "Con Stock",
          value: "STOCK",
        ),

        FilterItem(
          id: "2",
          label: "Sin Stock",
          value: "EMPTY",
        ),

      ],
    ),

    //-----------------------------------------
    // SWITCH
    //-----------------------------------------

    FilterField<bool>(
      id: "enabled",
      label: "Mostrar solo activos",
      type: FilterFieldType.switchField,
      defaultValue: true,
    ),

    //-----------------------------------------
    // DATE
    //-----------------------------------------

    FilterField<DateTime>(
      id: "createdAt",
      label: "Fecha creación",
      hint: "Seleccione una fecha",
      type: FilterFieldType.date,
    ),

    //-----------------------------------------
    // DATE RANGE
    //-----------------------------------------

    FilterField<DateTime>(
      id: "period",
      label: "Periodo",
      hint: "Seleccione un rango",
      type: FilterFieldType.dateRange,
    ),

    //-----------------------------------------
    // NUMBER
    //-----------------------------------------

    FilterField<int>(
      id: "quantity",
      label: "Cantidad mínima",
      hint: "0",
      type: FilterFieldType.number,
      minValue: 0,
      maxValue: 1000,
    ),

    //-----------------------------------------
    // NUMBER RANGE
    //-----------------------------------------

    FilterField<double>(
      id: "price",
      label: "Rango de precio",
      type: FilterFieldType.numberRange,
      minValue: 0,
      maxValue: 500,
    ),

  ],
);