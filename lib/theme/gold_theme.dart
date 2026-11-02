import 'package:flutter/material.dart';

class GoldTheme {
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF101010);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardInput = Color(0xFF121214);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF4F5F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardInput = Color(0xFFEFEFEF);

  // Gold Accents
  static const Color goldDark = Color(0xFF8C6221);
  static const Color goldLight = Color(0xFFFFF3A8);
  static const Color goldMid = Color(0xFFC29B47);
  static const Color goldText = Color(0xFF543B14);
  static const Color goldBorderColor = Color(0xFFF3E5AB);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, goldLight, goldMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color backgroundColor(bool isDarkMode) =>
      isDarkMode ? darkBackground : lightBackground;

  static Color cardColor(bool isDarkMode) =>
      isDarkMode ? darkCard : lightCard;

  static Color cardInputColor(bool isDarkMode) =>
      isDarkMode ? darkCardInput : lightCardInput;

  static Color textColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : const Color(0xFF1A1A1A);

  static Color subtextColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);

  static Color accentTitleColor(bool isDarkMode) =>
      isDarkMode ? goldLight : const Color(0xFF8B6508);

  static BoxDecoration goldBoxDecoration({
    double borderRadius = 8.0,
    bool isDarkMode = true,
  }) {
    return BoxDecoration(
      gradient: goldGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: goldBorderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: isDarkMode ? Colors.black45 : Colors.black12,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static ShapeBorder goldBorderShape({
    double borderRadius = 12.0,
    bool isDarkMode = true,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: const BorderSide(color: goldMid, width: 1.2),
    );
  }

  static ThemeData getThemeData({required bool isDarkMode}) {
    final bg = backgroundColor(isDarkMode);
    final card = cardColor(isDarkMode);
    final txt = textColor(isDarkMode);

    return (isDarkMode ? ThemeData.dark() : ThemeData.light()).copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: goldMid,
      dialogBackgroundColor: card,
      cardColor: card,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: accentTitleColor(isDarkMode)),
        titleTextStyle: TextStyle(
          color: accentTitleColor(isDarkMode),
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1.5,
        ),
      ),
      colorScheme: (isDarkMode ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: goldMid,
        surface: card,
        onSurface: txt,
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final double width;
  final double height;
  final IconData? icon;
  final bool isDarkMode;

  const GoldButton({
    super.key,
    required this.text,
    required this.onClick,
    this.width = 220,
    this.height = 48,
    this.icon,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: width,
        height: height,
        decoration: GoldTheme.goldBoxDecoration(
          borderRadius: 12,
          isDarkMode: isDarkMode,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: GoldTheme.goldText, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: GoldTheme.goldText,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
