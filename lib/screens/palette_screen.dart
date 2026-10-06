import 'dart:math';
import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class PaletteScreen extends StatefulWidget {
  final Color currentColor;
  final HSVColor hsv;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onCopyColor;
  final ValueChanged<Color> onSaveFavorite;
  final VoidCallback onToggleSniper;
  final String colorBlindnessMode;
  final bool isGoldMode;

  const PaletteScreen({
    super.key,
    required this.currentColor,
    required this.hsv,
    required this.onColorChanged,
    required this.onCopyColor,
    required this.onSaveFavorite,
    required this.onToggleSniper,
    this.colorBlindnessMode = 'None',
    this.isGoldMode = true,
  });

  @override
  State<PaletteScreen> createState() => _PaletteScreenState();
}

class _PaletteScreenState extends State<PaletteScreen> {
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: ColorManager.colorToHex(widget.currentColor),
    );
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
    _hexController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final comp = ColorManager.getComplementary(widget.currentColor);
    final analogous = ColorManager.getAnalogous(widget.currentColor, count: 7);
    final triadic = ColorManager.getTriadic(widget.currentColor);

    final colorItems = [
      _ColorCardItem("① Original", widget.currentColor),
      _ColorCardItem("② Complementario", comp),
      _ColorCardItem("③ Análogo L", analogous.length > 2 ? analogous[2] : analogous.first),
      _ColorCardItem("④ Análogo R", analogous.length > 4 ? analogous[4] : analogous.last),
      _ColorCardItem("⑤ Triádico 1", triadic[1]),
      _ColorCardItem("⑥ Triádico 2", triadic[2]),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          // Hex Input Row with Show & Camera Sniper buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _hexController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "#RRGGBB",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
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
              // Apply Hex Button
              GestureDetector(
                onTap: _applyHexInput,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: GoldTheme.goldBoxDecoration(borderRadius: 12),
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
              // Camera Sniper Trigger Button
              GestureDetector(
                onTap: widget.onToggleSniper,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: GoldTheme.goldBoxDecoration(borderRadius: 12),
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
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GoldButton(
                  text: "COMPLEMENTARIO",
                  onClick: () => widget.onColorChanged(comp),
                  height: 44,
                  icon: Icons.invert_colors,
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
              final textColor = isDark ? Colors.white : Colors.black;

              return GestureDetector(
                onTap: () => widget.onCopyColor(item.color),
                onLongPress: () => widget.onSaveFavorite(item.color),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GoldTheme.goldMid, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 3),
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
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.star_border, color: textColor, size: 18),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ColorManager.colorToHex(item.color),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            "RGB: (${(item.color.red * 255).round()}, ${(item.color.green * 255).round()}, ${(item.color.blue * 255).round()})",
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
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
