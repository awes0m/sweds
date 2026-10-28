# Eternal — cinematic wedding experience (Flutter Web)

## Run
```bash
flutter create . --platforms web          # adds web/ (keeps lib/)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # riverpod + freezed + json
flutter run -d chrome
flutter build web --release               # CanvasKit/Skwasm: required for fragment shaders
```
Edit all content in `lib/core/constants/wedding_config.dart`.

## How the engine works
- `ScrollEngine` (core/scroll) owns the only ScrollController: eased wheel glide, keyboard, touch passthrough, section jumps.
- `sceneViewport → sectionLayouts → scrollOffset → sectionProgress(i)` (shared/providers/scene_providers.dart). Progress is clamped, so off-screen chapters stop rebuilding.
- `SceneSection` pins a viewport-sized "stage" for chapters with `pinned: true`; the builder receives scrubbed progress `p`.
- Every chapter derives depth (`depthMatrix`), blur and opacity from `p`; the fixed `AtmosphereBackground` (GLSL fog/bloom + motes) shifts palette with total progress.
- Deep links: `/?s=venue`. Gallery and RSVP are deferred-loaded.

## Assets
Drop JPGs into `assets/images/` (missing ones render painted placeholders):
`story_1..4`, `venue`, `gallery_1..6` (≈1600px wide, 80% quality, WebP also fine if you change the extension in `art_image.dart`).
Ambient audio: implement `AmbientAudioService` (see comment in shared/services/audio_service.dart).
