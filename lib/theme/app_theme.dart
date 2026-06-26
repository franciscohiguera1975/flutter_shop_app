// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3:  true,
    brightness:    Brightness.dark,
    colorScheme:   _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme:   _appBarTheme,
    cardTheme:     _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme:  _elevatedButtonTheme,
    outlinedButtonTheme:  _outlinedButtonTheme,
    textButtonTheme:      _textButtonTheme,
    chipTheme:     _chipTheme,
    dividerTheme:  _dividerTheme,
    bottomNavigationBarTheme: _bottomNavTheme,
    navigationDrawerTheme:    _drawerTheme,
    snackBarTheme: _snackBarTheme,
    textTheme:     _textTheme,
    fontFamily:    'Roboto',
  );

  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary:          AppColors.accent,
    onPrimary:        AppColors.onAccent,
    secondary:        AppColors.accentLight,
    onSecondary:      AppColors.onAccent,
    surface:          AppColors.surface,
    onSurface:        AppColors.textPrimary,
    surfaceContainer: AppColors.surface2,
    error:            AppColors.error,
    onError:          Colors.white,
    outline:          AppColors.border,
    outlineVariant:   AppColors.borderLight,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation:       0,
    scrolledUnderElevation: 0,
    centerTitle:     false,
    titleTextStyle:  TextStyle(
      color:      AppColors.textPrimary,
      fontSize:   18,
      fontWeight: FontWeight.bold,
    ),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    color:        AppColors.surface,
    elevation:    0,
    shape:        RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.zero,
  );

  static const InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled:           true,
    fillColor:        AppColors.surface2,
    border:           OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide:   BorderSide(color: AppColors.border),
    ),
    enabledBorder:    OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide:   BorderSide(color: AppColors.border),
    ),
    focusedBorder:    OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide:   BorderSide(color: AppColors.accent, width: 2),
    ),
    errorBorder:      OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide:   BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide:   BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle:       TextStyle(color: AppColors.textSecondary),
    hintStyle:        TextStyle(color: AppColors.textFaint),
    prefixIconColor:  AppColors.textSecondary,
    suffixIconColor:  AppColors.textSecondary,
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.onAccent,
      minimumSize:     const Size(double.infinity, 52),
      shape:           const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      elevation:  0,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      minimumSize:     const Size(double.infinity, 52),
      shape:           const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      side:      const BorderSide(color: AppColors.border),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor:       AppColors.surface2,
    selectedColor:         AppColors.accent,
    labelStyle:            TextStyle(color: AppColors.textSecondary, fontSize: 12),
    secondaryLabelStyle:   TextStyle(color: AppColors.onAccent, fontSize: 12),
    side:                  BorderSide(color: AppColors.border),
    shape:                 StadiumBorder(),
    padding:               EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color:     AppColors.border,
    thickness: 0.5,
    space:     0,
  );

  static const BottomNavigationBarThemeData _bottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor:          AppColors.surface,
    selectedItemColor:        AppColors.accent,
    unselectedItemColor:      AppColors.textSecondary,
    selectedLabelStyle:       TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    unselectedLabelStyle:     TextStyle(fontSize: 11),
    elevation:                0,
  );

  static const NavigationDrawerThemeData _drawerTheme = NavigationDrawerThemeData(
    backgroundColor:     AppColors.surface,
    indicatorColor:      Color(0x1FD4A843),
    surfaceTintColor:    Colors.transparent,
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor:   AppColors.surface2,
    contentTextStyle:  TextStyle(color: AppColors.textPrimary),
    behavior:          SnackBarBehavior.floating,
    shape:             RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.bold),
    headlineMedium:TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.bold),
    titleLarge:    TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.bold),
    titleMedium:   TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w600),
    titleSmall:    TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w600),
    bodyLarge:     TextStyle(color: AppColors.textPrimary),
    bodyMedium:    TextStyle(color: AppColors.textSecondary),
    bodySmall:     TextStyle(color: AppColors.textSecondary, fontSize: 12),
    labelLarge:    TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.bold),
    labelSmall:    TextStyle(color: AppColors.textSecondary, fontSize: 11),
  );

  AppTheme._();
}