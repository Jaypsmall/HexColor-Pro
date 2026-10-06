import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';
import '../widgets/export_dialog.dart';

class PickerScreen extends StatefulWidget {
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<Color> onSaveFavorite;
  final ValueChanged<Color> onCopyColor;
  final String colorBlindnessMode;

  const PickerScreen({
    super.key,
    required this.onColorSelected,
    required this.onSaveFavorite,
    required this.onCopyColor,
    this.colorBlindnessMode = 'None',
  });

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  File? _imageFile;
  List<Color> _extractedColors = [];
  bool _isLoading = false;
  double _extractCount = 12.0;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _extractedColors.clear();
        });
        _extractColors();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al abrir imagen")),
        );
      }
    }
  }

  Future<void> _extractColors() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final imageProvider = FileImage(_imageFile!);
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: _extractCount.toInt(),
      );

      final colors = palette.colors.toList();

      if (mounted) {
        setState(() {
          _extractedColors = colors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showExportDialog() {
    if (_extractedColors.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => ExportDialogWidget(colors: _extractedColors),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          // Image Preview Container
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GoldTheme.goldMid, width: 1.2),
            ),
            alignment: Alignment.center,
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 56),
                      SizedBox(height: 8),
                      Text("Sin imagen seleccionada", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),

          const SizedBox(height: 14),

          // Extract Count Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Colores a extraer: ${_extractCount.toInt()}",
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _extractCount,
                min: 4.0,
                max: 32.0,
                divisions: 28,
                activeColor: GoldTheme.goldMid,
                inactiveColor: Colors.white24,
                onChanged: (val) {
                  setState(() => _extractCount = val);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Action Buttons: Add Image & Extract
          Row(
            children: [
              Expanded(
                child: GoldButton(
                  text: "AÑADIR IMAGEN",
                  onClick: _pickImage,
                  height: 46,
                  icon: Icons.image,
                ),
              ),
              if (_imageFile != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: GoldButton(
                    text: _isLoading ? "EXTRAYENDO..." : "EXTRAER COLORES",
                    onClick: _isLoading ? () {} : _extractColors,
                    height: 46,
                    icon: Icons.colorize,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 18),

          // Detected Colors Header & Share
          if (_extractedColors.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "COLORES DETECTADOS",
                  style: TextStyle(
                    color: GoldTheme.goldLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
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
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: _extractedColors.length,
              itemBuilder: (context, index) {
                final color = _extractedColors[index];
                final displayColor = ColorManager.simulateColorBlindness(
                  color,
                  widget.colorBlindnessMode,
                );
                final isDark = ColorManager.isDark(displayColor);
                final textColor = isDark ? Colors.white : Colors.black;

                return GestureDetector(
                  onTap: () => widget.onColorSelected(color),
                  onLongPress: () => widget.onSaveFavorite(color),
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
                        Text(
                          "Extraído #${index + 1}",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ColorManager.colorToHex(color),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
