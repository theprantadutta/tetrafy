import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic card with frosted glass effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool showGlow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 15.0,
    this.showGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.3);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.2),
                  theme.colorScheme.surface.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
