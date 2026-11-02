import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_manager.dart';
import 'favorites_manager.dart';
import 'rust_engine.dart';
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
  RustEngine.init();
  runApp(const HexColorApp());
}

class HexColorApp extends StatelessWidget {
  const HexColorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HexColor PRO',
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDarkMode = true;
  bool _isGoldMode = true;
  String _colorBlindnessMode = 'None';
  bool _isPageScrollable = true;
  int _analogousCount = 7;

  Color _currentColor = const Color(0xFF21DD10);
  late HSVColor _hsv;

  int _selectedTabIndex = 1; // Default to Wheel tab (Rueda)
  late PageController _pageController;

  bool _isSniperActive = false;
  bool _isSniperFullscreen = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FavoritesManager _favManager = FavoritesManager();

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(_currentColor);
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Future<void> _toggleFavorite(Color color) async {
    final hex = ColorManager.colorToHex(color);
    final added = await _favManager.toggleFavorite(color);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? "Añadido a Favoritos: $hex" : "Eliminado de Favoritos: $hex"),
          backgroundColor: added ? GoldTheme.goldMid : Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
        analogousCount: _analogousCount,
        onAnalogousCountChanged: (val) => setState(() => _analogousCount = val),
      ),
    );
  }

  Future<void> _importPaletteFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final content = await file.readAsString();

        final regex = RegExp(r'#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})');
        final matches = regex.allMatches(content);

        List<String> importedHexes = [];
        for (final match in matches) {
          final hex = match.group(0);
          if (hex != null) {
            importedHexes.add(hex);
          }
        }

        if (importedHexes.isNotEmpty) {
          for (final hex in importedHexes) {
            await _favManager.addFavorite(hex);
          }
          final firstColor = ColorManager.hexToColor(importedHexes.first) ?? Colors.grey;
          _updateColor(firstColor);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("¡Importados ${importedHexes.length} colores a favoritos!"),
                backgroundColor: GoldTheme.goldMid,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No se encontraron códigos de color válidos en el archivo."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al importar archivo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = GoldTheme.backgroundColor(_isDarkMode);
    final titleColor = GoldTheme.accentTitleColor(_isDarkMode);

    return MaterialApp(
      title: 'HexColor PRO',
      debugShowCheckedModeBanner: false,
      theme: GoldTheme.getThemeData(isDarkMode: _isDarkMode),
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bg,

        // Drawer Menu
        drawer: _buildDrawer(context),

        // App Bar
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: titleColor, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/icono_hex_radial.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.hexagon_outlined, color: GoldTheme.goldMid, size: 30),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "HEXCOLOR PRO",
                style: TextStyle(
                  color: titleColor,
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
                color: titleColor,
              ),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: titleColor),
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
                    isDarkMode: _isDarkMode,
                    onTap: () => _navigateToTab(0),
                  ),
                  const SizedBox(width: 6),
                  _TabButton(
                    label: "RUEDA",
                    isSelected: _selectedTabIndex == 1,
                    isDarkMode: _isDarkMode,
                    onTap: () => _navigateToTab(1),
                  ),
                  const SizedBox(width: 6),
                  _TabButton(
                    label: "EXTRACTOR",
                    isSelected: _selectedTabIndex == 2,
                    isDarkMode: _isDarkMode,
                    onTap: () => _navigateToTab(2),
                  ),
                  const SizedBox(width: 6),
                  _TabButton(
                    label: "FAVORITOS",
                    isSelected: _selectedTabIndex == 3,
                    isDarkMode: _isDarkMode,
                    onTap: () => _navigateToTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Body Content with PageView for Swipe Gesture Navigation
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: _isPageScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              children: [
                PaletteScreen(
                  currentColor: _currentColor,
                  hsv: _hsv,
                  onColorChanged: _updateColor,
                  onCopyColor: _copyToClipboard,
                  onToggleFavorite: _toggleFavorite,
                  onToggleSniper: () => setState(() => _isSniperActive = true),
                  colorBlindnessMode: _colorBlindnessMode,
                  isGoldMode: _isGoldMode,
                  isDarkMode: _isDarkMode,
                ),
                WheelScreen(
                  currentColor: _currentColor,
                  hsv: _hsv,
                  onColorChanged: _updateColor,
                  onCopyColor: _copyToClipboard,
                  onToggleFavorite: _toggleFavorite,
                  isGoldMode: _isGoldMode,
                  isDarkMode: _isDarkMode,
                  colorBlindnessMode: _colorBlindnessMode,
                  onColorBlindnessChanged: (val) => setState(() => _colorBlindnessMode = val),
                  analogousCount: _analogousCount,
                  onWheelInteracting: (isInteracting) {
                    setState(() => _isPageScrollable = !isInteracting);
                  },
                ),
                PickerScreen(
                  onColorSelected: (c) {
                    _updateColor(c);
                    _navigateToTab(1);
                  },
                  onToggleFavorite: _toggleFavorite,
                  onCopyColor: _copyToClipboard,
                  colorBlindnessMode: _colorBlindnessMode,
                  isDarkMode: _isDarkMode,
                ),
                FavoritesScreen(
                  onSelectColor: (c) {
                    _updateColor(c);
                    _navigateToTab(1);
                  },
                  colorBlindnessMode: _colorBlindnessMode,
                  isDarkMode: _isDarkMode,
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
                    _toggleFavorite(c);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final bg = GoldTheme.backgroundColor(_isDarkMode);
    final titleColor = GoldTheme.accentTitleColor(_isDarkMode);
    final txtColor = GoldTheme.textColor(_isDarkMode);

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icono_hex_radial.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.hexagon, color: GoldTheme.goldMid, size: 60),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "HEXCOLOR PRO",
                    style: TextStyle(
                      color: titleColor,
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
                    textColor: txtColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _isSniperActive = true);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.palette,
                    title: "Paleta de Colores",
                    textColor: txtColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToTab(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.color_lens,
                    title: "Rueda HSL (Moon)",
                    textColor: txtColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToTab(1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.colorize,
                    title: "Extractor de Imagen",
                    textColor: txtColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToTab(2);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.star,
                    title: "Mis Favoritos",
                    textColor: txtColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToTab(3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.folder_open,
                    title: "Importar Archivo / Paleta",
                    textColor: txtColor,
                    onTap: () {
                      Navigator.of(context).pop();
                      _importPaletteFromFile();
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.wb_sunny,
                    title: "Convertidor de Espectro",
                    textColor: txtColor,
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
                    textColor: txtColor,
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
                "v1.1.0 PRO Rust Engine - Developed by JAYLIZ",
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
  final bool isDarkMode;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
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
              ? GoldTheme.goldBoxDecoration(
                  borderRadius: 10,
                  isDarkMode: isDarkMode,
                )
              : BoxDecoration(
                  color: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDarkMode ? Colors.white10 : Colors.black12,
                  ),
                ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? GoldTheme.goldText : (isDarkMode ? Colors.grey : Colors.black54),
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
  final Color textColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: GoldTheme.goldMid, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
