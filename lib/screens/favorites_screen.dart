import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../favorites_manager.dart';
import '../theme/gold_theme.dart';
import '../widgets/export_dialog.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueChanged<Color> onSelectColor;
  final String colorBlindnessMode;
  final bool isDarkMode;

  const FavoritesScreen({
    super.key,
    required this.onSelectColor,
    this.colorBlindnessMode = 'None',
    this.isDarkMode = true,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesManager _favManager = FavoritesManager();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _favManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favManager.removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  List<String> get _filteredFavorites {
    final list = _favManager.favorites;
    if (_searchQuery.isEmpty) return list;
    return list.where((hex) => hex.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _showFavoritePaletteDialog(List<Color> favoriteColors) {
    if (favoriteColors.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: GoldTheme.cardColor(widget.isDarkMode),
          shape: GoldTheme.goldBorderShape(borderRadius: 20, isDarkMode: widget.isDarkMode),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PALETA DE FAVORITOS",
                        style: TextStyle(
                          color: GoldTheme.accentTitleColor(widget.isDarkMode),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Swatches Bar
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: GoldTheme.goldMid, width: 1.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: favoriteColors.map((color) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.onSelectColor(color);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                color: color,
                                child: Center(
                                  child: Text(
                                    ColorManager.colorToHex(color).replaceAll('#', ''),
                                    style: TextStyle(
                                      color: ColorManager.isDark(color) ? Colors.white : Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: GoldButton(
                          text: "EXPORTAR PALETA",
                          isDarkMode: widget.isDarkMode,
                          onClick: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) => ExportDialogWidget(
                                colors: favoriteColors,
                                isDarkMode: widget.isDarkMode,
                              ),
                            );
                          },
                          height: 44,
                          icon: Icons.share,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favList = _filteredFavorites;
    final txtColor = GoldTheme.textColor(widget.isDarkMode);
    final inputBg = GoldTheme.cardInputColor(widget.isDarkMode);

    if (_favManager.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border_purple500_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 12),
            Text(
              "No tienes colores favoritos guardados",
              style: TextStyle(color: txtColor.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      );
    }

    final allFavColors = _favManager.favorites
        .map((h) => ColorManager.hexToColor(h))
        .whereType<Color>()
        .toList();

    // Group into palettes of 5 colors max for horizontal palette cards
    List<List<Color>> paletteGroups = [];
    for (int i = 0; i < allFavColors.length; i += 5) {
      paletteGroups.add(allFavColors.sublist(i, i + 5 > allFavColors.length ? allFavColors.length : i + 5));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MIS FAVORITOS",
                style: TextStyle(
                  color: GoldTheme.accentTitleColor(widget.isDarkMode),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "${favList.length} guardados",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Field & Create Palette Button Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: txtColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Buscar por Hex...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: GoldTheme.goldMid, size: 20),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GoldTheme.goldMid, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GoldTheme.goldLight, width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showFavoritePaletteDialog(allFavColors),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: GoldTheme.goldBoxDecoration(
                    borderRadius: 12,
                    isDarkMode: widget.isDarkMode,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: const [
                      Icon(Icons.palette, color: GoldTheme.goldText, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "PALETA",
                        style: TextStyle(
                          color: GoldTheme.goldText,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section 1: Saved Palettes (Horizontal strips)
          if (paletteGroups.isNotEmpty && _searchQuery.isEmpty) ...[
            Text(
              "🎨 PALETAS AGRUPADAS",
              style: TextStyle(
                color: GoldTheme.subtextColor(widget.isDarkMode),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...paletteGroups.asMap().entries.map((entry) {
              final groupIndex = entry.key;
              final palette = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoldTheme.cardColor(widget.isDarkMode),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GoldTheme.goldMid.withOpacity(0.6), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Paleta #${groupIndex + 1} (${palette.length} colores)",
                          style: TextStyle(color: txtColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => _showFavoritePaletteDialog(palette),
                          child: const Text(
                            "Ver / Exportar",
                            style: TextStyle(color: GoldTheme.goldMid, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: palette.map((color) {
                            final hex = ColorManager.colorToHex(color);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onSelectColor(color),
                                child: Container(
                                  color: color,
                                  alignment: Alignment.center,
                                  child: Text(
                                    hex.replaceAll('#', ''),
                                    style: TextStyle(
                                      color: ColorManager.isDark(color) ? Colors.white : Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // Section 2: Individual Favorite Colors (Smaller cards grid)
          Text(
            "⭐ COLORES FAVORITOS INDIVIDUALES",
            style: TextStyle(
              color: GoldTheme.subtextColor(widget.isDarkMode),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final hex = favList[index];
              final color = ColorManager.hexToColor(hex) ?? Colors.grey;
              final displayColor = ColorManager.simulateColorBlindness(
                color,
                widget.colorBlindnessMode,
              );
              final isDark = ColorManager.isDark(displayColor);
              final textColor = isDark ? Colors.white : Colors.black;

              return GestureDetector(
                onTap: () => widget.onSelectColor(color),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GoldTheme.goldMid, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.star, color: GoldTheme.goldLight, size: 14),
                          GestureDetector(
                            onTap: () => _favManager.removeFavorite(hex),
                            child: Icon(Icons.delete_outline, color: textColor, size: 14),
                          ),
                        ],
                      ),
                      Text(
                        hex,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
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
      ),
    );
  }
}
