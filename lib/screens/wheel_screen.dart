import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';
import '../widgets/color_wheel.dart';
import '../widgets/export_dialog.dart';
import '../widgets/info_card.dart';

class WheelScreen extends StatefulWidget {
  final Color currentColor;
  final HSVColor hsv;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onCopyColor;
  final bool isGoldMode;
  final String colorBlindnessMode;
  final ValueChanged<String> onColorBlindnessChanged;

  const WheelScreen({
    super.key,
    required this.currentColor,
    required this.hsv,
    required this.onColorChanged,
    required this.onCopyColor,
    this.isGoldMode = true,
    this.colorBlindnessMode = 'None',
    required this.onColorBlindnessChanged,
  });

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  HarmonyMode _harmonyMode = HarmonyMode.complementary;
  int _analogousCount = 7;

  List<Color> _calculateHarmonyColors() {
    switch (_harmonyMode) {
      case HarmonyMode.complementary:
        return [
          widget.currentColor,
          ColorManager.getComplementary(widget.currentColor),
        ];
      case HarmonyMode.triadic:
        return ColorManager.getTriadic(widget.currentColor);
      case HarmonyMode.analogous:
        return ColorManager.getAnalogous(widget.currentColor, count: _analogousCount);
    }
  }

  void _showExportDialog() {
    final colors = _calculateHarmonyColors();
    showDialog(
      context: context,
      builder: (context) => ExportDialogWidget(colors: colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final harmonyColors = _calculateHarmonyColors();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          // Header Harmony Selector Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _HarmonyButton(
                      label: "COMPLEMENTARIO",
                      isSelected: _harmonyMode == HarmonyMode.complementary,
                      onTap: () => setState(() => _harmonyMode = HarmonyMode.complementary),
                    ),
                    const SizedBox(width: 6),
                    _HarmonyButton(
                      label: "TRIÁDICO",
                      isSelected: _harmonyMode == HarmonyMode.triadic,
                      onTap: () => setState(() => _harmonyMode = HarmonyMode.triadic),
                    ),
                    const SizedBox(width: 6),
                    _HarmonyButton(
                      label: "ANÁLOGO",
                      isSelected: _harmonyMode == HarmonyMode.analogous,
                      onTap: () => setState(() => _harmonyMode = HarmonyMode.analogous),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Export Share Button
              IconButton(
                onPressed: _showExportDialog,
                icon: const Icon(Icons.share, color: GoldTheme.goldLight),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  side: const BorderSide(color: GoldTheme.goldMid, width: 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive Color Wheel
          SizedBox(
            height: 320,
            width: double.infinity,
            child: ColorWheelWidget(
              currentColor: widget.currentColor,
              hsv: widget.hsv,
              harmonyMode: _harmonyMode,
              analogousCount: _analogousCount,
              onColorChanged: widget.onColorChanged,
              colorBlindnessMode: widget.colorBlindnessMode,
              isGoldMode: widget.isGoldMode,
            ),
          ),

          const SizedBox(height: 16),

          // Brightness / Value Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  "BRILLO / SOMBRA",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GoldTheme.goldMid, width: 1),
                ),
                child: Slider(
                  value: widget.hsv.value,
                  min: 0.0,
                  max: 1.0,
                  activeColor: GoldTheme.goldMid,
                  inactiveColor: Colors.white24,
                  onChanged: (val) {
                    final newColor = ColorManager.hsvToColor(
                      widget.hsv.hue,
                      widget.hsv.saturation,
                      val,
                    );
                    widget.onColorChanged(newColor);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info Card with WCAG contrast & swatches
          InfoCardWidget(
            currentColor: widget.currentColor,
            harmonyColors: harmonyColors,
            onCopyColor: widget.onCopyColor,
            colorBlindnessMode: widget.colorBlindnessMode,
            isGoldMode: widget.isGoldMode,
          ),
        ],
      ),
    );
  }
}

class _HarmonyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HarmonyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: isSelected
              ? GoldTheme.goldBoxDecoration(borderRadius: 10)
              : BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? GoldTheme.goldText : Colors.grey,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
