import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/scroll_engine.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/cursor.dart';
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
    final imgW = wide ? w * 0.38 : math.min(w * 0.65, 230.0);
    final imgH = wide ? h * 0.76 : math.min(h * 0.16, 115.0);
    final imgLeft = wide ? w * 0.08 : (w - imgW) / 2;
    final imgTop = wide ? (h - imgH) / 2 : 12.0;
    final panelW = wide ? w * 0.38 : math.min(w * 0.92, 440.0);
    final cardTop = wide ? h * 0.14 : (imgTop + imgH + 10.0);

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
                right: wide ? (-18 + o.dx * 16) : (-8 + o.dx * 8),
                bottom: wide ? (imgH * 0.12 + o.dy * 10) : (4 + o.dy * 4),
                child: Opacity(
                  opacity: settle,
                  child: GlassPanel(
                    radius: 60,
                    blur: 14,
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 22 : 14,
                      vertical: wide ? 14 : 6,
                    ),
                    child: Text(
                      WeddingConfig.venueCityShort,
                      style: LuxText.serif(
                        wide ? 22 : 14,
                        color: Lux.crimson,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
      // --- Flipping Info panel: Wedding vs Reception -------------------------
      Positioned(
        left: wide ? null : (w - panelW) / 2,
        right: wide ? w * 0.06 : null,
        top: cardTop,
        width: panelW,
        child: ProgressReveal(
          progress: p,
          start: 0.28,
          end: 0.6,
          dy: 80,
          blur: 12,
          child: _FlippingVenueCard(
            wide: wide,
            maxHeight: h - cardTop - 16,
          ),
        ),
      ),
    ]);
  }
}

class _FlippingVenueCard extends StatefulWidget {
  const _FlippingVenueCard({required this.wide, this.maxHeight});
  final bool wide;
  final double? maxHeight;

  @override
  State<_FlippingVenueCard> createState() => _FlippingVenueCardState();
}

class _FlippingVenueCardState extends State<_FlippingVenueCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showReception = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipTo(bool reception) {
    if (_showReception == reception) return;
    setState(() => _showReception = reception);
    if (_showReception) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggleFlip() {
    _flipTo(!_showReception);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final angle = _animation.value * math.pi;
        final isBack = angle > math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _buildVenueFace(isReception: true),
                )
              : _buildVenueFace(isReception: false),
        );
      },
    );
  }

  Widget _buildVenueFace({required bool isReception}) {
    final schedule = isReception ? kReceptionSchedule : kWeddingSchedule;
    final maxScheduleCount = widget.wide ? 4 : 2;
    final compact = !widget.wide;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Bar: Segmented Switcher & Flip Button
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Lux.dark.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Lux.champagne),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VenueTab(
                    label: 'Wedding',
                    icon: Icons.favorite_border_rounded,
                    active: !isReception,
                    compact: compact,
                    onTap: () => _flipTo(false),
                  ),
                  _VenueTab(
                    label: 'Reception',
                    icon: Icons.celebration_outlined,
                    active: isReception,
                    compact: compact,
                    onTap: () => _flipTo(true),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CursorHover(
              child: GestureDetector(
                onTap: _toggleFlip,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 10,
                    vertical: compact ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Lux.gold.withValues(alpha: .15),
                    border: Border.all(color: Lux.gold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flip_rounded, size: compact ? 13 : 15, color: Lux.goldDeep),
                      const SizedBox(width: 4),
                      Text(
                        'Flip',
                        style: LuxText.serif(
                          compact ? 11 : 12,
                          weight: FontWeight.w700,
                          color: Lux.goldDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 8 : 14),

        // Eyebrow Tag
        Text(
          isReception
              ? 'THE RECEPTION VENUE · BOU BHAAT'
              : 'THE WEDDING VENUE · SHUBHO BIBAHO',
          style: LuxText.eyebrow(),
        ),
        SizedBox(height: compact ? 3 : 6),

        // Venue Name
        Text(
          isReception
              ? WeddingConfig.receptionVenueName
              : WeddingConfig.weddingVenueName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LuxText.display(context.fluid(compact ? 19 : 24, 42)),
        ),
        SizedBox(height: compact ? 2 : 4),

        // Date & Time
        Row(
          children: [
            Icon(Icons.event_outlined, size: compact ? 14 : 16, color: Lux.goldDeep),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isReception
                    ? '${WeddingConfig.receptionDateLabel} · ${WeddingConfig.receptionTimeLabel}'
                    : '${WeddingConfig.weddingDateLabel} · ${WeddingConfig.weddingTimeLabel}',
                style: LuxText.serif(
                  context.fluid(compact ? 12 : 13, 15),
                  weight: FontWeight.w600,
                  color: Lux.goldDeep,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 2 : 4),

        // Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.location_on_outlined, size: compact ? 14 : 16, color: Lux.crimson),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isReception
                    ? WeddingConfig.receptionVenueAddress
                    : WeddingConfig.weddingVenueAddress,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: LuxText.body(context.fluid(compact ? 11.5 : 12.5, 14.5)),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 8 : 14),

        Container(height: 1, color: Lux.champagne),
        SizedBox(height: compact ? 6 : 10),

        // Schedule list
        for (final (time, what) in schedule.take(maxScheduleCount))
          Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: compact ? 66 : 78,
                  child: Text(
                    time,
                    style: LuxText.serif(
                      compact ? 13 : 16,
                      style: FontStyle.normal,
                      weight: FontWeight.w700,
                      color: Lux.goldDeep,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    what,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LuxText.body(context.fluid(compact ? 11.5 : 12.5, 13.5)),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: compact ? 10 : 14),

        // Bottom Action Row
        Wrap(
          spacing: compact ? 8 : 12,
          runSpacing: compact ? 6 : 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LuxuryButton(
              label: widget.wide ? 'Open in Google Maps' : 'Maps 📍',
              compact: compact,
              onPressed: () => launchUrl(
                Uri.parse(
                  isReception
                      ? WeddingConfig.receptionMapsUrl
                      : WeddingConfig.weddingMapsUrl,
                ),
                mode: LaunchMode.externalApplication,
              ),
            ),
            LuxuryButton(
              label: widget.wide ? 'RSVP & Get Invite 💌' : 'RSVP 💌',
              compact: compact,
              filled: false,
              onPressed: () => context.goToSection(Sec.rsvp),
            ),
            LuxuryButton(
              label: widget.wide
                  ? (isReception ? 'View Wedding ↺' : 'View Reception ↻')
                  : (isReception ? 'Wedding ↺' : 'Reception ↻'),
              compact: compact,
              filled: false,
              onPressed: _toggleFlip,
            ),
          ],
        ),
      ],
    );

    return GlassPanel(
      radius: 32,
      padding: EdgeInsets.symmetric(
        horizontal: widget.wide ? 32 : 16,
        vertical: widget.wide ? 26 : 14,
      ),
      child: widget.maxHeight != null
          ? ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight!),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: content,
              ),
            )
          : content,
    );
  }
}

class _VenueTab extends StatelessWidget {
  const _VenueTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final bool active, compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CursorHover(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: active ? Lux.gold : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: compact ? 12 : 14,
                color: active ? Lux.dark : Lux.dark.withValues(alpha: .6),
              ),
              SizedBox(width: compact ? 4 : 5),
              Text(
                label,
                style: LuxText.serif(
                  compact ? 11.5 : 13,
                  weight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Lux.dark : Lux.dark.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchReveal extends CustomClipper<Path> {
  _ArchReveal(this.t);
  final double t;

  @override
  Path getClip(Size s) {
    final inset = 1 - t;
    final r = Rect.fromLTRB(
      s.width * 0.3 * inset,
      s.height * 0.22 * inset,
      s.width * (1 - 0.3 * inset),
      s.height,
    );
    final rad = Radius.circular(r.width / 2);
    return Path()..addRRect(RRect.fromRectAndCorners(r, topLeft: rad, topRight: rad));
  }

  @override
  bool shouldReclip(_ArchReveal old) => old.t != t;
}
