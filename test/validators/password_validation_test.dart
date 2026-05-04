import 'package:flutter_test/flutter_test.dart';

/// Replica a lógica de validação de senha do signup_page.dart
/// pra garantir que as regras estão corretas.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Informe sua senha';
  if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Inclua pelo menos uma letra maiúscula';
  if (!RegExp(r'[0-9]').hasMatch(value)) return 'Inclua pelo menos um número';
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Informe seu e-mail';
  if (!value.contains('@')) return 'E-mail inválido';
  return null;
}

void main() {
  group('Validação de senha', () {
    test('rejeita senha vazia', () {
      expect(validatePassword(''), isNotNull);
      expect(validatePassword(null), isNotNull);
    });

    test('rejeita senha com menos de 8 caracteres', () {
      expect(validatePassword('Abc1'), isNotNull);
      expect(validatePassword('Ab1'), isNotNull);
      expect(validatePassword('Abcdef1'), isNotNull); // 7 chars
    });

    test('rejeita senha sem letra maiúscula', () {
      expect(validatePassword('abcdefg1'), isNotNull);
      expect(validatePassword('12345678'), isNotNull);
    });

    test('rejeita senha sem número', () {
      expect(validatePassword('Abcdefgh'), isNotNull);
      expect(validatePassword('ABCDEFGH'), isNotNull);
    });

    test('aceita senha válida', () {
      expect(validatePassword('Abcdefg1'), isNull);
      expect(validatePassword('MinhaSenh4'), isNull);
      expect(validatePassword('Global2024'), isNull);
      expect(validatePassword('T3steForte'), isNull);
    });

    test('aceita senha com caracteres especiais', () {
      expect(validatePassword('Abc@1234'), isNull);
      expect(validatePassword('S3nha!Forte'), isNull);
    });

    test('aceita senha longa', () {
      expect(validatePassword('UmaSenhaM1uitoLongaQueDeveSerAceita'), isNull);
    });
  });

  group('Validação de email', () {
    test('rejeita email vazio', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
    });

    test('rejeita email sem @', () {
      expect(validateEmail('usuario.com'), isNotNull);
      expect(validateEmail('teste'), isNotNull);
    });

    test('aceita email válido', () {
      expect(validateEmail('user@email.com'), isNull);
      expect(validateEmail('test@test.co'), isNull);
      expect(validateEmail('a@b.c'), isNull);
    });
  });
}
