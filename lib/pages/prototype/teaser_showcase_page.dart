import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/paywall/paywall_modal.dart';
import '../private/private_page.dart';
import 'teaser_player.dart';

/// Vitrine de teasers do Curso.
///
/// Mostra vídeos curtos (5-10s) gratuitos para aguçar a curiosidade e levar
/// à compra (assinatura premium). Puxa da tabela `education_content` os
/// registros com status='published' e is_teaser=true. Se não houver nenhum
/// cadastrado ainda, cai em exemplos embutidos para o protótipo funcionar.
class TeaserShowcasePage extends StatefulWidget {
  const TeaserShowcasePage({super.key});

  @override
  State<TeaserShowcasePage> createState() => _TeaserShowcasePageState();
}

class _Teaser {
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  const _Teaser({
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
  });
}

class _TeaserShowcasePageState extends State<TeaserShowcasePage> {
  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);

  // Exemplos usados enquanto não há teasers reais no Supabase.
  // (vídeos públicos de amostra — trocar pelos MP4 do bucket development-videos)
  static const _sampleTeasers = <_Teaser>[
    _Teaser(
      title: 'SCP: o segredo dos grandes investidores',
      description:
          'Por que os grandes usam SCP para multiplicar patrimônio no imobiliário.',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      durationSeconds: 9,
    ),
    _Teaser(
      title: 'Venda rentabilidade, não metragem',
      description:
          'A virada de chave no discurso de quem fecha com investidor.',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      durationSeconds: 9,
    ),
    _Teaser(
      title: 'Opere o portfólio da Global de onde estiver',
      description:
          'Mais de 100 empreendimentos em São Paulo, sem sair de casa.',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      durationSeconds: 8,
    ),
  ];

  late Future<List<_Teaser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTeasers();
  }

  Future<List<_Teaser>> _loadTeasers() async {
    try {
      final data = await Supabase.instance.client
          .from('education_content')
          .select()
          .eq('status', 'published')
          .eq('is_teaser', true)
          .order('created_at', ascending: false);

      final rows = List<Map<String, dynamic>>.from(data);
      final teasers = rows
          .where((r) => (r['video_url'] as String?)?.isNotEmpty ?? false)
          .map((r) => _Teaser(
                title: r['title'] as String? ?? 'Teaser',
                description: r['description'] as String? ?? '',
                videoUrl: r['video_url'] as String,
                thumbnailUrl: r['thumbnail_url'] as String?,
                durationSeconds: (r['duration_minutes'] as num?)?.toInt(),
              ))
          .toList();

      // Sem teasers reais ainda → usa exemplos para o protótipo.
      return teasers.isEmpty ? _sampleTeasers : teasers;
    } catch (_) {
      return _sampleTeasers;
    }
  }

  void _openTeaser(_Teaser t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeaserPlayer(videoUrl: t.videoUrl, title: t.title),
      ),
    );
  }

  Future<void> _unlockCourse() async {
    final isPremium = await AuthService.isPremiumUser();
    if (!mounted) return;
    if (isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PrivatePage(
            initialType: PrivateInvestmentType.education,
          ),
        ),
      );
    } else {
      _openPaywall();
    }
  }

  void _openPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallModal(
        onSubscribe: (planType) {
          final priceId = planType == 'annual'
              ? PaymentService.annualPriceId
              : PaymentService.monthlyPriceId;
          PaymentService.startCheckout(priceId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1628),
        title: Row(
          children: const [
            Icon(Icons.play_circle_outline, color: _gold, size: 20),
            SizedBox(width: 8),
            Text('Prévias do Curso', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: FutureBuilder<List<_Teaser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _gold));
          }
          final teasers = snapshot.data ?? const <_Teaser>[];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dê uma espiada no curso',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Prévias rápidas e gratuitas. Curtiu? Desbloqueie o curso completo.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ...teasers.map(_teaserCard),
                const SizedBox(height: 8),
                _unlockCta(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _teaserCard(_Teaser t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTeaser(t),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: t.thumbnailUrl != null && t.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          t.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbFallback(),
                        )
                      : _thumbFallback(),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold, width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: _gold, size: 30),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PRÉVIA GRÁTIS',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                if (t.durationSeconds != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${t.durationSeconds}s',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  if (t.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(t.description,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbFallback() {
    return Container(
      color: const Color(0xFF0D1628),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white24, size: 40),
      ),
    );
  }

  Widget _unlockCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F00), Color(0xFF1A1500)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gostou das prévias?',
              style: TextStyle(
                  color: _gold, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Desbloqueie o curso completo: todas as aulas, trilhas Varejo e Private e certificado.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _unlockCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Desbloquear curso completo',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
