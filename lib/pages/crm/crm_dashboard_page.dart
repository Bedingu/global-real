import 'package:flutter/material.dart';
import '../../services/crm_service.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../generated/app_localizations.dart';
import 'crm_account_settings_page.dart';
import 'crm_notification_settings_page.dart';
import 'crm_plan_page.dart';
import 'crm_properties_page.dart';
import 'crm_condominiums_page.dart';
import 'crm_keys_page.dart';
import 'crm_proposals_page.dart';
import 'crm_leads_page.dart';
import 'crm_lead_roulette_page.dart';
import 'crm_people_page.dart';
import 'crm_opportunities_page.dart';
import 'crm_activities_page.dart';
import 'crm_portals_page.dart';
import 'crm_rentals_contracts_page.dart';
import 'crm_rentals_invoices_page.dart';
import 'crm_rentals_transfers_page.dart';
import 'crm_rentals_analysis_page.dart';
import 'crm_rentals_billing_page.dart';

class CrmDashboardPage extends StatefulWidget {
  const CrmDashboardPage({super.key});

  @override
  State<CrmDashboardPage> createState() => _CrmDashboardPageState();
}

class _CrmDashboardPageState extends State<CrmDashboardPage> {
  CrmDashboardData? _data;
  bool _loading = true;
  int _selectedIndex = 0;
  bool _isRentalsExpanded = false;
  bool _isMySiteExpanded = false;
  bool _isSystemExpanded = false;

  static final _rentalsSubItems = [
    _SubItem('Contratos', const CrmRentalsContractsPage()),
    _SubItem('Faturas', const CrmRentalsInvoicesPage()),
    _SubItem('Repasses', const CrmRentalsTransfersPage()),
    _SubItem('Análises', const CrmRentalsAnalysisPage()),
    _SubItem('Régua de cobrança', const CrmRentalsBillingPage()),
  ];

  static const _mySiteSubLabels = ['Configurações', 'Blog', 'Páginas', 'Depoimentos'];
  static const _systemSubLabels = ['Configurações', 'Etiquetas e origens', 'Feriados', 'Usuários e grupos', 'Modelos de Doc', 'Importador XML', 'Webhooks'];

  static const _menuItems = [
    _MenuItem(icon: Icons.home_outlined, labelKey: 'crm_home'),
    _MenuItem(icon: Icons.apartment_outlined, labelKey: 'crm_properties'),
    _MenuItem(icon: Icons.domain_outlined, labelKey: 'crm_condominiums'),
    _MenuItem(icon: Icons.vpn_key_outlined, labelKey: 'crm_keys'),
    _MenuItem(icon: Icons.description_outlined, labelKey: 'crm_proposals'),
    _MenuItem(icon: Icons.people_outline, labelKey: 'crm_leads'),
    _MenuItem(icon: Icons.casino_outlined, labelKey: 'crm_lead_roulette'),
    _MenuItem(icon: Icons.person_outline, labelKey: 'crm_people'),
    _MenuItem(icon: Icons.trending_up_outlined, labelKey: 'crm_opportunities'),
    _MenuItem(icon: Icons.event_outlined, labelKey: 'crm_activities'),
    _MenuItem(icon: Icons.language_outlined, labelKey: 'crm_portals'),
    _MenuItem(icon: Icons.home_work_outlined, labelKey: 'crm_rentals'),
    _MenuItem(icon: Icons.sell_outlined, labelKey: 'crm_sales'),
    _MenuItem(icon: Icons.bar_chart_outlined, labelKey: 'crm_reports'),
    _MenuItem(icon: Icons.extension_outlined, labelKey: 'crm_integrations'),
    _MenuItem(icon: Icons.web_outlined, labelKey: 'crm_mysite'),
    _MenuItem(icon: Icons.settings_outlined, labelKey: 'crm_system'),
    _MenuItem(icon: Icons.info_outline, labelKey: 'crm_support'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await CrmService.fetchDashboard();
    if (!mounted) return;
    setState(() { _data = data; _loading = false; });
  }

  String _menuLabel(String key) {
    switch (key) {
      case 'crm_home': return 'Início';
      case 'crm_properties': return 'Imóveis';
      case 'crm_condominiums': return 'Condomínios';
      case 'crm_keys': return 'Chaves';
      case 'crm_proposals': return 'Propostas';
      case 'crm_leads': return 'Leads';
      case 'crm_lead_roulette': return 'Roletas de leads';
      case 'crm_people': return 'Pessoas';
      case 'crm_opportunities': return 'Oportunidades';
      case 'crm_activities': return 'Atividades';
      case 'crm_portals': return 'Portais';
      case 'crm_rentals': return 'Aluguéis';
      case 'crm_sales': return 'Vendas';
      case 'crm_reports': return 'Relatórios';
      case 'crm_integrations': return 'Integrações';
      case 'crm_mysite': return 'Meu site';
      case 'crm_system': return 'Sistema';
      case 'crm_support': return 'Dicas e apoio';
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Row(
            children: [
              // Sidebar
              _buildSidebar(isWide),
              // Content
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _selectedIndex == 0
                              ? _buildDashboardContent()
                              : Center(
                                  child: Text(
                                    _menuLabel(_menuItems[_selectedIndex].labelKey),
                                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(bool isWide) {
    return Container(
      width: isWide ? 220 : 60,
      color: AppTheme.primaryBlue,
      child: Column(
        children: [
          // Logo area
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.apartment, color: Colors.white, size: 24),
                if (isWide) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'Global Real',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (_, i) {
                final item = _menuItems[i];
                final selected = _selectedIndex == i;
                final menuItem = Material(
                  color: selected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (i == 1) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmPropertiesPage()));
                      } else if (i == 2) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmCondominiumsPage()));
                      } else if (i == 3) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmKeysPage()));
                      } else if (i == 4) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmProposalsPage()));
                      } else if (i == 5) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmLeadsPage()));
                      } else if (i == 6) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmLeadRoulettePage()));
                      } else if (i == 7) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmPeoplePage()));
                      } else if (i == 8) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmOpportunitiesPage()));
                      } else if (i == 9) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmActivitiesPage()));
                      } else if (i == 10) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmPortalsPage()));
                      } else if (i == 11) {
                        setState(() => _isRentalsExpanded = !_isRentalsExpanded);
                      } else if (i == 15) {
                        setState(() => _isMySiteExpanded = !_isMySiteExpanded);
                      } else if (i == 16) {
                        setState(() => _isSystemExpanded = !_isSystemExpanded);
                      } else {
                        setState(() => _selectedIndex = i);
                      }
                    },
                    child: Container(
                      height: 44,
                      padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
                      alignment: isWide ? Alignment.centerLeft : Alignment.center,
                      child: Row(
                        mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
                        children: [
                          Icon(item.icon, color: selected ? Colors.white : Colors.white60, size: 20),
                          if (isWide) ...[
                            const SizedBox(width: 12),
                            Expanded(child: Text(
                              _menuLabel(item.labelKey),
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white60,
                                fontSize: 13,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            )),
                            if (item.labelKey == 'crm_rentals')
                              Icon(_isRentalsExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white60, size: 18),
                            if (item.labelKey == 'crm_mysite')
                              Icon(_isMySiteExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white60, size: 18),
                            if (item.labelKey == 'crm_system')
                              Icon(_isSystemExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white60, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
                if (item.labelKey == 'crm_rentals' && _isRentalsExpanded && isWide) {
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    menuItem,
                    ..._rentalsSubItems.map((sub) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => sub.page)),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.only(left: 48),
                          alignment: Alignment.centerLeft,
                          child: Text(sub.label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ),
                      ),
                    )),
                  ]);
                }
                if (item.labelKey == 'crm_mysite' && _isMySiteExpanded && isWide) {
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    menuItem,
                    ..._mySiteSubLabels.map((label) => _subMenuItem(label)),
                  ]);
                }
                if (item.labelKey == 'crm_system' && _isSystemExpanded && isWide) {
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    menuItem,
                    ..._systemSubLabels.map((label) => _subMenuItem(label)),
                  ]);
                }
                return menuItem;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      color: AppTheme.primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '🔍',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Global Real Estate',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmAccountSettingsPage()));
                  break;
                case 'notifications':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmNotificationSettingsPage()));
                  break;
                case 'plan':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CrmPlanPage()));
                  break;
                case 'back':
                  Navigator.pop(context);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'settings', child: Row(children: [
                Icon(Icons.people_outline, size: 18), SizedBox(width: 8), Text('Configurações da conta'),
              ])),
              const PopupMenuItem(value: 'notifications', child: Row(children: [
                Icon(Icons.notifications_outlined, size: 18), SizedBox(width: 8), Text('Configurações de notificações'),
              ])),
              const PopupMenuItem(value: 'plan', child: Row(children: [
                Icon(Icons.rocket_launch_outlined, size: 18), SizedBox(width: 8), Text('Meu plano'),
              ])),
              const PopupMenuItem(value: 'remote', child: Row(children: [
                Icon(Icons.desktop_windows_outlined, size: 18), SizedBox(width: 8), Text('Acesso remoto'),
              ])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'back', child: Row(children: [
                Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Sair'),
              ])),
              PopupMenuItem(
                enabled: false,
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/privacidade'),
                      child: const Text('Política de privacidade', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Termos de uso', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                    ),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Text(
                    'G',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final d = _data!;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Atividades + Aluguéis + Propostas
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _activitiesCard(d)),
                      const SizedBox(width: 16),
                      Expanded(child: _rentalsCard(d)),
                      const SizedBox(width: 16),
                      Expanded(child: _proposalsCard(d)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _activitiesCard(d),
                    const SizedBox(height: 16),
                    _rentalsCard(d),
                    const SizedBox(height: 16),
                    _proposalsCard(d),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Row 2: Imóveis + Contratos + Chaves
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _propertiesCard(d)),
                      const SizedBox(width: 16),
                      Expanded(child: _contractsCard(d)),
                      const SizedBox(width: 16),
                      Expanded(child: _keysCard(d)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _propertiesCard(d),
                    const SizedBox(height: 16),
                    _contractsCard(d),
                    const SizedBox(height: 16),
                    _keysCard(d),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CARDS ====================

  Widget _sectionCard({
    required IconData icon,
    required String title,
    String? actionLabel,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                if (actionLabel != null)
                  TextButton(
                    onPressed: () {},
                    child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _activitiesCard(CrmDashboardData d) {
    return _sectionCard(
      icon: Icons.event_outlined,
      title: 'Atividades',
      actionLabel: 'Ver todos',
      child: d.activitiesDueToday == 0
          ? Column(
              children: [
                Icon(Icons.check_circle, size: 48, color: Colors.green[400]),
                const SizedBox(height: 12),
                Text(
                  'Nenhuma atividade atrasada ou\nagendada para hoje!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[400]),
                const SizedBox(width: 8),
                Text(
                  '${d.activitiesDueToday} atividade(s) pendente(s)',
                  style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w600),
                ),
              ],
            ),
    );
  }

  Widget _rentalsCard(CrmDashboardData d) {
    return _sectionCard(
      icon: Icons.home_work_outlined,
      title: 'Aluguéis',
      actionLabel: 'Ver todos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pendências', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statItem('${d.rentalsPendingInvoices}', 'Faturas\natrasadas'),
              _statItem('${d.rentalsBoletos7d}', 'Boletos\nexpiram em 7d'),
              _statItem('${d.rentalsPendingTransfers}', 'Repasses\npendentes'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Contratos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statItem('${d.contractsNotice}', 'Em aviso\nprévio'),
              _statItem('${d.contractsGuaranteesExpiring}', 'Garantias\nvencendo'),
              _statItem('${d.contractsReadjust}', 'Para reajustar\nneste mês'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proposalsCard(CrmDashboardData d) {
    return _sectionCard(
      icon: Icons.description_outlined,
      title: 'Propostas',
      child: Column(
        children: [
          _listRow('${d.proposalsActive} ativas', Colors.blue),
          const SizedBox(height: 8),
          _listRow('${d.proposalsDueToday} vencem hoje', Colors.orange),
        ],
      ),
    );
  }

  Widget _propertiesCard(CrmDashboardData d) {
    return _sectionCard(
      icon: Icons.apartment_outlined,
      title: 'Imóveis',
      actionLabel: 'Ver todos',
      child: Column(
        children: [
          Text(
            '${d.propertiesTotal}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          Text('Imóveis', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          _statusBadge('${d.propertiesPending} Em aprovação', const Color(0xFF2563EB)),
          const SizedBox(height: 6),
          _statusBadge('${d.propertiesUpdated} Atualizados', const Color(0xFF10B981)),
          const SizedBox(height: 6),
          _statusBadge('${d.propertiesExpiring} Expirando', const Color(0xFFF59E0B)),
          const SizedBox(height: 6),
          _statusBadge('${d.propertiesOutdated} Desatualizados', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _contractsCard(CrmDashboardData d) {
    return _sectionCard(
      icon: Icons.article_outlined,
      title: 'Contratos',
      child: Row(
        children: [
          _statItem('${d.contractsNotice}', 'Em aviso\nprévio'),
          _statItem('${d.contractsGuaranteesExpiring}', 'Garantias\nvencendo'),
          _statItem('${d.contractsReadjust}', 'Para reajustar\nneste mês'),
        ],
      ),
    );
  }

  Widget _keysCard(CrmDashboardData d) {
    return _sectionCard(
      icon: Icons.vpn_key_outlined,
      title: 'Chaves',
      actionLabel: 'Ver todas',
      child: Column(
        children: [
          _listRow('${d.keysWithdrawn} retiradas', Colors.blue),
          const SizedBox(height: 8),
          _listRow('${d.keysLate} atrasadas', Colors.red),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  Widget _subMenuItem(String label) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      child: Container(
        height: 36,
        padding: const EdgeInsets.only(left: 48),
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ),
    ),
  );

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _listRow(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String labelKey;
  const _MenuItem({required this.icon, required this.labelKey});
}

class _SubItem {
  final String label;
  final Widget page;
  const _SubItem(this.label, this.page);
}
