import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemHolidaysPage extends StatelessWidget {
  const CrmSystemHolidaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Feriados'), backgroundColor: AppTheme.primaryBlue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('FERIADOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Info + button
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Feriados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'A lista mostra todos os feriados nacionais, estaduais e municipais brasileiros. Quando o vencimento de uma fatura coincidir com a data de um feriado, será adiado até o próximo dia útil.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Novo feriado', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          // Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('Data', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                    DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                    DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                    DataColumn(label: Text('Município', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                    DataColumn(label: Text('', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                  ],
                  rows: _holidays.map((h) => DataRow(cells: [
                    DataCell(Text(h.date, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(h.name, style: const TextStyle(fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: h.type == 'Nacional' ? const Color(0xFF1E40AF).withValues(alpha: 0.1) : h.type == 'Estadual' ? const Color(0xFF059669).withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(h.type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: h.type == 'Nacional' ? const Color(0xFF1E40AF) : h.type == 'Estadual' ? const Color(0xFF059669) : Colors.grey[700])),
                    )),
                    DataCell(Text(h.city ?? '-', style: const TextStyle(fontSize: 12))),
                    DataCell(h.type != 'Nacional' ? Row(mainAxisSize: MainAxisSize.min, children: [
                      TextButton(onPressed: () {}, child: const Text('Editar', style: TextStyle(fontSize: 11))),
                      TextButton(onPressed: () {}, child: const Text('Excluir', style: TextStyle(fontSize: 11, color: Colors.red))),
                    ]) : const SizedBox()),
                  ])).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Holiday {
  final String date;
  final String name;
  final String type;
  final String? city;
  const _Holiday(this.date, this.name, this.type, [this.city]);
}

const _holidays = [
  _Holiday('01/01', 'Ano Novo', 'Nacional'),
  _Holiday('02/01', 'Feriado Municipal', 'Municipal', 'Centenário do Sul - PR'),
  _Holiday('02/01', 'Feriado Municipal', 'Municipal', 'Salinas da Margarida - BA'),
  _Holiday('02/01', 'Feriado Municipal', 'Municipal', 'Inajá - PE'),
  _Holiday('02/01', 'Feriado Municipal', 'Municipal', 'Icó - CE'),
  _Holiday('02/01', 'Feriado Municipal', 'Municipal', 'Porecatu - PR'),
  _Holiday('04/01', 'Aniversário de Rondônia', 'Estadual', 'RO'),
  _Holiday('06/01', 'Dia de Santos Reis', 'Municipal', 'Natal - RN'),
  _Holiday('10/01', 'São Gonçalo', 'Municipal', 'São Gonçalo - RJ'),
  _Holiday('12/01', 'Aniversário de Belém', 'Municipal', 'Belém - PA'),
  _Holiday('20/01', 'São Sebastião', 'Municipal', 'Ribeirão Preto - SP'),
  _Holiday('20/01', 'São Sebastião', 'Municipal', 'Rio de Janeiro - RJ'),
  _Holiday('22/01', 'Dia do Católico', 'Estadual', 'AC'),
  _Holiday('25/01', 'Aniversário da Cidade', 'Municipal', 'São Paulo - SP'),
  _Holiday('26/01', 'Aniversário da Cidade', 'Municipal', 'Santos - SP'),
  _Holiday('21/04', 'Tiradentes', 'Nacional'),
  _Holiday('01/05', 'Dia do Trabalho', 'Nacional'),
  _Holiday('07/09', 'Independência do Brasil', 'Nacional'),
  _Holiday('12/10', 'Nossa Sra. Aparecida', 'Nacional'),
  _Holiday('02/11', 'Finados', 'Nacional'),
  _Holiday('15/11', 'Proclamação da República', 'Nacional'),
  _Holiday('25/12', 'Natal', 'Nacional'),
];
