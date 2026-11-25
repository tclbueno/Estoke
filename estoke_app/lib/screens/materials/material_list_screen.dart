import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/material_model.dart';
import '../../services/material_service.dart';
import 'material_details_screen.dart';
import 'material_register_screen.dart';

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  final MaterialService materialService = MaterialService();
  final TextEditingController searchController = TextEditingController();

  late Future<List<MaterialModel>> materialsFuture;

  String selectedCategory = 'Todos';

  final List<String> categories = [
    'Todos',
    'Materiais de escritório',
    'Informática',
    'Limpeza',
    'Manutenção',
    'Uniformes',
    'Calçados',
    'Alimentícios',
    'EPIs',
    'Embalagens',
    'Higiene pessoal',
    'Materiais diversos',
    'Decoração',
  ];

  @override
  void initState() {
    super.initState();
    materialsFuture = materialService.getAllMaterials();
  }

  void _loadMaterials() {
    setState(() {
      materialsFuture = materialService.getAllMaterials();
    });
  }

  List<MaterialModel> _filterMaterials(List<MaterialModel> materials) {
    final query = searchController.text.toLowerCase().trim();

    final results = materials.where((item) {
      final matchesName = item.name.toLowerCase().contains(query);
      final matchesId = item.id.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'Todos' || item.category == selectedCategory;

      return (matchesName || matchesId) && matchesCategory;
    }).toList();

    results.sort((a, b) {
      return (b.isLowStock ? 1 : 0).compareTo(a.isLowStock ? 1 : 0);
    });

    return results;
  }

  Future<void> _openRegisterScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MaterialRegisterScreen()),
    );

    _loadMaterials();
  }

  Future<void> _openDetails(MaterialModel item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MaterialDetailsScreen(item: item)),
    );

    _loadMaterials();
  }

  @override
  void dispose() {
    searchController.dispose();
    materialService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lista de materiais'),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar'),
        onPressed: _openRegisterScreen,
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
                      Icons.cloud_off_outlined,
                      size: 45,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar os materiais.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadMaterials,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allMaterials = snapshot.data ?? [];
          final materials = _filterMaterials(allMaterials);

          return RefreshIndicator(
            onRefresh: () async {
              _loadMaterials();
              await materialsFuture;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Seus materiais',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.forestGreen,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Consulte os materiais disponíveis no estoque.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou código...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Categorias',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.forestGreen,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: AppTheme.forestGreen,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.forestGreen,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${materials.length} materiais encontrados',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                if (materials.isEmpty)
                  const EmptyState(
                    icon: Icons.search_off,
                    message:
                        'Nenhum material encontrado.\n'
                        'Tente outra pesquisa ou categoria.',
                  )
                else
                  ...materials.map(_materialCard),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _materialCard(MaterialModel item) {
    final lowStock = item.isLowStock;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 11),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppTheme.lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: AppTheme.forestGreen,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.forestGreen,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.category} • ${item.id}',
                style: const TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 5),
              Text(
                lowStock ? 'Estoque baixo' : 'Disponível',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: lowStock ? Colors.red : AppTheme.sageGreen,
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            Text(
              item.unit,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
        onTap: () => _openDetails(item),
      ),
    );
  }
}
