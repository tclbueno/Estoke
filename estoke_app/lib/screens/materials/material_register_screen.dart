import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../models/material_model.dart';
import '../../data/mock_materials.dart';

class MaterialRegisterScreen extends StatefulWidget {
  const MaterialRegisterScreen({super.key});

  @override
  State<MaterialRegisterScreen> createState() => _MaterialRegisterScreenState();
}

class _MaterialRegisterScreenState extends State<MaterialRegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final minimumController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final otherUnitController = TextEditingController();
  final otherVariationController = TextEditingController();

  final Map<String, TextEditingController> variationQuantities = {};
  final Map<String, TextEditingController> variationMinimums = {};

  String selectedCategory = 'Uniformes';
  String? selectedUnit;

  final categories = [
    'Uniformes',
    'Calçados',
    'Brindes',
    'Estandes',
    'Escritório',
    'Decoração',
    'Outros',
  ];

  final units = [
    'Unidade',
    'Par',
    'Caixa',
    'Pacote',
    'Resma',
    'Rolo',
    'Metro',
    'Litro',
    'Quilograma (kg)',
    'Outro',
  ];

  final uniformSizes = ['PP', 'P', 'M', 'G', 'GG', 'XG', 'XXG', 'Outro'];

  final shoeSizes = [
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    'Outro',
  ];

  final Set<String> selectedVariations = {};

  bool get hasVariations =>
      selectedCategory == 'Uniformes' || selectedCategory == 'Calçados';

  List<String> get availableVariations =>
      selectedCategory == 'Uniformes' ? uniformSizes : shoeSizes;

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    minimumController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    otherUnitController.dispose();
    otherVariationController.dispose();

    for (final controller in variationQuantities.values) {
      controller.dispose();
    }

    for (final controller in variationMinimums.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _createVariationControllers(String variation) {
    variationQuantities.putIfAbsent(variation, () => TextEditingController());

    variationMinimums.putIfAbsent(variation, () => TextEditingController());
  }

  void _toggleVariation(String variation, bool selected) {
    setState(() {
      if (selected) {
        selectedVariations.add(variation);
        _createVariationControllers(variation);
      } else {
        selectedVariations.remove(variation);

        if (variation != 'Outro') {
          variationQuantities.remove(variation)?.dispose();
          variationMinimums.remove(variation)?.dispose();
        } else {
          otherVariationController.clear();
          variationQuantities.remove(variation)?.dispose();
          variationMinimums.remove(variation)?.dispose();
        }
      }
    });
  }

  String _getUnit() {
    if (selectedUnit == 'Outro') {
      return otherUnitController.text.trim();
    }

    return selectedUnit ?? '';
  }

  String _getVariationName(String variation) {
    if (variation == 'Outro') {
      return otherVariationController.text.trim();
    }

    return variation;
  }

  void _registerMaterial() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma unidade de medida.')),
      );
      return;
    }

    if (selectedUnit == 'Outro' && otherUnitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a unidade personalizada.')),
      );
      return;
    }

    final List<MaterialVariation> variations = [];

    if (hasVariations) {
      if (selectedVariations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos um tamanho ou numeração.'),
          ),
        );
        return;
      }

      if (selectedVariations.contains('Outro') &&
          otherVariationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe o tamanho ou numeração personalizada.'),
          ),
        );
        return;
      }

      for (final variation in selectedVariations) {
        final quantity = int.tryParse(
          variationQuantities[variation]?.text ?? '',
        );

        final minimum = int.tryParse(variationMinimums[variation]?.text ?? '');

        if (quantity == null ||
            quantity < 0 ||
            minimum == null ||
            minimum < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Informe quantidades válidas para ${_getVariationName(variation)}.',
              ),
            ),
          );
          return;
        }

        variations.add(
          MaterialVariation(
            name: _getVariationName(variation),
            quantity: quantity,
            minimum: minimum,
          ),
        );
      }
    }

    final totalQuantity = hasVariations
        ? variations.fold<int>(0, (total, item) => total + item.quantity)
        : int.parse(quantityController.text);

    final totalMinimum = hasVariations
        ? variations.fold<int>(0, (total, item) => total + item.minimum)
        : int.parse(minimumController.text);

    final newMaterial = MaterialModel(
      id: 'MAT-${DateTime.now().millisecondsSinceEpoch}',
      name: nameController.text.trim(),
      category: selectedCategory,
      quantity: totalQuantity,
      minimum: totalMinimum,
      unit: _getUnit(),
      variations: variations,
      location: locationController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );

    mockMaterials.add(newMaterial);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Material cadastrado com sucesso!'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.forestGreen, width: 1.5),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Preencha este campo.';
            }
            return null;
          },
    );
  }

  Widget _buildVariationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamanhos / numerações disponíveis',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Selecione todas as opções disponíveis para este material.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableVariations.map((variation) {
            return FilterChip(
              label: Text(variation),
              selected: selectedVariations.contains(variation),
              selectedColor: AppTheme.lightGreen,
              checkmarkColor: AppTheme.forestGreen,
              onSelected: (selected) {
                _toggleVariation(variation, selected);
              },
            );
          }).toList(),
        ),

        if (selectedVariations.contains('Outro')) ...[
          const SizedBox(height: 15),
          _buildTextField(
            label: selectedCategory == 'Uniformes'
                ? 'Informe o tamanho'
                : 'Informe a numeração',
            controller: otherVariationController,
            hint: 'Digite a opção personalizada',
          ),
        ],

        if (selectedVariations.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'Quantidade por tamanho / numeração',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 12),

          ...selectedVariations.map((variation) {
            final displayName =
                variation == 'Outro' &&
                    otherVariationController.text.trim().isNotEmpty
                ? otherVariationController.text.trim()
                : variation;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.forestGreen,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Quantidade disponível',
                      controller: variationQuantities[variation]!,
                      hint: 'Ex.: 10',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final number = int.tryParse(value ?? '');
                        if (number == null || number < 0) {
                          return 'Informe uma quantidade válida.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Estoque mínimo',
                      controller: variationMinimums[variation]!,
                      hint: 'Ex.: 3',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final number = int.tryParse(value ?? '');
                        if (number == null || number < 0) {
                          return 'Informe um estoque mínimo válido.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cadastrar material'),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Novo material',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Informe os dados para cadastrar um material no estoque.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 25),

              _buildTextField(
                label: 'Nome do material',
                controller: nameController,
                hint: 'Ex.: Camiseta institucional',
              ),
              const SizedBox(height: 18),

              const Text(
                'Categoria',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCategory = value;
                    selectedVariations.clear();
                    otherVariationController.clear();

                    for (final controller in variationQuantities.values) {
                      controller.dispose();
                    }
                    for (final controller in variationMinimums.values) {
                      controller.dispose();
                    }

                    variationQuantities.clear();
                    variationMinimums.clear();

                    quantityController.clear();
                    minimumController.clear();
                  });
                },
              ),
              const SizedBox(height: 18),

              if (hasVariations)
                _buildVariationSection()
              else ...[
                _buildTextField(
                  label: 'Quantidade inicial',
                  controller: quantityController,
                  hint: 'Ex.: 50',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (number == null || number < 0) {
                      return 'Informe uma quantidade válida.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  label: 'Estoque mínimo',
                  controller: minimumController,
                  hint: 'Ex.: 10',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (number == null || number < 0) {
                      return 'Informe um estoque mínimo válido.';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 18),

              const Text(
                'Unidade de medida',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedUnit,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Selecione a unidade'),
                items: units.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value;
                    if (value != 'Outro') {
                      otherUnitController.clear();
                    }
                  });
                },
              ),

              if (selectedUnit == 'Outro') ...[
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Informe a unidade de medida',
                  controller: otherUnitController,
                  hint: 'Ex.: Fardo, kit, conjunto...',
                ),
              ],

              const SizedBox(height: 18),

              _buildTextField(
                label: 'Local de armazenamento',
                controller: locationController,
                hint: 'Ex.: Armário 01',
              ),
              const SizedBox(height: 18),

              _buildTextField(
                label: 'Descrição (opcional)',
                controller: descriptionController,
                hint: 'Informações adicionais sobre o material',
                maxLines: 3,
                validator: (_) => null,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _registerMaterial,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Cadastrar material'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
