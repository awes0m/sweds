import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/rsvp_models.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/services/card_generator_service.dart';

part 'rsvp_controller.g.dart';

@Riverpod(keepAlive: true)
class RsvpController extends _$RsvpController {
  @override
  RsvpFormState build() => const RsvpFormState();

  void setName(String v) => state = state.copyWith(name: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPhone(String v) => state = state.copyWith(phone: v);
  void setMessage(String v) => state = state.copyWith(message: v);
  void setAttendance(Attendance a) => state = state.copyWith(attendance: a);
  void setEvents(AttendingEvents e) => state = state.copyWith(events: e);
  void setGuests(int g) => state = state.copyWith(guests: g.clamp(1, 6));

  Future<void> submit() async {
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(status: RsvpStatus.submitting);
    try {
      final submission = state.toSubmission();
      await ref.read(rsvpServiceProvider).submit(submission);
      state = state.copyWith(status: RsvpStatus.success);

      // Automatically generate and trigger download of customized invite / greeting card
      try {
        const generator = CardGeneratorService();
        await generator.generateAndDownload(submission);
      } catch (err, errSt) {
        debugPrint(
          'Auto download card failed (can be downloaded from UI): $err\n$errSt',
        );
      }
    } catch (e, st) {
      debugPrint('RSVP submission error: $e\n$st');
      state = state.copyWith(status: RsvpStatus.failure);
    }
  }

  void reset() => state = const RsvpFormState();

  void edit() => state = state.copyWith(status: RsvpStatus.editing);
}
