// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PointerPx)
const pointerPxProvider = PointerPxProvider._();

final class PointerPxProvider extends $NotifierProvider<PointerPx, Offset> {
  const PointerPxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointerPxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointerPxHash();

  @$internal
  @override
  PointerPx create() => PointerPx();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Offset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Offset>(value),
    );
  }
}

String _$pointerPxHash() => r'ae0a0f3155f04e7f565dd5f84881ce17a9a386b4';

abstract class _$PointerPx extends $Notifier<Offset> {
  Offset build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Offset, Offset>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Offset, Offset>,
              Offset,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(HasMouse)
const hasMouseProvider = HasMouseProvider._();

final class HasMouseProvider extends $NotifierProvider<HasMouse, bool> {
  const HasMouseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasMouseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasMouseHash();

  @$internal
  @override
  HasMouse create() => HasMouse();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasMouseHash() => r'285227cc0ac4758e40b13f569c8921a46f58ed63';

abstract class _$HasMouse extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Pointer in -1..1 screen space (zero on touch devices).

@ProviderFor(pointerNorm)
const pointerNormProvider = PointerNormProvider._();

/// Pointer in -1..1 screen space (zero on touch devices).

final class PointerNormProvider
    extends $FunctionalProvider<Offset, Offset, Offset>
    with $Provider<Offset> {
  /// Pointer in -1..1 screen space (zero on touch devices).
  const PointerNormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointerNormProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointerNormHash();

  @$internal
  @override
  $ProviderElement<Offset> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Offset create(Ref ref) {
    return pointerNorm(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Offset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Offset>(value),
    );
  }
}

String _$pointerNormHash() => r'9365f37b6e201a6f9371c8d458e9157b4992d38b';

@ProviderFor(CursorHovering)
const cursorHoveringProvider = CursorHoveringProvider._();

final class CursorHoveringProvider
    extends $NotifierProvider<CursorHovering, bool> {
  const CursorHoveringProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cursorHoveringProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cursorHoveringHash();

  @$internal
  @override
  CursorHovering create() => CursorHovering();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$cursorHoveringHash() => r'67dffa6fb3c60cf9b3a17f539fe533b3857ee34e';

abstract class _$CursorHovering extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(audioService)
const audioServiceProvider = AudioServiceProvider._();

final class AudioServiceProvider
    extends
        $FunctionalProvider<
          AmbientAudioService,
          AmbientAudioService,
          AmbientAudioService
        >
    with $Provider<AmbientAudioService> {
  const AudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $ProviderElement<AmbientAudioService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AmbientAudioService create(Ref ref) {
    return audioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AmbientAudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AmbientAudioService>(value),
    );
  }
}

String _$audioServiceHash() => r'99941c8315b5fb53d9585e0c01a316983d8782fe';

@ProviderFor(AmbientMusic)
const ambientMusicProvider = AmbientMusicProvider._();

final class AmbientMusicProvider extends $NotifierProvider<AmbientMusic, bool> {
  const AmbientMusicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ambientMusicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ambientMusicHash();

  @$internal
  @override
  AmbientMusic create() => AmbientMusic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ambientMusicHash() => r'b2731cccd644dce6d21a5e143c79d0b4f81b31b1';

abstract class _$AmbientMusic extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(appTheme)
const appThemeProvider = AppThemeProvider._();

final class AppThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  const AppThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return appTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$appThemeHash() => r'5df7c492a59ec33ce1be6ae943f2acdd345b7b14';

@ProviderFor(rsvpService)
const rsvpServiceProvider = RsvpServiceProvider._();

final class RsvpServiceProvider
    extends $FunctionalProvider<RsvpService, RsvpService, RsvpService>
    with $Provider<RsvpService> {
  const RsvpServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rsvpServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rsvpServiceHash();

  @$internal
  @override
  $ProviderElement<RsvpService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RsvpService create(Ref ref) {
    return rsvpService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RsvpService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RsvpService>(value),
    );
  }
}

String _$rsvpServiceHash() => r'2cecf68b754670894d49ebd4f9b11232d5e8423d';

@ProviderFor(countdown)
const countdownProvider = CountdownProvider._();

final class CountdownProvider
    extends
        $FunctionalProvider<AsyncValue<Duration>, Duration, Stream<Duration>>
    with $FutureModifier<Duration>, $StreamProvider<Duration> {
  const CountdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countdownProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countdownHash();

  @$internal
  @override
  $StreamProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Duration> create(Ref ref) {
    return countdown(ref);
  }
}

String _$countdownHash() => r'3d3d647596052b4266ed04f67ecb056b8206afa9';
