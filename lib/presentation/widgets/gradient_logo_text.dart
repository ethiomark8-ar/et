import 'package:flutter/material.dart';

class GradientLogoText extends StatelessWidget {
  final double fontSize;

  const GradientLogoText({super.key, this.fontSize = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00CFFF), Color(0xFF4C6FFF)],
          ).createShader(bounds),
          child: Text(
            'Ethio',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFFF6B6B), Color(0xFFFF2D87)],
          ).createShader(bounds),
          child: Text(
            'Shop',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
