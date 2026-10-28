import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/rsvp_models.dart';
import '../../shared/providers/app_providers.dart';

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
  void setGuests(int g) => state = state.copyWith(guests: g.clamp(1, 6));

  Future<void> submit() async {
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(status: RsvpStatus.submitting);
    try {
      await ref.read(rsvpServiceProvider).submit(state.toSubmission());
      state = state.copyWith(status: RsvpStatus.success);
    } catch (_) {
      state = state.copyWith(status: RsvpStatus.failure);
    }
  }

  void reset() => state = const RsvpFormState();

  void edit() => state = state.copyWith(status: RsvpStatus.editing);
}
