import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/scroll/scene_section.dart';
import '../../core/scroll/scroll_engine.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/cursor.dart';
import '../../shared/painters/atmosphere_background.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/scene_providers.dart';
import '../countdown/countdown_section.dart';
import '../footer/footer_section.dart';
import '../gallery/gallery_section.dart' deferred as gallery;
import '../hero/hero_section.dart';
import '../love_story/love_story_section.dart';
import '../proposal/proposal_section.dart';
import '../rsvp/rsvp_section.dart' deferred as rsvp;
import '../timeline/timeline_section.dart';
import '../venue/venue_section.dart';
import 'nav.dart';

class ExperiencePage extends ConsumerStatefulWidget {
  const ExperiencePage({super.key, this.section});
  final String? section;

  @override
  ConsumerState<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends ConsumerState<ExperiencePage>
    with SingleTickerProviderStateMixin {
  late final ScrollEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = ScrollEngine(
      vsync: this,
      sectionTop: (i) => ref.read(sectionLayoutsProvider)[i].top,
    )..controller.addListener(_onScroll);

    final i = kSections.indexWhere((s) => s.id == widget.section);
    if (i > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _engine.jumpToSection(i);
      });
    }
  }

  @override
  void didUpdateWidget(ExperiencePage old) {
    super.didUpdateWidget(old);
    if (old.section != widget.section) {
      final i = kSections.indexWhere((s) => s.id == (widget.section ?? 'home'));
      if (i >= 0) _engine.goToSection(i);
    }
  }

  void _onScroll() {
    void push() {
      if (mounted) {
        ref.read(scrollOffsetProvider.notifier).set(_engine.controller.offset);
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => push());
    } else {
      push();
    }
  }

  @override
  void dispose() {
    _engine.controller.removeListener(_onScroll);
    _engine.dispose();
    super.dispose();
  }

  void _pointer(PointerEvent e) {
    ref.read(pointerPxProvider.notifier).set(e.position);
    if (e.kind == PointerDeviceKind.mouse) {
      ref.read(hasMouseProvider.notifier).set(true);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final f = FocusManager.instance.primaryFocus;
    if (f?.context?.findAncestorWidgetOfExactType<EditableText>() != null) {
      return KeyEventResult.ignored; // typing in the RSVP form
    }
    final vh = MediaQuery.sizeOf(context).height;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      _engine.wheel(140);
    } else if (k == LogicalKeyboardKey.arrowUp) {
      _engine.wheel(-140);
    } else if (k == LogicalKeyboardKey.pageDown ||
        k == LogicalKeyboardKey.space) {
      _engine.wheel(vh * 0.85);
    } else if (k == LogicalKeyboardKey.pageUp) {
      _engine.wheel(-vh * 0.85);
    } else if (k == LogicalKeyboardKey.home) {
      _engine.animateTo(0);
    } else if (k == LogicalKeyboardKey.end) {
      _engine.animateTo(double.maxFinite);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Widget _chapter(int i) => switch (i) {
    Sec.hero => const HeroSection(),
    Sec.story => const LoveStorySection(),
    Sec.proposal => const ProposalSection(),
    Sec.timeline => const TimelineSection(),
    Sec.venue => const VenueSection(),
    Sec.gallery => DeferredSection(
      load: () => gallery.loadLibrary(),
      builder: (_) => gallery.GallerySection(),
    ),
    Sec.countdown => const CountdownSection(),
    Sec.rsvp => DeferredSection(
      load: () => rsvp.loadLibrary(),
      builder: (_) => rsvp.RsvpSection(),
    ),
    _ => const FooterSection(),
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size != ref.read(sceneViewportProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(sceneViewportProvider.notifier).set(size);
      });
    }
    final layouts = ref.watch(sectionLayoutsProvider);

    return ScrollEngineScope(
      engine: _engine,
      child: Material(
        color: Lux.background,
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerHover: _pointer,
            onPointerMove: _pointer,
            child: MouseRegion(
              cursor: SystemMouseCursors.none,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: AtmosphereBackground()),
                  ),
                  Positioned.fill(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: CustomScrollView(
                        scrollCacheExtent: ScrollCacheExtent.pixels(
                          size.height * 0.6,
                        ),
                        controller: _engine.controller,
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverVariedExtentList(
                            itemExtentBuilder: (i, _) => layouts[i].height,
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => WheelCapture(
                                engine: _engine,
                                child: _chapter(i),
                              ),
                              childCount: kSections.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const TopBar(),
                  const SideDots(),
                  const ScrollProgressLine(),
                  const FloatingCta(),
                  const Positioned.fill(child: LuxuryCursor()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
