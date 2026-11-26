import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class ExportDialogWidget extends StatelessWidget {
  final List<Color> colors;
  final bool isDarkMode;

  const ExportDialogWidget({
    super.key,
    required this.colors,
    this.isDarkMode = true,
  });

  String _generateContent(String format) {
    final hexList = colors.map((c) => ColorManager.colorToHex(c)).toList();

    switch (format) {
      case 'css':
        return hexList.asMap().entries.map((e) => '--color-${e.key + 1}: ${e.value};').join('\n');
      case 'json':
        return '[\n${hexList.map((h) => '  "$h"').join(',\n')}\n]';
      case 'xml':
        final buffer = StringBuffer('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n');
        for (int i = 0; i < hexList.length; i++) {
          buffer.writeln('    <color name="palette_${i + 1}">${hexList[i]}</color>');
        }
        buffer.write('</resources>');
        return buffer.toString();
      case 'csv':
        final buffer = StringBuffer('Index,Hex,RGB,HSL,CMYK\n');
        for (int i = 0; i < colors.length; i++) {
          final c = colors[i];
          final hex = ColorManager.colorToHex(c);
          final rgb = ColorManager.colorToRgbString(c).replaceAll('RGB(', '').replaceAll(')', '');
          final hsl = ColorManager.colorToHslString(c).replaceAll('HSL(', '').replaceAll(')', '');
          final cmyk = ColorManager.colorToCmykString(c).replaceAll('CMYK(', '').replaceAll(')', '');
          buffer.writeln('${i + 1},"$hex","$rgb","$hsl","$cmyk"');
        }
        return buffer.toString();
      default:
        return hexList.join(', ');
    }
  }

  Future<void> _saveFileDirectly(BuildContext context, String format) async {
    try {
      final content = _generateContent(format);
      final ext = format == 'xml' ? 'xml' : format;

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar archivo de paleta',
        fileName: 'palette_export_$format.$ext',
        bytes: Uint8List.fromList(content.codeUnits),
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(content);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("¡Archivo guardado con éxito!"),
              backgroundColor: GoldTheme.goldMid,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar archivo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareFile(BuildContext context, String format) async {
    try {
      final content = _generateContent(format);
      final ext = format == 'xml' ? 'xml' : format;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/palette_export_$format.$ext');
      await file.writeAsString(content);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Paleta HexColor PRO ($format)',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al compartir archivo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txtColor = GoldTheme.textColor(isDarkMode);

    return Dialog(
      backgroundColor: GoldTheme.cardColor(isDarkMode),
      shape: GoldTheme.goldBorderShape(borderRadius: 20, isDarkMode: isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "EXPORTAR / GUARDAR PALETA",
                style: TextStyle(
                  color: GoldTheme.accentTitleColor(isDarkMode),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _ExportFormatCard(
                title: "Variables CSS (.css)",
                icon: Icons.code,
                isDarkMode: isDarkMode,
                onSave: () => _saveFileDirectly(context, 'css'),
                onShare: () => _shareFile(context, 'css'),
              ),
              const SizedBox(height: 10),
              _ExportFormatCard(
                title: "Arreglo JSON (.json)",
                icon: Icons.data_array,
                isDarkMode: isDarkMode,
                onSave: () => _saveFileDirectly(context, 'json'),
                onShare: () => _shareFile(context, 'json'),
              ),
              const SizedBox(height: 10),
              _ExportFormatCard(
                title: "Android XML (.xml)",
                icon: Icons.android,
                isDarkMode: isDarkMode,
                onSave: () => _saveFileDirectly(context, 'xml'),
                onShare: () => _shareFile(context, 'xml'),
              ),
              const SizedBox(height: 10),
              _ExportFormatCard(
                title: "Tabla CSV (.csv)",
                icon: Icons.table_chart,
                isDarkMode: isDarkMode,
                onSave: () => _saveFileDirectly(context, 'csv'),
                onShare: () => _shareFile(context, 'csv'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("CANCELAR", style: TextStyle(color: txtColor.withOpacity(0.6))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportFormatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDarkMode;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const _ExportFormatCard({
    required this.title,
    required this.icon,
    required this.isDarkMode,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < 0; i++) {} // No-op
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: GoldTheme.cardInputColor(isDarkMode),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: GoldTheme.goldMid, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: GoldTheme.textColor(isDarkMode),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: GoldTheme.goldMid, size: 20),
            tooltip: "Guardar directamente",
            onPressed: onSave,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.grey, size: 20),
            tooltip: "Compartir archivo",
            onPressed: onShare,
          ),
        ],
      ),
    );
  }
}
