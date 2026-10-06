import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../color_manager.dart';
import '../theme/gold_theme.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueChanged<Color> onSelectColor;
  final String colorBlindnessMode;

  const FavoritesScreen({
    super.key,
    required this.onSelectColor,
    this.colorBlindnessMode = 'None',
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> _favoriteHexes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('fav_colors') ?? [];
    setState(() {
      _favoriteHexes = favs;
    });
  }

  Future<void> _removeFavorite(String hex) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteHexes.remove(hex);
    });
    await prefs.setStringList('fav_colors', _favoriteHexes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eliminado: $hex"),
          backgroundColor: GoldTheme.goldMid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_favoriteHexes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.star_border_purple500_outlined, color: Colors.grey, size: 64),
            SizedBox(height: 12),
            Text(
              "No tienes colores favoritos guardados",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MIS FAVORITOS",
                style: TextStyle(
                  color: GoldTheme.goldLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "${_favoriteHexes.length} guardados",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: _favoriteHexes.length,
            itemBuilder: (context, index) {
              final hex = _favoriteHexes[index];
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
                          const Icon(Icons.star, color: GoldTheme.goldLight, size: 20),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: textColor, size: 18),
                            onPressed: () => _removeFavorite(hex),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      Text(
                        hex,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
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
