import '../models/material_model.dart';
import 'api_service.dart';

enum MovementType { entry, exit }

class Movement {
  final String id;
  final String materialId;
  final String materialName;
  final MovementType type;
  final double quantity;
  final String responsible;
  final String reason;
  final String? otherReason;
  final String? observation;
  final DateTime date;
  final String? variationName;

  const Movement({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.type,
    required this.quantity,
    required this.responsible,
    required this.reason,
    this.otherReason,
    this.observation,
    required this.date,
    this.variationName,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    final material = json['material'];
    final usuario = json['usuario'];
    final variacao = json['variacao'];

    final tipo = json['tipo']?.toString().toUpperCase();

    return Movement(
      id: json['id']?.toString() ?? '',
      materialId: material is Map ? material['id']?.toString() ?? '' : '',
      materialName: material is Map
          ? material['nome']?.toString() ?? 'Material'
          : 'Material',
      type: tipo == 'ENTRADA' ? MovementType.entry : MovementType.exit,
      quantity: (json['quantidade'] as num?)?.toDouble() ?? 0,
      responsible: usuario is Map
          ? usuario['nome']?.toString() ?? 'Usuário ${usuario['id'] ?? ''}'
          : 'Usuário não identificado',
      reason: json['motivo']?.toString() ?? '',
      otherReason: json['outroMotivo']?.toString(),
      observation: json['observacao']?.toString(),
      date:
          DateTime.tryParse(json['dataMovimentacao']?.toString() ?? '') ??
          DateTime.now(),
      variationName: variacao is Map ? variacao['nome']?.toString() : null,
    );
  }
}

class MovementService {
  static const int defaultUserId = 2;

  final ApiService _apiService;

  MovementService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<Movement>> getAllMovements() async {
    final response = await _apiService.get('/movimentacoes');

    if (response is! List) {
      throw Exception('A API retornou um histórico inválido.');
    }

    final movements = response
        .map((item) => Movement.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    movements.sort((a, b) => b.date.compareTo(a.date));

    return movements;
  }

  Future<List<Movement>> getMovementsByMaterial(String materialId) async {
    final response = await _apiService.get(
      '/movimentacoes/material/${Uri.encodeComponent(materialId)}',
    );

    if (response is! List) {
      throw Exception('A API retornou movimentações inválidas.');
    }

    final movements = response
        .map((item) => Movement.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    movements.sort((a, b) => b.date.compareTo(a.date));

    return movements;
  }

  Future<List<Movement>> getMovementsByUser(int userId) async {
    final response = await _apiService.get('/movimentacoes/usuario/$userId');

    if (response is! List) {
      throw Exception('A API retornou movimentações inválidas.');
    }

    final movements = response
        .map((item) => Movement.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    movements.sort((a, b) => b.date.compareTo(a.date));

    return movements;
  }

  Future<Movement> registerEntry({
    required MaterialModel material,
    required int quantity,
    required String responsible,
    String description = '',
    String? variationName,
    int? variationId,
    String? reason,
    String? observation,
  }) {
    return _registerMovement(
      material: material,
      quantity: quantity,
      type: MovementType.entry,
      responsible: responsible,
      description: description,
      variationId: variationId,
      reason: reason,
      observation: observation,
    );
  }

  Future<Movement> registerExit({
    required MaterialModel material,
    required int quantity,
    required String responsible,
    String description = '',
    String? variationName,
    int? variationId,
    String? reason,
    String? observation,
  }) {
    return _registerMovement(
      material: material,
      quantity: quantity,
      type: MovementType.exit,
      responsible: responsible,
      description: description,
      variationId: variationId,
      reason: reason,
      observation: observation,
    );
  }

  Future<Movement> registerAdjustment({
    required MaterialModel material,
    required int countedQuantity,
    required String responsible,
    String description = '',
    int? variationId,
  }) async {
    if (countedQuantity < 0) {
      throw Exception('A quantidade não pode ser negativa.');
    }

    final difference = countedQuantity - material.quantity;

    if (difference == 0) {
      throw Exception('Não há diferença para ajustar.');
    }

    final adjustmentDescription = description.trim().isEmpty
        ? 'Ajuste de inventário'
        : description.trim();

    if (difference > 0) {
      return registerEntry(
        material: material,
        quantity: difference,
        responsible: responsible,
        reason: adjustmentDescription,
        description: adjustmentDescription,
        variationId: variationId,
      );
    }

    return registerExit(
      material: material,
      quantity: difference.abs(),
      responsible: responsible,
      reason: adjustmentDescription,
      description: adjustmentDescription,
      variationId: variationId,
    );
  }

  Future<Movement> _registerMovement({
    required MaterialModel material,
    required int quantity,
    required MovementType type,
    required String responsible,
    required String description,
    int? variationId,
    String? reason,
    String? observation,
  }) async {
    if (quantity <= 0) {
      throw Exception('Informe uma quantidade maior que zero.');
    }

    if (responsible.trim().isEmpty) {
      throw Exception('Informe o responsável pela movimentação.');
    }

    final movementReason = reason?.trim().isNotEmpty == true
        ? reason!.trim()
        : description.trim().isNotEmpty
        ? description.trim()
        : type == MovementType.entry
        ? 'Entrada de estoque'
        : 'Saída de estoque';

    final queryParameters = <String, String>{
      'materialId': material.id,
      'usuarioId': defaultUserId.toString(),
    };

    if (variationId != null) {
      queryParameters['variacaoId'] = variationId.toString();
    }

    final endpoint = Uri(
      path: '/movimentacoes',
      queryParameters: queryParameters,
    ).toString();

    final response = await _apiService.post(endpoint, {
      'tipo': type == MovementType.entry ? 'ENTRADA' : 'SAIDA',
      'quantidade': quantity,
      'motivo': movementReason,
      'outroMotivo': null,
      'observacao': observation?.trim().isNotEmpty == true
          ? observation!.trim()
          : description.trim().isNotEmpty
          ? description.trim()
          : null,
    });

    if (response is! Map) {
      throw Exception('A API não retornou a movimentação cadastrada.');
    }

    return Movement.fromJson(Map<String, dynamic>.from(response));
  }

  Future<void> deleteMovement(String id) async {
    await _apiService.delete('/movimentacoes/$id');
  }

  void dispose() {
    _apiService.dispose();
  }
}
