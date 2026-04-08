import 'package:flutter/material.dart';
import '../../models/market_lead.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../theme.dart';
import 'chat_page.dart';
import 'lead_score_detail_page.dart';

class LeadFunnelPage extends StatefulWidget {
  const LeadFunnelPage({super.key});

  @override
  State<LeadFunnelPage> createState() => _LeadFunnelPageState();
}

class _LeadFunnelPageState extends State<LeadFunnelPage> {
  List<MarketLead> _leads = [];
  List<Map<String, dynamic>> _advisors = [];
  bool _loading = true;
  String? _filterAdvisor; // null = todos (só master usa)

  static const _stages = ['new', 'contacted', 'qualified', 'closed'];

  static const _stageLabels = {
    'new': 'Novo',
    'contacted': 'Contatado',
    'qualified': 'Qualificado',
    'closed': 'Fechado',
  };

  static const _stageColors = {
    'new': Colors.blue,
    'contacted': Colors.orange,
    'qualified': Colors.green,
    'closed': Colors.grey,
  };

  static const _stageIcons = {
    'new': Icons.fiber_new,
    'contacted': Icons.phone_in_talk,
    'qualified': Icons.verified,
    'closed': Icons.check_circle,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final leads = await ChatService.fetchLeads();
    List<Map<String, dynamic>> advisors = [];
    if (AuthService.isMaster) {
      advisors = await ChatService.fetchAdvisors();
    }
    if (!mounted) return;
    setState(() {
      _leads = leads;
      _advisors = advisors;
      _loading = false;
    });
  }

  List<MarketLead> _leadsForStage(String stage) {
    var filtered = _leads.where((l) => l.status == stage);
    if (_filterAdvisor != null) {
      filtered = filtered.where((l) => l.assignedTo == _filterAdvisor);
    }
    return filtered.toList();
  }

  Future<void> _moveLeadToStage(MarketLead lead, String newStage) async {
    if (lead.status == newStage) return;
    await ChatService.updateLeadStatus(lead.id, newStage);
    _load();
  }

  Color _scoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showAssignDialog(MarketLead lead) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atribuir assessor', style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_advisors.isEmpty)
                const Text('Nenhum assessor cadastrado')
              else
                ..._advisors.map((a) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    radius: 16,
                    child: Text(
                      (a['display_name'] as String? ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  title: Text(a['display_name'] ?? 'Sem nome', style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${a['lead_count'] ?? 0} leads', style: const TextStyle(fontSize: 11)),
                  selected: lead.assignedTo == a['id'],
                  onTap: () async {
                    await ChatService.assignLead(lead.id, a['id']);
                    if (mounted) Navigator.pop(context);
                    _load();
                  },
                )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Funil de Vendas'),
        actions: [
          // Filtro por assessor (só master)
          if (AuthService.isMaster && _advisors.isNotEmpty)
            PopupMenuButton<String?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrar por assessor',
              onSelected: (v) => setState(() => _filterAdvisor = v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('Todos')),
                ..._advisors.map((a) => PopupMenuItem(
                  value: a['id'] as String,
                  child: Text(a['display_name'] ?? 'Sem nome'),
                )),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                if (isWide) return _buildHorizontalKanban();
                return _buildVerticalKanban();
              },
            ),
    );
  }

  // Desktop/Web: colunas lado a lado
  Widget _buildHorizontalKanban() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _stages.map((stage) => Expanded(
        child: _buildColumn(stage),
      )).toList(),
    );
  }

  // Mobile: tabs ou scroll vertical
  Widget _buildVerticalKanban() {
    return DefaultTabController(
      length: _stages.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: Colors.grey,
            tabs: _stages.map((s) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_stageIcons[s], size: 16),
                  const SizedBox(width: 4),
                  Text('${_stageLabels[s]} (${_leadsForStage(s).length})'),
                ],
              ),
            )).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _stages.map((stage) {
                final leads = _leadsForStage(stage);
                return leads.isEmpty
                    ? Center(child: Text('Nenhum lead ${_stageLabels[stage]?.toLowerCase()}'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: leads.length,
                        itemBuilder: (_, i) => _kanbanCard(leads[i], stage),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String stage) {
    final leads = _leadsForStage(stage);
    final color = _stageColors[stage] ?? Colors.grey;

    return DragTarget<MarketLead>(
      onAcceptWithDetails: (details) => _moveLeadToStage(details.data, stage),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovering ? color.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isHovering ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(_stageIcons[stage], size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      _stageLabels[stage] ?? stage,
                      style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${leads.length}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                  ],
                ),
              ),
              // Cards
              Expanded(
                child: leads.isEmpty
                    ? Center(child: Text('Vazio', style: TextStyle(color: Colors.grey[400], fontSize: 12)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: leads.length,
                        itemBuilder: (_, i) => _kanbanCard(leads[i], stage),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kanbanCard(MarketLead lead, String currentStage) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(lead: lead)),
        ).then((_) => _load()),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lead.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LeadScoreDetailPage(lead: lead)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _scoreColor(lead.aiScore).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${lead.aiScore}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _scoreColor(lead.aiScore),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${lead.marketLabel} · ${lead.interest}',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (lead.budget != null) ...[
                const SizedBox(height: 4),
                Text(
                  'R\$ ${lead.budget!.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
              ],
              // Botão atribuir (só master)
              if (AuthService.isMaster) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _showAssignDialog(lead),
                  child: Row(
                    children: [
                      Icon(Icons.person_add_alt_1, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        lead.assignedTo != null ? 'Reatribuir' : 'Atribuir',
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Draggable só no desktop/web (colunas horizontais)
    return LongPressDraggable<MarketLead>(
      data: lead,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 200, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }
}
