import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock_materials.dart';
import '../../models/material_model.dart';

class ExitScreen extends StatefulWidget {
  const ExitScreen({super.key});

  @override
  State<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  final formKey = GlobalKey<FormState>();

  final quantityController = TextEditingController();
  final responsibleController = TextEditingController();
  final destinationController = TextEditingController();
  final observationsController = TextEditingController();
  final otherReasonController = TextEditingController();

  String? selectedCategory;
  String? selectedMaterial;
  String? selectedVariation;
  String? selectedReason;

  final categories = [
    'Uniformes',
    'Calçados',
    'Brindes',
    'Estandes',
    'Escritório',
    'Decoração',
    'Outros',
  ];

  final reasons = ['Uso interno', 'Evento', 'Doação', 'Descarte', 'Outro'];

  // Materiais filtrados pela categoria.
  List<MaterialModel> get filteredMaterials {
    if (selectedCategory == null) {
      return [];
    }

    return mockMaterials
        .where((material) => material.category == selectedCategory)
        .toList();
  }

  // Material selecionado.
  MaterialModel? get currentMaterial {
    if (selectedMaterial == null) {
      return null;
    }

    for (final material in mockMaterials) {
      if (material.id == selectedMaterial) {
        return material;
      }
    }

    return null;
  }

  // Variações do material selecionado.
  List<MaterialVariation> get availableVariations {
    return currentMaterial?.variations ?? [];
  }

  @override
  void dispose() {
    quantityController.dispose();
    responsibleController.dispose();
    destinationController.dispose();
    observationsController.dispose();
    otherReasonController.dispose();
    super.dispose();
  }

  void registerExit() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Saída validada! A atualização do estoque será integrada posteriormente.',
        ),
      ),
    );

    formKey.currentState!.reset();

    quantityController.clear();
    responsibleController.clear();
    destinationController.clear();
    observationsController.clear();
    otherReasonController.clear();

    setState(() {
      selectedCategory = null;
      selectedMaterial = null;
      selectedVariation = null;
      selectedReason = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final materials = filteredMaterials;
    final variations = availableVariations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saída de materiais'),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar saída',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Registre a retirada de materiais do estoque.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              const Text(
                'Informações da saída',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),

              const SizedBox(height: 15),

              // Categoria
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedMaterial = null;
                    selectedVariation = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione uma categoria.' : null,
              ),

              const SizedBox(height: 15),

              // Material filtrado pela categoria.
              DropdownButtonFormField<String>(
                key: ValueKey(selectedCategory),
                initialValue: selectedMaterial,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                hint: Text(
                  selectedCategory == null
                      ? 'Selecione primeiro uma categoria'
                      : materials.isEmpty
                      ? 'Nenhum material cadastrado nesta categoria'
                      : 'Selecione um material',
                ),
                items: materials.map((material) {
                  return DropdownMenuItem<String>(
                    value: material.id,
                    child: Text(material.name),
                  );
                }).toList(),
                onChanged: selectedCategory == null || materials.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          selectedMaterial = value;
                          selectedVariation = null;
                          quantityController.clear();
                        });
                      },
                validator: (value) {
                  if (selectedCategory == null) {
                    return 'Selecione uma categoria.';
                  }

                  if (materials.isEmpty) {
                    return 'Não existem materiais nesta categoria.';
                  }

                  if (value == null) {
                    return 'Selecione um material.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Tamanho ou numeração, quando houver variações.
              if (selectedMaterial != null &&
                  currentMaterial != null &&
                  currentMaterial!.variations.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  key: ValueKey(selectedMaterial),
                  initialValue: selectedVariation,
                  decoration: const InputDecoration(
                    labelText: 'Tamanho / numeração',
                    prefixIcon: Icon(Icons.straighten_outlined),
                  ),
                  items: variations.map((variation) {
                    return DropdownMenuItem<String>(
                      value: variation.name,
                      child: Text(
                        '${variation.name} — disponível: ${variation.quantity}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVariation = value;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Selecione o tamanho ou numeração.'
                      : null,
                ),

                const SizedBox(height: 15),
              ],

              // Quantidade
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade retirada',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');

                  if (quantity == null || quantity <= 0) {
                    return 'Informe uma quantidade válida.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Motivo
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Motivo da saída',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                items: reasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;

                    if (value != 'Outro') {
                      otherReasonController.clear();
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione o motivo.' : null,
              ),

              // Campo exibido somente quando o motivo for Outro.
              if (selectedReason == 'Outro') ...[
                const SizedBox(height: 15),

                TextFormField(
                  controller: otherReasonController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Informe o motivo da saída',
                    hintText: 'Descreva o motivo',
                    prefixIcon: Icon(Icons.edit_note_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (selectedReason == 'Outro' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Informe o motivo da saída.';
                    }

                    return null;
                  },
                ),
              ],

              const SizedBox(height: 15),

              // Destino
              TextFormField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destino / setor',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),

              const SizedBox(height: 15),

              // Responsável
              TextFormField(
                controller: responsibleController,
                decoration: const InputDecoration(
                  labelText: 'Responsável pela retirada',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o responsável.'
                    : null,
              ),

              const SizedBox(height: 15),

              // Observações
              TextFormField(
                controller: observationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Informações adicionais (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 25),

              // Botão
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: registerExit,
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Registrar saída'),
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
          ),
        ),
      ),
    );
  }
}
