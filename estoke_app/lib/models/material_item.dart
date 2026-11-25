class MaterialItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final int minimum;
  final String unit;
  final String location;

  final String? description;
  final String? lot;
  final DateTime? expirationDate;

  const MaterialItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimum,
    required this.unit,
    required this.location,
    this.description,
    this.lot,
    this.expirationDate,
  });
  bool get isLowStock => quantity <= minimum;
}
