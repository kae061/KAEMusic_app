import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // Dark theme colors
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF161616);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE8E8E8);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Common colors
  static const Color primary = Color(0xFF5A0E1A);
  static const Color primaryLight = Color(0xFF801424);
  static const Color primaryDark = Color(0xFF38050E);

  static const Color accent = Color(0xFF9E1B32);
  static const Color accentLight = Color(0xFFC82333);

  // Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextDisabled = Color(0xFF555555);

  // Light theme text colors
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextDisabled = Color(0xFFAAAAAA);

  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD740);

  static const List<Color> primaryGradient = [
    Color(0xFF5A0E1A),
    Color(0xFF38050E),
  ];
  static const List<Color> darkBackgroundGradient = [
    Color(0xFF141414),
    Color(0xFF0D0D0D),
  ];
  static const List<Color> darkCardGradient = [
    Color(0xFF1C1C1C),
    Color(0xFF141414),
  ];
  static const List<Color> accentGradient = [
    Color(0xFF801424),
    Color(0xFF5A0E1A),
  ];

  // Backwards compatibility - defaults to dark theme colors (const)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceVariant = darkSurfaceVariant;
  static const Color card = darkCard;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textDisabled = darkTextDisabled;
  static const List<Color> backgroundGradient = darkBackgroundGradient;
  static const List<Color> cardGradient = darkCardGradient;
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: GoogleFonts.outfit(
                fontSize: 57,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
                letterSpacing: -0.5,
              ),
              displayMedium: GoogleFonts.outfit(
                fontSize: 45,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
              displaySmall: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
              headlineLarge: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
              headlineMedium: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
              headlineSmall: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
              titleLarge: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextPrimary,
              ),
              titleSmall: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextPrimary,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.darkTextPrimary,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.darkTextSecondary,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
              labelLarge: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary, size: 24),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.darkSurfaceVariant,
        thumbColor: AppColors.primaryLight,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.darkSurfaceVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.outfit(
                fontSize: 57,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
                letterSpacing: -0.5,
              ),
              displayMedium: GoogleFonts.outfit(
                fontSize: 45,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
              displaySmall: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
              headlineLarge: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
              headlineMedium: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
              headlineSmall: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
              titleLarge: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextPrimary,
              ),
              titleSmall: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextPrimary,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightTextSecondary,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
              labelLarge: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary, size: 24),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.lightSurfaceVariant,
        thumbColor: AppColors.primaryLight,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.lightSurfaceVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.lightTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}