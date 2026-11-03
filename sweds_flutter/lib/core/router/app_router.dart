import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/rsvp/secret_guest_list_page.dart';
import '../../features/shell/experience_page.dart';

part 'app_router.g.dart';

/// One continuous journey = one route. Chapters are addressed with
/// `/?s=venue`; the page key is constant so navigating between chapters
/// never rebuilds (or restarts) the scene.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            key: const ValueKey('experience'),
            child: ExperiencePage(section: state.uri.queryParameters['s']),
          ),
        ),
        GoRoute(
          path: '/NoosuBunu',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey('secret_guest_list'),
            child: SecretGuestListPage(),
          ),
        ),
        GoRoute(
          path: '/noosubunu',
          pageBuilder: (context, state) => const NoTransitionPage(
            key: ValueKey('secret_guest_list_lower'),
            child: SecretGuestListPage(),
          ),
        ),
      ],
    );
