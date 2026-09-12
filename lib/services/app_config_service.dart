import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lê configurações dinâmicas do app da tabela `app_config` do Supabase.
///
/// Permite alterar valores (ex.: link de agendamento) sem recompilar o app.
/// Basta atualizar a linha correspondente na tabela `app_config`.
class AppConfigService {
  static final _supabase = Supabase.instance.client;

  /// Chave do link de agendamento da videoconferência de qualificação.
  static const String keyAssociateSchedulingUrl = 'associate_scheduling_url';

  // Cache simples em memória para evitar buscas repetidas na mesma sessão.
  static final Map<String, String> _cache = {};

  /// Busca um valor de configuração pela chave.
  ///
  /// Retorna [fallback] se a chave não existir, estiver vazia ou ocorrer erro.
  static Future<String> getValue(String key, {String fallback = ''}) async {
    if (_cache.containsKey(key) && _cache[key]!.isNotEmpty) {
      return _cache[key]!;
    }
    try {
      final row = await _supabase
          .from('app_config')
          .select('value')
          .eq('key', key)
          .maybeSingle();

      final value = (row?['value'] as String?)?.trim() ?? '';
      if (value.isNotEmpty) {
        _cache[key] = value;
        return value;
      }
      return fallback;
    } catch (e) {
      debugPrint('❌ Erro ao ler app_config[$key]: $e');
      return fallback;
    }
  }

  /// Limpa o cache (útil se o valor for atualizado durante a sessão).
  static void clearCache() => _cache.clear();
}
