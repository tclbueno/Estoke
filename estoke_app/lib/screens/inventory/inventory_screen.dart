import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../models/material_model.dart';
import '../../services/inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController responsibleController = TextEditingController();

  final TextEditingController observationsController = TextEditingController();

  final Map<String, TextEditingController> countControllers = {};

  final InventoryService _inventoryService = InventoryService();

  late Future<List<MaterialModel>> materialsFuture;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    materialsFuture = _inventoryService.getMaterialsForInventory();
  }

  @override
  void dispose() {
    responsibleController.dispose();
    observationsController.dispose();

    for (final controller in countControllers.values) {
      controller.dispose();
    }

    _inventoryService.dispose();

    super.dispose();
  }

  void reloadMaterials() {
    setState(() {
      materialsFuture = _inventoryService.getMaterialsForInventory();
    });
  }

  TextEditingController getController(MaterialModel material) {
    return countControllers.putIfAbsent(
      material.id,
      () => TextEditingController(text: material.quantity.toString()),
    );
  }

  Map<String, int> getCountedQuantities(List<MaterialModel> materials) {
    final quantities = <String, int>{};

    for (final material in materials) {
      final controller = getController(material);
      final quantity = int.tryParse(controller.text.trim());

      if (quantity == null || quantity < 0) {
        throw Exception('Informe uma quantidade válida para ${material.name}.');
      }

      quantities[material.id] = quantity;
    }

    return quantities;
  }

  Future<void> checkInventory(List<MaterialModel> materials) async {
    if (responsibleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o responsável pelo inventário.')),
      );
      return;
    }

    try {
      final countedQuantities = getCountedQuantities(materials);

      final result = await _inventoryService.checkInventory(
        countedQuantities: countedQuantities,
        responsible: responsibleController.text,
      );

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Resultado da conferência'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.totalItemsChecked} material(is) conferido(s).',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${result.totalDifferences} divergência(s) encontrada(s).',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (result.totalDifferences == 0)
                    const Text('Nenhuma divergência encontrada.')
                  else
                    ...result.adjustments
                        .where((item) => item.hasDifference)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.materialName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('Registrado: ${item.registeredQuantity}'),
                                Text('Contado: ${item.countedQuantity}'),
                                Text(
                                  'Diferença: '
                                  '${item.difference > 0 ? '+' : ''}'
                                  '${item.difference}',
                                  style: TextStyle(
                                    color: item.isIncrease
                                        ? AppTheme.sageGreen
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deseja registrar este inventário no sistema?',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Registrar inventário'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) return;

      await confirmInventory(countedQuantities);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> confirmInventory(Map<String, int> countedQuantities) async {
    setState(() {
      isSaving = true;
    });

    try {
      final result = await _inventoryService.confirmInventory(
        countedQuantities: countedQuantities,
        responsible: responsibleController.text,
        observation: observationsController.text,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Inventário registrado!'),
          content: Text(
            'O inventário foi salvo com sucesso.\n\n'
            'Materiais conferidos: ${result.totalItemsChecked}\n'
            'Divergências: ${result.totalDifferences}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      for (final controller in countControllers.values) {
        controller.dispose();
      }

      countControllers.clear();
      observationsController.clear();

      reloadMaterials();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao registrar inventário: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Map<String, List<MaterialModel>> groupMaterials(
    List<MaterialModel> materials,
  ) {
    final grouped = <String, List<MaterialModel>>{};

    for (final material in materials) {
      final category = material.category.trim().isEmpty
          ? 'Sem categoria'
          : material.category;

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(material);
    }

    return grouped;
  }

  Widget buildMaterialCard(MaterialModel material) {
    final controller = getController(material);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registrado: ${material.quantity} ${material.unit}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (material.location.isNotEmpty)
                  Text(
                    'Local: ${material.location}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 105,
            child: TextField(
              controller: controller,
              enabled: !isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Contagem',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMaterialsList(List<MaterialModel> materials) {
    if (materials.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'Nenhum material cadastrado para conferência.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final groupedMaterials = groupMaterials(materials);

    return Column(
      children: groupedMaterials.entries.map((entry) {
        final category = entry.key;
        final categoryMaterials = entry.value;

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ExpansionTile(
            leading: const Icon(
              Icons.inventory_2_outlined,
              color: AppTheme.sageGreen,
            ),
            title: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            subtitle: Text('${categoryMaterials.length} material(is)'),
            children: categoryMaterials.map(buildMaterialCard).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isSaving ? null : reloadMaterials,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar materiais',
          ),
        ],
      ),
      body: FutureBuilder<List<MaterialModel>>(
        future: materialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar os materiais.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: reloadMaterials,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final materials = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Conferência de estoque',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Confira fisicamente os materiais e compare '
                'com as quantidades registradas.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: responsibleController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Responsável pelo inventário',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Materiais por categoria',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 12),
              buildMaterialsList(materials),
              const SizedBox(height: 10),
              TextField(
                controller: observationsController,
                enabled: !isSaving,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações do inventário',
                  hintText: 'Registre informações importantes...',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving || materials.isEmpty
                      ? null
                      : () => checkInventory(materials),
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.fact_check_outlined),
                  label: Text(
                    isSaving
                        ? 'Registrando inventário...'
                        : 'Conferir divergências',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
