import 'package:flutter/material.dart';
import '../helpers/translate_helper.dart';
import 'package:ljubavnikalkulator/ui/ui_tokens.dart';


class FancyAppBarTitle extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;

  const FancyAppBarTitle({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [UiTokens.accentPink, UiTokens.accentPurple],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            t(context, titleKey),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          t(context, subtitleKey),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.8,
            color: UiTokens.textSecondary(context),
          ),
        ),
      ],
    );
  }
}
