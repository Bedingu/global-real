import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmRouletteSettingsPage extends StatefulWidget {
  const CrmRouletteSettingsPage({super.key});

  @override
  State<CrmRouletteSettingsPage> createState() => _CrmRouletteSettingsPageState();
}

class _CrmRouletteSettingsPageState extends State<CrmRouletteSettingsPage> {
  int _step = 0;
  bool _autoDistribute = true;
  String _prioritizeApi = 'Sim';

  // Step 2: Quando não houver roleta compatível
  final List<String?> _fallbackTeams = ['Equipe Matriz'];
  static const _availableTeams = ['Equipe Matriz', 'Equipe Filial SP', 'Equipe Filial RJ', 'Equipe Comercial'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Configurações'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Breadcrumb
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('ROLETAS DE LEADS', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('CONFIGURAÇÕES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),
          if (_step == 0) _buildActivationStep(),
          if (_step == 1) _buildAttendanceStep(),
          if (_step == 2) _buildNoRouletteStep(),
        ]),
      ),
    );
  }

  Widget _buildActivationStep() {
    return _card(Icons.auto_awesome_outlined, 'Ativação das roletas', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Ativar distribuição automática de leads pelas roletas?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          TextSpan(text: ' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
        ])),
        const SizedBox(height: 10),
        Row(children: [
          Switch(
            value: _autoDistribute,
            activeColor: AppTheme.primaryBlue,
            onChanged: (v) => setState(() => _autoDistribute = v),
          ),
          const SizedBox(width: 8),
          Text(_autoDistribute ? 'Ativo' : 'Inativo', style: const TextStyle(fontSize: 13)),
        ]),
        const SizedBox(height: 20),
        _navButtons(onNext: () => setState(() => _step = 1)),
      ],
    ));
  }

  Widget _buildAttendanceStep() {
    return _card(Icons.support_agent_outlined, 'Atendimento ao lead', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Leads que já possuírem negociações anteriores, sendo "abertas" ou "ganhas", serão obrigatoriamente repassados aos mesmos responsáveis.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        // Radio
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Priorizar responsável oriundo da API', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          TextSpan(text: ' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
        ])),
        const SizedBox(height: 6),
        Row(children: ['Sim', 'Não'].map((o) => Row(mainAxisSize: MainAxisSize.min, children: [
          Radio<String>(value: o, groupValue: _prioritizeApi, onChanged: (v) => setState(() => _prioritizeApi = v!),
            activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          Text(o, style: const TextStyle(fontSize: 12)), const SizedBox(width: 16),
        ])).toList()),
        const SizedBox(height: 20),
        // Finalidade cards
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth > 700) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _purposeCard('Venda')),
              const SizedBox(width: 12),
              Expanded(child: _purposeCard('Locação')),
              const SizedBox(width: 12),
              Expanded(child: _purposeCard('Temporada')),
            ]);
          }
          return Column(children: [
            _purposeCard('Venda'), const SizedBox(height: 12),
            _purposeCard('Locação'), const SizedBox(height: 12),
            _purposeCard('Temporada'),
          ]);
        }),
        const SizedBox(height: 24),
        _navButtons(onBack: () => setState(() => _step = 0), onNext: () => setState(() => _step = 2)),
      ],
    ));
  }

  Widget _purposeCard(String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      child: Column(children: [
        Align(alignment: Alignment.centerLeft, child: RichText(text: TextSpan(children: [
          TextSpan(text: label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const TextSpan(text: ' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.red)),
        ]))),
        const SizedBox(height: 16),
        Row(children: [
          Icon(Icons.home_work_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(width: 12),
          Expanded(child: RichText(text: TextSpan(
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            children: [
              const TextSpan(text: 'Você não possui imóveis nesta finalidade. Adicione-os no '),
              TextSpan(text: 'módulo de Imóveis', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
              const TextSpan(text: '.'),
            ],
          ))),
        ]),
      ]),
    );
  }

  // Helpers
  Widget _card(IconData icon, String title, Widget child) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
    child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 20, color: AppTheme.primaryBlue), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
      const Divider(height: 32), child,
    ])),
  );

  Widget _buildNoRouletteStep() {
    return _card(Icons.people_outline, 'Quando não houver roleta compatível', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'É necessário vincular sua roleta a pelo menos uma equipe ou um usuário nessa etapa.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        // Team rows + User button
        ..._fallbackTeams.asMap().entries.map((entry) {
          final idx = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: idx < _fallbackTeams.length - 1 ? 12 : 0),
            child: LayoutBuilder(builder: (ctx, c) {
              final teamDropdown = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(text: const TextSpan(children: [
                    TextSpan(text: 'Redistribuir leads para a equipe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    TextSpan(text: ' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
                  ])),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _fallbackTeams[idx],
                    isExpanded: true,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: _inputDeco('Selecione uma equipe'),
                    items: _availableTeams.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _fallbackTeams[idx] = v),
                  ),
                ],
              );
              final userButton = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Redistribuir leads para o usuário', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar usuário', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ],
              );
              if (c.maxWidth > 600) {
                return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: teamDropdown),
                  const SizedBox(width: 16),
                  userButton,
                  if (_fallbackTeams.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                      onPressed: () => setState(() => _fallbackTeams.removeAt(idx)),
                    ),
                  ],
                ]);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                teamDropdown, const SizedBox(height: 12), userButton,
              ]);
            }),
          );
        }),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() => _fallbackTeams.add(null)),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Adicionar equipe', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
        ),
        const SizedBox(height: 24),
        _navButtonsSave(onBack: () => setState(() => _step = 1)),
      ],
    ));
  }

  Widget _navButtonsSave({VoidCallback? onBack}) => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    if (onBack != null) ...[OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Voltar')), const SizedBox(width: 12)],
    ElevatedButton(onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas!'), backgroundColor: Colors.green));
    }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Salvar')),
  ]);

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
  );

  Widget _navButtons({VoidCallback? onBack, VoidCallback? onNext}) => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    if (onBack != null) ...[OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Voltar')), const SizedBox(width: 12)],
    ElevatedButton(onPressed: onNext, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Próximo')),
  ]);
}
