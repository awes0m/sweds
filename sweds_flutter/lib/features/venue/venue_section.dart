import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/luxury_button.dart';
import '../../core/widgets/pointer_parallax.dart';

class VenueSection extends StatelessWidget {
  const VenueSection({super.key});

  @override
  Widget build(BuildContext context) =>
      SceneSection(index: Sec.venue, builder: (c, p, size) => _VenueStage(p: p, size: size));
}

class _VenueStage extends StatelessWidget {
  const _VenueStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final w = size.width, h = size.height;
    final wide = w >= 900;
    final reveal = Motion.cinematic.transform(Motion.window(p, 0, 0.5));
    final settle = Motion.window(p, 0.3, 0.9);
    final imgW = wide ? w * 0.38 : w * 0.78;
    final imgH = wide ? h * 0.76 : h * 0.44;
    final imgLeft = wide ? w * 0.08 : (w - imgW) / 2;
    final imgTop = wide ? (h - imgH) / 2 : h * 0.07;
    final panelW = wide ? w * 0.36 : w * 0.88;

    return Stack(children: [
      // --- Layered arch: frame / photo / floating accents -------------------
      Positioned(
        left: imgLeft,
        top: imgTop,
        width: imgW,
        height: imgH,
        child: PointerParallax(
          builder: (c, o, _) => Transform(
            alignment: Alignment.center,
            transform: depthMatrix(
              ry: o.dx * 0.12 + (1 - reveal) * 0.45,
              rx: -o.dy * 0.08,
              dz: -(1 - reveal) * 240,
            ),
            child: Stack(clipBehavior: Clip.none, children: [
              // back layer: gold outline arch, separates as you scroll
              Transform.translate(
                offset: Offset(-26 * settle - o.dx * 18, -26 * settle - o.dy * 18),
                child: Opacity(
                  opacity: settle,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(imgW / 2)),
                      border: Border.all(color: Lux.gold.withValues(alpha: .7), width: 1.2),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              // main photo with clip-reveal + zoom
              Positioned.fill(
                child: ClipPath(
                  clipper: _ArchReveal(reveal),
                  child: Transform.scale(
                    scale: 1.35 - 0.35 * reveal,
                    child: Transform.translate(
                      offset: Offset(o.dx * -14, o.dy * -14),
                      child: const ArtImage(name: 'venue', seed: 3, cacheWidth: 1600),
                    ),
                  ),
                ),
              ),
              // front layer: floating glass seal
              Positioned(
                right: -18 + o.dx * 16,
                bottom: imgH * 0.12 + o.dy * 10,
                child: Opacity(
                  opacity: settle,
                  child: GlassPanel(
                    radius: 60,
                    blur: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    child: Text(WeddingConfig.venueCityShort, style: LuxText.serif(22, color: Lux.crimson, weight: FontWeight.w600)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
      // --- Info panel ---------------------------------------------------------
      Positioned(
        left: wide ? null : (w - panelW) / 2,
        right: wide ? w * 0.07 : null,
        top: wide ? h * 0.17 : h * 0.47,
        width: panelW,
        child: ProgressReveal(
          progress: p,
          start: 0.28,
          end: 0.6,
          dy: 80,
          blur: 12,
          child: GlassPanel(
            radius: 32,
            padding: EdgeInsets.all(wide ? 36 : 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('THE VENUE', style: LuxText.eyebrow()),
              const SizedBox(height: 10),
              Text(WeddingConfig.venueName, style: LuxText.display(context.fluid(30, 52))),
              const SizedBox(height: 8),
              Text(WeddingConfig.venueAddress, style: LuxText.body(context.fluid(13.5, 15.5))),
              const SizedBox(height: 18),
              Container(height: 1, color: Lux.champagne),
              const SizedBox(height: 14),
              for (final (time, what) in kVenueSchedule.take(wide ? 4 : 3))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 78, child: Text(time, style: LuxText.serif(18, style: FontStyle.normal, weight: FontWeight.w700, color: Lux.goldDeep))),
                    Expanded(child: Text(what, style: LuxText.body(14))),
                  ]),
                ),
              const SizedBox(height: 18),
              LuxuryButton(
                label: 'Open in Google Maps',
                onPressed: () => launchUrl(Uri.parse(WeddingConfig.mapsUrl), mode: LaunchMode.externalApplication),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _ArchReveal extends CustomClipper<Path> {
  _ArchReveal(this.t);
  final double t;

  @override
  Path getClip(Size s) {
    final inset = 1 - t;
    final r = Rect.fromLTRB(s.width * 0.3 * inset, s.height * 0.22 * inset, s.width * (1 - 0.3 * inset), s.height);
    final rad = Radius.circular(r.width / 2);
    return Path()..addRRect(RRect.fromRectAndCorners(r, topLeft: rad, topRight: rad));
  }

  @override
  bool shouldReclip(_ArchReveal old) => old.t != t;
}
