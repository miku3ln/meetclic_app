import 'package:flutter/material.dart';

class AtomStyles {
  // 📏 Medidas estándar

  static const double buttonHeight = 48;
  static const double buttonBorderRadius = 12;

  // Altura del campo dropdown (como input)
  // 📏 Dropdown Field
  static const double dropdownFieldHeight = 48;
  static const double dropdownPaddingVertical = 12;
  static const double dropdownPaddingHorizontal = 16;


  // Altura de los ítems del menú (opcional)
  static const double dropdownItemHeight = 40;

  // 🏷️ Tipografías
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    height: 1.4,
  );

  static const OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const TextStyle dropdownItemStyle = TextStyle(
    fontSize: 16,
    height: 1.4,
  );
}
