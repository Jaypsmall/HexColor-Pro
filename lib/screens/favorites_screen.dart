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
    final cardBg = GoldTheme.cardColor(widget.isDarkMode);
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

          const SizedBox(height: 14),

          // Grid View of Favorites
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
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
                          const Icon(Icons.star, color: GoldTheme.goldLight, size: 20),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: textColor, size: 18),
                            onPressed: () => _favManager.removeFavorite(hex),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hex,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            ColorManager.colorToRgbString(color),
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
