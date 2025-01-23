import 'package:flutter/material.dart';

import 'color.dart';

class Themes {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    hintColor: AppColors.secondary,
    scaffoldBackgroundColor: AppColors.background,
    buttonTheme: ButtonThemeData(buttonColor: AppColors.primary),
  );
}
