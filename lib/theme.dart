import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
class AppColors {
  // Backgrounds
  static const Color background    = Color(0xFF080C18);
  static const Color surface       = Color(0xFF0E1426);
  static const Color card          = Color(0xFF131D33);
  static const Color cardElevated  = Color(0xFF192340);
  static const Color border        = Color(0xFF243055);

  // Brand / Primary
  static const Color primary       = Color(0xFF4F8EF7);
  static const Color primaryLight  = Color(0xFF7EB3FF);
  static const Color primaryGlow   = Color(0x334F8EF7);

  // Accents
  static const Color cyan          = Color(0xFF00D4FF);
  static const Color purple        = Color(0xFF9B5DE5);
  static const Color teal          = Color(0xFF00C8A0);

  // Status
  static const Color success       = Color(0xFF00C897);
  static const Color successGlow   = Color(0x3300C897);
  static const Color warning       = Color(0xFFFF9F43);
  static const Color warningGlow   = Color(0x33FF9F43);
  static const Color error         = Color(0xFFFF4757);
  static const Color errorGlow     = Color(0x33FF4757);
  static const Color info          = Color(0xFF4F8EF7);
  static const Color infoGlow      = Color(0x334F8EF7);

  // Text
  static const Color textPrimary   = Color(0xFFEEF0F8);
  static const Color textSecondary = Color(0xFF8A9BBF);
  static const Color textMuted     = Color(0xFF4A5880);

  // Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF4F8EF7), Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientCyan = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF4F8EF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [Color(0xFF00C897), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientWarning = LinearGradient(
    colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientDark = LinearGradient(
    colors: [Color(0xFF131D33), Color(0xFF0E1426)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Theme ───────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: AppColors.surface),
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardElevated,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryGlow,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: AppColors.card,
        collapsedBackgroundColor: AppColors.card,
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textMuted,
        textColor: AppColors.textPrimary,
        collapsedTextColor: AppColors.textPrimary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.card),
        ),
      ),
    );
  }
}

// ─── Reusable Decorations ────────────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration glassCard({Color? borderColor, double radius = 16}) =>
      BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1),
      );

  static BoxDecoration glowCard(Color glowColor, {double radius = 16}) =>
      BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: glowColor.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      );

  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      );
}
