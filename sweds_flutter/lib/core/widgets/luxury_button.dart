import 'package:flutter/material.dart';

import '../animations/motion.dart';
import '../theme/lux.dart';
import 'cursor.dart';

class LuxuryButton extends StatefulWidget {
  const LuxuryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.loading = false,
    this.compact = false,
    this.padding,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool filled, loading, compact;
  final EdgeInsetsGeometry? padding;

  @override
  State<LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.filled;
    final compact = widget.compact;
    return CursorHover(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.loading ? null : widget.onPressed,
          child: AnimatedScale(
            scale: _hover ? 1.04 : 1,
            duration: const Duration(milliseconds: 400),
            curve: Motion.cinematic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: widget.padding ??
                  (compact
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 34, vertical: 17)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: filled
                    ? const LinearGradient(colors: [Color(0xFFF1D98C), Lux.gold, Color(0xFFC49A2C)])
                    : null,
                color: filled ? null : (_hover ? Lux.gold.withValues(alpha: 0.12) : Colors.transparent),
                border: filled ? null : Border.all(color: Lux.gold, width: 1.2),
                boxShadow: filled
                    ? [BoxShadow(color: Lux.gold.withValues(alpha: _hover ? 0.55 : 0.3), blurRadius: compact ? 18 : 32, offset: const Offset(0, 8))]
                    : null,
              ),
              child: widget.loading
                  ? SizedBox(
                      width: compact ? 14 : 18,
                      height: compact ? 14 : 18,
                      child: const CircularProgressIndicator(strokeWidth: 1.8, color: Lux.dark),
                    )
                  : Text(
                      widget.label.toUpperCase(),
                      style: LuxText.body(
                        compact ? 11 : 12.5,
                        weight: FontWeight.w600,
                        spacing: compact ? 1.5 : 3,
                        opacity: 1,
                        color: filled ? Lux.dark : Lux.goldDeep,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
