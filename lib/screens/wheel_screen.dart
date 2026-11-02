import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../favorites_manager.dart';
import '../theme/gold_theme.dart';
import '../widgets/color_wheel.dart';
import '../widgets/export_dialog.dart';
import '../widgets/info_card.dart';

class WheelScreen extends StatefulWidget {
  final Color currentColor;
  final HSVColor hsv;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onCopyColor;
  final ValueChanged<Color> onToggleFavorite;
  final bool isGoldMode;
  final bool isDarkMode;
  final String colorBlindnessMode;
  final ValueChanged<String> onColorBlindnessChanged;

  const WheelScreen({
    super.key,
    required this.currentColor,
    required this.hsv,
    required this.onColorChanged,
    required this.onCopyColor,
    required this.onToggleFavorite,
    this.isGoldMode = true,
    this.isDarkMode = true,
    this.colorBlindnessMode = 'None',
    required this.onColorBlindnessChanged,
  });

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  HarmonyMode _harmonyMode = HarmonyMode.complementary;
  final int _analogousCount = 7;
  bool _isShadowMode = false;
  final FavoritesManager _favManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _favManager.addListener(_onFavsChanged);
  }

  @override
  void dispose() {
    _favManager.removeListener(_onFavsChanged);
    super.dispose();
  }

  void _onFavsChanged() {
    if (mounted) setState(() {});
  }

  void _toggleMoonShadowMode() {
    setState(() {
      _isShadowMode = !_isShadowMode;
      if (_isShadowMode) {
        _harmonyMode = HarmonyMode.shades;
      } else {
        _harmonyMode = HarmonyMode.complementary;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isShadowMode
              ? "Modo Sombras Activado 🌙"
              : "Modo Luz Normal Activado ☀️",
        ),
        backgroundColor: GoldTheme.goldMid,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<Color> _calculateHarmonyColors() {
    if (_isShadowMode || _harmonyMode == HarmonyMode.shades) {
      return ColorManager.getShadesAndTints(widget.currentColor, count: 6);
    }

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
      case HarmonyMode.tetradic:
        return ColorManager.getTetradic(widget.currentColor);
      case HarmonyMode.splitComplementary:
        return ColorManager.getSplitComplementary(widget.currentColor);
      case HarmonyMode.monochromatic:
        return ColorManager.getMonochromatic(widget.currentColor, count: 5);
      case HarmonyMode.shades:
        return ColorManager.getShadesAndTints(widget.currentColor, count: 6);
    }
  }

  void _showExportDialog() {
    final colors = _calculateHarmonyColors();
    showDialog(
      context: context,
      builder: (context) => ExportDialogWidget(
        colors: colors,
        isDarkMode: widget.isDarkMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final harmonyColors = _calculateHarmonyColors();
    final isFav = _favManager.isFavorite(widget.currentColor);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          // Header Harmony Selector Row & Export/Favorite Actions
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _HarmonyChip(
                        label: "COMPLEMENTARIO",
                        isSelected: !_isShadowMode && _harmonyMode == HarmonyMode.complementary,
                        isDarkMode: widget.isDarkMode,
                        onTap: () => setState(() {
                          _isShadowMode = false;
                          _harmonyMode = HarmonyMode.complementary;
                        }),
                      ),
                      const SizedBox(width: 6),
                      _HarmonyChip(
                        label: "TRIÁDICO",
                        isSelected: !_isShadowMode && _harmonyMode == HarmonyMode.triadic,
                        isDarkMode: widget.isDarkMode,
                        onTap: () => setState(() {
                          _isShadowMode = false;
                          _harmonyMode = HarmonyMode.triadic;
                        }),
                      ),
                      const SizedBox(width: 6),
                      _HarmonyChip(
                        label: "ANÁLOGO",
                        isSelected: !_isShadowMode && _harmonyMode == HarmonyMode.analogous,
                        isDarkMode: widget.isDarkMode,
                        onTap: () => setState(() {
                          _isShadowMode = false;
                          _harmonyMode = HarmonyMode.analogous;
                        }),
                      ),
                      const SizedBox(width: 6),
                      _HarmonyChip(
                        label: "TETRÁDICO",
                        isSelected: !_isShadowMode && _harmonyMode == HarmonyMode.tetradic,
                        isDarkMode: widget.isDarkMode,
                        onTap: () => setState(() {
                          _isShadowMode = false;
                          _harmonyMode = HarmonyMode.tetradic;
                        }),
                      ),
                      const SizedBox(width: 6),
                      _HarmonyChip(
                        label: "SOMBRAS",
                        isSelected: _isShadowMode || _harmonyMode == HarmonyMode.shades,
                        isDarkMode: widget.isDarkMode,
                        onTap: () => setState(() {
                          _isShadowMode = true;
                          _harmonyMode = HarmonyMode.shades;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => widget.onToggleFavorite(widget.currentColor),
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? GoldTheme.goldLight : GoldTheme.accentTitleColor(widget.isDarkMode),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? Colors.black45 : Colors.black12,
                  side: const BorderSide(color: GoldTheme.goldMid, width: 1),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _showExportDialog,
                icon: Icon(Icons.share, color: GoldTheme.accentTitleColor(widget.isDarkMode)),
                style: IconButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? Colors.black45 : Colors.black12,
                  side: const BorderSide(color: GoldTheme.goldMid, width: 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive Color Wheel with Center Moon (taps switch shadow mode)
          SizedBox(
            height: 320,
            width: double.infinity,
            child: ColorWheelWidget(
              currentColor: widget.currentColor,
              hsv: widget.hsv,
              harmonyMode: _harmonyMode,
              analogousCount: _analogousCount,
              onColorChanged: widget.onColorChanged,
              onMoonTapped: _toggleMoonShadowMode,
              isShadowMode: _isShadowMode,
              colorBlindnessMode: widget.colorBlindnessMode,
              isGoldMode: widget.isGoldMode,
              isDarkMode: widget.isDarkMode,
            ),
          ),

          const SizedBox(height: 16),

          // Brightness / Value Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  _isShadowMode ? "SOMBRAS / MATIZ (BRILLO)" : "BRILLO / SOMBRA",
                  style: TextStyle(
                    color: GoldTheme.subtextColor(widget.isDarkMode),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: GoldTheme.cardInputColor(widget.isDarkMode),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GoldTheme.goldMid, width: 1),
                ),
                child: Slider(
                  value: widget.hsv.value,
                  min: 0.0,
                  max: 1.0,
                  activeColor: GoldTheme.goldMid,
                  inactiveColor: widget.isDarkMode ? Colors.white24 : Colors.black12,
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
            isDarkMode: widget.isDarkMode,
          ),
        ],
      ),
    );
  }
}

class _HarmonyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _HarmonyChip({
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: isSelected
            ? GoldTheme.goldBoxDecoration(
                borderRadius: 10,
                isDarkMode: isDarkMode,
              )
            : BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                ),
              ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? GoldTheme.goldText : (isDarkMode ? Colors.grey : Colors.black54),
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
