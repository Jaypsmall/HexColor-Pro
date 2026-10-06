import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class SpectrumDialogWidget extends StatefulWidget {
  final ValueChanged<Color> onSelectColor;

  const SpectrumDialogWidget({
    super.key,
    required this.onSelectColor,
  });

  @override
  State<SpectrumDialogWidget> createState() => _SpectrumDialogWidgetState();
}

class _SpectrumDialogWidgetState extends State<SpectrumDialogWidget> {
  double _wavelength = 520.0; // 520nm default (Green)

  @override
  Widget build(BuildContext context) {
    final currentColor = ColorManager.wavelengthToColor(_wavelength);
    final hexStr = ColorManager.colorToHex(currentColor);

    return Dialog(
      backgroundColor: GoldTheme.darkCard,
      shape: GoldTheme.goldBorderShape(borderRadius: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ESPECTRO VISIBLE (nm)",
              style: TextStyle(
                color: GoldTheme.goldLight,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Color Preview Box
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GoldTheme.goldMid, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                "$hexStr (${_wavelength.round()} nm)",
                style: TextStyle(
                  color: ColorManager.isDark(currentColor) ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Wavelength Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("380 nm (UV)", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(
                      "${_wavelength.toStringAsFixed(1)} nm",
                      style: const TextStyle(color: GoldTheme.goldLight, fontWeight: FontWeight.bold),
                    ),
                    const Text("780 nm (IR)", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                Slider(
                  value: _wavelength,
                  min: 380.0,
                  max: 780.0,
                  activeColor: GoldTheme.goldMid,
                  inactiveColor: Colors.white24,
                  onChanged: (val) {
                    setState(() {
                      _wavelength = val;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSelectColor(currentColor);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GoldTheme.goldMid,
                  ),
                  child: const Text(
                    "SELECCIONAR",
                    style: TextStyle(color: GoldTheme.goldText, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
