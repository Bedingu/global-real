import 'package:supabase_flutter/supabase_flutter.dart';

/// Tipos de evento para Lead Scoring
class LeadEvent {
  static const signup = 'signup';
  static const login = 'login';
  static const viewDevelopment = 'view_development';
  static const favoriteDevelopment = 'favorite_development';
  static const viewInvestment = 'view_investment';
  static const useCalculator = 'use_calculator';
  static const clickWhatsapp = 'click_whatsapp';
  static const replyChat = 'reply_chat';
  static const returnVisit = 'return_visit';
  static const shareContent = 'share_content';
  static const watchVideo = 'watch_video';
  static const downloadMaterial = 'download_material';
  static const requestContact = 'request_contact';
  static const advisorContacted = 'advisor_contacted';
  static const statusQualified = 'status_qualified';
}

class LeadScoringService {
  static final _supabase = Supabase.instance.client;

  /// Cache local das regras de pontuação
  static Map<String, int> _rulesCache = {};

  /// Carregar regras de pontuação do banco
  static Future<void> loadRules() async {
    try {
      final data = await _supabase.from('scoring_rules').select();
      _rulesCache = {
        for (final r in data) r['event_type'] as String: r['points'] as int,
      };
    } catch (_) {
      // Fallback com valores padrão
      _rulesCache = {
        LeadEvent.signup: 10,
        LeadEvent.login: 2,
        LeadEvent.viewDevelopment: 5,
        LeadEvent.favoriteDevelopment: 8,
        LeadEvent.viewInvestment: 10,
        LeadEvent.useCalculator: 12,
        LeadEvent.clickWhatsapp: 7,
        LeadEvent.replyChat: 15,
        LeadEvent.returnVisit: 4,
        LeadEvent.requestContact: 20,
        LeadEvent.advisorContacted: 5,
      };
    }
  }

  /// Registrar uma interação do lead
  static Future<void> trackEvent(
    String leadId,
    String eventType, {
    Map<String, dynamic>? eventData,
  }) async {
    if (_rulesCache.isEmpty) await loadRules();

    final points = _rulesCache[eventType] ?? 0;

    try {
      await _supabase.from('lead_interactions').insert({
        'lead_id': leadId,
        'event_type': eventType,
        'event_data': eventData ?? {},
        'points': points,
      });
    } catch (_) {
      // Silencioso — não bloquear a UX por falha de tracking
    }
  }

  /// Buscar histórico de interações de um lead
  static Future<List<Map<String, dynamic>>> fetchInteractions(String leadId) async {
    final data = await _supabase
        .from('lead_interactions')
        .select()
        .eq('lead_id', leadId)
        .order('created_at', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Buscar resumo de pontuação por tipo de evento
  static Future<Map<String, int>> fetchScoreSummary(String leadId) async {
    final interactions = await fetchInteractions(leadId);
    final summary = <String, int>{};
    for (final i in interactions) {
      final type = i['event_type'] as String;
      final pts = i['points'] as int? ?? 0;
      summary[type] = (summary[type] ?? 0) + pts;
    }
    return summary;
  }
}
