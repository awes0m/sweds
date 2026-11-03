import 'package:flutter_test/flutter_test.dart';
import 'package:sweds_flutter/shared/models/rsvp_models.dart';
import 'package:sweds_flutter/shared/services/card_generator_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CardGeneratorService', () {
    const generator = CardGeneratorService();

    test('generates valid PNG bytes for accepted RSVP invite card', () async {
      const submission = RsvpSubmission(
        name: 'Rahul Sharma',
        email: 'rahul@example.com',
        phone: '+919876543210',
        attendance: Attendance.accepts,
        guests: 2,
        message: 'Congratulations Som & Sayantika!',
      );

      final bytes = await generator.generateCardBytes(submission);
      expect(bytes.isNotEmpty, isTrue);
      // PNG magic header check: 0x89, 'P', 'N', 'G'
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    test('generates valid PNG bytes for weddingOnly event selection', () async {
      const submission = RsvpSubmission(
        name: 'Amit Mukherjee',
        phone: '+919876543210',
        attendance: Attendance.accepts,
        events: AttendingEvents.weddingOnly,
        guests: 1,
      );

      final bytes = await generator.generateCardBytes(submission);
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });

    test('generates valid PNG bytes for receptionOnly event selection', () async {
      const submission = RsvpSubmission(
        name: 'Suman Roy',
        phone: '+919876543211',
        attendance: Attendance.accepts,
        events: AttendingEvents.receptionOnly,
        guests: 3,
      );

      final bytes = await generator.generateCardBytes(submission);
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
      expect(bytes[2], 0x4E);
      expect(bytes[3], 0x47);
    });
  });
}

