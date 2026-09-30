import 'package:flutter/material.dart';

/// پالت رنگ حرفه‌ای تأسیسات‌یار: سرمه‌ای تیره + سفید + خاکستری روشن + تأکید آبی/فیروزه‌ای
class TyColors {
  TyColors._();
  static const navy = Color(0xFF0E2A47);
  static const navyLight = Color(0xFF1A3C60);
  static const teal = Color(0xFF0EA5A5);
  static const blue = Color(0xFF1E88E5);
  static const bgLight = Color(0xFFF4F6F9);
  static const bgDark = Color(0xFF0B1622);
  static const surfaceDark = Color(0xFF13253A);
  static const textDark = Color(0xFF1B2A38);
  static const success = Color(0xFF2E9E5B);
  static const warning = Color(0xFFE0A100);
  static const danger = Color(0xFFD64545);
}

class TyTheme {
  TyTheme._();

  static const String fontFamily = 'Vazirmatn';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: TyColors.teal,
      brightness: Brightness.light,
      primary: TyColors.navy,
      secondary: TyColors.teal,
      surface: Colors.white,
    );
    return _base(scheme, TyColors.bgLight);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: TyColors.teal,
      brightness: Brightness.dark,
      primary: const Color(0xFF64D8D8),
      secondary: TyColors.teal,
      surface: TyColors.surfaceDark,
    );
    return _base(scheme, TyColors.bgDark);
  }

  static ThemeData _base(ColorScheme scheme, Color scaffoldBg) {
    final base = ThemeData(brightness: scheme.brightness, useMaterial3: true);
    final textTheme = base.textTheme.apply(fontFamily: fontFamily);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.brightness == Brightness.light ? TyColors.navy : TyColors.surfaceDark,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: const TextStyle(
            fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TyColors.teal, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: TyColors.teal,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.55),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 11),
      ),
    );
  }
}

String levelLabel(String level) => switch (level) {
      'easy' => 'بررسی ساده',
      'hard' => 'تخصصی / تکنسین',
      _ => 'نیازمند بررسی فنی',
    };

Color levelColor(String level) => switch (level) {
      'easy' => TyColors.success,
      'hard' => TyColors.danger,
      _ => TyColors.warning,
    };
