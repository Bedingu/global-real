import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/market_lead.dart';
import 'auth_service.dart';
import 'lead_scoring_service.dart';

class ChatService {
  static final _supabase = Supabase.instance.client;

  /// Buscar todos os leads ordenados por score da IA
  /// Master vê todos, assessor vê só os dele (RLS cuida disso)
  static Future<List<MarketLead>> fetchLeads({String? market}) async {
    var query = _supabase.from('market_leads').select();
    if (market != null) {
      query = query.eq('market', market);
    }
    final data = await query.order('ai_score', ascending: false);
    return (data as List).map((j) => MarketLead.fromJson(j)).toList();
  }

  /// Atribuir lead a um assessor
  static Future<void> assignLead(String leadId, String advisorId) async {
    await _supabase
        .from('market_leads')
        .update({'assigned_to': advisorId})
        .eq('id', leadId);
  }

  /// Buscar lista de assessores
  static Future<List<Map<String, dynamic>>> fetchAdvisors() async {
    final data = await _supabase
        .from('advisors_list')
        .select()
        .order('display_name');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Buscar mensagens de um lead
  static Future<List<ChatMessage>> fetchMessages(String leadId) async {
    final data = await _supabase
        .from('chat_messages')
        .select()
        .eq('lead_id', leadId)
        .order('created_at', ascending: true);
    return (data as List).map((j) => ChatMessage.fromJson(j)).toList();
  }

  /// Enviar mensagem como assessor
  static Future<void> sendMessage(String leadId, String message) async {
    final userId = AuthService.currentUserId() ?? 'unknown';
    await _supabase.from('chat_messages').insert({
      'lead_id': leadId,
      'sender_type': 'advisor',
      'sender_id': userId,
      'message': message,
    });
    // Registrar interação para scoring
    await LeadScoringService.trackEvent(leadId, LeadEvent.advisorContacted);
  }

  /// Atualizar status do lead
  static Future<void> updateLeadStatus(String leadId, String status) async {
    await _supabase
        .from('market_leads')
        .update({'status': status})
        .eq('id', leadId);
    // Registrar mudança de status para scoring
    if (status == 'qualified') {
      await LeadScoringService.trackEvent(leadId, LeadEvent.statusQualified);
    }
  }

  /// Escutar novas mensagens em tempo real
  static RealtimeChannel subscribeToMessages(
    String leadId,
    void Function(ChatMessage) onMessage,
  ) {
    return _supabase
        .channel('chat-$leadId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'lead_id',
            value: leadId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record != null) {
              onMessage(ChatMessage.fromJson(record));
            }
          },
        )
        .subscribe();
  }
}
