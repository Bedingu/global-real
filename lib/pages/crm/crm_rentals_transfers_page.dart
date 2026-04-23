import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmRentalsTransfersPage extends StatelessWidget {
  const CrmRentalsTransfersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Repasses'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('ALUGUÉIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
            const Text('REPASSES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 24),
          Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
            child: Padding(padding: const EdgeInsets.all(40),
              child: Center(child: Column(children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Nenhum repasse encontrado.', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
              ])))),
        ]),
      ),
    );
  }
}
