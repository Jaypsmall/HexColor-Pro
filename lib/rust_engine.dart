import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

// Native function typedefs
typedef RustHexToRgbC = ffi.Int32 Function(ffi.Pointer<Utf8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef RustHexToRgbDart = int Function(ffi.Pointer<Utf8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

typedef RustRgbToHexC = ffi.Void Function(ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Pointer<ffi.Uint8>);
typedef RustRgbToHexDart = void Function(int, int, int, ffi.Pointer<ffi.Uint8>);

typedef RustRgbToHslC = ffi.Void Function(ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>);
typedef RustRgbToHslDart = void Function(int, int, int, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>);

typedef RustHslToRgbC = ffi.Void Function(ffi.Float, ffi.Float, ffi.Float, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef RustHslToRgbDart = void Function(double, double, double, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

typedef RustRgbToCmykC = ffi.Void Function(ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>);
typedef RustRgbToCmykDart = void Function(int, int, int, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>, ffi.Pointer<ffi.Float>);

typedef RustContrastC = ffi.Float Function(ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Uint8);
typedef RustContrastDart = double Function(int, int, int, int, int, int);

typedef RustSimulateColorblindnessC = ffi.Void Function(ffi.Uint8, ffi.Uint8, ffi.Uint8, ffi.Int32, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef RustSimulateColorblindnessDart = void Function(int, int, int, int, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

typedef RustWavelengthToRgbC = ffi.Void Function(ffi.Float, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef RustWavelengthToRgbDart = void Function(double, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

class RustEngine {
  static ffi.DynamicLibrary? _lib;
  static bool _isLoaded = false;

  static RustHexToRgbDart? _hexToRgb;
  static RustRgbToHexDart? _rgbToHex;
  static RustRgbToHslDart? _rgbToHsl;
  static RustHslToRgbDart? _hslToRgb;
  static RustRgbToCmykDart? _rgbToCmyk;
  static RustContrastDart? _contrastRatio;
  static RustSimulateColorblindnessDart? _simulateColorblindness;
  static RustWavelengthToRgbDart? _wavelengthToRgb;

  static void init() {
    if (_isLoaded) return;
    try {
      if (Platform.isWindows) {
        final path = File('native/rust_engine/target/release/hexcolor_engine.dll').absolute.path;
        if (File(path).existsSync()) {
          _lib = ffi.DynamicLibrary.open(path);
        } else {
          _lib = ffi.DynamicLibrary.open('hexcolor_engine.dll');
        }
      } else if (Platform.isAndroid || Platform.isLinux) {
        _lib = ffi.DynamicLibrary.open('libhexcolor_engine.so');
      } else if (Platform.isMacOS || Platform.isIOS) {
        _lib = ffi.DynamicLibrary.open('libhexcolor_engine.dylib');
      }

      if (_lib != null) {
        _hexToRgb = _lib!.lookupFunction<RustHexToRgbC, RustHexToRgbDart>('rust_hex_to_rgb');
        _rgbToHex = _lib!.lookupFunction<RustRgbToHexC, RustRgbToHexDart>('rust_rgb_to_hex');
        _rgbToHsl = _lib!.lookupFunction<RustRgbToHslC, RustRgbToHslDart>('rust_rgb_to_hsl');
        _hslToRgb = _lib!.lookupFunction<RustHslToRgbC, RustHslToRgbDart>('rust_hsl_to_rgb');
        _rgbToCmyk = _lib!.lookupFunction<RustRgbToCmykC, RustRgbToCmykDart>('rust_rgb_to_cmyk');
        _contrastRatio = _lib!.lookupFunction<RustContrastC, RustContrastDart>('rust_get_contrast_ratio');
        _simulateColorblindness = _lib!.lookupFunction<RustSimulateColorblindnessC, RustSimulateColorblindnessDart>('rust_simulate_colorblindness');
        _wavelengthToRgb = _lib!.lookupFunction<RustWavelengthToRgbC, RustWavelengthToRgbDart>('rust_wavelength_to_rgb');
        _isLoaded = true;
      }
    } catch (e) {
      _isLoaded = false;
    }
  }

  static bool get isRustLoaded {
    if (!_isLoaded) init();
    return _isLoaded;
  }

  /// Converts Hex string to Color (using Rust native library if loaded, Dart fallback otherwise)
  static Color? hexToColor(String hex) {
    if (isRustLoaded && _hexToRgb != null) {
      final nativeString = hex.toNativeUtf8();
      final rPtr = calloc<ffi.Uint8>();
      final gPtr = calloc<ffi.Uint8>();
      final bPtr = calloc<ffi.Uint8>();

      try {
        final res = _hexToRgb!(nativeString, rPtr, gPtr, bPtr);
        if (res == 0) {
          return Color.fromRGBO(rPtr.value, gPtr.value, bPtr.value, 1.0);
        }
      } finally {
        calloc.free(nativeString);
        calloc.free(rPtr);
        calloc.free(gPtr);
        calloc.free(bPtr);
      }
    }

    // Fallback Dart implementation
    try {
      String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  /// Converts Color to Hex (#RRGGBB)
  static String colorToHex(Color color) {
    int r = (color.r * 255.0).round().clamp(0, 255);
    int g = (color.g * 255.0).round().clamp(0, 255);
    int b = (color.b * 255.0).round().clamp(0, 255);

    if (isRustLoaded && _rgbToHex != null) {
      final outBuf = calloc<ffi.Uint8>(16);
      try {
        _rgbToHex!(r, g, b, outBuf);
        final ptr = outBuf.cast<Utf8>();
        return ptr.toDartString();
      } finally {
        calloc.free(outBuf);
      }
    }

    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  /// Converts RGB to HSL [Hue 0-360, Saturation 0-1, Lightness 0-1]
  static List<double> rgbToHsl(int r, int g, int b) {
    if (isRustLoaded && _rgbToHsl != null) {
      final hPtr = calloc<ffi.Float>();
      final sPtr = calloc<ffi.Float>();
      final lPtr = calloc<ffi.Float>();
      try {
        _rgbToHsl!(r, g, b, hPtr, sPtr, lPtr);
        return [hPtr.value, sPtr.value, lPtr.value];
      } finally {
        calloc.free(hPtr);
        calloc.free(sPtr);
        calloc.free(lPtr);
      }
    }

    final color = Color.fromRGBO(r, g, b, 1.0);
    final hsl = HSLColor.fromColor(color);
    return [hsl.hue, hsl.saturation, hsl.lightness];
  }

  /// Converts HSL to RGB [r, g, b]
  static List<int> hslToRgb(double h, double s, double l) {
    if (isRustLoaded && _hslToRgb != null) {
      final rPtr = calloc<ffi.Uint8>();
      final gPtr = calloc<ffi.Uint8>();
      final bPtr = calloc<ffi.Uint8>();
      try {
        _hslToRgb!(h, s, l, rPtr, gPtr, bPtr);
        return [rPtr.value, gPtr.value, bPtr.value];
      } finally {
        calloc.free(rPtr);
        calloc.free(gPtr);
        calloc.free(bPtr);
      }
    }

    final color = HSLColor.fromAHSL(1.0, h, s, l).toColor();
    return [(color.r * 255.0).round(), (color.g * 255.0).round(), (color.b * 255.0).round()];
  }

  /// Converts Color to CMYK [Cyan, Magenta, Yellow, Key/Black] (percentages 0-100)
  static List<double> colorToCmyk(Color color) {
    int r = (color.r * 255.0).round().clamp(0, 255);
    int g = (color.g * 255.0).round().clamp(0, 255);
    int b = (color.b * 255.0).round().clamp(0, 255);

    if (isRustLoaded && _rgbToCmyk != null) {
      final cPtr = calloc<ffi.Float>();
      final mPtr = calloc<ffi.Float>();
      final yPtr = calloc<ffi.Float>();
      final kPtr = calloc<ffi.Float>();
      try {
        _rgbToCmyk!(r, g, b, cPtr, mPtr, yPtr, kPtr);
        return [cPtr.value, mPtr.value, yPtr.value, kPtr.value];
      } finally {
        calloc.free(cPtr);
        calloc.free(mPtr);
        calloc.free(yPtr);
        calloc.free(kPtr);
      }
    }

    double rf = color.r;
    double gf = color.g;
    double bf = color.b;

    double k = 1.0 - max(rf, max(gf, bf));
    if ((1.0 - k).abs() < 1e-5) return [0, 0, 0, 100];

    double c = (1.0 - rf - k) / (1.0 - k);
    double m = (1.0 - gf - k) / (1.0 - k);
    double y = (1.0 - bf - k) / (1.0 - k);

    return [c * 100, m * 100, y * 100, k * 100];
  }

  /// Calculates WCAG contrast ratio
  static double getContrastRatio(Color color1, Color color2) {
    int r1 = (color1.r * 255.0).round().clamp(0, 255);
    int g1 = (color1.g * 255.0).round().clamp(0, 255);
    int b1 = (color1.b * 255.0).round().clamp(0, 255);

    int r2 = (color2.r * 255.0).round().clamp(0, 255);
    int g2 = (color2.g * 255.0).round().clamp(0, 255);
    int b2 = (color2.b * 255.0).round().clamp(0, 255);

    if (isRustLoaded && _contrastRatio != null) {
      return _contrastRatio!(r1, g1, b1, r2, g2, b2);
    }

    double luminance(Color c) {
      double calc(double val) => val <= 0.03928 ? val / 12.92 : pow((val + 0.055) / 1.055, 2.4).toDouble();
      final r = calc(c.r);
      final g = calc(c.g);
      final b = calc(c.b);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final l1 = luminance(color1);
    final l2 = luminance(color2);
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
  }

  /// Simulates colorblindness mode
  static Color simulateColorBlindness(Color color, String type) {
    if (type == 'None') return color;

    int r = (color.r * 255.0).round().clamp(0, 255);
    int g = (color.g * 255.0).round().clamp(0, 255);
    int b = (color.b * 255.0).round().clamp(0, 255);

    int mode = 0;
    if (type == 'Protanopia') mode = 1;
    if (type == 'Deuteranopia') mode = 2;
    if (type == 'Tritanopia') mode = 3;

    if (isRustLoaded && _simulateColorblindness != null) {
      final rPtr = calloc<ffi.Uint8>();
      final gPtr = calloc<ffi.Uint8>();
      final bPtr = calloc<ffi.Uint8>();
      try {
        _simulateColorblindness!(r, g, b, mode, rPtr, gPtr, bPtr);
        return Color.fromRGBO(rPtr.value, gPtr.value, bPtr.value, 1.0);
      } finally {
        calloc.free(rPtr);
        calloc.free(gPtr);
        calloc.free(bPtr);
      }
    }

    // Dart fallback simulation
    double toLinear(double c) => c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
    double fromLinear(double c) => c <= 0.0031308 ? c * 12.92 : 1.055 * pow(c, 1.0 / 2.4) - 0.055;

    final rL = toLinear(color.r);
    final gL = toLinear(color.g);
    final bL = toLinear(color.b);

    double nrL = rL, ngL = gL, nbL = bL;
    if (type == 'Protanopia') {
      nrL = 0.56667 * rL + 0.43333 * gL;
      ngL = 0.55833 * rL + 0.44167 * gL;
      nbL = 0.24167 * gL + 0.75833 * bL;
    } else if (type == 'Deuteranopia') {
      nrL = 0.625 * rL + 0.375 * gL;
      ngL = 0.7 * rL + 0.3 * gL;
      nbL = 0.3 * gL + 0.7 * bL;
    } else if (type == 'Tritanopia') {
      nrL = 1.01 * rL + 0.02 * gL - 0.03 * bL;
      ngL = 0.10 * rL + 0.73 * gL + 0.17 * bL;
      nbL = 0.85 * gL + 0.15 * bL;
    }

    final nr = (fromLinear(nrL) * 255).clamp(0, 255).round();
    final ng = (fromLinear(ngL) * 255).clamp(0, 255).round();
    final nb = (fromLinear(nbL) * 255).clamp(0, 255).round();

    return Color.fromRGBO(nr, ng, nb, 1.0);
  }

  /// Calculates color from spectrum wavelength (380 - 780 nm)
  static Color wavelengthToColor(double wavelength) {
    if (isRustLoaded && _wavelengthToRgb != null) {
      final rPtr = calloc<ffi.Uint8>();
      final gPtr = calloc<ffi.Uint8>();
      final bPtr = calloc<ffi.Uint8>();
      try {
        _wavelengthToRgb!(wavelength, rPtr, gPtr, bPtr);
        return Color.fromRGBO(rPtr.value, gPtr.value, bPtr.value, 1.0);
      } finally {
        calloc.free(rPtr);
        calloc.free(gPtr);
        calloc.free(bPtr);
      }
    }

    // Dart fallback
    const double gamma = 0.80;
    double rRaw = 0, gRaw = 0, bRaw = 0;

    if (wavelength >= 380 && wavelength < 440) {
      final attenuation = 0.3 + 0.7 * (wavelength - 380) / (440 - 380);
      rRaw = pow((-(wavelength - 440) / (440 - 380)) * attenuation, gamma).toDouble();
      bRaw = pow(1.0 * attenuation, gamma).toDouble();
    } else if (wavelength >= 440 && wavelength < 490) {
      gRaw = pow((wavelength - 440) / (490 - 440), gamma).toDouble();
      bRaw = 1.0;
    } else if (wavelength >= 490 && wavelength < 510) {
      gRaw = 1.0;
      bRaw = pow((-(wavelength - 510) / (510 - 490)), gamma).toDouble();
    } else if (wavelength >= 510 && wavelength < 580) {
      rRaw = pow((wavelength - 510) / (580 - 510), gamma).toDouble();
      gRaw = 1.0;
    } else if (wavelength >= 580 && wavelength < 645) {
      rRaw = 1.0;
      gRaw = pow((-(wavelength - 645) / (645 - 580)), gamma).toDouble();
    } else if (wavelength >= 645 && wavelength <= 780) {
      final attenuation = 0.3 + 0.7 * (780 - wavelength) / (780 - 645);
      rRaw = pow(1.0 * attenuation, gamma).toDouble();
    }

    final r = (rRaw * 255.0).round().clamp(0, 255);
    final g = (gRaw * 255.0).round().clamp(0, 255);
    final b = (bRaw * 255.0).round().clamp(0, 255);

    return Color.fromRGBO(r, g, b, 1.0);
  }
}
