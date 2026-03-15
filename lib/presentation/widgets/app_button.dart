import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final Widget? child;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.primaryGradientStart : Colors.white,
              ),
            ),
          )
        : child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            );

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 52,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height ?? 52,
      decoration: BoxDecoration(
        gradient: (onPressed != null && !isLoading)
            ? const LinearGradient(
                colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
              )
            : null,
        color: (onPressed == null || isLoading)
            ? AppColors.dividerBorder
            : backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: (onPressed != null && !isLoading)
            ? AppColors.primaryButtonShadow
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerBorder, width: 0.5),
        boxShadow: AppColors.softShadow,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color ?? AppColors.textPrimary, size: 20),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
