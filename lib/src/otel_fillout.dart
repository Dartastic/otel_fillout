// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_fillout_suppression.dart';

class FilloutResult {
  const FilloutResult({
    this.workspaceId,
    this.formId,
    this.formName,
    this.submissionId,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? workspaceId;
  final String? formId;
  final String? formName;
  final String? submissionId;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class FilloutCallResult<T> {
  const FilloutCallResult({required this.value, this.result});
  final T value;
  final FilloutResult? result;
}

Future<T> tracedFillout<T>({
  required String operation,
  required Future<FilloutCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (filloutInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_fillout');
  final span = t.startSpan('fillout $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'fillout');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.workspaceId != null) {
        span.setStringAttribute('fillout.workspace.id', res.workspaceId!);
      }
      if (res.formId != null) {
        span.setStringAttribute('fillout.form.id', res.formId!);
      }
      if (res.formName != null) {
        span.setStringAttribute('fillout.form.name', res.formName!);
      }
      if (res.submissionId != null) {
        span.setStringAttribute('fillout.submission.id', res.submissionId!);
      }
      if (res.status != null) {
        span.setStringAttribute('fillout.submission.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('fillout.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'fillout.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
