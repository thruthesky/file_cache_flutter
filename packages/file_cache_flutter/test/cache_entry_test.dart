import 'package:flutter_test/flutter_test.dart';
import 'package:file_cache_flutter/file_cache_flutter.dart';

void main() {
  group('CacheEntry', () {
    test('should create CacheEntry with correct properties', () {
      // given
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 30));

      // when
      final entry = CacheEntry<String>(
        data: 'test data',
        expiresAt: expiresAt,
        createdAt: now,
      );

      // then
      expect(entry.data, 'test data');
      expect(entry.expiresAt, expiresAt);
      expect(entry.createdAt, now);
    });

    test('isExpired should return false for non-expired entry', () {
      // given
      final entry = CacheEntry<String>(
        data: 'test',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        createdAt: DateTime.now(),
      );

      // then
      expect(entry.isExpired, false);
    });

    test('isExpired should return true for expired entry', () {
      // given
      final entry = CacheEntry<String>(
        data: 'test',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      // then
      expect(entry.isExpired, true);
    });

    test('remainingTime should return positive duration for non-expired entry',
        () {
      // given
      final entry = CacheEntry<String>(
        data: 'test',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        createdAt: DateTime.now(),
      );

      // then
      expect(entry.remainingTime.inMinutes, greaterThanOrEqualTo(29));
      expect(entry.remainingTime.inMinutes, lessThanOrEqualTo(30));
    });

    test('remainingTime should return Duration.zero for expired entry', () {
      // given
      final entry = CacheEntry<String>(
        data: 'test',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      // then
      expect(entry.remainingTime, Duration.zero);
    });

    test('toJson should correctly serialize the entry', () {
      // given
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final expiresAt = DateTime(2024, 1, 1, 12, 30, 0);
      final entry = CacheEntry<Map<String, dynamic>>(
        data: {'name': 'test', 'value': 123},
        expiresAt: expiresAt,
        createdAt: now,
      );

      // when
      final json = entry.toJson((data) => data);

      // then
      expect(json['data'], {'name': 'test', 'value': 123});
      expect(json['expiresAt'], expiresAt.toIso8601String());
      expect(json['createdAt'], now.toIso8601String());
    });

    test('fromJson should correctly deserialize the entry', () {
      // given
      final json = {
        'data': {'name': 'test', 'value': 123},
        'expiresAt': '2024-01-01T12:30:00.000',
        'createdAt': '2024-01-01T12:00:00.000',
      };

      // when
      final entry = CacheEntry<Map<String, dynamic>>.fromJson(
        json,
        (json) => json,
      );

      // then
      expect(entry.data, {'name': 'test', 'value': 123});
      expect(entry.expiresAt, DateTime(2024, 1, 1, 12, 30, 0));
      expect(entry.createdAt, DateTime(2024, 1, 1, 12, 0, 0));
    });

    test('toString should return correct format', () {
      // given
      final expiresAt = DateTime(2024, 1, 1, 12, 30, 0);
      final entry = CacheEntry<String>(
        data: 'test',
        expiresAt: expiresAt,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      // then
      expect(entry.toString(), contains('CacheEntry<String>'));
      expect(entry.toString(), contains('expiresAt:'));
      expect(entry.toString(), contains('isExpired:'));
    });

    test('should work with custom data types', () {
      // given
      final entry = CacheEntry<List<int>>(
        data: [1, 2, 3, 4, 5],
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        createdAt: DateTime.now(),
      );

      // then
      expect(entry.data, [1, 2, 3, 4, 5]);
      expect(entry.isExpired, false);
    });
  });
}
