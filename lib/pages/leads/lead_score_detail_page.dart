import 'package:flutter/material.dart';
import '../../models/market_lead.dart';
import '../../services/lead_scoring_service.dart';
import '../../theme.dart';

class LeadScoreDetailPage extends StatefulWidget {
  final MarketLead lead;
  const LeadScoreDetailPage({super.key, required this.lead});

  @override
  State<LeadScoreDetailPage> createState() => _LeadScoreDetailPageState();
}

class _LeadScoreDetailPageState extends State<LeadScoreDetailPage> {
  Map<String, int> _summary = {};
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await LeadScoringService.fetchScoreSummary(widget.lead.id);
    final history = await LeadScoringService.fetchInteractions(widget.lead.id);
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _history = history;
      _loading = false;
    });
  }

  static const _eventLabels = {
    'signup': '📝 Cadastro',
    'login': '🔑 Login',
    'view_development': '🏠 Viu empreendimento',
    'favorite_development': '⭐ Favoritou empreendimento',
    'view_investment': '💰 Viu investimento',
    'use_calculator': '🧮 Usou calculadora',
    'click_whatsapp': '💬 WhatsApp',
    'reply_chat': '💬 Respondeu no chat',
    'return_visit': '🔄 Retornou ao app',
    'share_content': '📤 Compartilhou',
    'watch_video': '🎬 Assistiu vídeo',
    'download_material': '📥 Baixou material',
    'request_contact': '📞 Solicitou contato',
    'advisor_contacted': '👤 Assessor contatou',
    'status_qualified': '✅ Qualificado',
  };

  Color _scoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final color = _scoreColor(lead.aiScore);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Score: ${lead.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Score card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: lead.aiScore / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${lead.aiScore}',
                                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
                                ),
                                Text('/ 100', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _scoreLabel(lead.aiScore),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
                        ),
                        if (lead.aiSummary.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            lead.aiSummary,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // AI Recommendations
                if (lead.aiRecommendations.isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.recommend, size: 18, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Produtos recomendados pela IA',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...lead.aiRecommendations.map((rec) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${rec['match_score'] ?? 0}%',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        rec['reason'] ?? '',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Breakdown por tipo
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pontuação por atividade',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        if (_summary.isEmpty)
                          Text('Nenhuma interação registrada', style: TextStyle(color: Colors.grey[500], fontSize: 13))
                        else
                          ..._summary.entries.map((e) => _scoreRow(e.key, e.value)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Histórico
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Histórico de interações',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        if (_history.isEmpty)
                          Text('Nenhuma interação ainda', style: TextStyle(color: Colors.grey[500], fontSize: 13))
                        else
                          ..._history.map((i) => _historyTile(i)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Lead Quente 🔥';
    if (score >= 60) return 'Lead Morno ☀️';
    if (score >= 40) return 'Lead Frio ❄️';
    return 'Lead Inicial 🌱';
  }

  Widget _scoreRow(String eventType, int points) {
    final label = _eventLabels[eventType] ?? eventType;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$points pts',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> interaction) {
    final type = interaction['event_type'] as String? ?? '';
    final points = interaction['points'] as int? ?? 0;
    final createdAt = DateTime.tryParse(interaction['created_at'] ?? '') ?? DateTime.now();
    final label = _eventLabels[type] ?? type;
    final timeAgo = _formatTimeAgo(createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text('+$points', style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(timeAgo, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
