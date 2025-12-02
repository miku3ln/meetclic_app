import 'package:flutter/material.dart';
void showTopModal( {
  required String title,
  required String contentText,
  required String buttonText,
  required VoidCallback onButtonPressed,

  double heightPercentage = 0.3,
  double borderRadius = 20,
  double padding = 16,
  Color backgroundColor = Colors.white,

  TextStyle? titleStyle,
  TextStyle? contentStyle,
  ButtonStyle? buttonStyle, required BuildContext context,
}) {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;
  final modalHeight = screenSize.height * heightPercentage;

  late OverlayEntry entry;
  final double appBarHeight = kToolbarHeight;  // estándar 56.0

  final double modalTopPosition = appBarHeight + 36.0;  // dejar un margen extra
  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        GestureDetector(
          onTap: () => entry.remove(),
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Positioned(
          top: modalTopPosition,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenSize.width,
              height: modalHeight,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(borderRadius),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: titleStyle ?? const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        contentText,
                        style: contentStyle ?? const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onButtonPressed();
                        entry.remove();
                      },
                      style: buttonStyle ?? ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
}
