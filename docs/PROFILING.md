# Profiling Audit

This document summarizes the audit of API calls and audio decoding tasks throughout the Flutter frontend and backend services. The goal is to ensure that no heavy work is executed directly inside `build()` or `initState()` methods.

## Methodology

- Searched the `lib/` directory for network requests, audio decoding and CPU intensive loops.
- Inspected widgets for `initState()` or `build()` implementations performing heavy work.
- Verified services responsible for audio playback and data fetching use asynchronous `Future` APIs.

## Findings

- All API interactions are encapsulated in Cubits or service classes and triggered asynchronously via `Future` methods. Widgets themselves only await lightweight calls.
- The audio player uses `audio_service` and `just_audio` which internally decode streams asynchronously. The `AudioPlayerScreen` does not decode audio in `build()` or `initState()`.
- The `YoutubeAudioService` resolves stream URLs using asynchronous calls to `YoutubeExplode`. No synchronous parsing or heavy computation was found in the UI layer.
- No calls to `compute()` or isolates were necessary given the absence of blocking operations in the UI thread.

## Recommendations

- Continue using `Future` based APIs for network and audio tasks. If future features introduce CPU heavy processing (e.g. waveform analysis), wrap it in `compute()` or a dedicated isolate.
- Profile new features using `flutter run --profile` to ensure frame times remain under 16ms on target devices.

