import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../models/material_model.dart';

class MaterialDetailsScreen extends StatelessWidget {
  final MaterialModel item;

  const MaterialDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final lowStock = item.isLowStock;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detalhes do material'),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Código: ${item.id}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lowStock
                    ? Colors.red.withOpacity(0.08)
                    : AppTheme.lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    lowStock
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: lowStock ? Colors.red : AppTheme.forestGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lowStock
                          ? 'Atenção: estoque baixo!'
                          : 'Estoque dentro do limite esperado.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: lowStock ? Colors.red : AppTheme.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Informações do material',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 12),
            _detailCard(
              icon: Icons.category_outlined,
              title: 'Categoria',
              value: item.category,
            ),
            _detailCard(
              icon: Icons.numbers_outlined,
              title: 'Quantidade disponível',
              value: '${item.quantity} ${item.unit}',
            ),
            _detailCard(
              icon: Icons.warning_amber_outlined,
              title: 'Estoque mínimo',
              value: '${item.minimum} ${item.unit}',
            ),
            _detailCard(
              icon: Icons.location_on_outlined,
              title: 'Local de armazenamento',
              value: item.location.isEmpty ? 'Não informado' : item.location,
            ),
            if (item.description != null && item.description!.isNotEmpty)
              _detailCard(
                icon: Icons.description_outlined,
                title: 'Descrição',
                value: item.description!,
              ),
            if (item.variations.isNotEmpty) ...[
              const SizedBox(height: 15),
              const Text(
                'Variações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 10),
              ...item.variations.map((variation) {
                return _detailCard(
                  icon: Icons.straighten,
                  title: variation.name,
                  value:
                      'Quantidade: ${variation.quantity} '
                      '• Mínimo: ${variation.minimum}',
                );
              }),
            ],
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar para materiais'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.forestGreen,
                  side: const BorderSide(color: AppTheme.forestGreen),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.sageGreen, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
