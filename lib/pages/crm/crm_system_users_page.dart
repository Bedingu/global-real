import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemUsersPage extends StatefulWidget {
  const CrmSystemUsersPage({super.key});

  @override
  State<CrmSystemUsersPage> createState() => _CrmSystemUsersPageState();
}

class _CrmSystemUsersPageState extends State<CrmSystemUsersPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
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
      appBar: AppBar(title: const Text('Usuários e grupos de permissão'), backgroundColor: AppTheme.primaryBlue),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('USUÁRIOS E GRUPOS DE PERMISSÃO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryBlue,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Usuários (1)'),
                Tab(text: 'Grupos de permissão (7)'),
                Tab(text: 'Equipes (1)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildUsersTab(),
                _buildGroupsTab(),
                _buildTeamsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo usuário', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('Nome do usuário', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('E-mail', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Grupos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Último acesso', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('GUSTAVO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  DataCell(Text('gustavobedinbedin@gmail.com', style: TextStyle(fontSize: 12))),
                  DataCell(Text('Administrador', style: TextStyle(fontSize: 12))),
                  DataCell(Text('26/06/2026 às 12:32', style: TextStyle(fontSize: 12))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    final groups = ['Administrador', 'Gerente Locações', 'Gerente Vendas', 'Corretor', 'Assistente', 'Financeiro', 'Marketing'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo grupo', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 16),
          ...groups.map((g) => Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: const Icon(Icons.shield_outlined, size: 20),
              title: Text(g, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
              ]),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nova equipe', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 16),
          DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            columns: const [
              DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              DataColumn(label: Text('Membros', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Equipe Matriz', style: TextStyle(fontSize: 13))),
                DataCell(Text('1', style: TextStyle(fontSize: 13))),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
