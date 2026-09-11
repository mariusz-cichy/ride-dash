class IndoorBikeData {
  const IndoorBikeData({
    required this.flags,
    this.speedKmh,
    this.cadenceRpm,
    this.totalDistanceMeters,
    this.instantaneousPowerWatts,
    this.heartRateBpm,
  });

  final int flags;
  final double? speedKmh;
  final double? cadenceRpm;
  final int? totalDistanceMeters;
  final int? instantaneousPowerWatts;
  final int? heartRateBpm;
}

class FtmsPacketFormatException implements Exception {
  const FtmsPacketFormatException(this.message);

  final String message;

  @override
  String toString() => 'FtmsPacketFormatException: $message';
}

class FtmsIndoorBikeDataParser {
  const FtmsIndoorBikeDataParser();

  IndoorBikeData parse(List<int> bytes) {
    if (bytes.length < 2) {
      throw const FtmsPacketFormatException(
        'Indoor Bike Data packet must contain at least two flag bytes.',
      );
    }

    final flags = _uint16(bytes, 0);

    var offset = 2;
    double? speedKmh;
    double? cadenceRpm;
    int? totalDistanceMeters;
    int? instantaneousPowerWatts;
    int? heartRateBpm;

    // More Data is inverted: instantaneous speed is present when bit 0 is 0.
    if ((flags & 0x0001) == 0) {
      _require(bytes, offset, 2, 'instantaneous speed');
      speedKmh = _uint16(bytes, offset) / 100;
      offset += 2;
    }
    if ((flags & 0x0002) != 0) {
      _require(bytes, offset, 2, 'average speed');
      offset += 2;
    }
    if ((flags & 0x0004) != 0) {
      _require(bytes, offset, 2, 'instantaneous cadence');
      cadenceRpm = _uint16(bytes, offset) / 2;
      offset += 2;
    }
    if ((flags & 0x0008) != 0) {
      _require(bytes, offset, 2, 'average cadence');
      offset += 2;
    }
    if ((flags & 0x0010) != 0) {
      _require(bytes, offset, 3, 'total distance');
      totalDistanceMeters = _uint24(bytes, offset);
      offset += 3;
    }
    if ((flags & 0x0020) != 0) {
      _require(bytes, offset, 2, 'resistance level');
      offset += 2;
    }
    if ((flags & 0x0040) != 0) {
      _require(bytes, offset, 2, 'instantaneous power');
      instantaneousPowerWatts = _sint16(bytes, offset);
      offset += 2;
    }
    if ((flags & 0x0080) != 0) {
      _require(bytes, offset, 2, 'average power');
      offset += 2;
    }
    if ((flags & 0x0100) != 0) {
      _require(bytes, offset, 7, 'expended energy');
      offset += 7;
    }
    if ((flags & 0x0200) != 0) {
      _require(bytes, offset, 1, 'heart rate');
      heartRateBpm = bytes[offset];
      offset += 1;
    }
    if ((flags & 0x0400) != 0) {
      _require(bytes, offset, 1, 'metabolic equivalent');
      offset += 1;
    }
    if ((flags & 0x0800) != 0) {
      _require(bytes, offset, 2, 'elapsed time');
      offset += 2;
    }
    if ((flags & 0x1000) != 0) {
      _require(bytes, offset, 2, 'remaining time');
    }

    return IndoorBikeData(
      flags: flags,
      speedKmh: speedKmh,
      cadenceRpm: cadenceRpm,
      totalDistanceMeters: totalDistanceMeters,
      instantaneousPowerWatts: instantaneousPowerWatts,
      heartRateBpm: heartRateBpm,
    );
  }

  int _uint16(List<int> bytes, int offset) =>
      bytes[offset] | (bytes[offset + 1] << 8);

  int _sint16(List<int> bytes, int offset) {
    final value = _uint16(bytes, offset);
    return value >= 0x8000 ? value - 0x10000 : value;
  }

  int _uint24(List<int> bytes, int offset) =>
      bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);

  void _require(List<int> bytes, int offset, int length, String field) {
    if (offset + length > bytes.length) {
      throw FtmsPacketFormatException(
        'Packet ended while reading $field at byte offset $offset.',
      );
    }
  }
}
