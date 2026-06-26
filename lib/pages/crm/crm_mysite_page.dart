import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmMySitePage extends StatefulWidget {
  const CrmMySitePage({super.key});

  @override
  State<CrmMySitePage> createState() => _CrmMySitePageState();
}

class _CrmMySitePageState extends State<CrmMySitePage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Meu Site'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text('MEU SITE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryBlue,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Configurações'),
                Tab(text: 'Blog'),
                Tab(text: 'Páginas'),
                Tab(text: 'Depoimentos'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildConfigTab(),
                _buildBlogTab(),
                _buildPagesTab(),
                _buildTestimonialsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══ CONFIGURAÇÕES ═══
  Widget _buildConfigTab() {
    return _MySiteConfigStepper();
  }

  // ═══ BLOG ═══
  Widget _buildBlogTab() {
    return _emptyState(
      icon: Icons.article_outlined,
      title: 'Nenhum post publicado',
      subtitle: 'Crie posts para atrair visitantes ao seu site.',
      buttonLabel: 'Novo post',
    );
  }

  // ═══ PÁGINAS ═══
  Widget _buildPagesTab() {
    return _emptyState(
      icon: Icons.web_outlined,
      title: 'Nenhuma página criada',
      subtitle: 'Crie páginas personalizadas para seu site.',
      buttonLabel: 'Nova página',
    );
  }

  // ═══ DEPOIMENTOS ═══
  Widget _buildTestimonialsTab() {
    return _emptyState(
      icon: Icons.format_quote_outlined,
      title: 'Nenhum depoimento cadastrado',
      subtitle: 'Adicione depoimentos de clientes para exibir no site.',
      buttonLabel: 'Novo depoimento',
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ═══ Stepper de Configurações do Site ═══
class _MySiteConfigStepper extends StatefulWidget {
  @override
  State<_MySiteConfigStepper> createState() => _MySiteConfigStepperState();
}

class _MySiteConfigStepperState extends State<_MySiteConfigStepper> {
  int _step = 0;
  static const _totalSteps = 9;

  // Step 1: SEO
  final _titleCtrl = TextEditingController();
  final _gtmCtrl = TextEditingController();
  final _metaDescCtrl = TextEditingController();

  // Step 2: Visibilidade
  bool _showWhatsappButton = false;
  bool _showTeamOnInstitutional = false;

  // Step 3: Área do cliente
  bool _clientAreaActive = true;
  bool _clientAreaCustom = false;
  bool _condominiumArea = false;
  bool _tenantArea = false;
  bool _ownerArea = false;

  // Step 5: Banners
  String? _bannerImage;

  // Step 6: Títulos
  final _homeTitleCtrl = TextEditingController();
  final _homeSubtitleCtrl = TextEditingController();

  // Step 7: Redes sociais
  final _blogCtrl = TextEditingController();
  final _skypeCtrl = TextEditingController();
  final _twitterCtrl = TextEditingController();
  final _youtubeCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  // Step 8: Termos
  final _termsCtrl = TextEditingController();

  // Step 9: Privacidade
  final _privacyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose(); _gtmCtrl.dispose(); _metaDescCtrl.dispose();
    _homeTitleCtrl.dispose(); _homeSubtitleCtrl.dispose();
    _blogCtrl.dispose(); _skypeCtrl.dispose(); _twitterCtrl.dispose();
    _youtubeCtrl.dispose(); _facebookCtrl.dispose(); _linkedinCtrl.dispose();
    _instagramCtrl.dispose(); _termsCtrl.dispose(); _privacyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _stepSeo();
      case 1: return _stepVisibility();
      case 2: return _stepClientArea();
      case 3: return _stepInstitutional();
      case 4: return _stepBanners();
      case 5: return _stepTitles();
      case 6: return _stepSocial();
      case 7: return _stepTerms();
      case 8: return _stepPrivacy();
      default: return const SizedBox();
    }
  }

  // Step 1: SEO
  Widget _stepSeo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informações para SEO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        _field('Título da página inicial', _titleCtrl, hint: '55 caracteres restantes'),
        _field('Google Tag Manager', _gtmCtrl, hint: 'Você pode gerenciar suas tags em Google Tag Manager'),
        _field('Meta description da página inicial', _metaDescCtrl, hint: '150 caracteres restantes', maxLines: 3),
      ],
    );
  }

  // Step 2: Visibilidade
  Widget _stepVisibility() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visibilidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        const Text('Botão Whatsapp na tela do imóvel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          _radioOption('Mostrar', _showWhatsappButton, (v) => setState(() => _showWhatsappButton = true)),
          const SizedBox(width: 16),
          _radioOption('Não mostrar', !_showWhatsappButton, (v) => setState(() => _showWhatsappButton = false)),
        ]),
        const SizedBox(height: 20),
        const Text('Equipe na página institucional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          _radioOption('Visível', _showTeamOnInstitutional, (v) => setState(() => _showTeamOnInstitutional = true)),
          const SizedBox(width: 16),
          _radioOption('Invisível', !_showTeamOnInstitutional, (v) => setState(() => _showTeamOnInstitutional = false)),
        ]),
      ],
    );
  }

  // Step 3: Área do cliente
  Widget _stepClientArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Área do cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Row(children: [
          _radioOption('Ativo', _clientAreaActive, (v) => setState(() => _clientAreaActive = true)),
          const SizedBox(width: 16),
          _radioOption('Inativo', !_clientAreaActive, (v) => setState(() => _clientAreaActive = false)),
        ]),
        const SizedBox(height: 16),
        const Text('Tipo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Row(children: [
          _radioOption('Padrão Jetimob', !_clientAreaCustom, (v) => setState(() => _clientAreaCustom = false)),
          const SizedBox(width: 16),
          _radioOption('Customizado', _clientAreaCustom, (v) => setState(() => _clientAreaCustom = true)),
        ]),
        const SizedBox(height: 16),
        SwitchListTile(title: const Text('Área do condomínio', style: TextStyle(fontSize: 13)), value: _condominiumArea, onChanged: (v) => setState(() => _condominiumArea = v), contentPadding: EdgeInsets.zero, dense: true),
        SwitchListTile(title: const Text('Área do locatário', style: TextStyle(fontSize: 13)), value: _tenantArea, onChanged: (v) => setState(() => _tenantArea = v), contentPadding: EdgeInsets.zero, dense: true),
        SwitchListTile(title: const Text('Área do proprietário', style: TextStyle(fontSize: 13)), value: _ownerArea, onChanged: (v) => setState(() => _ownerArea = v), contentPadding: EdgeInsets.zero, dense: true),
      ],
    );
  }

  // Step 4: Texto institucional
  Widget _stepInstitutional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Texto Institucional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(maxLines: 8, decoration: _inputDeco('Descreva sua empresa...')),
      ],
    );
  }

  // Step 5: Banners
  Widget _stepBanners() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _bannerImage = 'banner_selected.jpg'),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
                const SizedBox(height: 8),
                const Text('Adicionar imagem', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const Text('Selecionar', style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('*A imagem deve estar preferencialmente no formato JPG e no tamanho recomendado: 1400x500px.', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  // Step 6: Títulos
  Widget _stepTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Títulos da página inicial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        _field('Título', _homeTitleCtrl, hint: '29 caracteres restantes'),
        _field('Subtítulo', _homeSubtitleCtrl, hint: '5 caracteres restantes'),
      ],
    );
  }

  // Step 7: Redes sociais
  Widget _stepSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Redes Sociais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        _field('Blog', _blogCtrl, hint: 'URL do blog'),
        _field('Skype', _skypeCtrl, hint: 'Usuário Skype'),
        _field('Twitter', _twitterCtrl, hint: 'URL do Twitter'),
        _field('Youtube', _youtubeCtrl, hint: 'URL do Youtube'),
        _field('Facebook', _facebookCtrl, hint: 'URL do Facebook'),
        _field('LinkedIn', _linkedinCtrl, hint: 'URL do LinkedIn'),
        _field('Instagram', _instagramCtrl, hint: 'URL do Instagram'),
      ],
    );
  }

  // Step 8: Termos
  Widget _stepTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Termos de uso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(controller: _termsCtrl, maxLines: 10, decoration: _inputDeco('Cole seus termos de uso aqui...')),
      ],
    );
  }

  // Step 9: Privacidade
  Widget _stepPrivacy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Política de privacidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(controller: _privacyCtrl, maxLines: 10, decoration: _inputDeco('Cole sua política de privacidade aqui...')),
      ],
    );
  }

  // ═══ HELPERS ═══
  Widget _field(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(controller: ctrl, maxLines: maxLines, decoration: _inputDeco(hint ?? '')),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _radioOption(String label, bool selected, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<bool>(value: true, groupValue: selected ? true : null, onChanged: onChanged, visualDensity: VisualDensity.compact),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          // Step indicator
          Text('${_step + 1} / $_totalSteps', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          if (_step > 0)
            OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Voltar'),
            ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _step < _totalSteps - 1
                ? () => setState(() => _step++)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas!'), backgroundColor: Colors.green));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF232845),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_step < _totalSteps - 1 ? 'Próximo' : 'Salvar'),
          ),
        ],
      ),
    );
  }
}
