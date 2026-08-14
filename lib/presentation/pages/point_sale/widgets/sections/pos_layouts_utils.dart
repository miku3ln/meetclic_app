import 'package:flutter/cupertino.dart';
enum PosLayoutMode {
  modal,
  screen,
}
class PosThreeSectionLayout extends StatelessWidget {
  final Widget top;
  final Widget body;
  final Widget footer;
  final PosLayoutMode mode;
  const PosThreeSectionLayout({
    super.key,
    required this.top,
    required this.body,
    required this.footer,
    this.mode = PosLayoutMode.modal, // 👈 default
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final isKeyboardOpen = keyboardHeight > 0;

        final totalHeight = constraints.maxHeight;

        double topHeight;
        double bodyHeight;
        double footerHeight;

        if (mode == PosLayoutMode.modal) {
          /// 🔥 TU LÓGICA ACTUAL (MODAL)
          topHeight = totalHeight * 0.10;
          bodyHeight = isKeyboardOpen
              ? totalHeight * 0.60
              : totalHeight * 0.8;
          footerHeight = isKeyboardOpen
              ? totalHeight * 0.30
              : totalHeight * 0.10;
        } else {
          /// 🔥 NUEVA LÓGICA (PANTALLA NORMAL)
          topHeight = totalHeight * 0.10;
          if (isKeyboardOpen) {
            footerHeight = totalHeight * 0.35;
            bodyHeight = totalHeight - topHeight - footerHeight;
          } else {
            footerHeight = totalHeight * 0.20;
            bodyHeight = totalHeight - topHeight - footerHeight;
          }
        }

        return Column(
          children: [
            /// 🔝 TOP
            SizedBox(
              height: topHeight,
              child: SingleChildScrollView(
                child: top,
              ),
            ),

            /// 📜 BODY
            SizedBox(
              height: bodyHeight,
              child: SingleChildScrollView(
                child: body,
              ),
            ),

            /// 🔻 FOOTER
            SizedBox(
              height: footerHeight,
              child: footer,
            ),
          ],
        );
      },
    );
  }
}


class PosSectionController<T> extends ChangeNotifier {
  T _section;

  PosSectionController(this._section);

  T get section => _section;

  void setSection(T value) {
    if (_section == value) return;

    _section = value;
    notifyListeners();
  }
}