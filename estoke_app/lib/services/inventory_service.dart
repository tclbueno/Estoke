import '../models/material_model.dart';
import 'api_service.dart';
import 'material_service.dart';

class InventoryAdjustment {
  final String materialId;
  final String materialName;
  final int registeredQuantity;
  final int countedQuantity;
  final int difference;

  const InventoryAdjustment({
    required this.materialId,
    required this.materialName,
    required this.registeredQuantity,
    required this.countedQuantity,
    required this.difference,
  });

  bool get hasDifference => difference != 0;
  bool get isIncrease => difference > 0;
  bool get isDecrease => difference < 0;
}

class InventoryResult {
  final String responsible;
  final DateTime date;
  final List<InventoryAdjustment> adjustments;

  const InventoryResult({
    required this.responsible,
    required this.date,
    required this.adjustments,
  });

  int get totalItemsChecked => adjustments.length;

  int get totalDifferences =>
      adjustments.where((item) => item.hasDifference).length;

  int get totalIncreases => adjustments.where((item) => item.isIncrease).length;

  int get totalDecreases => adjustments.where((item) => item.isDecrease).length;
}

class InventoryService {
  static const int defaultUserId = 2;

  final MaterialService _materialService;
  final ApiService _apiService;

  InventoryService({MaterialService? materialService, ApiService? apiService})
    : _materialService = materialService ?? MaterialService(),
      _apiService = apiService ?? ApiService();

  Future<List<MaterialModel>> getMaterialsForInventory() async {
    return _materialService.getAllMaterials();
  }

  Future<InventoryResult> checkInventory({
    required Map<String, int> countedQuantities,
    required String responsible,
  }) async {
    if (responsible.trim().isEmpty) {
      throw Exception('Informe o responsável pelo inventário.');
    }

    if (countedQuantities.isEmpty) {
      throw Exception('Informe as quantidades conferidas.');
    }

    final materials = await _materialService.getAllMaterials();

    final adjustments = <InventoryAdjustment>[];

    for (final entry in countedQuantities.entries) {
      if (entry.value < 0) {
        throw Exception('A quantidade de um material não pode ser negativa.');
      }

      final matchingMaterials = materials.where(
        (material) => material.id == entry.key,
      );

      if (matchingMaterials.isEmpty) {
        throw Exception('Material não encontrado: ${entry.key}');
      }

      final material = matchingMaterials.first;
      final difference = entry.value - material.quantity;

      adjustments.add(
        InventoryAdjustment(
          materialId: material.id,
          materialName: material.name,
          registeredQuantity: material.quantity,
          countedQuantity: entry.value,
          difference: difference,
        ),
      );
    }

    return InventoryResult(
      responsible: responsible.trim(),
      date: DateTime.now(),
      adjustments: List.unmodifiable(adjustments),
    );
  }

  Future<InventoryResult> confirmInventory({
    required Map<String, int> countedQuantities,
    required String responsible,
    String observation = '',
  }) async {
    final result = await checkInventory(
      countedQuantities: countedQuantities,
      responsible: responsible,
    );

    final inventoryResponse = await _apiService.post(
      '/inventarios?usuarioId=$defaultUserId',
      {
        'observacao': observation.trim().isEmpty
            ? 'Inventário realizado por ${responsible.trim()}'
            : observation.trim(),
      },
    );

    if (inventoryResponse is! Map || inventoryResponse['id'] == null) {
      throw Exception('Não foi possível identificar o inventário criado.');
    }

    final inventoryId = inventoryResponse['id'].toString();

    for (final adjustment in result.adjustments) {
      final endpoint = Uri(
        path: '/itens-inventario',
        queryParameters: {
          'inventarioId': inventoryId,
          'materialId': adjustment.materialId,
        },
      ).toString();

      await _apiService.post(endpoint, {
        'quantidadeSistema': adjustment.registeredQuantity,
        'quantidadeContada': adjustment.countedQuantity,
      });
    }

    return result;
  }

  void dispose() {
    _materialService.dispose();
    _apiService.dispose();
  }
}
