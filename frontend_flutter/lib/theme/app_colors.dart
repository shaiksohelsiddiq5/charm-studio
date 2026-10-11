import 'package:flutter/material.dart';

class AppColors {
  // Brand Accents
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo-50
  
  static const Color purple = Color(0xFF8B5CF6); // Violet-500
  static const Color purpleDark = Color(0xFF7C3AED); // Violet-600
  static const Color purpleLight = Color(0xFFF5F3FF); // Violet-50

  // Neutrals & Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate-100

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400

  // Status & Feedback
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successBg = Color(0xFFECFDF5); // Emerald-50
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6); // Blue-500
  static const Color infoBg = Color(0xFFEFF6FF);

  // Gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFEEF2FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
