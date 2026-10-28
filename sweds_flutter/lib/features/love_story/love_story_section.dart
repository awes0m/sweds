import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/motion.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/glass_panel.dart';
import '../../shared/providers/scene_providers.dart';

class LoveStorySection extends StatelessWidget {
  const LoveStorySection({super.key});

  @override
  Widget build(BuildContext context) =>
      SceneSection(index: Sec.story, builder: (c, p, size) => _StoryStage(p: p, size: size));
}

/// Cards live on a "camera rail": scroll moves a fractional focus index `f`;
/// each card derives depth, tilt, blur and speed from its distance to `f`.
class _StoryStage extends ConsumerWidget {
  const _StoryStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depth = ref.watch(deviceClassProvider).depth;
    final n = kStory.length;
    final f = p * (n - 1);
    final wide = size.width >= 900;
    final pad = wide ? 64.0 : 22.0;
    final active = f.round().clamp(0, n - 1);
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) => (f - b).abs().compareTo((f - a).abs())); // far → near

    return Stack(children: [
      for (final i in order) _Numeral(index: i, d: f - i, size: size, depth: depth),
      for (final i in order) _card(context, i, f - i, wide, depth),
      Positioned(
        left: pad,
        top: size.height * (wide ? .10 : .085),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CHAPTER ${active + 1} OF $n', style: LuxText.eyebrow()),
          const SizedBox(height: 10),
          Text('Our Story', style: LuxText.display(context.fluid(34, 64))),
          const SizedBox(height: 14),
          Row(children: [
            for (var i = 0; i < n; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Motion.cinematic,
                margin: const EdgeInsets.only(right: 6),
                width: i == active ? 38 : 12,
                height: 2,
                color: i == active ? Lux.gold : Lux.champagne,
              ),
          ]),
        ]),
      ),
    ]);
  }

  Widget _card(BuildContext context, int i, double d, bool wide, double depth) {
    final ad = d.abs().clamp(0.0, 1.6);
    final side = i.isEven ? -1.0 : 1.0;
    final speed = 0.94 + 0.06 * (i % 3);
    final dy = -d * size.height * (d < 0 ? 0.62 : 0.55) * speed;
    final opacity = (1 - ad * 0.85).clamp(0.0, 1.0);
    final sigma = ((ad - 0.25).clamp(0.0, 1.0)) * 7;

    Widget w = Transform(
      alignment: Alignment.center,
      transform: depthMatrix(
        rx: -d * 0.28 * depth,
        ry: side * (0.10 + ad * 0.22) * depth,
        rz: side * 0.012 * d,
        dx: wide ? side * size.width * 0.07 : 0,
        dy: dy,
        dz: -ad * 160 * depth,
      ),
      child: Opacity(opacity: opacity, child: RepaintBoundary(child: _StoryCard(chapter: kStory[i], size: size, wide: wide))),
    );
    if (sigma > 0.3) {
      w = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
        child: w,
      );
    }
    return Positioned.fill(child: Center(child: w));
  }
}

class _Numeral extends StatelessWidget {
  const _Numeral({required this.index, required this.d, required this.size, required this.depth});
  final int index;
  final double d, depth;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final side = index.isEven ? -1.0 : 1.0;
    final a = (1 - d.abs()).clamp(0.0, 1.0);
    return Positioned.fill(
      child: Opacity(
        opacity: a * 0.9,
        child: Transform.translate(
          offset: Offset(side * size.width * 0.16, -d * size.height * 0.35 * depth),
          child: Align(
            alignment: Alignment(side * 0.2, 0),
            child: Text('0${index + 1}', style: LuxText.outline(context.fluid(200, 420))),
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.chapter, required this.size, required this.wide});
  final StoryChapter chapter;
  final Size size;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cardW = wide ? math.min(size.width * 0.74, 1020.0) : size.width * 0.9;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(chapter.date.toUpperCase(), style: LuxText.eyebrow()),
        const SizedBox(height: 12),
        Text(chapter.title, style: LuxText.display(context.fluid(26, 46))),
        const SizedBox(height: 14),
        Container(width: 48, height: 1, color: Lux.gold),
        const SizedBox(height: 14),
        Text(chapter.body, style: LuxText.body(context.fluid(14, 16.5), height: 1.75)),
      ],
    );

    if (wide) {
      final imgH = math.min(size.height * 0.46, cardW * 0.34 * 1.25);
      return SizedBox(
        width: cardW,
        child: GlassPanel(
          padding: const EdgeInsets.all(20),
          radius: 32,
          child: Row(children: [
            SizedBox(
              width: imgH * 0.8,
              height: imgH,
              child: ArtImage(name: chapter.image, seed: chapter.seed, radius: 22),
            ),
            const SizedBox(width: 40),
            Expanded(child: text),
            const SizedBox(width: 20),
          ]),
        ),
      );
    }
    return SizedBox(
      width: cardW,
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        radius: 28,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: size.height * 0.2,
            width: double.infinity,
            child: ArtImage(name: chapter.image, seed: chapter.seed, radius: 18),
          ),
          const SizedBox(height: 18),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: text),
          const SizedBox(height: 6),
        ]),
      ),
    );
  }
}
