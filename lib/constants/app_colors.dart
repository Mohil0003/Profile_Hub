import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryLight = Color(0xFFE1BEE7);  // Colors.purple[100]
  static const Color primary = Color(0xFFCE93D8);       // Colors.purple[200]
  static const Color primaryDark = Color(0xFFBA68C8);   // Colors.purple[300]

  // Gradient colors
  static const List<Color> backgroundGradient = [
    Color(0xFFBBDEFB),  // Colors.lightBlue[100]
    Color(0xFFF8BBD0),  // Colors.pink[100]
    Color(0xFFE1BEE7),  // Colors.purple[100]
  ];

  // Form field colors
  static const List<Color> formFieldGradient = [
    Color(0xFFE3F2FD),  // Colors.lightBlue[50]
    Color(0xFFFCE4EC),  // Colors.pink[50]
  ];

  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFFFFFFFF70); // white with 70% opacity
  static const Color textDark = Colors.black87;

  // Button colors
  static const Color buttonPrimary = Color(0xFFAB47BC);  // Colors.purple[400]
  static const Color buttonText = Colors.white;

  // Icon colors
  static const Color iconPrimary = Colors.white;
  static const Color iconSecondary = Colors.grey;
} 