// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_fillout/otel_fillout.dart';
import 'package:test/test.dart';

void main() {
  group('otel_fillout', () {
    test('suppression toggles in zone', () async {
      expect(filloutInstrumentationSuppressed(), isFalse);
      await runWithoutFilloutInstrumentationAsync(() async {
        expect(filloutInstrumentationSuppressed(), isTrue);
      });
      expect(filloutInstrumentationSuppressed(), isFalse);
    });

    test('FilloutResult fields default null', () {
      const r = FilloutResult();
      expect(r.statusCode, isNull);
    });
  });
}
