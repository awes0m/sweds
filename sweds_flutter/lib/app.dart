import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/wedding_config.dart';
import 'core/router/app_router.dart';
import 'shared/providers/app_providers.dart';

class WeddingApp extends ConsumerWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '${WeddingConfig.bride} & ${WeddingConfig.groom}',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(appThemeProvider),
      routerConfig: ref.watch(appRouterProvider),
      scrollBehavior: const _CinematicScrollBehavior(),
    );
  }
}

/// No scrollbars / glow: the experience draws its own progress UI.
class _CinematicScrollBehavior extends MaterialScrollBehavior {
  const _CinematicScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.trackpad};
  @override
  Widget buildScrollbar(BuildContext c, Widget child, ScrollableDetails d) => child;
  @override
  Widget buildOverscrollIndicator(BuildContext c, Widget child, ScrollableDetails d) => child;
}
