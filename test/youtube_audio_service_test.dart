import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('returns highest bitrate url', () async {
    final service = YoutubeAudioService(fetcher: (id) async => [
      AudioInfo(128, Uri.parse('u1')),
      AudioInfo(256, Uri.parse('u2')),
    ]);

    final url = await service.getAudioUrl('abc');
    expect(url, 'u2');
  });
}
