import 'package:flutter/material.dart';
import '../../theme.dart';

class CrmSystemXmlPage extends StatelessWidget {
  const CrmSystemXmlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Importar XML'), backgroundColor: AppTheme.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Text('INÍCIO', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              const Text('IMPORTAR XML', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 24),
            // Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Importador de imóveis padrão VRSync', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 24),
                    const Text('Enviar XML', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    // Upload area
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecionar arquivo XML...'), duration: Duration(seconds: 2)),
                        );
                      },
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
                            Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Adicionar arquivo', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text('Arraste ou clique para selecionar', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
