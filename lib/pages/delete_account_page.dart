import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF111C2E);
  static const _border = Color(0xFF1F2A44);
  static const _gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo_global_real.png', height: 48),
                const SizedBox(height: 32),
                const Text(
                  'Exclusão de Conta e Dados',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Global Real Estate',
                  style: TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _infoCard(
                  'Como solicitar a exclusão',
                  'Para solicitar a exclusão da sua conta e todos os dados associados, '
                  'envie um email para o endereço abaixo com o assunto "Exclusão de conta", '
                  'informando o email cadastrado no app.',
                ),
                const SizedBox(height: 16),
                _infoCard(
                  'Dados que serão excluídos',
                  '• Dados de perfil (nome, email)\n'
                  '• Favoritos e preferências\n'
                  '• Histórico de navegação no app\n'
                  '• Dados de assinatura (cancelada automaticamente)',
                ),
                const SizedBox(height: 16),
                _infoCard(
                  'Prazo de exclusão',
                  'Seus dados serão excluídos permanentemente em até 30 dias '
                  'após a confirmação da solicitação. Dados de transações financeiras '
                  'podem ser mantidos por até 5 anos conforme exigência legal.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('mailto:contato@globalrealestate.com.br?subject=Exclusão de conta');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    icon: const Icon(Icons.email_outlined, size: 20),
                    label: const Text('Enviar Email de Solicitação',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'contato@globalrealestate.com.br',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Voltar ao início', style: TextStyle(color: Colors.white38)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}
