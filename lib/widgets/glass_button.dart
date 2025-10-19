import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic button with frosted glass effect and neon glow
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? glowColor;
  final bool isPrimary;
  final bool isOutlined;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.glowColor,
    this.isPrimary = true,
    this.isOutlined = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    final glowColor = widget.glowColor ?? buttonColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  // Outer glow
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 0,
                  ),
                  // Inner shadow for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.isOutlined
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                buttonColor.withValues(alpha: 0.3),
                                buttonColor.withValues(alpha: 0.1),
                              ],
                            ),
                      border: Border.all(
                        color: buttonColor.withValues(
                          alpha: widget.isOutlined ? 0.8 : 0.3,
                        ),
                        width: widget.isOutlined ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: widget.icon != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.icon,
                                  color: theme.colorScheme.onSurface,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.text,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.text,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
