import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo/main.dart';

void main() {
  group('scheduleHasPassed', () {
    final now = DateTime(2026, 11, 6, 13, 30);

    test('rejects a schedule on a previous date', () {
      expect(
        scheduleHasPassed(
          DateTime(2026, 11, 5),
          const TimeOfDay(hour: 23, minute: 59),
          now,
        ),
        isTrue,
      );
    });

    test('rejects a schedule earlier today', () {
      expect(
        scheduleHasPassed(
          DateTime(2026, 11, 6),
          const TimeOfDay(hour: 13, minute: 29),
          now,
        ),
        isTrue,
      );
    });

    test('allows a schedule later today', () {
      expect(
        scheduleHasPassed(
          DateTime(2026, 11, 6),
          const TimeOfDay(hour: 13, minute: 31),
          now,
        ),
        isFalse,
      );
    });

    test('allows a schedule on a future date', () {
      expect(
        scheduleHasPassed(
          DateTime(2026, 11, 7),
          const TimeOfDay(hour: 9, minute: 0),
          now,
        ),
        isFalse,
      );
    });
  });
}
