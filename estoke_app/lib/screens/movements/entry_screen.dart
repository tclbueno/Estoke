import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock_materials.dart';
import '../../models/material_model.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final formKey = GlobalKey<FormState>();

  final quantityController = TextEditingController();
  final supplierController = TextEditingController();
  final responsibleController = TextEditingController();
  final observationsController = TextEditingController();
  final otherReasonController = TextEditingController();

  String? selectedCategory;
  String? selectedMaterial;
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

  final reasons = [
    'Compra',
    'Doação recebida',
    'Devolução',
    'Reposição',
    'Outro',
  ];

  // Busca os materiais de acordo com a categoria selecionada.
  List<MaterialModel> get filteredMaterials {
    if (selectedCategory == null) {
      return [];
    }

    return mockMaterials
        .where((material) => material.category == selectedCategory)
        .toList();
  }

  @override
  void dispose() {
    quantityController.dispose();
    supplierController.dispose();
    responsibleController.dispose();
    observationsController.dispose();
    otherReasonController.dispose();
    super.dispose();
  }

  void registerEntry() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Entrada validada! A atualização do estoque será integrada posteriormente.',
        ),
      ),
    );

    formKey.currentState!.reset();

    quantityController.clear();
    supplierController.clear();
    responsibleController.clear();
    observationsController.clear();
    otherReasonController.clear();

    setState(() {
      selectedCategory = null;
      selectedMaterial = null;
      selectedReason = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final materials = filteredMaterials;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada de materiais'),
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
                'Registrar entrada',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.forestGreen,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Registre o recebimento de materiais no estoque.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              const Text(
                'Informações da entrada',
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
                        });
                      },
                validator: (value) {
                  if (selectedCategory == null) {
                    return 'Selecione primeiro uma categoria.';
                  }

                  if (materials.isEmpty) {
                    return 'Não existem materiais cadastrados nesta categoria.';
                  }

                  if (value == null) {
                    return 'Selecione um material.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Quantidade
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade recebida',
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
                  labelText: 'Motivo da entrada',
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
                    labelText: 'Informe o motivo da entrada',
                    hintText: 'Descreva o motivo',
                    prefixIcon: Icon(Icons.edit_note_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (selectedReason == 'Outro' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Informe o motivo da entrada.';
                    }

                    return null;
                  },
                ),
              ],

              const SizedBox(height: 15),

              // Fornecedor
              TextFormField(
                controller: supplierController,
                decoration: const InputDecoration(
                  labelText: 'Fornecedor / procedência',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
              ),

              const SizedBox(height: 15),

              // Responsável
              TextFormField(
                controller: responsibleController,
                decoration: const InputDecoration(
                  labelText: 'Responsável pelo recebimento',
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

              // Botão de registro
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: registerEntry,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Registrar entrada'),
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
