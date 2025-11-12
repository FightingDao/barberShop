import 'package:flutter/material.dart';

/// App主题配置 - 严格还原frontend_old的设计
class AppTheme {
  // 主色调 - 红色/粉色 (与frontend_old保持一致 #FF4D6A)
  static const Color primary = Color(0xFFFF4D6A);
  static const Color primaryLight = Color(0xFFFFE5EA);
  static const Color primaryDark = Color(0xFFE63950);

  // 辅助色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFF5222D);
  static const Color info = Color(0xFF1890FF);

  // 文字颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // 背景色
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF7F8FA);
  static const Color bgTertiary = Color(0xFFF0F0F0);

  // 边框色
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFF0F0F0);

  // 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 50.0;

  // 圆角别名（为了保持代码一致性）
  static const double radiusSm = radiusSmall;
  static const double radiusMd = radiusMedium;
  static const double radiusLg = radiusLarge;

  // 间距
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;

  // 间距别名（为了保持代码一致性）
  static const double paddingXs = spacingXS;
  static const double paddingSm = spacingSM;
  static const double paddingMd = spacingMD;
  static const double paddingLg = spacingLG;
  static const double paddingXl = spacingXL;
  static const double paddingXxl = spacingXXL;

  // 字体大小
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 13.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeMD = 15.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeHuge = 24.0;

  // 字体大小别名
  static const double fontSizeXs = fontSizeXS;
  static const double fontSizeSm = fontSizeSM;
  static const double fontSizeMd = fontSizeMD;
  static const double fontSizeLg = fontSizeLG;
  static const double fontSizeXl = fontSizeXL;

  // 阴影
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ];

  static List<BoxShadow> get shadowPrimary => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  // Material主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: bgSecondary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primary,
        error: error,
        surface: bgPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: fontSizeLG,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeLG,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: bgPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLG,
          vertical: spacingMD,
        ),
      ),
    );
  }
}
