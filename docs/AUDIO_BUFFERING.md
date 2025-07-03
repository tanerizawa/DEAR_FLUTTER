# Android Audio Buffering

This document explains the buffering messages printed by Android when playing audio and how `just_audio` configures ExoPlayer.

## CCodecConfig and CCodecBufferChannel

`CCodecConfig` and `CCodecBufferChannel` messages originate from Android's `MediaCodec` stack. They appear in `adb logcat` when a codec is created or buffers are queued.

- **`CCodecConfig`** – describes the codec parameters such as sample rate and channel count. It is logged during decoder setup and is informational rather than an error.
- **`CCodecBufferChannel`** – indicates input or output buffer activity. These logs typically show buffer sizes or that the decoder is ready. They are normally harmless and can be ignored unless accompanied by an error.

## just_audio and ExoPlayer

On Android, the `just_audio` package wraps ExoPlayer. ExoPlayer allocates memory for decoding and buffering audio streams. With default settings the player keeps roughly 15–50 seconds of audio data in memory using a few megabytes per instance. Only the buffered region is stored; the remainder of the track is streamed from the network or file system on demand.

## Adjusting buffer sizes

Buffering parameters can be tuned when constructing the `AudioPlayer`:

```dart
final player = AudioPlayer(
  audioLoadConfiguration: AudioLoadConfiguration(
    androidLoadControl: AndroidLoadControl(
      minBufferDuration: const Duration(seconds: 10),
      maxBufferDuration: const Duration(seconds: 60),
      bufferForPlaybackDuration: const Duration(seconds: 1),
      bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 5),
    ),
  ),
);
```

You may also implement your own `AndroidLoadControl` to override ExoPlayer's `DefaultLoadControl` and specify a `targetBufferBytes` value. Increasing these values increases memory usage but can reduce stalling on slower connections.

The same configuration can be supplied when creating `AudioPlayerHandler` so the underlying player uses those buffer sizes:

```dart
final handler = AudioPlayerHandler(
  youtubeService,
  loadConfiguration: AudioLoadConfiguration(
    androidLoadControl: AndroidLoadControl(
      minBufferDuration: const Duration(seconds: 10),
      maxBufferDuration: const Duration(seconds: 60),
      bufferForPlaybackDuration: const Duration(seconds: 1),
      bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 5),
    ),
  ),
);
```
