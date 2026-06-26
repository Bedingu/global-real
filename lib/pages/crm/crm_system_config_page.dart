import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemConfigPage extends StatefulWidget {
  const CrmSystemConfigPage({super.key});

  @override
  State<CrmSystemConfigPage> createState() => _CrmSystemConfigPageState();
}

class _CrmSystemConfigPageState extends State<CrmSystemConfigPage> {
  int _step = 0;
  static const _totalSteps = 10;

  // Step 1: Dados
  bool _isPJ = true;
  final _razaoSocialCtrl = TextEditingController();
  final _nomeFantasiaCtrl = TextEditingController();
  final _creciCtrl = TextEditingController();
  bool _noCRECI = false;
  final _cnpjCtrl = TextEditingController();
  final _ieCtrl = TextEditingController();
  final _imCtrl = TextEditingController();

  // Step 2: Agências
  final _agencyNameCtrl = TextEditingController();
  final _agencySiglaCtrl = TextEditingController();
  final _agencyIntermediaryCtrl = TextEditingController();
  final _agencyHoursCtrl = TextEditingController();
  final _agencyCepCtrl = TextEditingController();
  final _agencyStateCtrl = TextEditingController();
  final _agencyCityCtrl = TextEditingController();
  final _agencyNeighCtrl = TextEditingController();
  final _agencyStreetCtrl = TextEditingController();
  final _agencyNumCtrl = TextEditingController();
  final _agencyComplementCtrl = TextEditingController();

  // Step 3: Identidade Visual
  String? _logoFile;
  String? _watermarkFile;
  String? _faviconFile;
  String _primaryColor = '#232845';
  String _secondaryColor = '#FFC107';
  String _watermarkPosition = 'Centro';

  // Step 4: Layout Documento
  String _headerAlign = 'Centralizado';
  String _paginationAlign = 'Centralizado';

  // Step 6: Pessoas
  bool _cpfRequired = true;
  bool _cnpjRequired = false;

  // Step 7: Imóveis
  final Set<String> _transactions = {'Venda', 'Locação', 'Temporada'};
  String _addressVisibility = 'Todas acima incluindo logradouro';
  String _mapVisibility = 'Exata';
  String _codeGeneration = 'Sequencial';
  bool _cepRequired = true;
  final _honorariosVendaCtrl = TextEditingController();
  final _honorariosLocCtrl = TextEditingController();
  final _honorariosTempCtrl = TextEditingController();
  bool _updateActive = true;
  final _expiringDaysCtrl = TextEditingController(text: '30');
  final _outdatedDaysCtrl = TextEditingController(text: '60');

  // Step 8: Propostas
  final _proposalValidityCtrl = TextEditingController(text: '7');

  // Step 9: Backup
  final _backupReasonCtrl = TextEditingController();
  final _backupObsCtrl = TextEditingController();

  @override
  void dispose() {
    _razaoSocialCtrl.dispose(); _nomeFantasiaCtrl.dispose(); _creciCtrl.dispose();
    _cnpjCtrl.dispose(); _ieCtrl.dispose(); _imCtrl.dispose();
    _agencyNameCtrl.dispose(); _agencySiglaCtrl.dispose(); _agencyIntermediaryCtrl.dispose();
    _agencyHoursCtrl.dispose(); _agencyCepCtrl.dispose(); _agencyStateCtrl.dispose();
    _agencyCityCtrl.dispose(); _agencyNeighCtrl.dispose(); _agencyStreetCtrl.dispose();
    _agencyNumCtrl.dispose(); _agencyComplementCtrl.dispose();
    _honorariosVendaCtrl.dispose(); _honorariosLocCtrl.dispose(); _honorariosTempCtrl.dispose();
    _expiringDaysCtrl.dispose(); _outdatedDaysCtrl.dispose();
    _proposalValidityCtrl.dispose(); _backupReasonCtrl.dispose(); _backupObsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Configurações do sistema'), backgroundColor: AppTheme.primaryBlue),
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
              const Text('CONFIGURAÇÕES DO SISTEMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(padding: const EdgeInsets.all(24), child: _buildStep()),
              ),
            ),
          ),
          _buildNav(),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _stepDados();
      case 1: return _stepAgencias();
      case 2: return _stepIdentidade();
      case 3: return _stepLayoutDoc();
      case 4: return _stepFormularios();
      case 5: return _stepPessoas();
      case 6: return _stepImoveis();
      case 7: return _stepPropostas();
      case 8: return _stepBackup();
      default: return const SizedBox();
    }
  }

  // ═══ STEP 1: DADOS ═══
  Widget _stepDados() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Dados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      const Text('Tipo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [
        _radio('Pessoa Física', !_isPJ, (_) => setState(() => _isPJ = false)),
        const SizedBox(width: 16),
        _radio('Pessoa Jurídica', _isPJ, (_) => setState(() => _isPJ = true)),
      ]),
      const SizedBox(height: 14),
      _f('Razão Social', _razaoSocialCtrl),
      _f('Nome Fantasia', _nomeFantasiaCtrl),
      Row(children: [
        Expanded(child: _f('CRECI', _creciCtrl)),
        const SizedBox(width: 12),
        Row(children: [
          Checkbox(value: _noCRECI, onChanged: (v) => setState(() => _noCRECI = v!), visualDensity: VisualDensity.compact),
          const Text('Não tenho CRECI', style: TextStyle(fontSize: 12)),
        ]),
      ]),
      _f('CNPJ', _cnpjCtrl),
      _f('Inscrição Estadual', _ieCtrl),
      _f('Inscrição Municipal', _imCtrl),
    ]);
  }

  // ═══ STEP 2: AGÊNCIAS ═══
  Widget _stepAgencias() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Agências', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      _f('Nome agência', _agencyNameCtrl),
      _f('Sigla agência', _agencySiglaCtrl),
      _f('Intermediador', _agencyIntermediaryCtrl),
      _f('Horário de atendimento', _agencyHoursCtrl),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Adicionar Telefone', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Adicionar E-mail', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
      const SizedBox(height: 14),
      _f('CEP', _agencyCepCtrl),
      Row(children: [Expanded(child: _f('Estado', _agencyStateCtrl)), const SizedBox(width: 12), Expanded(child: _f('Cidade', _agencyCityCtrl))]),
      _f('Bairro', _agencyNeighCtrl),
      Row(children: [Expanded(flex: 3, child: _f('Logradouro', _agencyStreetCtrl)), const SizedBox(width: 12), Expanded(child: _f('Número', _agencyNumCtrl))]),
      _f('Complemento', _agencyComplementCtrl),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Adicionar Agência', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
    ]);
  }

  // ═══ STEP 3: IDENTIDADE VISUAL ═══
  Widget _stepIdentidade() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Identidade Visual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      _uploadField('Logo', _logoFile, () => setState(() => _logoFile = 'logo.png')),
      const SizedBox(height: 14),
      const Text('Cores', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: [
        _colorField('Principal', _primaryColor),
        const SizedBox(width: 16),
        _colorField('Secundária', _secondaryColor),
      ]),
      const SizedBox(height: 14),
      _uploadField('Marca d\'água', _watermarkFile, () => setState(() => _watermarkFile = 'watermark.png')),
      const SizedBox(height: 8),
      const Text('Posição da marca d\'água', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      DropdownButton<String>(value: _watermarkPosition, items: ['Centro', 'Canto superior', 'Canto inferior'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (v) => setState(() => _watermarkPosition = v!)),
      const SizedBox(height: 6),
      Text('Envie uma imagem no formato .PNG (sem fundo) em um tamanho de pelo menos 150 pixels de largura.', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      const SizedBox(height: 14),
      _uploadField('Favicon', _faviconFile, () => setState(() => _faviconFile = 'favicon.ico')),
    ]);
  }

  // ═══ STEP 4: LAYOUT DOCUMENTO ═══
  Widget _stepLayoutDoc() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Layout do modelo de Documento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      const Text('Alinhamento do cabeçalho', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      DropdownButton<String>(value: _headerAlign, items: ['Centralizado', 'Esquerda', 'Direita'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (v) => setState(() => _headerAlign = v!)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Pré-visualização cabeçalho', style: TextStyle(fontSize: 12, color: Colors.grey)))),
      const SizedBox(height: 20),
      const Text('Alinhamento da paginação', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      DropdownButton<String>(value: _paginationAlign, items: ['Centralizado', 'Esquerda', 'Direita'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (v) => setState(() => _paginationAlign = v!)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('— 1 —', style: TextStyle(fontSize: 12, color: Colors.grey)))),
    ]);
  }

  // ═══ STEP 5: FORMULÁRIOS NO SITE ═══
  Widget _stepFormularios() {
    final forms = ['Contato', 'Trabalhe conosco', 'Cadastre seu imóvel', 'Imóvel venda', 'Imóvel locação', 'Imóvel temporada', 'Solicitação reparo locação', 'Solicitação de manutenção condomínio', 'Solicite seu imóvel'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Formulários no site', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      ...forms.map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Nenhum e-mail informado', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        const SizedBox(height: 4),
        TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 14), label: const Text('Adicionar E-mail', style: TextStyle(fontSize: 11))),
      ]))),
    ]);
  }

  // ═══ STEP 6: PESSOAS ═══
  Widget _stepPessoas() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pessoas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      const Text('CPF obrigatório', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [_radio('Sim', _cpfRequired, (_) => setState(() => _cpfRequired = true)), const SizedBox(width: 16), _radio('Não', !_cpfRequired, (_) => setState(() => _cpfRequired = false))]),
      const SizedBox(height: 14),
      const Text('CNPJ obrigatório', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [_radio('Sim', _cnpjRequired, (_) => setState(() => _cnpjRequired = true)), const SizedBox(width: 16), _radio('Não', !_cnpjRequired, (_) => setState(() => _cnpjRequired = false))]),
    ]);
  }

  // ═══ STEP 7: IMÓVEIS ═══
  Widget _stepImoveis() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Imóveis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      const Text('Transações imobiliárias', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Wrap(spacing: 8, children: ['Venda', 'Locação', 'Temporada'].map((t) => FilterChip(label: Text(t, style: const TextStyle(fontSize: 12)), selected: _transactions.contains(t), onSelected: (v) => setState(() => v ? _transactions.add(t) : _transactions.remove(t)))).toList()),
      const SizedBox(height: 14),
      const Text('Endereço no site', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      DropdownButton<String>(value: _addressVisibility, isExpanded: true, items: ['Todas acima incluindo logradouro', 'Apenas bairro e cidade', 'Completo'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (v) => setState(() => _addressVisibility = v!)),
      const SizedBox(height: 14),
      const Text('Visibilidade no mapa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [_radio('Exata', _mapVisibility == 'Exata', (_) => setState(() => _mapVisibility = 'Exata')), const SizedBox(width: 8), _radio('Aproximada', _mapVisibility == 'Aproximada', (_) => setState(() => _mapVisibility = 'Aproximada')), const SizedBox(width: 8), _radio('Não mostrar', _mapVisibility == 'Não mostrar', (_) => setState(() => _mapVisibility = 'Não mostrar'))]),
      const SizedBox(height: 14),
      const Text('Geração de código', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [_radio('Sequencial', _codeGeneration == 'Sequencial', (_) => setState(() => _codeGeneration = 'Sequencial')), const SizedBox(width: 16), _radio('Randômico', _codeGeneration == 'Randômico', (_) => setState(() => _codeGeneration = 'Randômico'))]),
      const SizedBox(height: 14),
      const Text('CEP obrigatório', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [_radio('Sim', _cepRequired, (_) => setState(() => _cepRequired = true)), const SizedBox(width: 16), _radio('Não', !_cepRequired, (_) => setState(() => _cepRequired = false))]),
      const SizedBox(height: 14),
      _f('Honorários de venda', _honorariosVendaCtrl),
      _f('Honorários de locação', _honorariosLocCtrl),
      _f('Honorários de temporada', _honorariosTempCtrl),
      const SizedBox(height: 14),
      const Text('Atualização dos imóveis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Row(children: [_radio('Sim', _updateActive, (_) => setState(() => _updateActive = true)), const SizedBox(width: 16), _radio('Não', !_updateActive, (_) => setState(() => _updateActive = false))]),
      if (_updateActive) ...[
        const SizedBox(height: 8),
        Row(children: [
          const Text('Expirando: ', style: TextStyle(fontSize: 12)),
          SizedBox(width: 60, child: TextField(controller: _expiringDaysCtrl, keyboardType: TextInputType.number, decoration: _deco(''), textAlign: TextAlign.center)),
          const Text(' dias', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          const Text('Desatualizados: ', style: TextStyle(fontSize: 12)),
          SizedBox(width: 60, child: TextField(controller: _outdatedDaysCtrl, keyboardType: TextInputType.number, decoration: _deco(''), textAlign: TextAlign.center)),
          const Text(' dias', style: TextStyle(fontSize: 12)),
        ]),
      ],
    ]);
  }

  // ═══ STEP 8: PROPOSTAS ═══
  Widget _stepPropostas() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Propostas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      const Text('Acesso à propostas:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Grupos de gerência', style: TextStyle(fontSize: 12, color: Colors.grey)),
      Wrap(spacing: 8, children: [Chip(label: const Text('Gerente Locações', style: TextStyle(fontSize: 11))), Chip(label: const Text('Gerente Vendas', style: TextStyle(fontSize: 11)))]),
      const SizedBox(height: 14),
      Row(children: [
        const Text('Validade inicial da proposta: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(width: 60, child: TextField(controller: _proposalValidityCtrl, keyboardType: TextInputType.number, decoration: _deco(''), textAlign: TextAlign.center)),
        const Text(' dias', style: TextStyle(fontSize: 12)),
      ]),
    ]);
  }

  // ═══ STEP 9: BACKUP ═══
  Widget _stepBackup() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Backup do sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      _f('Motivo', _backupReasonCtrl),
      const Text('Observações:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(controller: _backupObsCtrl, maxLines: 4, decoration: _deco('500 caracteres restantes')),
      const SizedBox(height: 8),
      Text('Isso pode demorar alguns minutos', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      const SizedBox(height: 16),
      const Text('Backups anteriores', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Nenhum backup foi solicitado.', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
    ]);
  }

  // ═══ HELPERS ═══
  Widget _f(String label, TextEditingController ctrl) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, decoration: _deco('')),
    ]));
  }

  InputDecoration _deco(String hint) => InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10));

  Widget _radio(String label, bool selected, ValueChanged<bool?> onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<bool>(value: true, groupValue: selected ? true : null, onChanged: onChanged, visualDensity: VisualDensity.compact),
      Text(label, style: const TextStyle(fontSize: 13)),
    ]);
  }

  Widget _uploadField(String label, String? fileName, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(fileName ?? 'Enviar imagem', style: TextStyle(fontSize: 13, color: fileName != null ? Colors.black87 : Colors.grey[500])),
          ]),
        ),
      ),
    ]);
  }

  Widget _colorField(String label, String color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 4),
      Container(width: 80, height: 32, decoration: BoxDecoration(color: Color(int.parse(color.replaceFirst('#', '0xFF'))), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300))),
    ]);
  }

  Widget _buildNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))]),
      child: Row(children: [
        Text('${_step + 1} / $_totalSteps', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Spacer(),
        if (_step > 0) OutlinedButton(onPressed: () => setState(() => _step--), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Voltar')),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _step < _totalSteps - 1 ? () => setState(() => _step++) : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas!'), backgroundColor: Colors.green)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF232845), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: Text(_step < _totalSteps - 1 ? 'Próximo' : 'Salvar'),
        ),
      ]),
    );
  }
}
