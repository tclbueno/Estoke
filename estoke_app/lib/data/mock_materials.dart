import '../models/material_model.dart';

final List<MaterialModel> mockMaterials = [
  const MaterialModel(
    id: '1',
    name: 'Camiseta institucional',
    category: 'Uniformes',
    quantity: 25,
    minimum: 10,
    unit: 'unidades',
  ),
  const MaterialModel(
    id: '2',
    name: 'Caneta personalizada',
    category: 'Brindes',
    quantity: 8,
    minimum: 15,
    unit: 'unidades',
  ),
  const MaterialModel(
    id: '3',
    name: 'Banner institucional',
    category: 'Estandes',
    quantity: 12,
    minimum: 5,
    unit: 'unidades',
  ),
  const MaterialModel(
    id: '4',
    name: 'Papel A4',
    category: 'Escritório',
    quantity: 3,
    minimum: 10,
    unit: 'resmas',
  ),
  const MaterialModel(
    id: '5',
    name: 'Toalha de mesa',
    category: 'Decoração',
    quantity: 15,
    minimum: 5,
    unit: 'unidades',
  ),
  const MaterialModel(
    id: '6',
    name: 'Fita adesiva',
    category: 'Outros',
    quantity: 20,
    minimum: 8,
    unit: 'unidades',
  ),
];
