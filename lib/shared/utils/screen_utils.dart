class AppBarTitleConfig {
  final int primaryFlex;
  final int secondaryFlex;

  const AppBarTitleConfig({
    required this.primaryFlex,
    required this.secondaryFlex,
  });
}

class ScreenUtils {
  ScreenUtils._();

  static AppBarTitleConfig appBarConfigTitle({
    required double width,
    required double height,
    required bool isLandscape,
    required bool isTablet,
  }) {
    if (isTablet) {
      return const AppBarTitleConfig(
        primaryFlex: 30,
        secondaryFlex: 70,
      );
    }

    if (isLandscape) {
      return const AppBarTitleConfig(
        primaryFlex: 50,
        secondaryFlex: 50,
      );
    }

    return const AppBarTitleConfig(
      primaryFlex: 70,
      secondaryFlex: 30,
    );
  }
}
