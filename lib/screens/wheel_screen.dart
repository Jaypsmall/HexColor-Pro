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
  final int analogousCount;
  final ValueChanged<bool>? onWheelInteracting;

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
    this.analogousCount = 7,
    this.onWheelInteracting,
  });

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  HarmonyMode _harmonyMode = HarmonyMode.complementary;
  bool _isShadowMode = false;
  bool _isWheelDragging = false;
  final FavoritesManager _favManager = FavoritesManager();

  // Floating Overlay State
  bool _isOverlayActive = false;
  Offset _overlayPos = const Offset(60, 180);

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

  void _onMoonTapped() {
    setState(() {
      _isShadowMode = !_isShadowMode;
      if (_isShadowMode) {
        final newColor = ColorManager.hsvToColor(
          widget.hsv.hue,
          widget.hsv.saturation,
          0.5,
        );
        widget.onColorChanged(newColor);
      } else {
        final newColor = ColorManager.hsvToColor(
          widget.hsv.hue,
          widget.hsv.saturation,
          1.0,
        );
        widget.onColorChanged(newColor);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isShadowMode
              ? "Modo Sombras Activado 🌙 (Brillo al 50%)"
              : "Modo Luz Normal Activado ☀️ (Brillo al 100%)",
        ),
        backgroundColor: GoldTheme.goldMid,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _setWheelDragging(bool dragging) {
    if (_isWheelDragging != dragging) {
      setState(() {
        _isWheelDragging = dragging;
      });
      widget.onWheelInteracting?.call(dragging);
    }
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
        return ColorManager.getAnalogous(widget.currentColor, count: widget.analogousCount);
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

    return Stack(
      children: [
        SingleChildScrollView(
          physics: _isWheelDragging ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              // Header Harmony Selector Row (Scrollable chips)
              SingleChildScrollView(
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

              const SizedBox(height: 10),

              // Action Buttons Row (Favorite, Share & Floating Overlay Toggle)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isOverlayActive = !_isOverlayActive),
                    icon: Icon(
                      _isOverlayActive ? Icons.picture_in_picture : Icons.picture_in_picture_alt,
                      color: _isOverlayActive ? GoldTheme.goldLight : GoldTheme.goldMid,
                      size: 16,
                    ),
                    label: Text(
                      _isOverlayActive ? "Ocultar Flotante" : "Superposición",
                      style: TextStyle(color: GoldTheme.accentTitleColor(widget.isDarkMode), fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: widget.isDarkMode ? Colors.black45 : Colors.black12,
                      side: const BorderSide(color: GoldTheme.goldMid, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: () => widget.onToggleFavorite(widget.currentColor),
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? GoldTheme.goldLight : GoldTheme.accentTitleColor(widget.isDarkMode),
                      size: 16,
                    ),
                    label: Text(
                      isFav ? "Favorito" : "Guardar",
                      style: TextStyle(color: GoldTheme.accentTitleColor(widget.isDarkMode), fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: widget.isDarkMode ? Colors.black45 : Colors.black12,
                      side: const BorderSide(color: GoldTheme.goldMid, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: _showExportDialog,
                    icon: const Icon(Icons.share, color: GoldTheme.goldMid, size: 16),
                    label: const Text(
                      "Exportar",
                      style: TextStyle(color: GoldTheme.goldMid, fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: widget.isDarkMode ? Colors.black45 : Colors.black12,
                      side: const BorderSide(color: GoldTheme.goldMid, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Interactive Color Wheel with Center Moon
              SizedBox(
                height: 260,
                width: double.infinity,
                child: ColorWheelWidget(
                  currentColor: widget.currentColor,
                  hsv: widget.hsv,
                  harmonyMode: _harmonyMode,
                  analogousCount: widget.analogousCount,
                  onColorChanged: widget.onColorChanged,
                  onMoonTapped: _onMoonTapped,
                  onPanStart: () => _setWheelDragging(true),
                  onPanEnd: () => _setWheelDragging(false),
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
        ),

        // Draggable Floating Overlay Widget (Superposición)
        if (_isOverlayActive)
          Positioned(
            left: _overlayPos.dx,
            top: _overlayPos.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _overlayPos += details.delta;
                });
              },
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GoldTheme.cardColor(widget.isDarkMode).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GoldTheme.goldMid, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "🪟 Flotante (Hex)",
                            style: TextStyle(
                              color: GoldTheme.goldLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isOverlayActive = false),
                            child: const Icon(Icons.close, color: Colors.grey, size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: harmonyColors.map((color) {
                          final hex = ColorManager.colorToHex(color);
                          return GestureDetector(
                            onTap: () => widget.onCopyColor(color),
                            child: Container(
                              width: 60,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GoldTheme.goldMid, width: 1),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                hex,
                                style: TextStyle(
                                  color: ColorManager.isDark(color) ? Colors.white : Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Toca para copiar Hex",
                        style: TextStyle(color: Colors.grey, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
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
