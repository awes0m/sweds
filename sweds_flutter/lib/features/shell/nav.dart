import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../gallery/gallery_page.dart';

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

const _links = [
  Sec.story,
  Sec.proposal,
  Sec.timeline,
  Sec.venue,
  Sec.gallery,
  Sec.rsvp,
];

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
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 40 : 14,
          vertical: wide ? 18 : 12,
        ),
        child: Row(
          children: [
            CursorHover(
              child: GestureDetector(
                onTap: () => context.goToSection(Sec.hero),
                child: Text(
                  '${WeddingConfig.bride[0]} & ${WeddingConfig.groom[0]}',
                  style: LuxText.display(
                    wide ? 26 : 22,
                    color: Lux.crimson,
                    style: FontStyle.italic,
                    spacing: 1,
                  ),
                ),
              ),
            ),
            if (wide) ...[
              const Spacer(),
              GlassPanel(
                radius: 40,
                blur: 18,
                opacity: 0.35,
                shadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    for (final i in _links)
                      _NavLink(index: i, active: active == i),
                  ],
                ),
              ),
              const Spacer(),
            ] else ...[
              const Spacer(),
              const _MobileMenuButton(),
            ],
            MusicToggle(compact: !wide),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile hamburger button switch
// ---------------------------------------------------------------------------

class _MobileMenuButton extends ConsumerWidget {
  const _MobileMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(mobileSidebarOpenProvider);
    return GestureDetector(
      onTap: () =>
          ref.read(mobileSidebarOpenProvider.notifier).toggle(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Lux.ivory.withValues(alpha: 0.7),
          border: Border.all(color: Lux.gold.withValues(alpha: 0.9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Lux.crimson.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: isOpen ? 0.25 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Motion.cinematic,
          child: Icon(
            isOpen ? Icons.close_rounded : Icons.menu_rounded,
            size: 22,
            color: Lux.crimson,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile slide-in sidebar drawer (inside ExperiencePage Stack)
// ---------------------------------------------------------------------------

class MobileSidebarDrawer extends ConsumerWidget {
  const MobileSidebarDrawer({super.key});

  static const _items = [
    (Sec.story, Icons.favorite_rounded, 'Our Story'),
    (Sec.proposal, Icons.diamond_rounded, 'The Ring'),
    (Sec.timeline, Icons.celebration_rounded, 'Celebrations'),
    (Sec.venue, Icons.place_rounded, 'Venues & Reception'),
    (Sec.gallery, Icons.photo_camera_rounded, 'Moments / Photos'),
    (-1, Icons.restaurant_menu_rounded, 'Feast Menu'),
    (Sec.countdown, Icons.hourglass_top_rounded, 'Countdown'),
    (Sec.rsvp, Icons.mail_outline_rounded, 'RSVP'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(mobileSidebarOpenProvider);
    final active = ref.watch(activeSectionProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (wide && isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mobileSidebarOpenProvider.notifier).close();
      });
    }

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isOpen,
        child: Stack(
          children: [
            // Darkened backdrop barrier
            GestureDetector(
              onTap: () =>
                  ref.read(mobileSidebarOpenProvider.notifier).close(),
              behavior: HitTestBehavior.opaque,
              child: AnimatedOpacity(
                opacity: isOpen ? 1 : 0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // Slide-in drawer
            AnimatedPositioned(
              left: isOpen ? 0 : -310,
              top: 0,
              bottom: 0,
              width: 285,
              duration: const Duration(milliseconds: 320),
              curve: Motion.cinematic,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Lux.ivory,
                        Color.lerp(Lux.ivory, Lux.crimson, 0.05)!,
                      ],
                    ),
                    border: Border(
                      right: BorderSide(
                        color: Lux.gold.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(8, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                          child: Row(
                            children: [
                              Text(
                                '${WeddingConfig.bride} & ${WeddingConfig.groom}',
                                style: LuxText.display(
                                  18,
                                  color: Lux.crimson,
                                  style: FontStyle.italic,
                                  spacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => ref
                                    .read(mobileSidebarOpenProvider.notifier)
                                    .close(),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Lux.gold.withValues(alpha: 0.6),
                                    ),
                                    color: Lux.ivory.withValues(alpha: 0.8),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Lux.crimson,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Gold divider
                        Container(
                          height: 1.5,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Lux.gold.withValues(alpha: 0.1),
                              Lux.gold,
                              Lux.gold.withValues(alpha: 0.1),
                            ]),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Navigation links
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              for (final (sec, icon, label) in _items)
                                _DrawerItem(
                                  sec: sec,
                                  icon: icon,
                                  label: label,
                                  isActive: active == sec,
                                  onTap: () {
                                    ref
                                        .read(
                                          mobileSidebarOpenProvider.notifier,
                                        )
                                        .close();
                                    if (sec == -1) {
                                      context.push('/menu');
                                    } else if (sec == Sec.gallery) {
                                      GalleryPage.open(context);
                                    } else {
                                      context.goToSection(sec);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),

                        // Drawer footer
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: Column(
                            children: [
                              Container(
                                height: 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Lux.champagne.withValues(alpha: 0.5),
                              ),
                              Text(
                                WeddingConfig.hashtag,
                                style: LuxText.serif(
                                  14,
                                  style: FontStyle.normal,
                                  color: Lux.crimson,
                                  weight: FontWeight.w600,
                                  spacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                WeddingConfig.dateLabel,
                                style: LuxText.body(
                                  12,
                                  color: Lux.goldDeep,
                                  opacity: 0.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  const _DrawerItem({
    required this.sec,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final int sec;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.isActive || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Motion.cinematic,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: highlighted
                ? Lux.gold.withValues(alpha: 0.18)
                : Colors.transparent,
            border: Border.all(
              color: widget.isActive
                  ? Lux.gold.withValues(alpha: 0.65)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: highlighted
                      ? Lux.crimson.withValues(alpha: 0.12)
                      : Lux.ivory.withValues(alpha: 0.8),
                  border: Border.all(
                    color: highlighted
                        ? Lux.gold.withValues(alpha: 0.8)
                        : Lux.gold.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 19,
                  color: highlighted
                      ? Lux.crimson
                      : Lux.dark.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: LuxText.serif(
                    16,
                    style: FontStyle.normal,
                    weight: highlighted ? FontWeight.w700 : FontWeight.w500,
                    color: highlighted
                        ? Lux.crimson
                        : Lux.dark.withValues(alpha: 0.8),
                  ),
                ),
              ),
              if (widget.isActive)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Lux.crimson,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop nav link
// ---------------------------------------------------------------------------

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
            onTap: () {
              if (widget.index == Sec.gallery) {
                GalleryPage.open(context);
              } else {
                context.goToSection(widget.index);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.index == Sec.gallery
                        ? 'Photos'
                        : kSections[widget.index].label,
                    style: LuxText.serif(
                      17,
                      style: FontStyle.normal,
                      weight: FontWeight.w600,
                      color: widget.active || _hover
                          ? Lux.crimson
                          : Lux.dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Motion.cinematic,
                    height: 1.5,
                    width: widget.active ? 22 : 0,
                    color: Lux.crimson,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class MusicToggle extends ConsumerWidget {
  const MusicToggle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(ambientMusicProvider);
    final size = compact ? 38.0 : 46.0;
    return CursorHover(
      child: GestureDetector(
        onTap: () => ref.read(ambientMusicProvider.notifier).toggle(),
        child: Container(
          width: size,
          height: size,
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
                      height: on
                          ? 5 + 13 * (0.5 + 0.5 * math.sin(t * 4 + i * 1.3))
                          : 4,
                      decoration: BoxDecoration(
                        color: Lux.goldDeep,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < kSections.length; i++)
              _Dot(index: i, active: i == active),
          ],
        ),
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
            onTap: () {
              if (widget.index == Sec.gallery) {
                GalleryPage.open(context);
              } else {
                context.goToSection(widget.index);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _hover ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        widget.index == Sec.gallery
                            ? 'Photos'
                            : kSections[widget.index].label,
                        style: LuxText.serif(
                          16,
                          style: FontStyle.normal,
                          color: Lux.goldDeep,
                          weight: FontWeight.w600,
                        ),
                      ),
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
                ],
              ),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Lux.crimson, Lux.goldLight, Lux.gold],
              ),
            ),
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
            child: LuxuryButton(
              label: 'RSVP',
              onPressed: () => context.goToSection(Sec.rsvp),
            ),
          ),
        ),
      ),
    );
  }
}
