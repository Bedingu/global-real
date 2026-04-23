import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVideosPage extends StatefulWidget {
  const AdminVideosPage({super.key});

  @override
  State<AdminVideosPage> createState() => _AdminVideosPageState();
}

class _AdminVideosPageState extends State<AdminVideosPage> {
  // ── Cores ──────────────────────────────────────────────
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF1A1A2E);
  static const _gold = Color(0xFFD4AF37);

  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;
  bool _isAdmin = false;

  // ── Lifecycle ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _checkAdminAndLoad();
  }

  Future<void> _checkAdminAndLoad() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
      return;
    }

    try {
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = profile['role'] as String? ?? '';
      if (role != 'admin') {
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
        return;
      }

      _isAdmin = true;
      await _fetchVideos();
    } catch (_) {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
    }
  }

  Future<void> _fetchVideos() async {
    setState(() => _loading = true);
    try {
      final data = await _supabase
          .from('education_content')
          .select()
          .order('created_at', ascending: false);
      _videos = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      _videos = [];
    }
    setState(() => _loading = false);
  }

  // ── CRUD ───────────────────────────────────────────────
  Future<void> _insertVideo(Map<String, dynamic> fields) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final payload = {
      ...fields,
      'created_by': userId,
    };

    // If publishing now, set publish_at
    if (payload['status'] == 'published') {
      payload['publish_at'] = DateTime.now().toUtc().toIso8601String();
    }

    await _supabase.from('education_content').insert(payload);
    await _fetchVideos();
  }

  Future<void> _updateVideo(String id, Map<String, dynamic> fields) async {
    final payload = Map<String, dynamic>.from(fields);

    if (payload['status'] == 'published' && payload['publish_at'] == null) {
      payload['publish_at'] = DateTime.now().toUtc().toIso8601String();
    }

    await _supabase.from('education_content').update(payload).eq('id', id);
    await _fetchVideos();
  }

  Future<void> _deleteVideo(String id) async {
    await _supabase.from('education_content').delete().eq('id', id);
    await _fetchVideos();
  }

  // ── Dialogs ────────────────────────────────────────────
  void _showVideoForm({Map<String, dynamic>? existing}) {
    final isEditing = existing != null;

    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl =
        TextEditingController(text: existing?['description'] ?? '');
    final urlCtrl = TextEditingController(text: existing?['video_url'] ?? '');
    final thumbCtrl =
        TextEditingController(text: existing?['thumbnail_url'] ?? '');
    final durationCtrl = TextEditingController(
      text: existing?['duration_minutes']?.toString() ?? '',
    );

    String category = existing?['category'] ?? 'Mercado Imobiliário';
    String status = existing?['status'] ?? 'draft';
    DateTime? publishAt = existing?['publish_at'] != null
        ? DateTime.tryParse(existing!['publish_at'].toString())
        : null;

    final categories = [
      'Mercado Imobiliário',
      'Investimentos',
      'Análise de Empreendimentos',
      'Dicas para Investidores',
      'Tutoriais',
    ];

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Handle bar ──
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Text(
                        isEditing ? 'Editar Vídeo' : 'Novo Vídeo',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Título
                      _buildTextField(
                        controller: titleCtrl,
                        label: 'Título',
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 12),

                      // Descrição
                      _buildTextField(
                        controller: descCtrl,
                        label: 'Descrição',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      // Categoria
                      _buildDropdown<String>(
                        label: 'Categoria',
                        value: category,
                        items: categories,
                        onChanged: (v) =>
                            setModalState(() => category = v ?? category),
                      ),
                      const SizedBox(height: 12),

                      // URL do Vídeo
                      _buildTextField(
                        controller: urlCtrl,
                        label: 'URL do Vídeo',
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 12),

                      // Thumbnail URL
                      _buildTextField(
                        controller: thumbCtrl,
                        label: 'URL da Thumbnail (opcional)',
                      ),
                      const SizedBox(height: 12),

                      // Duração
                      _buildTextField(
                        controller: durationCtrl,
                        label: 'Duração em minutos',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      // Status
                      _buildDropdown<String>(
                        label: 'Status',
                        value: status,
                        items: const ['draft', 'scheduled', 'published'],
                        itemLabel: (v) => _statusLabel(v),
                        onChanged: (v) =>
                            setModalState(() => status = v ?? status),
                      ),
                      const SizedBox(height: 12),

                      // Data de publicação (only for scheduled)
                      if (status == 'scheduled') ...[
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: publishAt ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: _gold,
                                      surface: _card,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() => publishAt = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration('Data de Publicação'),
                            child: Text(
                              publishAt != null
                                  ? '${publishAt!.day.toString().padLeft(2, '0')}/${publishAt!.month.toString().padLeft(2, '0')}/${publishAt!.year}'
                                  : 'Selecionar data',
                              style: TextStyle(
                                color: publishAt != null
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 8),

                      // Save button
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final fields = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'category': category,
                            'video_url': urlCtrl.text.trim(),
                            'thumbnail_url': thumbCtrl.text.trim().isNotEmpty
                                ? thumbCtrl.text.trim()
                                : null,
                            'duration_minutes':
                                int.tryParse(durationCtrl.text.trim()),
                            'status': status,
                            'publish_at': status == 'scheduled' &&
                                    publishAt != null
                                ? publishAt!.toUtc().toIso8601String()
                                : (status == 'published'
                                    ? DateTime.now().toUtc().toIso8601String()
                                    : null),
                          };

                          Navigator.pop(ctx);

                          try {
                            if (isEditing) {
                              await _updateVideo(
                                  existing['id'].toString(), fields);
                            } else {
                              await _insertVideo(fields);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing
                                      ? 'Vídeo atualizado!'
                                      : 'Vídeo adicionado!'),
                                  backgroundColor: _gold,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'Salvar' : 'Adicionar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        title: const Text(
          'Excluir vídeo?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${video['title']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _deleteVideo(video['id'].toString());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vídeo excluído'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────
  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Rascunho';
      case 'scheduled':
        return 'Agendado';
      case 'published':
        return 'Publicado';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'scheduled':
        return Colors.orange;
      case 'published':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  // ── Input widgets ──────────────────────────────────────
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _gold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemLabel,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: _card,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel != null ? itemLabel(item) : item.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: _gold),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            'Acesso restrito a administradores.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVideoForm(),
        backgroundColor: _gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Vídeo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: _fetchVideos,
        child: _videos.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.videocam_off, color: Colors.white24, size: 64),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum vídeo cadastrado',
                          style: TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: _videos.length,
                itemBuilder: (_, i) => _buildVideoCard(_videos[i]),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Gerenciar Vídeos',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _bg,
      elevation: 0,
      iconTheme: const IconThemeData(color: _gold),
      actions: [
        if (_isAdmin)
          IconButton(
            icon: const Icon(Icons.refresh, color: _gold),
            onPressed: _fetchVideos,
            tooltip: 'Atualizar',
          ),
      ],
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final title = video['title'] ?? '';
    final category = video['category'] ?? '';
    final status = video['status'] ?? 'draft';
    final duration = video['duration_minutes'];
    final createdAt = video['created_at'] as String?;
    final publishAt = video['publish_at'] as String?;
    final thumbnailUrl = video['thumbnail_url'] as String?;

    return Dismissible(
      key: ValueKey(video['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.red, size: 28),
      ),
      confirmDismiss: (_) async {
        _confirmDelete(video);
        return false; // We handle deletion in the dialog
      },
      child: GestureDetector(
        onTap: () => _showVideoForm(existing: video),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _thumbnailPlaceholder(),
                        )
                      : _thumbnailPlaceholder(),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Badges row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _badge(category, _gold),
                          _badge(
                            _statusLabel(status),
                            _statusColor(status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Meta row
                      Row(
                        children: [
                          if (duration != null) ...[
                            const Icon(Icons.timer_outlined,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$duration min',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (createdAt != null) ...[
                            const Icon(Icons.calendar_today,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(createdAt),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ],
                      ),

                      // Scheduled date
                      if (status == 'scheduled' && publishAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Publicação: ${_formatDate(publishAt)}',
                              style: const TextStyle(
                                  color: Colors.orange, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Delete button
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 4),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white24, size: 20),
                  onPressed: () => _confirmDelete(video),
                  tooltip: 'Excluir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: Colors.white10,
      child: const Center(
        child: Icon(Icons.play_circle_outline, color: _gold, size: 40),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
