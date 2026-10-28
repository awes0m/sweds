// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SceneViewport)
const sceneViewportProvider = SceneViewportProvider._();

final class SceneViewportProvider
    extends $NotifierProvider<SceneViewport, Size> {
  const SceneViewportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneViewportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneViewportHash();

  @$internal
  @override
  SceneViewport create() => SceneViewport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Size value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Size>(value),
    );
  }
}

String _$sceneViewportHash() => r'bbcc79b3e87761f165e3c9cacda0151d6bb5150d';

abstract class _$SceneViewport extends $Notifier<Size> {
  Size build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Size, Size>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Size, Size>,
              Size,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(deviceClass)
const deviceClassProvider = DeviceClassProvider._();

final class DeviceClassProvider
    extends $FunctionalProvider<DeviceClass, DeviceClass, DeviceClass>
    with $Provider<DeviceClass> {
  const DeviceClassProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceClassProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceClassHash();

  @$internal
  @override
  $ProviderElement<DeviceClass> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceClass create(Ref ref) {
    return deviceClass(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceClass value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceClass>(value),
    );
  }
}

String _$deviceClassHash() => r'3b45ce4bb73dc8316f9978feac989b46ce7a7c1b';

/// Absolute geometry of every chapter, derived from the viewport.

@ProviderFor(sectionLayouts)
const sectionLayoutsProvider = SectionLayoutsProvider._();

/// Absolute geometry of every chapter, derived from the viewport.

final class SectionLayoutsProvider
    extends
        $FunctionalProvider<
          List<SectionLayout>,
          List<SectionLayout>,
          List<SectionLayout>
        >
    with $Provider<List<SectionLayout>> {
  /// Absolute geometry of every chapter, derived from the viewport.
  const SectionLayoutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sectionLayoutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sectionLayoutsHash();

  @$internal
  @override
  $ProviderElement<List<SectionLayout>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SectionLayout> create(Ref ref) {
    return sectionLayouts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SectionLayout> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SectionLayout>>(value),
    );
  }
}

String _$sectionLayoutsHash() => r'a89e2fd086e1e431849198143882dbfec282cc77';

@ProviderFor(ScrollOffset)
const scrollOffsetProvider = ScrollOffsetProvider._();

final class ScrollOffsetProvider
    extends $NotifierProvider<ScrollOffset, double> {
  const ScrollOffsetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scrollOffsetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scrollOffsetHash();

  @$internal
  @override
  ScrollOffset create() => ScrollOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$scrollOffsetHash() => r'e85e574ebb06eacf4377b2332af8135b39d5923c';

abstract class _$ScrollOffset extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Per-chapter progress. Because it is clamped, chapters that are off-screen
/// stop notifying and therefore stop rebuilding.

@ProviderFor(sectionProgress)
const sectionProgressProvider = SectionProgressFamily._();

/// Per-chapter progress. Because it is clamped, chapters that are off-screen
/// stop notifying and therefore stop rebuilding.

final class SectionProgressProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Per-chapter progress. Because it is clamped, chapters that are off-screen
  /// stop notifying and therefore stop rebuilding.
  const SectionProgressProvider._({
    required SectionProgressFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'sectionProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sectionProgressHash();

  @override
  String toString() {
    return r'sectionProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as int;
    return sectionProgress(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SectionProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sectionProgressHash() => r'76f50e2657b1ccc299a4b1c58668b7b1fcc1ba64';

/// Per-chapter progress. Because it is clamped, chapters that are off-screen
/// stop notifying and therefore stop rebuilding.

final class SectionProgressFamily extends $Family
    with $FunctionalFamilyOverride<double, int> {
  const SectionProgressFamily._()
    : super(
        retry: null,
        name: r'sectionProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-chapter progress. Because it is clamped, chapters that are off-screen
  /// stop notifying and therefore stop rebuilding.

  SectionProgressProvider call(int index) =>
      SectionProgressProvider._(argument: index, from: this);

  @override
  String toString() => r'sectionProgressProvider';
}

/// Which chapter currently owns the middle of the screen (drives navigation).

@ProviderFor(activeSection)
const activeSectionProvider = ActiveSectionProvider._();

/// Which chapter currently owns the middle of the screen (drives navigation).

final class ActiveSectionProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Which chapter currently owns the middle of the screen (drives navigation).
  const ActiveSectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSectionHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeSection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeSectionHash() => r'4d92fdb817d4bd12825e9828653b28f31ee3d62e';

/// 0..1 progress of the whole journey.

@ProviderFor(scrollProgress)
const scrollProgressProvider = ScrollProgressProvider._();

/// 0..1 progress of the whole journey.

final class ScrollProgressProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// 0..1 progress of the whole journey.
  const ScrollProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scrollProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scrollProgressHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return scrollProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$scrollProgressHash() => r'e73fd6ea1eb024fa1e598f4c58d769363dfffe77';
