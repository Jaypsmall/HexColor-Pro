import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void _copyToClipboard(BuildContext context, String format) {
    final content = _generateContent(format);
    Clipboard.setData(ClipboardData(text: content));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Exportado a portapapeles ($format)"),
        backgroundColor: GoldTheme.goldMid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txtColor = GoldTheme.textColor(isDarkMode);

    return Dialog(
      backgroundColor: GoldTheme.cardColor(isDarkMode),
      shape: GoldTheme.goldBorderShape(borderRadius: 20, isDarkMode: isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "EXPORTAR PALETA",
              style: TextStyle(
                color: GoldTheme.accentTitleColor(isDarkMode),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _ExportOptionTile(
              title: "Variables CSS",
              subtitle: "Para desarrollo Web",
              icon: Icons.code,
              isDarkMode: isDarkMode,
              onTap: () => _copyToClipboard(context, 'css'),
            ),
            const SizedBox(height: 10),
            _ExportOptionTile(
              title: "Arreglo JSON",
              subtitle: "Para integraciones y config",
              icon: Icons.data_array,
              isDarkMode: isDarkMode,
              onTap: () => _copyToClipboard(context, 'json'),
            ),
            const SizedBox(height: 10),
            _ExportOptionTile(
              title: "Android XML",
              subtitle: "Para colors.xml en Android",
              icon: Icons.android,
              isDarkMode: isDarkMode,
              onTap: () => _copyToClipboard(context, 'xml'),
            ),
            const SizedBox(height: 10),
            _ExportOptionTile(
              title: "Tabla CSV",
              subtitle: "Para Excel, Figma y hojas de cálculo",
              icon: Icons.table_chart,
              isDarkMode: isDarkMode,
              onTap: () => _copyToClipboard(context, 'csv'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("CANCELAR", style: TextStyle(color: txtColor.withOpacity(0.6))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: GoldTheme.cardInputColor(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: GoldTheme.goldMid, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: GoldTheme.textColor(isDarkMode),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy, color: GoldTheme.goldMid, size: 18),
          ],
        ),
      ),
    );
  }
}
