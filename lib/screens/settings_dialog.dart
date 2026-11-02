import 'package:flutter/material.dart';

import '../theme/gold_theme.dart';
import '../widgets/spectrum_dialog.dart';

class SettingsDialogWidget extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final bool isGoldMode;
  final ValueChanged<bool> onToggleGoldMode;
  final String colorBlindnessMode;
  final ValueChanged<String> onColorBlindnessChanged;
  final ValueChanged<Color> onSelectSpectrumColor;

  const SettingsDialogWidget({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.isGoldMode,
    required this.onToggleGoldMode,
    required this.colorBlindnessMode,
    required this.onColorBlindnessChanged,
    required this.onSelectSpectrumColor,
  });

  @override
  Widget build(BuildContext context) {
    final txtColor = GoldTheme.textColor(isDarkMode);
    final inputBg = GoldTheme.cardInputColor(isDarkMode);

    return Dialog(
      backgroundColor: GoldTheme.cardColor(isDarkMode),
      shape: GoldTheme.goldBorderShape(borderRadius: 24, isDarkMode: isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AJUSTES",
                    style: TextStyle(
                      color: GoldTheme.accentTitleColor(isDarkMode),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gold Mode Premium
              _SettingsSwitchTile(
                icon: Icons.workspace_premium,
                title: "Modo Oro (Premium)",
                value: isGoldMode,
                isDarkMode: isDarkMode,
                onChanged: onToggleGoldMode,
              ),

              const SizedBox(height: 10),

              // Dark Mode Toggle
              _SettingsSwitchTile(
                icon: Icons.dark_mode,
                title: "Modo Oscuro",
                value: isDarkMode,
                isDarkMode: isDarkMode,
                onChanged: onToggleDarkMode,
              ),

              const SizedBox(height: 16),

              // Color Blindness Dropdown Tile
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: GoldTheme.goldMid, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Daltonismo",
                        style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: colorBlindnessMode,
                      dropdownColor: GoldTheme.cardColor(isDarkMode),
                      underline: const SizedBox(),
                      style: TextStyle(color: GoldTheme.accentTitleColor(isDarkMode), fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 'None', child: Text('Ninguno')),
                        DropdownMenuItem(value: 'Protanopia', child: Text('Protanopia')),
                        DropdownMenuItem(value: 'Deuteranopia', child: Text('Deuteranopia')),
                        DropdownMenuItem(value: 'Tritanopia', child: Text('Tritanopia')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          onColorBlindnessChanged(val);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Spectrum Converter Tile
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => SpectrumDialogWidget(
                      onSelectColor: onSelectSpectrumColor,
                      isDarkMode: isDarkMode,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: GoldTheme.goldMid, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Convertidor de Espectro (nm)",
                          style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: GoldTheme.accentTitleColor(isDarkMode), size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "HexColor PRO v1.1.0 (Rust Accelerated)",
                style: TextStyle(color: txtColor.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Creado con ❤️ por JAYLIZ",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: GoldTheme.cardInputColor(isDarkMode),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GoldTheme.goldMid.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: GoldTheme.goldMid, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: GoldTheme.textColor(isDarkMode), fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: value,
            activeColor: GoldTheme.goldMid,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
