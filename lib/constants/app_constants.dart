// Centralized UI constants: colors, spacing, radii, fonts, typography, dimens, buttons
// Keep all design tokens in one place for easy maintenance.
import 'package:flutter/material.dart';

class AppColors {
  // Brand/seed
  static const Color accent = Color(0xFFFC5800);

  // Surfaces
  static const Color background = Color(0xFF0B0B0D);
  static const Color black = Colors.black;

  // Text/icons
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;

  // Strokes/dividers/overlays
  static const Color white24 = Colors.white24;
  static const Color white12 = Colors.white12;
  static const Color transparent = Colors.transparent;

  // Semantic aliases
  static const Color icon = white70;
  static const Color divider = white24;
  static const Color stroke = white24;
}

class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadii {
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double handle = 2; // small grabber/handle

  static const BorderRadius brS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius brM = BorderRadius.all(Radius.circular(m));
  static const BorderRadius brL = BorderRadius.all(Radius.circular(l));
}

class AppFonts {
  // Must match pubspec.yaml
  static const String primary = 'SFPro';
}

// Typographic scale tokens
class AppTypography {
  static const double sizeHeadline = 24;
  static const double sizeTitle = 20;
  static const double sizeBody = 16;
  static const double sizeLabel = 13;
  static const double sizeCaption = 12;
  static const double sizeButton = 14;
  static const double sizeOverline = 11;
}

// Named text styles used across the app
class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: AppTypography.sizeHeadline,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    fontFamily: AppFonts.primary,
    letterSpacing: 0.5,
  );

  static const TextStyle title = TextStyle(
    fontSize: AppTypography.sizeTitle,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    fontFamily: AppFonts.primary,
  );

  static const TextStyle subtitleMuted = TextStyle(
    fontSize: AppTypography.sizeBody,
    fontWeight: FontWeight.w500,
    color: AppColors.white70,
    fontFamily: AppFonts.primary,
  );

  static const TextStyle body = TextStyle(
    fontSize: AppTypography.sizeBody,
    color: AppColors.white,
    fontFamily: AppFonts.primary,
    height: 1.25,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: AppTypography.sizeBody,
    color: AppColors.white70,
    fontFamily: AppFonts.primary,
    height: 1.25,
  );

  static const TextStyle captionMuted = TextStyle(
    fontSize: AppTypography.sizeCaption,
    color: AppColors.white54,
    fontFamily: AppFonts.primary,
  );

  static const TextStyle labelCaps = TextStyle(
    fontSize: AppTypography.sizeLabel,
    color: AppColors.white70,
    letterSpacing: 4,
    fontWeight: FontWeight.w400,
    fontFamily: AppFonts.primary,
  );

  static const TextStyle button = TextStyle(
    fontSize: AppTypography.sizeButton,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
    fontFamily: AppFonts.primary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: AppTypography.sizeOverline,
    color: AppColors.white70,
    letterSpacing: 2,
    fontFamily: AppFonts.primary,
  );
}

class AppDimens {
  static const double iconS = 20;
  static const double iconM = 28;
  static const double iconL = 56;
  static const double iconXL = 64;
  static const double controlS = 40;
  static const double controlM = 56;
  static const double controlL = 140;
  static const double playArea = 240;
  static const double trackHeight = 3;
  static const double borderThin = 1;
  static const double handleWidth = 36;
  static const double handleHeight = 4;
}

class AppButtons {
  static ButtonStyle filled({
    Color? background,
    Color? foreground,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? radius,
  }) {
    final Color bg = background ?? AppColors.accent;
    final Color fg = foreground ?? AppColors.white;
    final BorderRadiusGeometry shapeRadius = radius ?? AppRadii.brM;
    final EdgeInsetsGeometry contentPadding = padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s);
    Color resolveBg(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return bg.withValues(alpha: 0.38);
      if (states.contains(WidgetState.pressed)) return bg.withValues(alpha: 0.90);
      return bg;
    }
    Color resolveFg(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return AppColors.white70;
      return fg;
    }
    Color resolveOverlay(Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) return AppColors.white24;
      return AppColors.transparent;
    }
    return ButtonStyle(
      textStyle: WidgetStateProperty.all(AppTextStyles.button),
      padding: WidgetStateProperty.all(contentPadding),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: shapeRadius as BorderRadius)),
      backgroundColor: WidgetStateProperty.resolveWith(resolveBg),
      foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
      overlayColor: WidgetStateProperty.resolveWith(resolveOverlay),
      elevation: const WidgetStatePropertyAll(0),
    );
  }

  static ButtonStyle outline({
    Color? foreground,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? radius,
  }) {
    final Color fg = foreground ?? AppColors.white;
    final Color border = borderColor ?? AppColors.stroke;
    final BorderRadiusGeometry shapeRadius = radius ?? AppRadii.brM;
    final EdgeInsetsGeometry contentPadding = padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s);
    Color resolveFg(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return AppColors.white54;
      return fg;
    }
    Color resolveOverlay(Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) return AppColors.white24;
      return AppColors.transparent;
    }
    BorderSide resolveSide(Set<WidgetState> states) {
      final color = states.contains(WidgetState.disabled) ? AppColors.white24 : border;
      return BorderSide(color: color, width: AppDimens.borderThin);
    }
    return ButtonStyle(
      textStyle: WidgetStateProperty.all(AppTextStyles.button),
      padding: WidgetStateProperty.all(contentPadding),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: shapeRadius as BorderRadius)),
      backgroundColor: const WidgetStatePropertyAll(AppColors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith(resolveFg),
      overlayColor: WidgetStateProperty.resolveWith(resolveOverlay),
      side: WidgetStateProperty.resolveWith(resolveSide),
      elevation: const WidgetStatePropertyAll(0),
    );
  }

  static ButtonStyle tonal({
    Color? background,
    Color? foreground,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? radius,
  }) {
    final Color bg = background ?? AppColors.white12;
    final Color fg = foreground ?? AppColors.white;
    final BorderRadiusGeometry shapeRadius = radius ?? AppRadii.brM;
    final EdgeInsetsGeometry contentPadding = padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s);
    Color resolveBg(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) return bg.withValues(alpha: 0.5);
      if (states.contains(WidgetState.pressed)) return bg.withValues(alpha: 0.9);
      return bg;
    }
    return ButtonStyle(
      textStyle: WidgetStateProperty.all(AppTextStyles.button),
      padding: WidgetStateProperty.all(contentPadding),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: shapeRadius as BorderRadius)),
      backgroundColor: WidgetStateProperty.resolveWith(resolveBg),
      foregroundColor: WidgetStateProperty.all(fg),
      overlayColor: const WidgetStatePropertyAll(AppColors.white24),
      elevation: const WidgetStatePropertyAll(0),
    );
  }

  static ButtonStyle ghost({
    Color? foreground,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? radius,
  }) {
    final Color fg = foreground ?? AppColors.white;
    final BorderRadiusGeometry shapeRadius = radius ?? AppRadii.brM;
    final EdgeInsetsGeometry contentPadding = padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s);
    return ButtonStyle(
      textStyle: WidgetStateProperty.all(AppTextStyles.button),
      padding: WidgetStateProperty.all(contentPadding),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: shapeRadius as BorderRadius)),
      backgroundColor: const WidgetStatePropertyAll(AppColors.transparent),
      foregroundColor: WidgetStateProperty.all(fg),
      overlayColor: const WidgetStatePropertyAll(AppColors.white24),
      elevation: const WidgetStatePropertyAll(0),
    );
  }
}
