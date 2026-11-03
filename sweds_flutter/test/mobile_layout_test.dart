import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:sweds_flutter/core/scroll/section_spec.dart';
import 'package:sweds_flutter/features/rsvp/rsvp_section.dart';
import 'package:sweds_flutter/features/venue/venue_section.dart';
import 'package:sweds_flutter/shared/providers/scene_providers.dart';

void main() {
  testWidgets(
    'Venue and RSVP sections render without overflow on mobile viewport (360x640)',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      container.read(sceneViewportProvider.notifier).set(const Size(360, 640));

      // Test VenueSection
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: VenueSection())),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));

      // Verify all 3 Venue buttons are present in the tree
      expect(find.text('MAPS 📍'), findsOneWidget);
      expect(find.text('RSVP 💌'), findsOneWidget);
      expect(find.text('RECEPTION ↻'), findsOneWidget);

      // Test RsvpSection
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: RsvpSection())),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));

      // Verify RSVP form fields and submit button are present
      expect(find.text('SEND MY REPLY'), findsOneWidget);
      expect(find.text('Joyfully accepts'), findsOneWidget);
      expect(find.text('Both Celebrations'), findsOneWidget);

      // No overflow exception should have been thrown
      expect(tester.takeException(), isNull);
    },
  );
}
