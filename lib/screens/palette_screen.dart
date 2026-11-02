import 'dart:math';
import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../favorites_manager.dart';
import '../theme/gold_theme.dart';

class PaletteScreen extends StatefulWidget {
  final Color currentColor;
  final HSVColor hsv;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onCopyColor;
  final ValueChanged<Color> onToggleFavorite;
  final VoidCallback onToggleSniper;
  final String colorBlindnessMode;
  final bool isGoldMode;
  final bool isDarkMode;

  const PaletteScreen({
    super.key,
    required this.currentColor,
    required this.hsv,
    required this.onColorChanged,
    required this.onCopyColor,
    required this.onToggleFavorite,
    required this.onToggleSniper,
    this.colorBlindnessMode = 'None',
    this.isGoldMode = true,
    this.isDarkMode = true,
  });

  @override
  State<PaletteScreen> createState() => _PaletteScreenState();
}

enum PaletteMode { standard, tetradic, monochromatic, shadesTints }

class _PaletteScreenState extends State<PaletteScreen> {
  late TextEditingController _hexController;
  PaletteMode _mode = PaletteMode.standard;
  final FavoritesManager _favManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: ColorManager.colorToHex(widget.currentColor),
    );
    _favManager.addListener(_onFavsChanged);
  }

  @override
  void didUpdateWidget(covariant PaletteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentColor != widget.currentColor) {
      _hexController.text = ColorManager.colorToHex(widget.currentColor);
    }
  }

  @override
  void dispose() {
    _favManager.removeListener(_onFavsChanged);
    _hexController.dispose();
    super.dispose();
  }

  void _onFavsChanged() {
    if (mounted) setState(() {});
  }

  void _applyHexInput() {
    final parsed = ColorManager.hexToColor(_hexController.text);
    if (parsed != null) {
      widget.onColorChanged(parsed);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hex inválido (#RRGGBB)"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _generateRandomColor() {
    final random = Random();
    final newColor = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
    widget.onColorChanged(newColor);
  }

  List<_ColorCardItem> _buildColorItems() {
    final color = widget.currentColor;
    final comp = ColorManager.getComplementary(color);
    final analogous = ColorManager.getAnalogous(color, count: 7);
    final triadic = ColorManager.getTriadic(color);

    switch (_mode) {
      case PaletteMode.standard:
        return [
          _ColorCardItem("① Original", color),
          _ColorCardItem("② Complementario", comp),
          _ColorCardItem("③ Análogo L", analogous.length > 2 ? analogous[2] : analogous.first),
          _ColorCardItem("④ Análogo R", analogous.length > 4 ? analogous[4] : analogous.last),
          _ColorCardItem("⑤ Triádico 1", triadic[1]),
          _ColorCardItem("⑥ Triádico 2", triadic[2]),
        ];
      case PaletteMode.tetradic:
        final tetradic = ColorManager.getTetradic(color);
        return [
          _ColorCardItem("① Base", tetradic[0]),
          _ColorCardItem("② Tetrádico +90°", tetradic[1]),
          _ColorCardItem("③ Tetrádico +180°", tetradic[2]),
          _ColorCardItem("④ Tetrádico +270°", tetradic[3]),
        ];
      case PaletteMode.monochromatic:
        final mono = ColorManager.getMonochromatic(color, count: 6);
        return List.generate(
          mono.length,
          (i) => _ColorCardItem("Tono ${i + 1}", mono[i]),
        );
      case PaletteMode.shadesTints:
        final shades = ColorManager.getShadesAndTints(color, count: 6);
        return List.generate(
          shades.length,
          (i) => _ColorCardItem("Matiz ${i + 1}", shades[i]),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorItems = _buildColorItems();
    final txtColor = GoldTheme.textColor(widget.isDarkMode);
    final inputBg = GoldTheme.cardInputColor(widget.isDarkMode);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          // Hex Input Row & Sniper Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _hexController,
                    style: TextStyle(
                      color: txtColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "#RRGGBB",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GoldTheme.goldMid, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GoldTheme.goldLight, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _applyHexInput(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _applyHexInput,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: GoldTheme.goldBoxDecoration(
                    borderRadius: 12,
                    isDarkMode: widget.isDarkMode,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "MOSTRAR",
                    style: TextStyle(
                      color: GoldTheme.goldText,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onToggleSniper,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: GoldTheme.goldBoxDecoration(
                    borderRadius: 12,
                    isDarkMode: widget.isDarkMode,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.camera_alt,
                    color: GoldTheme.goldText,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Palette Mode Filter Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ModeChip(
                  label: "ESTÁNDAR",
                  isSelected: _mode == PaletteMode.standard,
                  isDarkMode: widget.isDarkMode,
                  onTap: () => setState(() => _mode = PaletteMode.standard),
                ),
                const SizedBox(width: 6),
                _ModeChip(
                  label: "TETRÁDICO",
                  isSelected: _mode == PaletteMode.tetradic,
                  isDarkMode: widget.isDarkMode,
                  onTap: () => setState(() => _mode = PaletteMode.tetradic),
                ),
                const SizedBox(width: 6),
                _ModeChip(
                  label: "MONOCROMÁTICO",
                  isSelected: _mode == PaletteMode.monochromatic,
                  isDarkMode: widget.isDarkMode,
                  onTap: () => setState(() => _mode = PaletteMode.monochromatic),
                ),
                const SizedBox(width: 6),
                _ModeChip(
                  label: "SOMBRAS / MATICES",
                  isSelected: _mode == PaletteMode.shadesTints,
                  isDarkMode: widget.isDarkMode,
                  onTap: () => setState(() => _mode = PaletteMode.shadesTints),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Hue Rainbow Slider
          Container(
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GoldTheme.goldMid, width: 1.2),
              gradient: const LinearGradient(
                colors: [
                  Colors.red,
                  Colors.yellow,
                  Colors.green,
                  Colors.cyan,
                  Colors.blue,
                  Color(0xFFFF00FF),
                  Colors.red,
                ],
              ),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 36,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: widget.hsv.hue,
                min: 0.0,
                max: 360.0,
                onChanged: (val) {
                  final newColor = ColorManager.hsvToColor(
                    val,
                    widget.hsv.saturation,
                    widget.hsv.value,
                  );
                  widget.onColorChanged(newColor);
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Random & Complementary
          Row(
            children: [
              Expanded(
                child: GoldButton(
                  text: "ALEATORIO",
                  onClick: _generateRandomColor,
                  height: 44,
                  icon: Icons.shuffle,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GoldButton(
                  text: "COMPLEMENTARIO",
                  onClick: () => widget.onColorChanged(
                    ColorManager.getComplementary(widget.currentColor),
                  ),
                  height: 44,
                  icon: Icons.invert_colors,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemCount: colorItems.length,
            itemBuilder: (context, index) {
              final item = colorItems[index];
              final displayColor = ColorManager.simulateColorBlindness(
                item.color,
                widget.colorBlindnessMode,
              );
              final isDark = ColorManager.isDark(displayColor);
              final cardTextColor = isDark ? Colors.white : Colors.black;
              final isFav = _favManager.isFavorite(item.color);

              return GestureDetector(
                onTap: () => widget.onCopyColor(item.color),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GoldTheme.goldMid, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDarkMode ? Colors.black38 : Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: cardTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onToggleFavorite(item.color),
                            child: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: isFav ? GoldTheme.goldLight : cardTextColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ColorManager.colorToHex(item.color),
                            style: TextStyle(
                              color: cardTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            ColorManager.colorToRgbString(item.color),
                            style: TextStyle(
                              color: cardTextColor.withOpacity(0.85),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ColorCardItem {
  final String title;
  final Color color;

  _ColorCardItem(this.title, this.color);
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ModeChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? GoldTheme.goldBoxDecoration(
                borderRadius: 10,
                isDarkMode: isDarkMode,
              )
            : BoxDecoration(
                color: isDarkMode ? Colors.black38 : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                ),
              ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? GoldTheme.goldText : (isDarkMode ? Colors.grey : Colors.black54),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
