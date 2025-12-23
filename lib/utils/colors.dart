import 'package:flutter/material.dart';

/// Centralized color definitions for the Padel Tournament App
/// Following the V7.0 specification for visual redesign
class AppColors {
  // Court Colors (Blue Theme) - F-018, F-019
  
  /// Primary court background - very light blue
  static const Color courtBackgroundLight = Color(0xFFE3F2FD); // Colors.blue[50]
  
  /// Secondary court background - light blue
  static const Color courtBackgroundDark = Color(0xFFBBDEFB); // Colors.blue[100]
  
  /// Court header background - dark blue
  static const Color courtHeader = Color(0xFF1565C0); // Colors.blue[800]
  
  /// Court border - dark blue
  static const Color courtBorder = Color(0xFF1976D2); // Colors.blue[700]
  
  /// Net/divider primary color - very dark blue
  static const Color netPrimary = Color(0xFF0D47A1); // Colors.blue[900]
  
  /// Net/divider accent color - dark blue
  static const Color netAccent = Color(0xFF1565C0); // Colors.blue[800]
  
  /// Player marker border - medium blue
  static const Color playerBorder = Color(0xFF64B5F6); // Colors.blue[300]
  
  /// Player marker icon color - dark blue
  static const Color playerIcon = Color(0xFF1976D2); // Colors.blue[700]
  
  /// Team label color - darker blue
  static const Color teamLabel = Color(0xFF1565C0); // Colors.blue[800]
  
  // Score Colors - F-023
  
  /// Score display when empty - grey
  static const Color scoreEmpty = Color(0xFFEEEEEE); // Colors.grey[300]
  
  /// Score display text when empty - dark grey
  static const Color scoreEmptyText = Color(0xFF757575); // Colors.grey[600]
  
  /// Score display when entered - green
  static const Color scoreEntered = Color(0xFF43A047); // Colors.green[600]
  
  // Bench/Pause Colors (Orange Theme) - F-024
  
  /// Bench header icon color - very dark orange
  static const Color benchHeaderIcon = Color(0xFFE65100); // Colors.orange[900]
  
  /// Bench header text color - very dark orange
  static const Color benchHeaderText = Color(0xFFE65100); // Colors.orange[900]
  
  /// Bench background light - very light orange
  static const Color benchBackgroundLight = Color(0xFFFFF3E0); // Colors.orange[50]
  
  /// Bench background dark - light orange
  static const Color benchBackgroundDark = Color(0xFFFFE0B2); // Colors.orange[100]
  
  /// Bench border - dark orange
  static const Color benchBorder = Color(0xFFE64A19); // Colors.orange[700]
  
  /// Bench player chip border - medium orange
  static const Color benchChipBorder = Color(0xFFFFB74D); // Colors.orange[300]
  
  /// Bench player chip icon - dark orange
  static const Color benchChipIcon = Color(0xFFE64A19); // Colors.orange[700]
  
  // Common Colors
  
  /// White background for cards and chips
  static const Color cardBackground = Colors.white;
  
  /// Standard text color - dark grey
  static const Color textDark = Color(0xFF424242); // Colors.grey[800]
  
  /// White text for headers
  static const Color textLight = Colors.white;
}
