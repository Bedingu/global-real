import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dashboard/dashboard_page.dart';

/// Fluxo "Seja um Corretor Associado".
///
/// Comunica que a associação é um processo à parte, com aprovação humana via
/// videoconferência (conforme o PDF de reposicionamento), e leva o candidato
/// a agendar a conversa de qualificação com o time da Global (Leandro).
class AssociatePage extends StatelessWidget {
  const AssociatePage({super.key});

  // Link real de agendamento do Leandro (Calendly/Cal.com). Enquanto vazio,
  // o botão mostra um aviso de "agenda em configuração" em vez de abrir um
  // link quebrado. Basta preencher com a URL para ativar o agendamento real.
  static const String _schedulingUrl = '';

  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF22C55E);

  Future<void> _openScheduling(BuildContext context) async {
    // Sem link configurado ainda: mostra aviso amigável em vez de link quebrado.
    if (_schedulingUrl.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.event_available, color: _gold, size: 32),
          title: const Text(
            'Agenda em configuração',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Em breve você poderá escolher aqui o melhor horário para sua '
            'videoconferência de qualificação com o time da Global.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendi',
                    style: TextStyle(
                        color: _gold, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final uri = Uri.parse(_schedulingUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a agenda. Tente novamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1628),
        title: const Text('Seja um Corretor Associado',
            style: TextStyle(fontSize: 15)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Opere o portfólio da Global de qualquer lugar do Brasil',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Como associado, você tem acesso a mais de 100 empreendimentos '
                    'e diversos fundos de investimento que a Global já opera em São Paulo.',
                    style: TextStyle(
                        color: Colors.white60, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _noticeCard(),
                  const SizedBox(height: 24),
                  _stepsTitle(),
                  const SizedBox(height: 12),
                  _step(1, 'Agende sua videoconferência',
                      'Escolha um horário para conversar com o time da Global.'),
                  _step(2, 'Conversa de qualificação',
                      'Uma conversa por vídeo onde os termos da parceria são definidos.',
                      isLast: false),
                  _step(3, 'Aprovação e acesso',
                      'Aprovado, você passa a operar o portfólio completo.',
                      isLast: true),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openScheduling(context),
                      icon: const Icon(Icons.videocam_outlined, size: 20),
                      label: const Text('Agendar minha videoconferência',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'A conversa é obrigatória para se tornar associado.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardPage()),
                      ),
                      icon: const Icon(Icons.trending_up, size: 20),
                      label: const Text('Acessar Portfólio',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: BorderSide(color: _blue.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Aviso em destaque: associação é processo à parte, com aprovação humana.
  Widget _noticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: _blue, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Virar associado é um processo à parte, com aprovação humana via '
              'videoconferência. Não é um acesso automático: você conversa com o '
              'time da Global antes de operar o portfólio.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepsTitle() {
    return const Text(
      'Como funciona',
      style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _step(int number, String title, String desc, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text('$number',
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: _border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              SizedBox(
                width: 560,
                child: Text(desc,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12.5, height: 1.4)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
