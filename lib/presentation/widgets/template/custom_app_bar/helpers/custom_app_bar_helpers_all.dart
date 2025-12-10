import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';

import '../models/custom_app_bar_all_model.dart';

HeaderSectionModel buildButtonsSectionFromMenuItems(List<MenuTabUpItem> items) {
  return HeaderSectionModel(
    type: HeaderSectionType.buttons,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: items.map((item) {
        return IconButton(
          icon: Image.asset(item.asset, width: 26, height: 26),
          onPressed: item.onTap,
        );
      }).toList(),
    ),
  );
}

HeaderLayoutConfiguration buildTripleColumnHeader(List<MenuTabUpItem> items) {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: [0.20, 0.50, 0.30],
    sections: [
      // 0.20 IMAGEICONO (logo o avatar)
      const HeaderSectionModel(
        type: HeaderSectionType.imageIcon,
        content: Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/meetclic_logo.png'),
          ),
        ),
      ),

      // 0.50 TEXTINPUT (texto o input)
      const HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar negocios, productos, categorías…',
            border: InputBorder.none,
          ),
        ),
      ),

      // 0.30 BUTTONS (tus íconos de gamificación)
      buildButtonsSectionFromMenuItems(items),
    ],
  );
}

HeaderLayoutConfiguration buildDoubleLeftHeader(List<MenuTabUpItem> items) {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnLeftWeighted,
    percentages: [0.70, 0.30],
    sections: [
      // 0.70 TEXTINPUT
      const HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar en MeetClic…',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),

      // 0.30 BUTTONS
      buildButtonsSectionFromMenuItems(items),
    ],
  );
}

HeaderLayoutConfiguration buildSingleFullButtons(List<MenuTabUpItem> items) {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.singleColumnFullWidth,
    percentages: [1.0],
    sections: [buildButtonsSectionFromMenuItems(items)],
  );
}

HeaderLayoutConfiguration buildSingleFullTitle(String title) {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.singleColumnFullWidth,
    percentages: [1.0],
    sections: [
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
}

HeaderLayoutConfiguration buildDoubleRightAvatarButtons() {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnRightWeighted,
    percentages: [0.25, 0.75],
    sections: [
      // 0.25 IMAGEICONO (avatar)
      const HeaderSectionModel(
        type: HeaderSectionType.imageIcon,
        content: Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/user_avatar.png'),
          ),
        ),
      ),

      // 0.75 BUTTONS (acciones rápidas)
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ],
  );
}

HeaderLayoutConfiguration buildDoubleRightLogoSearch() {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnRightWeighted,
    percentages: [0.25, 0.75],
    sections: [
      const HeaderSectionModel(
        type: HeaderSectionType.imageIcon,
        content: Align(
          alignment: Alignment.centerLeft,
          child: FlutterLogo(size: 30),
        ),
      ),
      const HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar productos y negocios…',
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  );
}
