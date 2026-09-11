import 'package:flutter_test/flutter_test.dart';
import 'package:ride_dash/bluetooth/ftms_indoor_bike_data.dart';

void main() {
  const parser = FtmsIndoorBikeDataParser();

  group('Schwinn IC8 Indoor Bike Data', () {
    test('parses real packet vector 1', () {
      final data = parser.parse([
        0x44,
        0x02,
        0x1E,
        0x0A,
        0x6E,
        0x00,
        0x5A,
        0x00,
        0x00,
      ]);

      expect(data.flags, 0x0244);
      expect(data.speedKmh, 25.90);
      expect(data.cadenceRpm, 55.0);
      expect(data.instantaneousPowerWatts, 90);
      expect(data.heartRateBpm, 0);
      expect(data.totalDistanceMeters, isNull);
    });

    test('parses real packet vector 2', () {
      final data = parser.parse([
        0x44,
        0x02,
        0xF0,
        0x0A,
        0x78,
        0x00,
        0x6E,
        0x00,
        0x00,
      ]);

      expect(data.speedKmh, 28.00);
      expect(data.cadenceRpm, 60.0);
      expect(data.instantaneousPowerWatts, 110);
      expect(data.heartRateBpm, 0);
      expect(data.totalDistanceMeters, isNull);
    });

    test('parses real packet vector 3', () {
      final data = parser.parse([
        0x44,
        0x02,
        0x86,
        0x0B,
        0x82,
        0x00,
        0x7E,
        0x00,
        0x00,
      ]);

      expect(data.speedKmh, 29.50);
      expect(data.cadenceRpm, 65.0);
      expect(data.instantaneousPowerWatts, 126);
      expect(data.heartRateBpm, 0);
      expect(data.totalDistanceMeters, isNull);
    });

    test('parses real packet vector 4', () {
      final data = parser.parse([
        0x44,
        0x02,
        0xC6,
        0x07,
        0x46,
        0x00,
        0x2F,
        0x00,
        0x00,
      ]);

      expect(data.speedKmh, 19.90);
      expect(data.cadenceRpm, 35.0);
      expect(data.instantaneousPowerWatts, 47);
      expect(data.heartRateBpm, 0);
      expect(data.totalDistanceMeters, isNull);
    });
  });

  test('decodes standard little-endian UInt16 speed and cadence', () {
    final data = parser.parse([0x00, 0x00, 0x1E, 0x0A]);
    expect(data.speedKmh, 25.90);

    final cadence = parser.parse([0x05, 0x00, 0x6E, 0x00]);
    expect(cadence.speedKmh, isNull);
    expect(cadence.cadenceRpm, 55.0);
  });

  test('decodes standard little-endian UInt24 distance', () {
    final data = parser.parse([0x11, 0x00, 0x5A, 0x00, 0x00]);
    expect(data.speedKmh, isNull);
    expect(data.totalDistanceMeters, 90);
  });

  test('decodes signed instantaneous power and heart rate', () {
    final data = parser.parse([
      0x44,
      0x02,
      0x1E,
      0x0A,
      0x6E,
      0x00,
      0x9C,
      0xFF,
      0x48,
    ]);

    expect(data.instantaneousPowerWatts, -100);
    expect(data.heartRateBpm, 72);
  });

  test('represents missing cadence and distance as null', () {
    final data = parser.parse([0x00, 0x00, 0x1E, 0x0A]);
    expect(data.cadenceRpm, isNull);
    expect(data.totalDistanceMeters, isNull);
  });

  test('represents missing speed when More Data is set', () {
    final data = parser.parse([0x01, 0x00]);
    expect(data.speedKmh, isNull);
  });

  test('rejects a packet shorter than the flags', () {
    expect(
      () => parser.parse([0x00]),
      throwsA(isA<FtmsPacketFormatException>()),
    );
  });

  test('rejects a packet truncated during a flagged field', () {
    expect(
      () => parser.parse([0x10, 0x00, 0x5A, 0x00]),
      throwsA(isA<FtmsPacketFormatException>()),
    );
  });

  test('ignores unknown flags without crashing', () {
    final data = parser.parse([0x01, 0x80]);
    expect(data.flags, 0x8001);
    expect(data.speedKmh, isNull);
  });
}
