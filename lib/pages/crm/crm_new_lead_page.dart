import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

class CrmNewLeadPage extends StatefulWidget {
  const CrmNewLeadPage({super.key});

  @override
  State<CrmNewLeadPage> createState() => _CrmNewLeadPageState();
}

class _CrmNewLeadPageState extends State<CrmNewLeadPage> {
  final _supabase = Supabase.instance.client;
  int _step = 0;

  // Step 1: Pessoa
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isWhatsapp = false;
  String? _origin;
  String? _agency;
  String? _campaign;

  // Step 2: Atendimento
  final Set<String> _interests = {};
  final _propertyCtrl = TextEditingController();
  String _assignType = 'open'; // 'responsible', 'roulette', 'open'
  final _observationsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _propertyCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Novo Lead'), backgroundColor: AppTheme.primaryBlue),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Text('LEADS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('NOVO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF232845))),
            ]),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.people_outline, size: 20, color: Color(0xFF232845)),
                    SizedBox(width: 8),
                    Text('Novo lead', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 20),
                  if (_step == 0) _buildStep1Pessoa(),
                  if (_step == 1) _buildStep2Atendimento(),
                ],
              ),
            ),
          ),
          // Navigation
          _buildNav(),
        ],
      ),
    );
  }

  // ═══ STEP 1: PESSOA ═══
  Widget _buildStep1Pessoa() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _requiredLabel('Pessoa'),
            const SizedBox(height: 4),
            Text('Preencha o nome completo e pelo menos uma opção de contato.', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 20),
            // Nome + Telefone + Email
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 250,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _requiredLabel('Nome completo'),
                    const SizedBox(height: 6),
                    TextField(controller: _nameCtrl, decoration: _deco('Informe o nome')),
                  ]),
                ),
                SizedBox(
                  width: 220,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Telefone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '(11) 96123 4567',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon: const Padding(padding: EdgeInsets.only(left: 8), child: Text('🇧🇷 +55', style: TextStyle(fontSize: 13))),
                        prefixIconConstraints: const BoxConstraints(minWidth: 60),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Checkbox(value: _isWhatsapp, onChanged: (v) => setState(() => _isWhatsapp = v!), visualDensity: VisualDensity.compact),
                      const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chat, size: 14, color: Color(0xFF25D366)),
                    ]),
                  ]),
                ),
                SizedBox(
                  width: 220,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('E-mail', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _emailCtrl, decoration: _deco('exemplo@exemplo.com')),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Origem + Agência + Campanha
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _requiredLabel('Origem'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _origin,
                      decoration: _deco('Selecione uma origem'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Selecione uma origem')),
                        DropdownMenuItem(value: 'site', child: Text('Site')),
                        DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                        DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                        DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                        DropdownMenuItem(value: 'indicacao', child: Text('Indicação')),
                        DropdownMenuItem(value: 'google_ads', child: Text('Google Ads')),
                        DropdownMenuItem(value: 'telefone', child: Text('Telefone')),
                      ],
                      onChanged: (v) => setState(() => _origin = v),
                    ),
                  ]),
                ),
                SizedBox(
                  width: 200,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _requiredLabel('Agência'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _agency,
                      decoration: _deco('Selecione uma agência'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Selecione uma agência')),
                        DropdownMenuItem(value: 'matriz', child: Text('Matriz')),
                      ],
                      onChanged: (v) => setState(() => _agency = v),
                    ),
                  ]),
                ),
                SizedBox(
                  width: 200,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Campanha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _campaign,
                      decoration: _deco('Selecione uma campanha'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Selecione uma campanha')),
                      ],
                      onChanged: (v) => setState(() => _campaign = v),
                    ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══ STEP 2: ATENDIMENTO ═══
  Widget _buildStep2Atendimento() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.support_agent, size: 20, color: Color(0xFF232845)),
              SizedBox(width: 8),
              Text('Atendimento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 20),
            // Interesse
            const Text('Interesse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['Venda', 'Locação', 'Temporada'].map((t) => FilterChip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              selected: _interests.contains(t),
              onSelected: (v) => setState(() => v ? _interests.add(t) : _interests.remove(t)),
            )).toList()),
            const SizedBox(height: 16),
            // Imóvel de referência
            const Text('Imóvel de referência', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _propertyCtrl, decoration: _deco('Pesquise por: Código, endereço ou condomínio')),
            const SizedBox(height: 20),
            // Como será atendido
            const Text('Como o lead será atendido?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _radioTile('Escolher responsável', 'responsible'),
            _radioTile('Distribuir nas roletas', 'roulette'),
            _radioTile('Manter lead em aberto', 'open'),
            const SizedBox(height: 16),
            // Observações
            const Text('Observações', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _observationsCtrl, maxLines: 4, decoration: _deco('')),
          ],
        ),
      ),
    );
  }

  Widget _radioTile(String label, String value) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      groupValue: _assignType,
      onChanged: (v) => setState(() => _assignType = v!),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ═══ NAVIGATION ═══
  Widget _buildNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Text('${_step + 1} / 2', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          if (_step > 0)
            OutlinedButton(onPressed: () => setState(() => _step--), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Voltar')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _step == 0 ? () => setState(() => _step++) : _save,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF232845), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text(_step == 0 ? 'Próximo' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  // ═══ HELPERS ═══
  Widget _requiredLabel(String text) {
    return RichText(text: TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87), children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]));
  }

  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10));

  Future<void> _save() async {
    try {
      await _supabase.from('market_leads').insert({
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
        'email': _emailCtrl.text,
        'market': 'sao_paulo',
        'interest': _interests.join(', '),
        'status': _assignType == 'open' ? 'new' : 'contacted',
        'notes': _observationsCtrl.text,
        'company': '',
        'ai_score': 0,
        'ai_summary': '',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead salvo com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
