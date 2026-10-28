import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/motion.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scroll_engine.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/cursor.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/luxury_button.dart';
import '../../core/widgets/ticking.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/scene_providers.dart';

const _links = [Sec.story, Sec.proposal, Sec.timeline, Sec.venue, Sec.gallery, Sec.rsvp];

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSectionProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wide ? 40 : 18, vertical: 18),
        child: Row(children: [
          CursorHover(
            child: GestureDetector(
              onTap: () => context.goToSection(Sec.hero),
              child: Text('${WeddingConfig.bride[0]} & ${WeddingConfig.groom[0]}',
                  style: LuxText.display(26, color: Lux.crimson, style: FontStyle.italic, spacing: 1)),
            ),
          ),
          const Spacer(),
          if (wide)
            GlassPanel(
              radius: 40,
              blur: 18,
              opacity: 0.35,
              shadow: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(children: [
                for (final i in _links) _NavLink(index: i, active: active == i),
              ]),
            ),
          const Spacer(),
          const MusicToggle(),
        ]),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.index, required this.active});
  final int index;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => CursorHover(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: () => context.goToSection(widget.index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(kSections[widget.index].label,
                    style: LuxText.serif(17, style: FontStyle.normal, weight: FontWeight.w600, color: widget.active || _hover ? Lux.crimson : Lux.dark)),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Motion.cinematic,
                  height: 1.5,
                  width: widget.active ? 22 : 0,
                  color: Lux.crimson,
                ),
              ]),
            ),
          ),
        ),
      );
}

class MusicToggle extends ConsumerWidget {
  const MusicToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(ambientMusicProvider);
    return CursorHover(
      child: GestureDetector(
        onTap: () => ref.read(ambientMusicProvider.notifier).toggle(),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Lux.ivory.withValues(alpha: .55),
            border: Border.all(color: Lux.gold.withValues(alpha: .8)),
          ),
          child: Ticking(
            builder: (c, time) => ValueListenableBuilder<double>(
              valueListenable: time,
              builder: (c, t, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 2.4,
                      height: on ? 5 + 13 * (0.5 + 0.5 * math.sin(t * 4 + i * 1.3)) : 4,
                      decoration: BoxDecoration(color: Lux.goldDeep, borderRadius: BorderRadius.circular(2)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right-edge chapter dots (desktop only).
class SideDots extends ConsumerWidget {
  const SideDots({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (MediaQuery.sizeOf(context).width < 900) return const SizedBox.shrink();
    final active = ref.watch(activeSectionProvider);
    return Positioned(
      right: 22,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < kSections.length; i++) _Dot(index: i, active: i == active),
        ]),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.index, required this.active});
  final int index;
  final bool active;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => CursorHover(
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.goToSection(widget.index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _hover ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(kSections[widget.index].label, style: LuxText.serif(16, style: FontStyle.normal, color: Lux.goldDeep, weight: FontWeight.w600)),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Motion.cinematic,
                  width: 6,
                  height: widget.active ? 26 : 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: widget.active ? Lux.gold : Lux.champagne,
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}

class ScrollProgressLine extends ConsumerWidget {
  const ScrollProgressLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(scrollProgressProvider);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 2.5,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: p,
          child: const DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Lux.goldDeep, Lux.goldLight, Lux.gold])),
            child: SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// Floating RSVP call-to-action; hidden on the hero and once RSVP is reached.
class FloatingCta extends ConsumerWidget {
  const FloatingCta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSectionProvider);
    final show = active > Sec.hero && active < Sec.rsvp;
    return Positioned(
      right: 26,
      bottom: 26,
      child: IgnorePointer(
        ignoring: !show,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 700),
          curve: Motion.cinematic,
          offset: show ? Offset.zero : const Offset(0, 1.6),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: show ? 1 : 0,
            child: LuxuryButton(label: 'RSVP', onPressed: () => context.goToSection(Sec.rsvp)),
          ),
        ),
      ),
    );
  }
}
