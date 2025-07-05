// test/enhanced_radio_cubit_test.dart

import 'package:dear_flutter/domain/entities/radio_station.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadioCategory', () {
    test('should have correct category properties', () {
      expect(RadioCategory.santai.id, 'santai');
      expect(RadioCategory.santai.displayName, 'Santai');
      expect(RadioCategory.santai.emoji, '🌙');
      expect(RadioCategory.santai.description, 'Musik untuk bersantai dan relax');

      expect(RadioCategory.energik.id, 'energik');
      expect(RadioCategory.energik.displayName, 'Energik');
      expect(RadioCategory.energik.emoji, '⚡');

      expect(RadioCategory.fokus.id, 'fokus');
      expect(RadioCategory.fokus.displayName, 'Fokus');
      expect(RadioCategory.fokus.emoji, '🎯');
    });

    test('should have all required categories', () {
      const expectedCategories = [
        'santai', 'energik', 'fokus', 'bahagia', 'sedih', 'romantis',
        'nostalgia', 'instrumental', 'jazz', 'rock', 'pop', 'electronic'
      ];
      
      final actualCategories = RadioCategory.values.map((c) => c.id).toList();
      
      for (final category in expectedCategories) {
        expect(actualCategories.contains(category), true, 
               reason: 'Category $category should exist');
      }
    });
  });

  group('RadioStation', () {
    test('should create radio station with required fields', () {
      const station = RadioStation(
        id: 'test_station',
        name: 'Test Radio Station',
        category: 'test',
        description: 'Test description',
      );

      expect(station.id, 'test_station');
      expect(station.name, 'Test Radio Station');
      expect(station.category, 'test');
      expect(station.description, 'Test description');
      expect(station.isLive, false); // default value
      expect(station.isPremium, false); // default value
      expect(station.listeners, 0); // default value
      expect(station.tags, isEmpty); // default value
      expect(station.playlist, isEmpty); // default value
    });

    test('should create radio station with all fields', () {
      const station = RadioStation(
        id: 'premium_station',
        name: 'Premium Radio Station',
        category: 'jazz',
        description: 'Premium jazz station',
        imageUrl: 'https://example.com/image.jpg',
        color: '#1DB954',
        tags: ['jazz', 'smooth', 'relaxing'],
        listeners: 150,
        isLive: true,
        isPremium: true,
        streamUrl: 'https://example.com/stream',
      );

      expect(station.id, 'premium_station');
      expect(station.name, 'Premium Radio Station');
      expect(station.category, 'jazz');
      expect(station.description, 'Premium jazz station');
      expect(station.imageUrl, 'https://example.com/image.jpg');
      expect(station.color, '#1DB954');
      expect(station.tags, ['jazz', 'smooth', 'relaxing']);
      expect(station.listeners, 150);
      expect(station.isLive, true);
      expect(station.isPremium, true);
      expect(station.streamUrl, 'https://example.com/stream');
    });
  });
}
