import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class _FakeYoutubeExplode extends YoutubeExplode {
  bool closed = false;

  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('returns highest bitrate url', () async {
    final service = YoutubeAudioService(YoutubeExplode(), fetcher: (id) async => [
      AudioInfo(128, Uri.parse('u1')),
      AudioInfo(256, Uri.parse('u2')),
    ]);

    final url = await service.getAudioUrl('abc');
    expect(url, 'u2');
  });

  test('throws when _AudioFetcher throws for invalid id', () async {
    final service = YoutubeAudioService(YoutubeExplode(), fetcher: (id) async {
      throw FormatException('invalid');
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

  test('close disposes YoutubeExplode client', () {
    final fake = _FakeYoutubeExplode();
    final service = YoutubeAudioService(fake, fetcher: (id) async => []);

    service.close();

    expect(fake.closed, isTrue);
  });
}
