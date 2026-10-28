import 'package:flutter/material.dart';

import '../theme/lux.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.align = CrossAxisAlignment.center,
    this.size,
  });
  final String eyebrow, title;
  final String? subtitle;
  final CrossAxisAlignment align;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final center = align == CrossAxisAlignment.center;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(eyebrow.toUpperCase(), style: LuxText.eyebrow()),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: LuxText.display(size ?? context.fluid(38, 76)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Text(
            subtitle!,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: LuxText.serif(context.fluid(18, 24)),
          ),
        ],
        const SizedBox(height: 20),
        Container(width: 56, height: 1, color: Lux.gold),
      ],
    );
  }
}
