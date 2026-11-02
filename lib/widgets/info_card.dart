import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class InfoCardWidget extends StatelessWidget {
  final Color currentColor;
  final List<Color> harmonyColors;
  final ValueChanged<Color> onCopyColor;
  final String colorBlindnessMode;
  final bool isGoldMode;
  final bool isDarkMode;

  const InfoCardWidget({
    super.key,
    required this.currentColor,
    required this.harmonyColors,
    required this.onCopyColor,
    this.colorBlindnessMode = 'None',
    this.isGoldMode = true,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final contrastWhite = ColorManager.getContrastRatio(currentColor, Colors.white);
    final contrastBlack = ColorManager.getContrastRatio(currentColor, Colors.black);
    final maxContrast = contrastWhite > contrastBlack ? contrastWhite : contrastBlack;
    final isPass = maxContrast >= 4.5;
    final bestTextColor = contrastWhite > contrastBlack ? "Blanco" : "Negro";

    final hexStr = ColorManager.colorToHex(currentColor);
    final rgbStr = ColorManager.colorToRgbString(currentColor);
    final hslStr = ColorManager.colorToHslString(currentColor);
    final cmykStr = ColorManager.colorToCmykString(currentColor);

    final cardBg = GoldTheme.cardColor(isDarkMode);
    final txtColor = GoldTheme.textColor(isDarkMode);
    final inputBg = GoldTheme.cardInputColor(isDarkMode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GoldTheme.goldMid, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hex Badge Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
            ),
            child: Text(
              hexStr,
              style: TextStyle(
                color: txtColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Format Values Row (RGB, HSL, CMYK)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FormatChip(label: rgbStr, isDarkMode: isDarkMode),
                const SizedBox(width: 6),
                _FormatChip(label: hslStr, isDarkMode: isDarkMode),
                const SizedBox(width: 6),
                _FormatChip(label: cmykStr, isDarkMode: isDarkMode),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // WCAG Contrast Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPass ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPass ? "WCAG PASS" : "WCAG FAIL",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Ratio: ${maxContrast.toStringAsFixed(1)}:1 ($bestTextColor)",
                style: TextStyle(
                  color: GoldTheme.subtextColor(isDarkMode),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Harmony Swatches Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(harmonyColors.length, (index) {
                final color = harmonyColors[index];
                final displayColor = ColorManager.simulateColorBlindness(color, colorBlindnessMode);
                final isDark = ColorManager.isDark(displayColor);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onCopyColor(color),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: displayColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GoldTheme.goldMid.withOpacity(0.6),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ColorManager.colorToHex(color).replaceAll('#', ''),
                          style: TextStyle(
                            color: GoldTheme.subtextColor(isDarkMode),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  final bool isDarkMode;

  const _FormatChip({required this.label, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black38 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GoldTheme.goldMid.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: GoldTheme.textColor(isDarkMode),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
