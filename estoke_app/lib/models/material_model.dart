class MaterialVariation {
  final String name;
  final int quantity;
  final int minimum;

  const MaterialVariation({
    required this.name,
    required this.quantity,
    required this.minimum,
  });

  bool get isLowStock => quantity <= minimum;

  factory MaterialVariation.fromJson(Map<String, dynamic> json) {
    return MaterialVariation(
      name: json['nome']?.toString() ?? '',
      quantity: (json['quantidade'] as num?)?.toInt() ?? 0,
      minimum: (json['quantidadeMinima'] as num?)?.toInt() ?? 0,
    );
  }
}

class MaterialModel {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final int minimum;
  final String unit;
  final List<MaterialVariation> variations;
  final String location;
  final String? description;

  const MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimum,
    required this.unit,
    this.variations = const [],
    this.location = '',
    this.description,
  });

  bool get isLowStock => quantity <= minimum;

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    final categoria = json['categoria'];

    final variacoes = json['variacoes'];

    return MaterialModel(
      id: json['id'].toString(),
      name: json['nome']?.toString() ?? '',
      category: categoria is Map ? categoria['nome']?.toString() ?? '' : '',
      quantity: (json['quantidade'] as num?)?.toInt() ?? 0,
      minimum: (json['quantidadeMinima'] as num?)?.toInt() ?? 0,
      unit: json['unidade']?.toString() ?? '',
      location: json['localizacao']?.toString() ?? '',
      description: json['descricao']?.toString(),
      variations: variacoes is List
          ? variacoes
                .map(
                  (item) => MaterialVariation.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : [],
    );
  }
}
