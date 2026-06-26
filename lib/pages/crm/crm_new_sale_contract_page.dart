import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

class CrmNewSaleContractPage extends StatefulWidget {
  const CrmNewSaleContractPage({super.key});

  @override
  State<CrmNewSaleContractPage> createState() => _CrmNewSaleContractPageState();
}

class _CrmNewSaleContractPageState extends State<CrmNewSaleContractPage> {
  final _supabase = Supabase.instance.client;
  int _currentStep = 0;

  // Step 1: Contrato
  final _propertyCtrl = TextEditingController();
  final _contractCodeCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();
  List<String> _tags = [];

  // Step 2: Pessoas
  final _sellerCtrl = TextEditingController();
  final _intermediaryCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();
  final _buyerPercentCtrl = TextEditingController(text: '100');

  // Step 3: Honorários
  final _feeGrossCtrl = TextEditingController();
  final List<_HonorarioItem> _honorarios = [
    _HonorarioItem(),
  ];

  // Step 4: Anexos
  String? _contractFileName;
  String? _intermediaryFileName;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDateCtrl.text = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _propertyCtrl.dispose();
    _contractCodeCtrl.dispose();
    _startDateCtrl.dispose();
    _valueCtrl.dispose();
    _observationsCtrl.dispose();
    _sellerCtrl.dispose();
    _intermediaryCtrl.dispose();
    _buyerCtrl.dispose();
    _buyerPercentCtrl.dispose();
    _feeGrossCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Novo Contrato de Venda'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('VENDAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('NOVO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF232845))),
            ]),
          ),
          // Banner informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF856404)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'O lançamento deste contrato de venda não irá alterar a disponibilidade nem os proprietários do imóvel negociado.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                  ),
                ),
              ],
            ),
          ),
          // Stepper content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildCurrentStep(),
            ),
          ),
          // Navigation buttons
          _buildStepButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1Contrato();
      case 1: return _buildStep2Pessoas();
      case 2: return _buildStep3Honorarios();
      case 3: return _buildStep4Anexos();
      default: return const SizedBox();
    }
  }

  // ═══════════════════════════════════════
  // STEP 1: CONTRATO
  // ═══════════════════════════════════════
  Widget _buildStep1Contrato() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description_outlined, size: 20, color: Color(0xFF232845)),
                SizedBox(width: 8),
                Text('Contrato', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            // Imóvel
            _requiredLabel('Imóvel'),
            const SizedBox(height: 6),
            TextField(
              controller: _propertyCtrl,
              decoration: _inputDecoration('Pesquise por: Código, endereço ou condomínio'),
            ),
            const SizedBox(height: 16),
            // Row: Código, Data, Valor
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _requiredLabel('Código do contrato'),
                      const SizedBox(height: 6),
                      TextField(controller: _contractCodeCtrl, decoration: _inputDecoration('')),
                    ],
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _requiredLabel('Data de Início'),
                      const SizedBox(height: 6),
                      TextField(controller: _startDateCtrl, decoration: _inputDecoration('dd/mm/aaaa')),
                    ],
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _requiredLabel('Valor negociado'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _valueCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('R\$ 5.000,00'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Etiquetas
            const Text('Etiquetas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _showNewTagDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _tags.isEmpty
                          ? Text('Selecione ou pesquise etiquetas', style: TextStyle(color: Colors.grey[400], fontSize: 14))
                          : Wrap(
                              spacing: 6,
                              children: _tags.map((t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 11)),
                                onDeleted: () => setState(() => _tags.remove(t)),
                                visualDensity: VisualDensity.compact,
                              )).toList(),
                            ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Observações
            const Text('Observações', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _observationsCtrl,
              maxLines: 4,
              decoration: _inputDecoration(''),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 2: PESSOAS
  // ═══════════════════════════════════════
  Widget _buildStep2Pessoas() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: Color(0xFF232845)),
                SizedBox(width: 8),
                Text('Pessoas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            // Vendedores
            _requiredLabel('Vendedores'),
            const SizedBox(height: 6),
            TextField(controller: _sellerCtrl, decoration: _inputDecoration('Pesquise por: Nome, CPF, Telefone')),
            const SizedBox(height: 16),
            // Intermediador
            _requiredLabel('Intermediador'),
            const SizedBox(height: 6),
            TextField(
              controller: _intermediaryCtrl,
              decoration: _inputDecoration('Gustavo Bedin'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            // Compradores
            _requiredLabel('Compradores'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(controller: _buyerCtrl, decoration: _inputDecoration('Pesquise por: Nome, CPF, Telefone')),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _buyerPercentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('%'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar comprador', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 3: HONORÁRIOS
  // ═══════════════════════════════════════
  Widget _buildStep3Honorarios() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payments_outlined, size: 20, color: Color(0xFF232845)),
                SizedBox(width: 8),
                Text('Honorários', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            // Honorários bruto
            _requiredLabel('Honorários (Bruto)'),
            const SizedBox(height: 6),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _feeGrossCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('R\$ 250.000,00'),
              ),
            ),
            const SizedBox(height: 20),
            // Tabela de honorários
            ..._honorarios.asMap().entries.map((entry) {
              final i = entry.key;
              final h = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Tipo de relação
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i == 0) ...[_requiredLabel('Tipo de relação'), const SizedBox(height: 6)],
                          DropdownButtonFormField<String>(
                            value: h.type,
                            decoration: _inputDecoration('Selecione'),
                            items: const [
                              DropdownMenuItem(value: 'intermediador', child: Text('Intermediador')),
                              DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                              DropdownMenuItem(value: 'comprador', child: Text('Comprador')),
                            ],
                            onChanged: (v) => setState(() => h.type = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Pessoa
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i == 0) ...[_requiredLabel('Pessoa'), const SizedBox(height: 6)],
                          TextField(
                            controller: h.personCtrl,
                            decoration: _inputDecoration('Nome, CPF, Telefone'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Percentual
                    SizedBox(
                      width: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i == 0) ...[_requiredLabel('Valor'), const SizedBox(height: 6)],
                          TextField(
                            controller: h.percentCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('%'),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Valor calculado
                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i == 0) const SizedBox(height: 22),
                          TextField(
                            readOnly: true,
                            decoration: _inputDecoration('0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete
                    if (i > 0)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _honorarios.removeAt(i)),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _honorarios.add(_HonorarioItem())),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar honorário', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 4: ANEXOS
  // ═══════════════════════════════════════
  Widget _buildStep4Anexos() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.attach_file, size: 20, color: Color(0xFF232845)),
                SizedBox(width: 8),
                Text('Anexos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Contrato de Negociação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contrato de Negociação', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _fileUploadButton(_contractFileName, () {
                        setState(() => _contractFileName = 'contrato_negociacao.pdf');
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Contrato de Intermediação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contrato de Intermediação', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _fileUploadButton(_intermediaryFileName, () {
                        setState(() => _intermediaryFileName = 'contrato_intermediacao.pdf');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileUploadButton(String? fileName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              fileName ?? 'Adicionar arquivo',
              style: TextStyle(fontSize: 13, color: fileName != null ? Colors.black87 : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // NAVIGATION BUTTONS
  // ═══════════════════════════════════════
  Widget _buildStepButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          // Step indicators
          ...List.generate(4, (i) => Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= _currentStep ? const Color(0xFF232845) : Colors.grey.shade300,
            ),
          )),
          const Spacer(),
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Voltar'),
            ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _currentStep < 3 ? () => setState(() => _currentStep++) : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF232845),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_currentStep < 3 ? 'Próximo' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════
  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  void _showNewTagDialog() {
    final nameCtrl = TextEditingController();
    int selectedColor = 0;
    final colors = [const Color(0xFFB8860B), const Color(0xFF1E40AF), const Color(0xFF166534), const Color(0xFFDC2626), const Color(0xFF581C87)];
    final modules = {'Condomínios': false, 'Gestão de locação': false, 'Gestão de vendas': true, 'Imóveis': false, 'Pessoas': false};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.label_outline, size: 20),
              const SizedBox(width: 8),
              const Text('Nova etiqueta', style: TextStyle(fontSize: 16)),
              const Spacer(),
              const Icon(Icons.help_outline, size: 18, color: Colors.grey),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _requiredLabel('Nome'),
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: _inputDecoration('Nome')),
                const SizedBox(height: 16),
                _requiredLabel('Cor'),
                const SizedBox(height: 8),
                Row(
                  children: colors.asMap().entries.map((e) => GestureDetector(
                    onTap: () => setDialog(() => selectedColor = e.key),
                    child: Container(
                      width: 32, height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: e.value,
                        borderRadius: BorderRadius.circular(6),
                        border: selectedColor == e.key ? Border.all(color: Colors.black, width: 2) : null,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                _requiredLabel('Módulos'),
                const SizedBox(height: 8),
                ...modules.entries.map((e) => CheckboxListTile(
                  title: Text(e.key, style: const TextStyle(fontSize: 13)),
                  value: e.value,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (v) => setDialog(() => modules[e.key] = v ?? false),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() => _tags.add(nameCtrl.text));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    try {
      await _supabase.from('crm_sales_contracts').insert({
        'contract_number': _contractCodeCtrl.text,
        'property_name': _propertyCtrl.text,
        'buyer_name': _buyerCtrl.text,
        'seller_name': _sellerCtrl.text,
        'intermediary_name': _intermediaryCtrl.text.isNotEmpty ? _intermediaryCtrl.text : 'Gustavo Bedin',
        'value': double.tryParse(_valueCtrl.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
        'signing_date': DateTime.now().toIso8601String(),
        'tags': _tags,
        'observations': _observationsCtrl.text,
        'fee_gross': double.tryParse(_feeGrossCtrl.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrato salvo com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _HonorarioItem {
  String? type = 'intermediador';
  final personCtrl = TextEditingController(text: 'Gustavo Bedin');
  final percentCtrl = TextEditingController(text: '100');
}
