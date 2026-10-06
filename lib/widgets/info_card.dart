import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class InfoCardWidget extends StatelessWidget {
  final Color currentColor;
  final List<Color> harmonyColors;
  final ValueChanged<Color> onCopyColor;
  final String colorBlindnessMode;
  final bool isGoldMode;

  const InfoCardWidget({
    super.key,
    required this.currentColor,
    required this.harmonyColors,
    required this.onCopyColor,
    this.colorBlindnessMode = 'None',
    this.isGoldMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final contrastWhite = ColorManager.getContrastRatio(currentColor, Colors.white);
    final contrastBlack = ColorManager.getContrastRatio(currentColor, Colors.black);
    final maxContrast = contrastWhite > contrastBlack ? contrastWhite : contrastBlack;
    final isPass = maxContrast >= 4.5;
    final bestTextColor = contrastWhite > contrastBlack ? "Blanco" : "Negro";

    final hexStr = ColorManager.colorToHex(currentColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GoldTheme.darkCard.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GoldTheme.goldMid, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hex Badge Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
            ),
            child: Text(
              hexStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 8),

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
                style: const TextStyle(color: Colors.grey, fontSize: 11),
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
                          style: const TextStyle(
                            color: Colors.grey,
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
