import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class UiTokens {
  // Brand
  static const accentPink = Color(0xFFFF5FA2);
  static const accentPurple = Color(0xFFB388FF);

  // Layout
  static const pagePadding = EdgeInsets.all(16);
  static const cardRadius = 18.0;
  static const buttonRadius = 20.0;

  // Text colors (dark-safe)
  static Color textPrimary(BuildContext c) =>
      NeumorphicTheme.isUsingDark(c) ? Colors.white : Colors.black87;

  static Color textSecondary(BuildContext c) =>
      NeumorphicTheme.isUsingDark(c) ? Colors.white70 : Colors.black54;

  static Color iconMuted(BuildContext c) =>
      NeumorphicTheme.isUsingDark(c) ? Colors.white54 : Colors.black45;

  static Color surface(BuildContext c) => NeumorphicTheme.baseColor(c);

  // Simple background gradient (subtle)
  static BoxDecoration background(BuildContext c) {
    final isDark = NeumorphicTheme.isUsingDark(c);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF141414),
                const Color(0xFF1A1522),
              ]
            : [
                const Color(0xFFFFF7FB),
                const Color(0xFFF6F0FF),
              ],
      ),
    );
  }
}
