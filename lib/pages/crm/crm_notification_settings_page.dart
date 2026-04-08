import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmNotificationSettingsPage extends StatefulWidget {
  const CrmNotificationSettingsPage({super.key});

  @override
  State<CrmNotificationSettingsPage> createState() => _CrmNotificationSettingsPageState();
}

class _CrmNotificationSettingsPageState extends State<CrmNotificationSettingsPage> {
  String _search = '';

  // Estado dos checkboxes: chave = "modulo.notificacao.canal" (whatsapp/push)
  final Map<String, bool> _settings = {};

  // Estrutura de módulos e notificações
  static final _modules = [
    _Module(icon: Icons.apartment_outlined, title: 'Imóveis', notifications: [
      _Notif(key: 'property_approved', title: 'Cadastro de imóvel aprovado', desc: 'O cadastro do imóvel foi aprovado.'),
      _Notif(key: 'property_rejected', title: 'Cadastro de imóvel não aprovado', desc: 'Revisar imóvel pois o cadastro não foi aprovado.'),
      _Notif(key: 'property_imported', title: 'Imóveis importados', desc: 'Os imóveis solicitados para importação foram finalizados.'),
    ]),
    _Module(icon: Icons.vpn_key_outlined, title: 'Chaves', notifications: [
      _Notif(key: 'key_late', title: 'Devolução de chave atrasada', desc: 'Chave emprestada tinha devolução agendada para hoje.'),
    ]),
    _Module(icon: Icons.people_outline, title: 'Leads', notifications: [
      _Notif(key: 'lead_new', title: 'Novo lead', desc: 'Um novo lead aguarda seu contato.'),
      _Notif(key: 'lead_accepted', title: 'Lead aceito', desc: 'O lead tornou-se seu lead.'),
      _Notif(key: 'lead_rejected', title: 'Lead recusado', desc: 'O lead será repassado para outro atendimento.'),
      _Notif(key: 'lead_expired', title: 'Lead expirado', desc: 'O lead aguardava seu contato.'),
    ]),
    _Module(icon: Icons.trending_up_outlined, title: 'Oportunidades', notifications: [
      _Notif(key: 'opp_property_discarded', title: 'Imóvel descartado', desc: 'Um assessor descartou o imóvel.'),
      _Notif(key: 'opp_visit_scheduled', title: 'Visita agendada a imóvel', desc: 'Uma visita foi agendada no imóvel.'),
      _Notif(key: 'opp_note_added', title: 'Nota adicionada', desc: 'Uma nota foi adicionada na oportunidade.'),
      _Notif(key: 'opp_compatible', title: 'Imóvel compatível com oportunidade', desc: 'Um imóvel foi atualizado e pode interessar ao lead.'),
      _Notif(key: 'opp_new', title: 'Nova oportunidade', desc: 'Uma nova oportunidade foi cadastrada para você.'),
      _Notif(key: 'opp_transfer', title: 'Transferência de oportunidades', desc: 'Oportunidades foram transferidas para você.'),
      _Notif(key: 'opp_info_request', title: 'Informação solicitada sobre imóvel', desc: 'Alguém solicitou informações sobre o imóvel.'),
      _Notif(key: 'opp_exchange', title: 'Permuta compatível', desc: 'Um imóvel aceita permuta e pode interessar ao lead.'),
    ]),
    _Module(icon: Icons.event_outlined, title: 'Atividades', notifications: [
      _Notif(key: 'act_visit', title: 'Visita', desc: 'Agendado para hoje.'),
      _Notif(key: 'act_email', title: 'E-mail', desc: 'Agendado para hoje.'),
      _Notif(key: 'act_meeting', title: 'Reunião', desc: 'Agendado para hoje.'),
      _Notif(key: 'act_task', title: 'Tarefa', desc: 'Agendado para hoje.'),
      _Notif(key: 'act_message', title: 'Mensagem', desc: 'Agendado para hoje.'),
      _Notif(key: 'act_call', title: 'Ligação', desc: 'Agendado para hoje.'),
    ]),
    _Module(icon: Icons.home_work_outlined, title: 'Locação', notifications: [
      _Notif(key: 'rent_invoice_error', title: 'Erro na fatura', desc: 'A fatura do contrato não pôde ser gerada.'),
      _Notif(key: 'rent_boleto_expiring', title: 'Boleto de locatário expirando', desc: 'Boleto do contrato expira em 2 dias.'),
      _Notif(key: 'rent_reminder', title: 'Lembrete financeiro', desc: 'Você tem uma fatura que vence hoje.'),
      _Notif(key: 'rent_cancelled_payment', title: 'Pagamento de fatura cancelada', desc: 'Foi identificado um pagamento em uma fatura cancelada.'),
      _Notif(key: 'rent_transfer_fail', title: 'Falha de transferência', desc: 'A transferência solicitada não foi concluída.'),
      _Notif(key: 'rent_irrf', title: 'Lançamento de IRRF', desc: 'Lançamento de IRRF requer atenção.'),
      _Notif(key: 'rent_auto_transfer_fail', title: 'Falha em repasse automático', desc: 'Repasses automáticos do contrato falharam.'),
      _Notif(key: 'rent_pix_fail', title: 'Falha de PIX', desc: 'O PIX solicitado falhou, uma nova tentativa via TED foi realizada.'),
    ]),
    _Module(icon: Icons.backup_outlined, title: 'Backup', notifications: [
      _Notif(key: 'backup_fail', title: 'Falha de backup', desc: 'Ocorreu um erro com a solicitação de backup.'),
      _Notif(key: 'backup_ready', title: 'Backup pronto', desc: 'O backup está pronto para download.'),
    ]),
    _Module(icon: Icons.person_outline, title: 'Usuário', notifications: [
      _Notif(key: 'user_other_device', title: 'Outro dispositivo utilizado', desc: 'Seu usuário foi utilizado em outro dispositivo.'),
    ]),
    _Module(icon: Icons.email_outlined, title: 'E-mail', notifications: [
      _Notif(key: 'email_added', title: 'E-mail adicionado', desc: 'Lembre-se de alterar a senha já no primeiro acesso.'),
      _Notif(key: 'email_removed', title: 'E-mail excluído', desc: 'O e-mail foi excluído.'),
      _Notif(key: 'email_edited', title: 'E-mail editado', desc: 'Lembre-se de alterar a senha já no primeiro acesso.'),
    ]),
    _Module(icon: Icons.notifications_outlined, title: 'Notificações Global Real', notifications: [
      _Notif(key: 'gr_invoice', title: 'Sua fatura Global Real está pronta', desc: 'Sua fatura referente à competência já está disponível para pagamento.'),
      _Notif(key: 'gr_chat', title: 'Nova mensagem no chat de atendimento', desc: 'A equipe de suporte enviou uma nova mensagem para você.'),
    ]),
  ];

  List<_Module> get _filteredModules {
    if (_search.isEmpty) return _modules;
    final q = _search.toLowerCase();
    return _modules.where((m) =>
      m.title.toLowerCase().contains(q) ||
      m.notifications.any((n) => n.title.toLowerCase().contains(q) || n.desc.toLowerCase().contains(q))
    ).toList();
  }

  bool _getValue(String key, String channel) => _settings['$key.$channel'] ?? false;

  void _setValue(String key, String channel, bool val) {
    setState(() => _settings['$key.$channel'] = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Configurações de Notificações'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Column(
        children: [
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
                      const Text('CONFIGURAÇÕES DE NOTIFICAÇÕES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Card principal
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          const Row(
                            children: [
                              Icon(Icons.notifications_outlined, size: 20, color: AppTheme.primaryBlue),
                              SizedBox(width: 8),
                              Text('Notificações', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Banner push desabilitado
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Suas notificações Push estão desabilitadas nesse navegador. Veja como habilitá-las clicando aqui.',
                                    style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Busca
                          const Text('Busca', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) => setState(() => _search = v),
                            decoration: InputDecoration(
                              hintText: 'Busque por módulo do sistema ou nome de uma notificação',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                              prefixIcon: const Icon(Icons.search, size: 20),
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
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Header: Módulos | WhatsApp | Push
                          const Text('Módulos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Spacer(),
                              Row(children: [
                                Icon(Icons.chat_outlined, size: 16, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text('WhatsApp', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                const SizedBox(width: 4),
                                Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
                              ]),
                              const SizedBox(width: 24),
                              Row(children: [
                                Icon(Icons.notifications_outlined, size: 16, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text('Push', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                const SizedBox(width: 4),
                                Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
                              ]),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const Divider(height: 24),

                          // Módulos
                          ..._filteredModules.map((m) => _buildModule(m)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar: Cancelar / Salvar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: salvar preferências no Supabase
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preferências salvas!'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModule(_Module module) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Module header
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Row(
            children: [
              Icon(module.icon, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                module.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryBlue),
              ),
            ],
          ),
        ),
        // Notifications
        ...module.notifications.map((n) => _buildNotifRow(n)),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildNotifRow(_Notif notif) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(notif.desc, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // WhatsApp checkbox
          SizedBox(
            width: 60,
            child: Center(
              child: Checkbox(
                value: _getValue(notif.key, 'whatsapp'),
                onChanged: (v) => _setValue(notif.key, 'whatsapp', v ?? false),
                activeColor: AppTheme.primaryBlue,
              ),
            ),
          ),
          // Push checkbox
          SizedBox(
            width: 60,
            child: Center(
              child: Checkbox(
                value: _getValue(notif.key, 'push'),
                onChanged: (v) => _setValue(notif.key, 'push', v ?? false),
                activeColor: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Module {
  final IconData icon;
  final String title;
  final List<_Notif> notifications;
  const _Module({required this.icon, required this.title, required this.notifications});
}

class _Notif {
  final String key;
  final String title;
  final String desc;
  const _Notif({required this.key, required this.title, required this.desc});
}
