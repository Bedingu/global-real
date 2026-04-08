import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

class CrmNewCondominiumPage extends StatefulWidget {
  const CrmNewCondominiumPage({super.key});

  @override
  State<CrmNewCondominiumPage> createState() => _CrmNewCondominiumPageState();
}

class _CrmNewCondominiumPageState extends State<CrmNewCondominiumPage> {
  final _supabase = Supabase.instance.client;
  int _currentSection = 0;
  bool _saving = false;
  bool _hasChanges = false;

  // Dados do condomínio
  final _nameCtrl = TextEditingController();
  String _type = '';
  final _registroCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _andaresCtrl = TextEditingController();
  String _fechado = '';
  String _loteamento = '';

  // Localização
  final _cepCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  static const _sections = [
    _Sec(Icons.description_outlined, 'Dados'),
    _Sec(Icons.location_on_outlined, 'Localização'),
    _Sec(Icons.image_outlined, 'Mídia'),
    _Sec(Icons.play_circle_outline, 'Vídeo'),
    _Sec(Icons.info_outline, 'Detalhes'),
    _Sec(Icons.star_outline, 'Comodidades'),
    _Sec(Icons.attach_money, 'Valores'),
    _Sec(Icons.settings_outlined, 'Config'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _registroCtrl.dispose(); _areaCtrl.dispose();
    _andaresCtrl.dispose(); _cepCtrl.dispose(); _addressCtrl.dispose();
    _numberCtrl.dispose(); _complementCtrl.dispose();
    _neighborhoodCtrl.dispose(); _cityCtrl.dispose(); _stateCtrl.dispose();
    super.dispose();
  }

  void _markChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 56, color: Color(0xFFF59E0B)),
            const SizedBox(height: 16),
            const Text('Deseja sair sem salvar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(text: 'As alterações '),
                  TextSpan(text: 'não serão salvas.', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome é obrigatório'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _supabase.from('crm_condominiums').insert({
        'owner_id': AuthService.currentUserId(),
        'name': _nameCtrl.text.trim(),
        'neighborhood': _neighborhoodCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Condomínio salvo!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          title: const Text('Novo Condomínio'),
          backgroundColor: AppTheme.primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb
                    Row(children: [
                      GestureDetector(
                        onTap: () async {
                          if (_hasChanges) {
                            final ok = await _onWillPop();
                            if (ok && mounted) Navigator.pop(context);
                          } else { Navigator.pop(context); }
                        },
                        child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                      const Text('CONDOMÍNIOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                      const Text('NOVO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 24),
                    _buildCurrentSection(),
                  ],
                ),
              ),
            ),
            // Right sidebar
            Container(
              width: 56,
              color: Colors.white,
              child: Column(
                children: List.generate(_sections.length, (i) {
                  final selected = _currentSection == i;
                  return InkWell(
                    onTap: () => setState(() => _currentSection = i),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryBlue : Colors.transparent,
                      ),
                      child: Icon(_sections[i].icon, color: selected ? Colors.white : Colors.grey[400], size: 22),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 0: return _buildDataSection();
      case 1: return _buildLocationSection();
      default:
        return _sectionCard(
          icon: _sections[_currentSection].icon,
          title: _sections[_currentSection].label,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Seção "${_sections[_currentSection].label}" — em breve',
                  style: TextStyle(color: Colors.grey[400])),
            ),
          ),
        );
    }
  }

  // ==================== SEÇÃO 1: DADOS ====================
  Widget _buildDataSection() {
    return _sectionCard(
      icon: Icons.description_outlined,
      title: 'Dados do condomínio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Nome + Fechado + Loteamento
          _formRow([
            _field('Nome *', _nameCtrl, flex: 3),
            _radioField('Fechado *', _fechado, ['Sim', 'Não'], (v) => setState(() { _fechado = v; _markChanged(); })),
            _radioField('Loteamento *', _loteamento, ['Sim', 'Não'], (v) => setState(() { _loteamento = v; _markChanged(); })),
          ]),
          const SizedBox(height: 16),
          // Row 2: Tipo + Registro + Área + Andares
          _formRow([
            _radioField('Tipo *', _type, ['Vertical', 'Horizontal', 'Misto'], (v) => setState(() { _type = v; _markChanged(); })),
            _field('Registro de incorporação', _registroCtrl),
            _field('Área do terreno', _areaCtrl, suffix: 'm²', keyboard: TextInputType.number),
            _field('Andares', _andaresCtrl, keyboard: TextInputType.number),
          ]),
          const SizedBox(height: 16),
          // Logo
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Logo do Empreendimento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    width: 160, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(Icons.image_outlined, size: 40, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload, size: 16),
                    label: const Text('Enviar imagem', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _navButtons(onNext: () => setState(() => _currentSection = 1)),
        ],
      ),
    );
  }

  // ==================== SEÇÃO 2: LOCALIZAÇÃO ====================
  Widget _buildLocationSection() {
    return _sectionCard(
      icon: Icons.location_on_outlined,
      title: 'Localização',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formRow([
            _field('CEP', _cepCtrl, keyboard: TextInputType.number),
            _field('Endereço', _addressCtrl, flex: 2),
            _field('Número', _numberCtrl),
          ]),
          const SizedBox(height: 16),
          _formRow([
            _field('Complemento', _complementCtrl),
            _field('Bairro', _neighborhoodCtrl),
            _field('Cidade', _cityCtrl),
            _field('Estado', _stateCtrl),
          ]),
          const SizedBox(height: 24),
          _navButtons(
            onBack: () => setState(() => _currentSection = 0),
            onNext: () => setState(() => _currentSection = 2),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ]),
            const Divider(height: 32),
            child,
          ],
        ),
      ),
    );
  }

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth > 600) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: w))).toList(),
        );
      }
      return Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList());
    });
  }

  Widget _field(String label, TextEditingController ctrl, {int flex = 1, String? suffix, TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          onChanged: (_) => _markChanged(),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            suffixText: suffix,
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _radioField(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...options.map((o) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(value: o, groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Text(o, style: const TextStyle(fontSize: 12)),
          ],
        )),
      ],
    );
  }

  Widget _navButtons({VoidCallback? onBack, VoidCallback? onNext}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onBack != null) ...[
          OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Voltar')),
          const SizedBox(width: 12),
        ],
        ElevatedButton(
          onPressed: onNext ?? _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          child: Text(onNext != null ? 'Próximo' : 'Salvar'),
        ),
      ],
    );
  }
}

class _Sec {
  final IconData icon;
  final String label;
  const _Sec(this.icon, this.label);
}
