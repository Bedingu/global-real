import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

class CrmAccountSettingsPage extends StatefulWidget {
  const CrmAccountSettingsPage({super.key});

  @override
  State<CrmAccountSettingsPage> createState() => _CrmAccountSettingsPageState();
}

class _CrmAccountSettingsPageState extends State<CrmAccountSettingsPage> {
  final _supabase = Supabase.instance.client;
  int _currentSection = 0;
  bool _loading = true;
  bool _saving = false;

  // Dados do perfil
  final _nameCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _creciCtrl = TextEditingController();
  String _gender = '';
  String _state = '';
  String _city = '';
  bool _hasWhatsapp = false;

  // Profissional
  String _jobTitle = '';
  final _bioCtrl = TextEditingController();

  // Social
  final _facebookCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _twitterCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _skypeCtrl = TextEditingController();

  // Senha
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  static const _sections = [
    _Section(icon: Icons.person_outline, label: 'Dados do perfil'),
    _Section(icon: Icons.badge_outlined, label: 'Profissional'),
    _Section(icon: Icons.share_outlined, label: 'Social'),
    _Section(icon: Icons.lock_outline, label: 'Redefinir senha'),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _birthCtrl.dispose(); _cpfCtrl.dispose();
    _phoneCtrl.dispose(); _creciCtrl.dispose(); _bioCtrl.dispose();
    _facebookCtrl.dispose(); _instagramCtrl.dispose(); _twitterCtrl.dispose();
    _websiteCtrl.dispose(); _linkedinCtrl.dispose(); _skypeCtrl.dispose();
    _currentPassCtrl.dispose(); _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = AuthService.currentUserId();
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _nameCtrl.text = data['full_name'] ?? data['display_name'] ?? '';
      _birthCtrl.text = data['birth_date'] ?? '';
      _cpfCtrl.text = data['cpf'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _creciCtrl.text = data['creci'] ?? '';
      _gender = data['gender'] ?? '';
      _state = data['state'] ?? '';
      _city = data['city'] ?? '';
      _hasWhatsapp = data['has_whatsapp'] ?? false;
      _jobTitle = data['job_title'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _facebookCtrl.text = data['facebook_url'] ?? '';
      _instagramCtrl.text = data['instagram_url'] ?? '';
      _twitterCtrl.text = data['twitter_url'] ?? '';
      _websiteCtrl.text = data['website_url'] ?? '';
      _linkedinCtrl.text = data['linkedin_url'] ?? '';
      _skypeCtrl.text = data['skype'] ?? '';
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    final userId = AuthService.currentUserId();
    if (userId == null) return;

    setState(() => _saving = true);

    try {
      await _supabase.from('profiles').update({
        'full_name': _nameCtrl.text.trim(),
        'birth_date': _birthCtrl.text.trim().isEmpty ? null : _birthCtrl.text.trim(),
        'cpf': _cpfCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'creci': _creciCtrl.text.trim(),
        'gender': _gender,
        'state': _state,
        'city': _city,
        'has_whatsapp': _hasWhatsapp,
        'job_title': _jobTitle,
        'bio': _bioCtrl.text.trim(),
        'facebook_url': _facebookCtrl.text.trim(),
        'instagram_url': _instagramCtrl.text.trim(),
        'twitter_url': _twitterCtrl.text.trim(),
        'website_url': _websiteCtrl.text.trim(),
        'linkedin_url': _linkedinCtrl.text.trim(),
        'skype': _skypeCtrl.text.trim(),
      }).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _saving = false);
  }

  Future<void> _changePassword() async {
    final newPass = _newPassCtrl.text.trim();
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A nova senha deve ter pelo menos 6 caracteres'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPass));
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Colors.green),
        );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Configurações da Conta'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                            ),
                            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                            const Text('CONFIGURAÇÕES DA CONTA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Current section
                        _buildCurrentSection(),
                      ],
                    ),
                  ),
                ),
                // Right sidebar with section icons
                Container(
                  width: 56,
                  color: Colors.white,
                  child: Column(
                    children: List.generate(_sections.length, (i) {
                      final selected = _currentSection == i;
                      return InkWell(
                        onTap: () => setState(() => _currentSection = i),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primaryBlue : Colors.transparent,
                          ),
                          child: Icon(
                            _sections[i].icon,
                            color: selected ? Colors.white : Colors.grey[400],
                            size: 22,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 0: return _buildProfileSection();
      case 1: return _buildProfessionalSection();
      case 2: return _buildSocialSection();
      case 3: return _buildPasswordSection();
      default: return const SizedBox();
    }
  }

  // ==================== SEÇÃO 1: DADOS DO PERFIL ====================

  Widget _buildProfileSection() {
    return _sectionCard(
      icon: Icons.person_outline,
      title: 'Dados do perfil',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text('Alterar foto', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Row 1: Nome, Data nascimento, Gênero
          _formRow([
            _formField('Nome completo *', _nameCtrl),
            _formField('Data de nascimento', _birthCtrl, hint: 'dd/mm/aaaa'),
            _genderField(),
          ]),
          const SizedBox(height: 16),
          // Row 2: CPF, Estado, Cidade
          _formRow([
            _formField('CPF', _cpfCtrl, hint: '123.456.789-32'),
            _stateDropdown(),
            _cityDropdown(),
          ]),
          const SizedBox(height: 16),
          // Row 3: Telefone, WhatsApp, CRECI
          _formRow([
            _formField('Telefone', _phoneCtrl, hint: '(11) 99999-9999'),
            _whatsappField(),
            _formField('CRECI', _creciCtrl),
          ]),
          const SizedBox(height: 24),
          _navigationButtons(onNext: () => setState(() => _currentSection = 1)),
        ],
      ),
    );
  }

  // ==================== SEÇÃO 2: PROFISSIONAL ====================

  Widget _buildProfessionalSection() {
    return _sectionCard(
      icon: Icons.badge_outlined,
      title: 'Profissional',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cargo *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _jobTitle.isEmpty ? null : _jobTitle,
            decoration: _inputDecoration('Selecionar'),
            items: const [
              DropdownMenuItem(value: 'corretor', child: Text('Corretor')),
              DropdownMenuItem(value: 'gerente', child: Text('Gerente')),
              DropdownMenuItem(value: 'diretor', child: Text('Diretor')),
              DropdownMenuItem(value: 'assessor', child: Text('Assessor')),
              DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              DropdownMenuItem(value: 'outro', child: Text('Outro')),
            ],
            onChanged: (v) => setState(() => _jobTitle = v ?? ''),
          ),
          const SizedBox(height: 20),
          const Text('Sobre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _bioCtrl,
            maxLines: 6,
            decoration: _inputDecoration('Descreva sua experiência profissional...'),
          ),
          const SizedBox(height: 24),
          _navigationButtons(
            onBack: () => setState(() => _currentSection = 0),
            onNext: () => setState(() => _currentSection = 2),
          ),
        ],
      ),
    );
  }

  // ==================== SEÇÃO 3: SOCIAL ====================

  Widget _buildSocialSection() {
    return _sectionCard(
      icon: Icons.share_outlined,
      title: 'Social',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formRow([
            _socialField(Icons.facebook, 'Facebook', _facebookCtrl, 'URL do Facebook'),
            _socialField(Icons.camera_alt_outlined, 'Instagram', _instagramCtrl, 'URL do Instagram'),
            _socialField(Icons.alternate_email, 'Twitter', _twitterCtrl, 'URL do Twitter'),
          ]),
          const SizedBox(height: 16),
          _formRow([
            _socialField(Icons.language, 'Website', _websiteCtrl, 'https://www.seusite.com.br'),
            _socialField(Icons.work_outline, 'LinkedIn', _linkedinCtrl, 'https://www.linkedin.com/perfil'),
            _socialField(Icons.video_call_outlined, 'Skype', _skypeCtrl, 'E-mail ou telefone'),
          ]),
          const SizedBox(height: 24),
          _navigationButtons(
            onBack: () => setState(() => _currentSection = 1),
            onNext: () => setState(() => _currentSection = 3),
            nextLabel: 'Próximo',
          ),
        ],
      ),
    );
  }

  // ==================== SEÇÃO 4: REDEFINIR SENHA ====================

  Widget _buildPasswordSection() {
    return _sectionCard(
      icon: Icons.lock_outline,
      title: 'Redefinir senha',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formRow([
            _formField('Senha atual', _currentPassCtrl, hint: 'Informe sua senha', obscure: true),
            _formField('Nova senha', _newPassCtrl, obscure: true),
          ]),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _currentSection = 2),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Voltar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saving ? null : () async {
                  await _saveProfile();
                  await _changePassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Salvar'),
              ),
            ],
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
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const Divider(height: 32),
            child,
          ],
        ),
      ),
    );
  }

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((c) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: c,
            ))).toList(),
          );
        }
        return Column(
          children: children.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: c,
          )).toList(),
        );
      },
    );
  }

  Widget _formField(String label, TextEditingController ctrl, {String? hint, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: _inputDecoration(hint ?? ''),
        ),
      ],
    );
  }

  Widget _socialField(IconData icon, String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryBlue),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(controller: ctrl, decoration: _inputDecoration(hint)),
      ],
    );
  }

  Widget _genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gênero *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Radio<String>(value: 'F', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
            const Text('Feminino', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 12),
            Radio<String>(value: 'M', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)),
            const Text('Masculino', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _whatsappField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Radio<bool>(value: true, groupValue: _hasWhatsapp, onChanged: (v) => setState(() => _hasWhatsapp = v!)),
            const Text('Sim', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 12),
            Radio<bool>(value: false, groupValue: _hasWhatsapp, onChanged: (v) => setState(() => _hasWhatsapp = v!)),
            const Text('Não', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _stateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _state.isEmpty ? null : _state,
          decoration: _inputDecoration('Escolha o estado'),
          items: const [
            DropdownMenuItem(value: 'SP', child: Text('São Paulo')),
            DropdownMenuItem(value: 'RJ', child: Text('Rio de Janeiro')),
            DropdownMenuItem(value: 'MG', child: Text('Minas Gerais')),
            DropdownMenuItem(value: 'PR', child: Text('Paraná')),
            DropdownMenuItem(value: 'SC', child: Text('Santa Catarina')),
            DropdownMenuItem(value: 'RS', child: Text('Rio Grande do Sul')),
            DropdownMenuItem(value: 'BA', child: Text('Bahia')),
            DropdownMenuItem(value: 'DF', child: Text('Distrito Federal')),
            DropdownMenuItem(value: 'OTHER', child: Text('Outro')),
          ],
          onChanged: (v) => setState(() => _state = v ?? ''),
        ),
      ],
    );
  }

  Widget _cityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cidade', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          decoration: _inputDecoration('Digite a cidade'),
          onChanged: (v) => _city = v,
          controller: TextEditingController(text: _city),
        ),
      ],
    );
  }

  Widget _navigationButtons({VoidCallback? onBack, VoidCallback? onNext, String nextLabel = 'Próximo'}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onBack != null) ...[
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Voltar'),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton(
          onPressed: onNext ?? () async { await _saveProfile(); },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(nextLabel),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}

class _Section {
  final IconData icon;
  final String label;
  const _Section({required this.icon, required this.label});
}
