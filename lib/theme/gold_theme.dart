import 'package:flutter/material.dart';

class GoldTheme {
  static const Color darkBackground = Color(0xFF101010);
  static const Color darkCard = Color(0xFF1C1C1E);
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

  static BoxDecoration goldBoxDecoration({double borderRadius = 8.0}) {
    return BoxDecoration(
      gradient: goldGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: goldBorderColor, width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  static ShapeBorder goldBorderShape({double borderRadius = 12.0}) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: const BorderSide(color: goldMid, width: 1.2),
    );
  }
}

class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final double width;
  final double height;
  final IconData? icon;

  const GoldButton({
    super.key,
    required this.text,
    required this.onClick,
    this.width = 220,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: width,
        height: height,
        decoration: GoldTheme.goldBoxDecoration(borderRadius: 12),
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
