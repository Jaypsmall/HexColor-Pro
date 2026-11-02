import 'package:flutter/material.dart';
import 'rust_engine.dart';

class ColorManager {
  /// Converts Hex string (#RRGGBB or RRGGBB) to Color.
  static Color? hexToColor(String hex) {
    return RustEngine.hexToColor(hex);
  }

  /// Converts Color to Hex string format (e.g. #FF5733).
  static String colorToHex(Color color, {bool includeAlpha = false}) {
    return RustEngine.colorToHex(color);
  }

  /// Calculates complementary color.
  static Color getComplementary(Color color) {
    final hsv = HSVColor.fromColor(color);
    final newHue = (hsv.hue + 180) % 360;
    return hsv.withHue(newHue).toColor();
  }

  /// Generates analogous colors palette.
  static List<Color> getAnalogous(Color color, {int count = 7}) {
    final hsv = HSVColor.fromColor(color);
    const double startAngle = -90.0;
    const double endAngle = 90.0;
    final double step = count > 1 ? (endAngle - startAngle) / (count - 1) : 0.0;

    return List.generate(count, (i) {
      final double offset = startAngle + (i * step);
      final double newHue = (hsv.hue + offset + 360) % 360;
      return hsv.withHue(newHue).toColor();
    });
  }

  /// Generates triadic colors.
  static List<Color> getTriadic(Color color) {
    final hsv = HSVColor.fromColor(color);
    return [0.0, 120.0, 240.0].map((offset) {
      final double newHue = (hsv.hue + offset) % 360;
      return hsv.withHue(newHue).toColor();
    }).toList();
  }

  /// Generates tetradic (4-color square/rectangular) palette.
  static List<Color> getTetradic(Color color) {
    final hsv = HSVColor.fromColor(color);
    return [0.0, 90.0, 180.0, 270.0].map((offset) {
      final double newHue = (hsv.hue + offset) % 360;
      return hsv.withHue(newHue).toColor();
    }).toList();
  }

  /// Generates split-complementary palette.
  static List<Color> getSplitComplementary(Color color) {
    final hsv = HSVColor.fromColor(color);
    return [0.0, 150.0, 210.0].map((offset) {
      final double newHue = (hsv.hue + offset) % 360;
      return hsv.withHue(newHue).toColor();
    }).toList();
  }

  /// Generates monochromatic colors (varying value/saturation).
  static List<Color> getMonochromatic(Color color, {int count = 5}) {
    final hsv = HSVColor.fromColor(color);
    final double step = count > 1 ? 0.8 / (count - 1) : 0.0;
    return List.generate(count, (i) {
      final double v = (0.2 + (i * step)).clamp(0.1, 1.0);
      return hsv.withValue(v).toColor();
    });
  }

  /// Generates shades (darker) and tints (lighter).
  static List<Color> getShadesAndTints(Color color, {int count = 7}) {
    final hsl = HSLColor.fromColor(color);
    final double step = 1.0 / (count + 1);
    return List.generate(count, (i) {
      final double lightness = (step * (i + 1)).clamp(0.05, 0.95);
      return hsl.withLightness(lightness).toColor();
    });
  }

  /// Converts HSV parameters to Color.
  static Color hsvToColor(double hue, [double saturation = 1.0, double value = 1.0]) {
    return HSVColor.fromAHSV(1.0, hue % 360, saturation.clamp(0.0, 1.0), value.clamp(0.0, 1.0)).toColor();
  }

  /// Checks if color is dark (for text contrast).
  static bool isDark(Color color) {
    final r = color.r * 255.0;
    final g = color.g * 255.0;
    final b = color.b * 255.0;
    final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
    return luminance < 128;
  }

  /// Calculates WCAG contrast ratio between two colors using Rust or Dart.
  static double getContrastRatio(Color color1, Color color2) {
    return RustEngine.getContrastRatio(color1, color2);
  }

  /// Simulates color blindness types using Rust engine or Dart.
  static Color simulateColorBlindness(Color color, String type) {
    return RustEngine.simulateColorBlindness(color, type);
  }

  /// Calculates color from spectrum wavelength (380 - 780 nm).
  static Color wavelengthToColor(double wavelength) {
    return RustEngine.wavelengthToColor(wavelength);
  }

  /// Returns RGB string format e.g. "RGB(255, 128, 0)"
  static String colorToRgbString(Color color) {
    int r = (color.r * 255.0).round();
    int g = (color.g * 255.0).round();
    int b = (color.b * 255.0).round();
    return "RGB($r, $g, $b)";
  }

  /// Returns HSL string format e.g. "HSL(210°, 80%, 50%)"
  static String colorToHslString(Color color) {
    final hsl = HSLColor.fromColor(color);
    int h = hsl.hue.round();
    int s = (hsl.saturation * 100).round();
    int l = (hsl.lightness * 100).round();
    return "HSL($h°, $s%, $l%)";
  }

  /// Returns CMYK string format e.g. "CMYK(0%, 50%, 100%, 0%)"
  static String colorToCmykString(Color color) {
    final cmyk = RustEngine.colorToCmyk(color);
    int c = cmyk[0].round();
    int m = cmyk[1].round();
    int y = cmyk[2].round();
    int k = cmyk[3].round();
    return "CMYK($c%, $m%, $y%, $k%)";
  }
}
