import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class ExportDialogWidget extends StatelessWidget {
  final List<Color> colors;

  const ExportDialogWidget({
    super.key,
    required this.colors,
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
      default:
        return '';
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
    return Dialog(
      backgroundColor: GoldTheme.darkCard,
      shape: GoldTheme.goldBorderShape(borderRadius: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "EXPORTAR PALETA",
              style: TextStyle(
                color: GoldTheme.goldLight,
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
              onTap: () => _copyToClipboard(context, 'css'),
            ),
            const SizedBox(height: 10),
            _ExportOptionTile(
              title: "Arreglo JSON",
              subtitle: "Para integraciones y config",
              icon: Icons.data_array,
              onTap: () => _copyToClipboard(context, 'json'),
            ),
            const SizedBox(height: 10),
            _ExportOptionTile(
              title: "Android XML",
              subtitle: "Para colors.xml en Android",
              icon: Icons.android,
              onTap: () => _copyToClipboard(context, 'xml'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
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
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
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
          color: Colors.black38,
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
                    style: const TextStyle(
                      color: Colors.white,
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
            const Icon(Icons.copy, color: GoldTheme.goldLight, size: 18),
          ],
        ),
      ),
    );
  }
}
