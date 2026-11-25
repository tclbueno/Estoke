import '../models/material_model.dart';
import 'api_service.dart';

class MaterialService {
  final ApiService _apiService;

  MaterialService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Converte a resposta da API em uma lista de materiais.
  Future<List<MaterialModel>> getAllMaterials() async {
    final response = await _apiService.get('/materiais');

    if (response is! List) {
      throw Exception('Resposta inválida ao consultar materiais.');
    }

    return response
        .map((item) => MaterialModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Busca um material pelo ID.
  Future<MaterialModel> getMaterialById(String id) async {
    final response = await _apiService.get('/materiais/$id');

    return MaterialModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Pesquisa materiais pelo nome.
  Future<List<MaterialModel>> searchMaterials(String query) async {
    final search = query.trim();

    if (search.isEmpty) {
      return getAllMaterials();
    }

    final endpoint =
        '/materiais/buscar?nome=${Uri.encodeQueryComponent(search)}';

    final response = await _apiService.get(endpoint);

    if (response is! List) {
      throw Exception('Resposta inválida ao pesquisar materiais.');
    }

    return response
        .map((item) => MaterialModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Filtra materiais pelo ID da categoria.
  Future<List<MaterialModel>> getMaterialsByCategory(int categoryId) async {
    final response = await _apiService.get('/materiais/categoria/$categoryId');

    if (response is! List) {
      throw Exception('Resposta inválida ao filtrar materiais.');
    }

    return response
        .map((item) => MaterialModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Retorna materiais com estoque baixo.
  Future<List<MaterialModel>> getLowStockMaterials() async {
    final materials = await getAllMaterials();

    return materials.where((material) => material.isLowStock).toList();
  }

  // Cadastra um material no banco de dados.
  Future<MaterialModel> addMaterial(
    MaterialModel material, {
    required int categoryId,
  }) async {
    final response = await _apiService.post(
      '/materiais?categoriaId=$categoryId',
      {
        'nome': material.name,
        'quantidade': material.quantity,
        'quantidadeMinima': material.minimum,
        'unidade': material.unit,
        'localizacao': material.location,
        'descricao': material.description,
      },
    );

    return MaterialModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Atualiza um material existente.
  Future<MaterialModel> updateMaterial(
    MaterialModel material, {
    required int categoryId,
  }) async {
    final response = await _apiService.put(
      '/materiais/${material.id}?categoriaId=$categoryId',
      {
        'nome': material.name,
        'quantidade': material.quantity,
        'quantidadeMinima': material.minimum,
        'unidade': material.unit,
        'localizacao': material.location,
        'descricao': material.description,
      },
    );

    return MaterialModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Exclui um material pelo ID.
  Future<void> removeMaterial(String id) async {
    await _apiService.delete('/materiais/$id');
  }

  // Retorna a quantidade total de materiais.
  Future<int> getTotalMaterials() async {
    final materials = await getAllMaterials();

    return materials.length;
  }

  // Fecha o cliente HTTP.
  void dispose() {
    _apiService.dispose();
  }
}
