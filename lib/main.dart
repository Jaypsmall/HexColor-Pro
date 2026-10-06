import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color_manager.dart';
import 'screens/favorites_screen.dart';
import 'screens/palette_screen.dart';
import 'screens/picker_screen.dart';
import 'screens/settings_dialog.dart';
import 'screens/wheel_screen.dart';
import 'theme/gold_theme.dart';
import 'widgets/camera_sniper.dart';
import 'widgets/spectrum_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HexColorApp());
}

class HexColorApp extends StatefulWidget {
  const HexColorApp({super.key});

  @override
  State<HexColorApp> createState() => _HexColorAppState();
}

class _HexColorAppState extends State<HexColorApp> {
  bool _isDarkMode = true;
  bool _isGoldMode = true;
  String _colorBlindnessMode = 'None';

  Color _currentColor = const Color(0xFF21DD10);
  late HSVColor _hsv;

  int _selectedTabIndex = 1; // Default to Wheel tab as requested!
  bool _isSniperActive = false;
  bool _isSniperFullscreen = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(_currentColor);
  }

  void _updateColor(Color newColor) {
    setState(() {
      _currentColor = newColor;
      _hsv = HSVColor.fromColor(newColor);
    });
  }

  void _copyToClipboard(Color color) {
    final hex = ColorManager.colorToHex(color);
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copiado al portapapeles: $hex"),
        backgroundColor: GoldTheme.goldMid,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveFavorite(Color color) async {
    final hex = ColorManager.colorToHex(color);
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('fav_colors') ?? [];

    if (!favs.contains(hex)) {
      favs.add(hex);
      await prefs.setStringList('fav_colors', favs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Guardado en Favoritos: $hex"),
            backgroundColor: GoldTheme.goldMid,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$hex ya está en Favoritos"),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialogWidget(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: (val) => setState(() => _isDarkMode = val),
        isGoldMode: _isGoldMode,
        onToggleGoldMode: (val) => setState(() => _isGoldMode = val),
        colorBlindnessMode: _colorBlindnessMode,
        onColorBlindnessChanged: (val) => setState(() => _colorBlindnessMode = val),
        onSelectSpectrumColor: _updateColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexColor PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GoldTheme.darkBackground,
        primaryColor: GoldTheme.goldMid,
        colorScheme: const ColorScheme.dark(
          primary: GoldTheme.goldMid,
          surface: GoldTheme.darkCard,
        ),
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: GoldTheme.darkBackground,

            // Navigation Drawer
            drawer: _buildDrawer(context),

            // Main App Bar
            appBar: AppBar(
              backgroundColor: GoldTheme.darkBackground,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: GoldTheme.goldLight, size: 28),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Row(
                children: const [
                  Icon(Icons.hexagon_outlined, color: GoldTheme.goldMid, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "HEXCOLOR PRO",
                    style: TextStyle(
                      color: GoldTheme.goldLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: GoldTheme.goldLight,
                  ),
                  onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: GoldTheme.goldLight),
                  onPressed: _showSettingsDialog,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: GoldTheme.goldMid, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        label: "PALETA",
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: "RUEDA",
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: "EXTRACTOR",
                        isSelected: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                      const SizedBox(width: 6),
                      _TabButton(
                        label: "FAVORITOS",
                        isSelected: _selectedTabIndex == 3,
                        onTap: () => setState(() => _selectedTabIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body Content with Stack for Camera Sniper Overlay
            body: Stack(
              children: [
                IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    PaletteScreen(
                      currentColor: _currentColor,
                      hsv: _hsv,
                      onColorChanged: _updateColor,
                      onCopyColor: _copyToClipboard,
                      onSaveFavorite: _saveFavorite,
                      onToggleSniper: () => setState(() => _isSniperActive = true),
                      colorBlindnessMode: _colorBlindnessMode,
                      isGoldMode: _isGoldMode,
                    ),
                    WheelScreen(
                      currentColor: _currentColor,
                      hsv: _hsv,
                      onColorChanged: _updateColor,
                      onCopyColor: _copyToClipboard,
                      isGoldMode: _isGoldMode,
                      colorBlindnessMode: _colorBlindnessMode,
                      onColorBlindnessChanged: (val) => setState(() => _colorBlindnessMode = val),
                    ),
                    PickerScreen(
                      onColorSelected: (c) {
                        _updateColor(c);
                        setState(() => _selectedTabIndex = 1);
                      },
                      onSaveFavorite: _saveFavorite,
                      onCopyColor: _copyToClipboard,
                      colorBlindnessMode: _colorBlindnessMode,
                    ),
                    FavoritesScreen(
                      onSelectColor: (c) {
                        _updateColor(c);
                        setState(() => _selectedTabIndex = 1);
                      },
                      colorBlindnessMode: _colorBlindnessMode,
                    ),
                  ],
                ),

                // Camera Sniper Overlay
                if (_isSniperActive)
                  Positioned.fill(
                    child: CameraSniperWidget(
                      isFullscreen: _isSniperFullscreen,
                      onToggleFullscreen: () {
                        setState(() => _isSniperFullscreen = !_isSniperFullscreen);
                      },
                      onClose: () => setState(() => _isSniperActive = false),
                      onColorCaptured: (c) {},
                      onColorConfirmed: (c) {
                        _updateColor(c);
                        _saveFavorite(c);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: GoldTheme.darkBackground,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Icon(Icons.hexagon, color: GoldTheme.goldMid, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "HEXCOLOR PRO",
                    style: TextStyle(
                      color: GoldTheme.goldLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: GoldTheme.goldMid, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerItem(
                    icon: Icons.camera_alt,
                    title: "Modo Sniper (Cámara)",
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _isSniperActive = true);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.palette,
                    title: "Paleta de Colores",
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _selectedTabIndex = 0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.color_lens,
                    title: "Rueda HSL (Moon)",
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _selectedTabIndex = 1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.colorize,
                    title: "Extractor de Imagen",
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _selectedTabIndex = 2);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.star,
                    title: "Mis Favoritos",
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _selectedTabIndex = 3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.wb_sunny,
                    title: "Convertidor de Espectro",
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (ctx) => SpectrumDialogWidget(
                          onSelectColor: _updateColor,
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings,
                    title: "Ajustes",
                    onTap: () {
                      Navigator.of(context).pop();
                      _showSettingsDialog();
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "v1.0.6 PRO - Developed by JAYLIZ",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: isSelected
              ? GoldTheme.goldBoxDecoration(borderRadius: 10)
              : BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? GoldTheme.goldText : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: GoldTheme.goldMid, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
