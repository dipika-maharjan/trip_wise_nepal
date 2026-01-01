import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/app/theme/app_colors.dart';

/// Extension methods for theme-related properties
extension ThemeExtensions on BuildContext {
  /// Get primary text color based on theme brightness
  Color get textPrimary {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white
        : AppColors.textPrimary;
  }

  /// Get secondary text color based on theme brightness
  Color get textSecondary {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white70
        : AppColors.textSecondary;
  }

  /// Get hint text color based on theme brightness
  Color get textHint {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white38
        : AppColors.textHint;
  }

  /// Get background color based on theme brightness
  Color get backgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : AppColors.background;
  }

  /// Get surface color based on theme brightness
  Color get surfaceColor {
    return Theme.of(this).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : AppColors.surface;
  }

  /// Get surface variant color
  Color get surfaceVariant {
    return Theme.of(this).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : AppColors.surfaceVariant;
  }

  /// Get primary color from theme
  Color get primaryColor {
    return Theme.of(this).primaryColor;
  }

  /// Get accent color from theme
  Color get accentColor {
    return Theme.of(this).colorScheme.secondary;
  }

  /// Soft shadow for cards and elevated surfaces
  List<BoxShadow> get softShadow {
    return [
      BoxShadow(
        color: Colors.black.withAlpha(25),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Medium shadow for more prominent surfaces
  List<BoxShadow> get mediumShadow {
    return [
      BoxShadow(
        color: Colors.black.withAlpha(40),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Strong shadow for modals and dialogs
  List<BoxShadow> get strongShadow {
    return [
      BoxShadow(
        color: Colors.black.withAlpha(60),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Get input border styling
  OutlineInputBorder get inputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: surfaceVariant,
        width: 1.5,
      ),
    );
  }

  /// Get focused input border styling
  OutlineInputBorder get focusedInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: primaryColor,
        width: 2,
      ),
    );
  }

  /// Get error input border styling
  OutlineInputBorder get errorInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.5,
      ),
    );
  }

  /// Get screen size
  Size get screenSize {
    return MediaQuery.of(this).size;
  }

  /// Get screen width
  double get screenWidth {
    return MediaQuery.of(this).size.width;
  }

  /// Get screen height
  double get screenHeight {
    return MediaQuery.of(this).size.height;
  }

  /// Check if device is in landscape
  bool get isLandscape {
    return MediaQuery.of(this).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait
  bool get isPortrait {
    return MediaQuery.of(this).orientation == Orientation.portrait;
  }

  /// Get padding (safe area + insets)
  EdgeInsets get screenPadding {
    return MediaQuery.of(this).padding;
  }

  /// Get view insets (keyboard height, etc)
  EdgeInsets get viewInsets {
    return MediaQuery.of(this).viewInsets;
  }

  /// Check if screen is small (mobile)
  bool get isSmallScreen {
    return screenWidth < 600;
  }

  /// Check if screen is medium (tablet)
  bool get isMediumScreen {
    return screenWidth >= 600 && screenWidth < 1200;
  }

  /// Check if screen is large (desktop)
  bool get isLargeScreen {
    return screenWidth >= 1200;
  }
}
