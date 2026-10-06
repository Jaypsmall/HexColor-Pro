import 'dart:math';
import 'package:flutter/material.dart';
import '../color_manager.dart';
import '../theme/gold_theme.dart';

enum HarmonyMode { complementary, triadic, analogous }

class ColorWheelWidget extends StatelessWidget {
  final Color currentColor;
  final HSVColor hsv;
  final HarmonyMode harmonyMode;
  final int analogousCount;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color>? onColorTapped;
  final String colorBlindnessMode;
  final bool isGoldMode;
  final Color uiAccentColor;

  const ColorWheelWidget({
    super.key,
    required this.currentColor,
    required this.hsv,
    required this.harmonyMode,
    this.analogousCount = 7,
    required this.onColorChanged,
    this.onColorTapped,
    this.colorBlindnessMode = 'None',
    this.isGoldMode = true,
    this.uiAccentColor = GoldTheme.goldMid,
  });

  List<double> _getHarmonyOffsets() {
    switch (harmonyMode) {
      case HarmonyMode.complementary:
        return [0.0, 180.0];
      case HarmonyMode.triadic:
        return [0.0, 120.0, 240.0];
      case HarmonyMode.analogous:
        const double startAngle = -90.0;
        const double endAngle = 90.0;
        final double step = analogousCount > 1 ? (endAngle - startAngle) / (analogousCount - 1) : 0.0;
        return List.generate(analogousCount, (i) => startAngle + (i * step));
    }
  }

  void _handleTouch(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pos = localPosition - center;
    final dist = sqrt(pos.dx * pos.dx + pos.dy * pos.dy);
    final radius = min(size.width, size.height) / 2;

    if (radius <= 0) return;

    double hue = (atan2(pos.dy, pos.dx) * (180.0 / pi) + 360.0) % 360.0;
    double saturation = (dist / radius).clamp(0.0, 1.0);

    final newColor = ColorManager.hsvToColor(hue, saturation, hsv.value);
    onColorChanged(newColor);
  }

  @override
  Widget build(BuildContext context) {
    final offsets = _getHarmonyOffsets();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final minDim = min(size.width, size.height);

        return GestureDetector(
          onPanStart: (details) => _handleTouch(details.localPosition, size),
          onPanUpdate: (details) => _handleTouch(details.localPosition, size),
          onTapDown: (details) => _handleTouch(details.localPosition, size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: size,
                painter: _WheelPainter(
                  hsv: hsv,
                  currentColor: currentColor,
                  harmonyOffsets: offsets,
                  colorBlindnessMode: colorBlindnessMode,
                  isGoldMode: isGoldMode,
                  uiAccentColor: uiAccentColor,
                ),
              ),
              // Moon Icon in the center
              Icon(
                hsv.value > 0.5 ? Icons.nightlight_round : Icons.brightness_3_outlined,
                size: minDim * 0.28,
                color: isGoldMode
                    ? GoldTheme.goldLight.withOpacity(0.85)
                    : uiAccentColor.withOpacity(0.85),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  final HSVColor hsv;
  final Color currentColor;
  final List<double> harmonyOffsets;
  final String colorBlindnessMode;
  final bool isGoldMode;
  final Color uiAccentColor;

  _WheelPainter({
    required this.hsv,
    required this.currentColor,
    required this.harmonyOffsets,
    required this.colorBlindnessMode,
    required this.isGoldMode,
    required this.uiAccentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    if (radius <= 0) return;

    final ringThickness = radius * 0.12;
    final gap = radius * 0.02;

    final sweepColors = [
      Colors.red,
      Colors.yellow,
      Colors.green,
      Colors.cyan,
      Colors.blue,
      const Color(0xFFFF00FF),
      Colors.red,
    ].map((c) => ColorManager.simulateColorBlindness(c, colorBlindnessMode)).toList();

    // 1. Draw 3 Saturation Rings
    for (int i = 0; i < 3; i++) {
      final r = radius - (i * (ringThickness + gap)) - (ringThickness / 2);
      final ringSat = i == 0 ? 1.0 : (i == 1 ? 0.7 : 0.4);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..shader = SweepGradient(
          colors: sweepColors,
          center: Alignment.center,
        ).createShader(Rect.fromCircle(center: center, radius: r));

      canvas.drawCircle(center, r, paint);

      // Darkening for value / brightness
      if (hsv.value < 1.0) {
        final darkPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringThickness
          ..color = Colors.black.withOpacity(1.0 - hsv.value);
        canvas.drawCircle(center, r, darkPaint);
      }

      // Desaturation overlay
      final desatPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..color = Colors.grey.withOpacity((1.0 - (hsv.saturation * ringSat)) * 0.4);
      canvas.drawCircle(center, r, desatPaint);
    }

    // 2. Guide Line to Main Hue
    final mainRad = hsv.hue * pi / 180.0;
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * cos(mainRad), center.dy + radius * sin(mainRad)),
      linePaint,
    );

    // 3. Harmony Targets/Dots
    for (int i = 0; i < harmonyOffsets.length; i++) {
      final offsetAngle = harmonyOffsets[i];
      final targetHue = (hsv.hue + offsetAngle + 360.0) % 360.0;
      final rad = targetHue * pi / 180.0;

      final labelRadius = radius + 22.0;
      final labelPos = Offset(
        center.dx + labelRadius * cos(rad),
        center.dy + labelRadius * sin(rad),
      );

      final dotPaint = Paint()
        ..color = isGoldMode ? GoldTheme.goldMid : uiAccentColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(labelPos, 12.0, dotPaint);

      // Border for target dot
      final borderPaint = Paint()
        ..color = GoldTheme.goldBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(labelPos, 12.0, borderPaint);

      // Draw number index
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: isGoldMode ? GoldTheme.goldText : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          labelPos.dx - textPainter.width / 2,
          labelPos.dy - textPainter.height / 2,
        ),
      );
    }

    // 4. Handle Selector Dot at current (Hue, Saturation)
    final handleDist = hsv.saturation * radius;
    final handlePos = Offset(
      center.dx + handleDist * cos(mainRad),
      center.dy + handleDist * sin(mainRad),
    );

    canvas.drawCircle(handlePos, 11.0, Paint()..color = Colors.black);
    canvas.drawCircle(handlePos, 9.0, Paint()..color = Colors.white);
    canvas.drawCircle(
      handlePos,
      7.0,
      Paint()..color = ColorManager.simulateColorBlindness(currentColor, colorBlindnessMode),
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.hsv != hsv ||
        oldDelegate.currentColor != currentColor ||
        oldDelegate.harmonyOffsets != harmonyOffsets ||
        oldDelegate.colorBlindnessMode != colorBlindnessMode ||
        oldDelegate.isGoldMode != isGoldMode ||
        oldDelegate.uiAccentColor != uiAccentColor;
  }
}
