import 'package:flutter_test/flutter_test.dart';
import 'package:global_real/helpers/retry_helper.dart';

void main() {
  group('withRetry', () {
    test('retorna resultado na primeira tentativa se não falhar', () async {
      var callCount = 0;

      final result = await withRetry(
        () async {
          callCount++;
          return 42;
        },
        initialDelay: Duration.zero,
      );

      expect(result, 42);
      expect(callCount, 1);
    });

    test('faz retry e retorna resultado na segunda tentativa', () async {
      var callCount = 0;

      final result = await withRetry(
        () async {
          callCount++;
          if (callCount < 2) throw Exception('falha temporária');
          return 'sucesso';
        },
        maxAttempts: 3,
        initialDelay: Duration.zero,
      );

      expect(result, 'sucesso');
      expect(callCount, 2);
    });

    test('faz retry e retorna resultado na terceira tentativa', () async {
      var callCount = 0;

      final result = await withRetry(
        () async {
          callCount++;
          if (callCount < 3) throw Exception('falha');
          return 'ok';
        },
        maxAttempts: 3,
        initialDelay: Duration.zero,
      );

      expect(result, 'ok');
      expect(callCount, 3);
    });

    test('lança exceção após esgotar todas as tentativas', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw Exception('sempre falha');
          },
          maxAttempts: 3,
          initialDelay: Duration.zero,
        ),
        throwsException,
      );
    });

    test('respeita maxAttempts = 1 (sem retry)', () async {
      var callCount = 0;

      expect(
        () => withRetry(
          () async {
            callCount++;
            throw Exception('falha');
          },
          maxAttempts: 1,
          initialDelay: Duration.zero,
        ),
        throwsException,
      );

      // Aguarda a execução assíncrona
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callCount, 1);
    });

    test('funciona com tipos diferentes de retorno', () async {
      final listResult = await withRetry(
        () async => [1, 2, 3],
        initialDelay: Duration.zero,
      );
      expect(listResult, [1, 2, 3]);

      final mapResult = await withRetry(
        () async => {'key': 'value'},
        initialDelay: Duration.zero,
      );
      expect(mapResult, {'key': 'value'});

      final boolResult = await withRetry(
        () async => true,
        initialDelay: Duration.zero,
      );
      expect(boolResult, true);
    });

    test('funciona com Future<void>', () async {
      var executed = false;

      await withRetry(
        () async {
          executed = true;
        },
        initialDelay: Duration.zero,
      );

      expect(executed, true);
    });
  });
}
