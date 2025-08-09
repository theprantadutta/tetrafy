import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData.from(colorScheme: pastel);
  static final ThemeData darkTheme = ThemeData.from(colorScheme: retroNeon);
  static final ThemeData monochromeTheme = ThemeData.from(colorScheme: monochrome);
  static final ThemeData cyberpunkTheme = ThemeData.from(colorScheme: cyberpunk);
}