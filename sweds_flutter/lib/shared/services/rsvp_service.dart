import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/rsvp_models.dart';

abstract interface class RsvpService {
  /// Submits an RSVP record to the database.
  Future<void> submit(RsvpSubmission submission);

  /// Retrieves confirmed guests (attendance == accepts) as typed submissions.
  Future<List<RsvpSubmission>> getConfirmedGuests();

  /// Real-time stream of confirmed guests.
  Stream<List<RsvpSubmission>> watchConfirmedGuests();

  /// Retrieves confirmed guests as raw JSON maps.
  Future<List<Map<String, dynamic>>> getConfirmedGuestsJson();

  /// Retrieves all RSVP records as raw JSON maps.
  Future<List<Map<String, dynamic>>> getAllRsvpsJson();

  /// Retrieves all submissions as typed objects.
  Future<List<RsvpSubmission>> getAllSubmissions();
}

/// Production implementation using Cloud Firestore.
class FirestoreRsvpService implements RsvpService {
  FirestoreRsvpService({
    FirebaseFirestore? firestore,
    this.collectionPath = 'rsvps',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  @override
  Future<void> submit(RsvpSubmission submission) async {
    final payload = <String, dynamic>{
      'name': submission.name.trim(),
      'email': submission.email.trim(),
      'phone': submission.phone.trim(),
      'attendance': submission.attendance.name,
      'guests': submission.guests,
      'message': submission.message.trim(),
      'submittedAt': FieldValue.serverTimestamp(),
    };

    debugPrint(
      'FirestoreRsvpService submitting: ${submission.name} (${submission.attendance.name}, ${submission.email})',
    );
    try {
      await _collection.add(payload);
      debugPrint('FirestoreRsvpService submission successful');
    } catch (e) {
      debugPrint('FirestoreRsvpService primary submission failed: $e. Retrying without server timestamp...');
      final fallbackPayload = <String, dynamic>{
        'name': submission.name.trim(),
        'email': submission.email.trim(),
        'phone': submission.phone.trim(),
        'attendance': submission.attendance.name,
        'guests': submission.guests,
        'message': submission.message.trim(),
      };
      await _collection.add(fallbackPayload);
      debugPrint('FirestoreRsvpService fallback submission successful');
    }
  }

  @override
  Future<List<RsvpSubmission>> getConfirmedGuests() async {
    final snapshot = await _collection
        .where('attendance', isEqualTo: 'accepts')
        .get();

    return snapshot.docs
        .map((doc) => _tryParseSubmission(doc.data()))
        .whereType<RsvpSubmission>()
        .toList();
  }

  @override
  Stream<List<RsvpSubmission>> watchConfirmedGuests() {
    return _collection
        .where('attendance', isEqualTo: 'accepts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _tryParseSubmission(doc.data()))
              .whereType<RsvpSubmission>()
              .toList(),
        );
  }

  @override
  Future<List<Map<String, dynamic>>> getConfirmedGuestsJson() async {
    final snapshot = await _collection
        .where('attendance', isEqualTo: 'accepts')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRsvpsJson() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<RsvpSubmission>> getAllSubmissions() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => _tryParseSubmission(doc.data()))
        .whereType<RsvpSubmission>()
        .toList();
  }

  RsvpSubmission? _tryParseSubmission(Map<String, dynamic> data) {
    try {
      return RsvpSubmission.fromJson(data);
    } catch (e) {
      debugPrint('FirestoreRsvpService parse error: $e');
      return null;
    }
  }
}

/// In-memory mock implementation for testing and development.
class MockRsvpService implements RsvpService {
  final List<RsvpSubmission> _items = [];

  @override
  Future<void> submit(RsvpSubmission s) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _items.removeWhere((item) => item.email.toLowerCase() == s.email.toLowerCase());
    _items.add(s);
    debugPrint('Mock RSVP → ${jsonEncode(s.toJson())}');
  }

  @override
  Future<List<RsvpSubmission>> getConfirmedGuests() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _items.where((s) => s.attendance == Attendance.accepts).toList();
  }

  @override
  Stream<List<RsvpSubmission>> watchConfirmedGuests() async* {
    yield await getConfirmedGuests();
  }

  @override
  Future<List<Map<String, dynamic>>> getConfirmedGuestsJson() async {
    final confirmed = await getConfirmedGuests();
    return confirmed.map((e) => e.toJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRsvpsJson() async {
    return _items.map((e) => e.toJson()).toList();
  }

  @override
  Future<List<RsvpSubmission>> getAllSubmissions() async {
    return List.unmodifiable(_items);
  }
}
