// lib/domain/entities/radio_station.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

part 'radio_station.freezed.dart';
part 'radio_station.g.dart';

@freezed
class RadioStation with _$RadioStation {
  const factory RadioStation({
    required String id,
    required String name,
    required String category,
    required String description,
    String? imageUrl,
    String? color, // Hex color for theming
    @Default([]) List<String> tags,
    @Default([]) List<AudioTrack> playlist,
    @Default(0) int listeners,
    @Default(false) bool isLive,
    @Default(false) bool isPremium,
    String? streamUrl, // For live streams
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _RadioStation;

  factory RadioStation.fromJson(Map<String, dynamic> json) =>
      _$RadioStationFromJson(json);
}

// Predefined radio station categories
enum RadioCategory {
  santai('santai', 'Santai', '🌙', 'Musik untuk bersantai dan relax'),
  energik('energik', 'Energik', '⚡', 'Musik yang membangkitkan semangat'),
  fokus('fokus', 'Fokus', '🎯', 'Musik untuk konsentrasi dan bekerja'),
  bahagia('bahagia', 'Bahagia', '😊', 'Musik yang menggembirakan hati'),
  sedih('sedih', 'Melankolis', '🌧️', 'Musik untuk saat sedih dan galau'),
  romantis('romantis', 'Romantis', '💕', 'Musik cinta dan romantis'),
  nostalgia('nostalgia', 'Nostalgia', '🎵', 'Musik kenangan dan klasik'),
  instrumental('instrumental', 'Instrumental', '🎼', 'Musik tanpa vokal'),
  jazz('jazz', 'Jazz', '🎷', 'Musik jazz dan smooth'),
  rock('rock', 'Rock', '🎸', 'Musik rock dan alternatif'),
  pop('pop', 'Pop', '🎤', 'Musik pop mainstream'),
  electronic('electronic', 'Electronic', '🎧', 'Musik elektronik dan dance');

  const RadioCategory(this.id, this.displayName, this.emoji, this.description);
  
  final String id;
  final String displayName;
  final String emoji;
  final String description;
}
