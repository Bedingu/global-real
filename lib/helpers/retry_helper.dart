import 'dart:async';
import 'package:flutter/foundation.dart';

/// Executa [fn] com retry automático em caso de falha.
/// - [maxAttempts]: número máximo de tentativas (padrão: 3)
/// - [initialDelay]: delay antes do primeiro retry (padrão: 500ms)
/// - [backoffMultiplier]: multiplicador do delay a cada retry (padrão: 2x)
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
  double backoffMultiplier = 2.0,
}) async {
  var delay = initialDelay;

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (attempt == maxAttempts) {
        debugPrint('❌ Falha após $maxAttempts tentativas: $e');
        rethrow;
      }
      debugPrint('⚠️ Tentativa $attempt/$maxAttempts falhou, retry em ${delay.inMilliseconds}ms...');
      await Future.delayed(delay);
      delay = Duration(
        milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
      );
    }
  }

  // Nunca chega aqui, mas o compilador exige
  throw StateError('Unreachable');
}
