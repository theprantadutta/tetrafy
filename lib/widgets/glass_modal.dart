import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic modal/dialog overlay
class GlassModal extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? borderColor;
  final bool barrierDismissible;

  const GlassModal({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderColor,
    this.barrierDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    Color? borderColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => GlassModal(
        width: width,
        height: height,
        borderColor: borderColor,
        barrierDismissible: barrierDismissible,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.3),
                    theme.colorScheme.surface.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: borderColor ??
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
