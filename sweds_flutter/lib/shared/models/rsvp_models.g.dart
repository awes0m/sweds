// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsvp_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RsvpSubmission _$RsvpSubmissionFromJson(Map<String, dynamic> json) =>
    _RsvpSubmission(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      attendance: $enumDecode(_$AttendanceEnumMap, json['attendance']),
      guests: (json['guests'] as num).toInt(),
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$RsvpSubmissionToJson(_RsvpSubmission instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'attendance': _$AttendanceEnumMap[instance.attendance]!,
      'guests': instance.guests,
      'message': instance.message,
    };

const _$AttendanceEnumMap = {
  Attendance.accepts: 'accepts',
  Attendance.declines: 'declines',
};
