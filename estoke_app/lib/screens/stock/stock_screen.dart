import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock_materials.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String selectedCategory = 'Todos';

  final List<String> categories = [
    'Todos',
    'Uniformes',
    'Brindes',
    'Estandes',
    'Escritório',
    'Decoração',
    'Outros',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMaterials = mockMaterials.where((material) {
      return selectedCategory == 'Todos' ||
          material.category == selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppTheme.forestGreen,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estoque',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Consulte seus materiais disponíveis.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorias',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;

                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          selectedColor: AppTheme.lightGreen,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.forestGreen
                                : Colors.black54,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filteredMaterials.isEmpty
                  ? const Center(child: Text('Nenhum material encontrado.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: filteredMaterials.length,
                      itemBuilder: (context, index) {
                        final material = filteredMaterials[index];
                        final lowStock = material.isLowStock;

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.lightGreen,
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                            title: Text(
                              material.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(material.category),
                                  const SizedBox(height: 5),
                                  Text('${material.quantity} ${material.unit}'),
                                  if (lowStock)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text(
                                        'Estoque baixo - Reposição necessária',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: AppTheme.sageGreen,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
