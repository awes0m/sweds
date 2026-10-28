// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsvp_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RsvpController)
const rsvpControllerProvider = RsvpControllerProvider._();

final class RsvpControllerProvider
    extends $NotifierProvider<RsvpController, RsvpFormState> {
  const RsvpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rsvpControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rsvpControllerHash();

  @$internal
  @override
  RsvpController create() => RsvpController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RsvpFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RsvpFormState>(value),
    );
  }
}

String _$rsvpControllerHash() => r'123fb8f249e599fe659e6f8299eabc32665540ca';

abstract class _$RsvpController extends $Notifier<RsvpFormState> {
  RsvpFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RsvpFormState, RsvpFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RsvpFormState, RsvpFormState>,
              RsvpFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
