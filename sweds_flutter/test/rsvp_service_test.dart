import 'package:flutter_test/flutter_test.dart';
import 'package:sweds_flutter/shared/models/rsvp_models.dart';
import 'package:sweds_flutter/shared/services/rsvp_service.dart';

void main() {
  group('RsvpSubmission serialization', () {
    test('serializes to and from json', () {
      const sub = RsvpSubmission(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        attendance: Attendance.accepts,
        guests: 2,
        message: 'Congratulations!',
      );

      final json = sub.toJson();
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['phone'], '+1234567890');
      expect(json['attendance'], 'accepts');
      expect(json['events'], 'both');
      expect(json['guests'], 2);
      expect(json['message'], 'Congratulations!');

      final parsed = RsvpSubmission.fromJson(json);
      expect(parsed, equals(sub));
    });

    test('serializes with empty optional email and specific event', () {
      const sub = RsvpSubmission(
        name: 'Sayantika Fan',
        phone: '+919876543210',
        attendance: Attendance.accepts,
        events: AttendingEvents.weddingOnly,
        guests: 1,
      );

      final json = sub.toJson();
      expect(json['email'], '');
      expect(json['events'], 'weddingOnly');

      final parsed = RsvpSubmission.fromJson(json);
      expect(parsed, equals(sub));
      expect(parsed.email, isEmpty);
      expect(parsed.events, AttendingEvents.weddingOnly);
    });
  });

  group('MockRsvpService operations', () {
    test('submits and retrieves confirmed guests', () async {
      final service = MockRsvpService();

      const guest1 = RsvpSubmission(
        name: 'Alice',
        email: 'alice@example.com',
        phone: '+1234567890',
        attendance: Attendance.accepts,
        guests: 1,
      );

      const guest2 = RsvpSubmission(
        name: 'Bob',
        email: 'bob@example.com',
        phone: '+1987654321',
        attendance: Attendance.declines,
        guests: 0,
      );

      await service.submit(guest1);
      await service.submit(guest2);

      final confirmed = await service.getConfirmedGuests();
      expect(confirmed.length, 1);
      expect(confirmed.first.name, 'Alice');

      final confirmedJson = await service.getConfirmedGuestsJson();
      expect(confirmedJson.length, 1);
      expect(confirmedJson.first['name'], 'Alice');

      final allJson = await service.getAllRsvpsJson();
      expect(allJson.length, 2);
    });
  });
}

