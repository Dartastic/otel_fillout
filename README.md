# otel_fillout

Dartastic OpenTelemetry bridge for Fillout (forms + workflows).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_fillout/otel_fillout.dart';

await tracedFillout<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return FilloutCallResult(value: r, result: FilloutResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutFilloutInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
