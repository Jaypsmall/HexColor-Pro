import 'dart:math';
import 'package:flutter/material.dart';

class ColorManager {
  /// Converts Hex string (#RRGGBB or RRGGBB) to Color.
  static Color? hexToColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  /// Converts Color to Hex string format (e.g. #FF5733).
  static String colorToHex(Color color, {bool includeAlpha = false}) {
    int r = color.red;
    int g = color.green;
    int b = color.blue;

    // Noise cleanup matching original Kotlin logic
    if (r < 8 && g < 8 && b < 8) {
      r = 0;
      g = 0;
      b = 0;
    }
    if (r > 248 && g > 248 && b > 248) {
      r = 255;
      g = 255;
      b = 255;
    }

    if (includeAlpha) {
      int a = color.alpha;
      return '#${a.toRadixString(16).padLeft(2, '0')}'
          '${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
    }

    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
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

  /// Converts HSV parameters to Color.
  static Color hsvToColor(double hue, [double saturation = 1.0, double value = 1.0]) {
    return HSVColor.fromAHSV(1.0, hue % 360, saturation.clamp(0.0, 1.0), value.clamp(0.0, 1.0)).toColor();
  }

  /// Checks if color is dark (for text contrast).
  static bool isDark(Color color) {
    final r = color.red.toDouble();
    final g = color.green.toDouble();
    final b = color.blue.toDouble();
    final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
    return luminance < 128;
  }

  /// Calculates WCAG contrast ratio between two colors.
  static double getContrastRatio(Color color1, Color color2) {
    double luminance(Color c) {
      double calc(double val) => val <= 0.03928 ? val / 12.92 : pow((val + 0.055) / 1.055, 2.4).toDouble();
      final r = calc(c.red / 255.0);
      final g = calc(c.green / 255.0);
      final b = calc(c.blue / 255.0);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final l1 = luminance(color1);
    final l2 = luminance(color2);
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
  }

  /// Simulates color blindness types.
  static Color simulateColorBlindness(Color color, String type) {
    if (type == 'None') return color;

    double toLinear(double c) => c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
    double fromLinear(double c) => c <= 0.0031308 ? c * 12.92 : 1.055 * pow(c, 1.0 / 2.4) - 0.055;

    final rL = toLinear(color.red / 255.0);
    final gL = toLinear(color.green / 255.0);
    final bL = toLinear(color.blue / 255.0);

    double nrL, ngL, nbL;

    switch (type) {
      case 'Protanopia':
        nrL = 0.56667 * rL + 0.43333 * gL + 0.0 * bL;
        ngL = 0.55833 * rL + 0.44167 * gL + 0.0 * bL;
        nbL = 0.0 * rL + 0.24167 * gL + 0.75833 * bL;
        break;
      case 'Deuteranopia':
        nrL = 0.625 * rL + 0.375 * gL + 0.0 * bL;
        ngL = 0.7 * rL + 0.3 * gL + 0.0 * bL;
        nbL = 0.0 * rL + 0.3 * gL + 0.7 * bL;
        break;
      case 'Tritanopia':
        nrL = 1.01 * rL + 0.02 * gL - 0.03 * bL;
        ngL = 0.10 * rL + 0.73 * gL + 0.17 * bL;
        nbL = 0.0 * rL + 0.85 * gL + 0.15 * bL;
        break;
      default:
        nrL = rL;
        ngL = gL;
        nbL = bL;
    }

    final r = (fromLinear(nrL) * 255).clamp(0, 255).round();
    final g = (fromLinear(ngL) * 255).clamp(0, 255).round();
    final b = (fromLinear(nbL) * 255).clamp(0, 255).round();

    return Color.fromRGBO(r, g, b, color.opacity);
  }

  /// Calculates color from spectrum wavelength (380 - 780 nm).
  static Color wavelengthToColor(double wavelength) {
    const double gamma = 0.80;
    const double intensityMax = 255.0;

    double rRaw = 0, gRaw = 0, bRaw = 0;

    if (wavelength >= 380 && wavelength < 440) {
      final attenuation = 0.3 + 0.7 * (wavelength - 380) / (440 - 380);
      rRaw = pow((-(wavelength - 440) / (440 - 380)) * attenuation, gamma).toDouble();
      gRaw = 0.0;
      bRaw = pow(1.0 * attenuation, gamma).toDouble();
    } else if (wavelength >= 440 && wavelength < 490) {
      rRaw = 0.0;
      gRaw = pow((wavelength - 440) / (490 - 440), gamma).toDouble();
      bRaw = 1.0;
    } else if (wavelength >= 490 && wavelength < 510) {
      rRaw = 0.0;
      gRaw = 1.0;
      bRaw = pow((-(wavelength - 510) / (510 - 490)), gamma).toDouble();
    } else if (wavelength >= 510 && wavelength < 580) {
      rRaw = pow((wavelength - 510) / (580 - 510), gamma).toDouble();
      gRaw = 1.0;
      bRaw = 0.0;
    } else if (wavelength >= 580 && wavelength < 645) {
      rRaw = 1.0;
      gRaw = pow((-(wavelength - 645) / (645 - 580)), gamma).toDouble();
      bRaw = 0.0;
    } else if (wavelength >= 645 && wavelength <= 780) {
      final attenuation = 0.3 + 0.7 * (780 - wavelength) / (780 - 645);
      rRaw = pow(1.0 * attenuation, gamma).toDouble();
      gRaw = 0.0;
      bRaw = 0.0;
    }

    final r = (rRaw * intensityMax).round().clamp(0, 255);
    final g = (gRaw * intensityMax).round().clamp(0, 255);
    final b = (bRaw * intensityMax).round().clamp(0, 255);

    return Color.fromRGBO(r, g, b, 1.0);
  }
}
