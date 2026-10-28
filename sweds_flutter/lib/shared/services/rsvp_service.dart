import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/rsvp_models.dart';

abstract interface class RsvpService {
  Future<void> submit(RsvpSubmission submission);
}

/// Replace with an HTTP / Firebase / Supabase implementation.
class MockRsvpService implements RsvpService {
  @override
  Future<void> submit(RsvpSubmission s) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    debugPrint('RSVP → ${jsonEncode(s.toJson())}');
  }
}
