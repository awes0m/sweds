import 'package:freezed_annotation/freezed_annotation.dart';

part 'rsvp_models.freezed.dart';
part 'rsvp_models.g.dart';

enum Attendance { accepts, declines }

enum RsvpStatus { editing, submitting, success, failure }

@freezed
abstract class RsvpSubmission with _$RsvpSubmission {
  const factory RsvpSubmission({
    required String name,
    required String email,
    required String phone,
    required Attendance attendance,
    required int guests,
    @Default('') String message,
  }) = _RsvpSubmission;

  factory RsvpSubmission.fromJson(Map<String, dynamic> json) =>
      _$RsvpSubmissionFromJson(json);
}

@freezed
abstract class RsvpFormState with _$RsvpFormState {
  const RsvpFormState._();

  const factory RsvpFormState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String phone,
    @Default(Attendance.accepts) Attendance attendance,
    @Default(1) int guests,
    @Default('') String message,
    @Default(RsvpStatus.editing) RsvpStatus status,
    @Default(false) bool showErrors,
  }) = _RsvpFormState;

  String? get nameError => name.trim().length < 2 ? 'Please tell us your name' : null;
  String? get emailError => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())
      ? null
      : 'Enter a valid email address';
  String? get phoneError =>
      RegExp(r'^[+()\-\s\d]{7,18}$').hasMatch(phone.trim()) ? null : 'Enter a valid number';

  bool get isValid => nameError == null && emailError == null && phoneError == null;

  RsvpSubmission toSubmission() => RsvpSubmission(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        attendance: attendance,
        guests: attendance == Attendance.accepts ? guests : 0,
        message: message.trim(),
      );
}
