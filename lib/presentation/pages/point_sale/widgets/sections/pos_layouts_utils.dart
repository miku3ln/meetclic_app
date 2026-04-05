import 'package:flutter/cupertino.dart';

class PosThreeSectionLayout extends StatelessWidget {
  final Widget top;
  final Widget body;
  final Widget footer;

  const PosThreeSectionLayout({
    super.key,
    required this.top,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final isKeyboardOpen = keyboardHeight > 0;
        final totalHeight = constraints.maxHeight;
        final topHeight = isKeyboardOpen
            ? totalHeight * 0.10
            : totalHeight * 0.15;
        final bodyHeight = isKeyboardOpen
            ? totalHeight * 0.60
            : totalHeight * 0.70;
        final footerHeight = isKeyboardOpen
            ? totalHeight * 0.30
            : totalHeight * 0.15;

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