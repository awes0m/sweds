import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/scene_providers.dart';

typedef StageBuilder = Widget Function(BuildContext context, double p, Size size);

/// Hosts one chapter of the film.
///
/// Pinned chapters keep a viewport-sized stage glued to the screen while the
/// builder receives scrubbed progress [p]. Flow chapters scroll normally and
/// receive "through-the-viewport" progress. Only this widget rebuilds as the
/// scroll moves, and only while its progress actually changes.
class SceneSection extends ConsumerWidget {
  const SceneSection({super.key, required this.index, required this.builder});
  final int index;
  final StageBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(sectionLayoutsProvider)[index];
    final p = ref.watch(sectionProgressProvider(index));
    final vp = ref.watch(sceneViewportProvider);

    if (layout.spec.pinned) {
      return SizedBox(
        height: layout.height,
        child: Stack(children: [
          Positioned(
            left: 0,
            right: 0,
            top: p * layout.pinTravel,
            height: vp.height,
            child: ClipRect(child: builder(context, p, Size(vp.width, vp.height))),
          ),
        ]),
      );
    }
    return SizedBox(
      height: layout.height,
      child: builder(context, p, Size(vp.width, layout.height)),
    );
  }
}

/// Loads a deferred library the first time the section is built.
class DeferredSection extends StatefulWidget {
  const DeferredSection({super.key, required this.load, required this.builder});
  final Future<void> Function() load;
  final WidgetBuilder builder;

  @override
  State<DeferredSection> createState() => _DeferredSectionState();
}

class _DeferredSectionState extends State<DeferredSection> {
  late final Future<void> _future = widget.load();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _future.then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _ready ? widget.builder(context) : const SizedBox.expand();
}
