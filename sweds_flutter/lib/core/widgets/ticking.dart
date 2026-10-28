import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Provides a continuously-increasing clock (seconds) without rebuilding the
/// subtree: painters listen to it through `CustomPainter(repaint: time)`.
class Ticking extends StatefulWidget {
  const Ticking({super.key, required this.builder});
  final Widget Function(BuildContext context, ValueListenable<double> time) builder;

  @override
  State<Ticking> createState() => _TickingState();
}

class _TickingState extends State<Ticking> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _time = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) => _time.value = d.inMicroseconds / 1e6)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _time);
}
