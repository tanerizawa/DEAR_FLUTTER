import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http_parser/http_parser.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class _FakeYoutubeExplode extends YoutubeExplode {
  bool closed = false;

  @override
  void close() {
    closed = true;
    super.close();
  }
}

class _MockYoutubeExplode extends Mock implements YoutubeExplode {}

class _MockVideoClient extends Mock implements VideoClient {}

class _MockStreamClient extends Mock implements StreamClient {}

class _FakeAudioOnlyStreamInfo implements AudioOnlyStreamInfo {
  @override
  final VideoId videoId;

  @override
  final int tag;

  @override
  final Uri url;

  @override
  final StreamContainer container;

  @override
  final FileSize size;

  @override
  final Bitrate bitrate;

  @override
  final String audioCodec;

  @override
  final MediaType codec;

  @override
  final List<Fragment> fragments;

  @override
  final String qualityLabel;

  @override
  final AudioTrack? audioTrack;

  _FakeAudioOnlyStreamInfo({
    required this.videoId,
    required this.tag,
    required this.url,
    required this.bitrate,
    this.container = StreamContainer.mp4,
    this.size = const FileSize(0),
    this.audioCodec = 'aac',
    this.qualityLabel = '',
    this.fragments = const [],
    this.codec = const MediaType('audio', 'mp4'),
    this.audioTrack,
  });

  @override
  bool get isThrottled => false;

  @override
  Map<String, dynamic> toJson() => {};

  @override
  String toString() => 'FakeAudio($tag, ${bitrate.kiloBitsPerSecond})';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('returns best medium bitrate url', () async {
    final service = YoutubeAudioService(YoutubeExplode(), fetcher: (id) async => [
      AudioInfo(128, Uri.parse('u1')),
      AudioInfo(256, Uri.parse('u2')),
    ]);

    final url = await service.getAudioUrl('abc');
    expect(url, 'u1');
  });

  test('throws when _AudioFetcher throws for invalid id', () async {
    final service = YoutubeAudioService(YoutubeExplode(), fetcher: (id) async {
      throw const FormatException('invalid');
    });

    expect(
      () => service.getAudioUrl('bad'),
      throwsA(isA<FormatException>()),
    );
  });

  test('throws when _AudioFetcher fails with network error', () async {
    final service = YoutubeAudioService(YoutubeExplode(), fetcher: (id) async {
      throw Exception('network');
    });

    expect(
      () => service.getAudioUrl('abc'),
      throwsA(isA<Exception>()),
    );
  });

  test('throws when no audio streams are available', () async {
    final service = YoutubeAudioService(YoutubeExplode(), fetcher: (id) async => []);

    expect(
      () => service.getAudioUrl('abc'),
      throwsA(isA<StateError>()),
    );
  });

  test('close disposes YoutubeExplode client', () {
    final fake = _FakeYoutubeExplode();
    final service = YoutubeAudioService(fake, fetcher: (id) async => []);

    service.close();

    expect(fake.closed, isTrue);
  });

  group('_fetch fallback', () {
    late _MockYoutubeExplode yt;
    late _MockVideoClient videos;
    late _MockStreamClient streams;

    setUp(() {
      yt = _MockYoutubeExplode();
      videos = _MockVideoClient();
      streams = _MockStreamClient();
      when(() => yt.videos).thenReturn(videos);
      when(() => videos.streamsClient).thenReturn(streams);
    });

    test('prefers itag 140 when available', () async {
      final manifest = StreamManifest([
        _FakeAudioOnlyStreamInfo(
          videoId: VideoId('id'),
          tag: 140,
          url: Uri.parse('u140'),
          bitrate: const Bitrate(128000),
        ),
        _FakeAudioOnlyStreamInfo(
          videoId: VideoId('id'),
          tag: 141,
          url: Uri.parse('u141'),
          bitrate: const Bitrate(150000),
        ),
      ]);
      when(() => streams.getManifest(any())).thenAnswer((_) async => manifest);

      final service = YoutubeAudioService(yt);
      final url = await service.getAudioUrl('id');

      expect(url, 'u140');
    });

    test('falls back to highest bitrate below max', () async {
      final manifest = StreamManifest([
        _FakeAudioOnlyStreamInfo(
          videoId: VideoId('id'),
          tag: 141,
          url: Uri.parse('u150'),
          bitrate: const Bitrate(150000),
        ),
        _FakeAudioOnlyStreamInfo(
          videoId: VideoId('id'),
          tag: 142,
          url: Uri.parse('u200'),
          bitrate: const Bitrate(200000),
        ),
      ]);
      when(() => streams.getManifest(any())).thenAnswer((_) async => manifest);

      final service = YoutubeAudioService(yt);
      final url = await service.getAudioUrl('id');

      expect(url, 'u150');
    });

    test('returns lowest bitrate when none under max', () async {
      final manifest = StreamManifest([
        _FakeAudioOnlyStreamInfo(
          videoId: VideoId('id'),
          tag: 141,
          url: Uri.parse('u170'),
          bitrate: const Bitrate(170000),
        ),
        _FakeAudioOnlyStreamInfo(
          videoId: VideoId('id'),
          tag: 142,
          url: Uri.parse('u200'),
          bitrate: const Bitrate(200000),
        ),
      ]);
      when(() => streams.getManifest(any())).thenAnswer((_) async => manifest);

      final service = YoutubeAudioService(yt);

      expect(
        () => service.getAudioUrl('id'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
