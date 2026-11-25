import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'Todos';

  final List<Map<String, dynamic>> history = [
    {
      'type': 'Entrada',
      'material': 'Camiseta institucional',
      'quantity': 20,
      'unit': 'unidades',
      'responsible': 'Maria Oliveira',
      'date': '22/11/2026',
      'time': '09:30',
      'description': 'Reposição de estoque',
    },
    {
      'type': 'Saída',
      'material': 'Canetas personalizadas',
      'quantity': 10,
      'unit': 'unidades',
      'responsible': 'João Santos',
      'date': '21/11/2026',
      'time': '14:15',
      'description': 'Distribuição em evento',
    },
    {
      'type': 'Ajuste',
      'material': 'Crachás',
      'quantity': 5,
      'unit': 'unidades',
      'responsible': 'Ana Costa',
      'date': '20/11/2026',
      'time': '11:00',
      'description': 'Ajuste após inventário',
    },
    {
      'type': 'Entrada',
      'material': 'Blocos de anotação',
      'quantity': 50,
      'unit': 'unidades',
      'responsible': 'Maria Oliveira',
      'date': '19/11/2026',
      'time': '10:45',
      'description': 'Compra de materiais',
    },
    {
      'type': 'Saída',
      'material': 'Banners institucionais',
      'quantity': 2,
      'unit': 'unidades',
      'responsible': 'Carlos Lima',
      'date': '18/11/2026',
      'time': '16:20',
      'description': 'Utilização em evento',
    },
  ];

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter == 'Todos') {
      return history;
    }

    return history.where((item) => item['type'] == selectedFilter).toList();
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'Entrada':
        return AppTheme.sageGreen;
      case 'Saída':
        return Colors.redAccent;
      case 'Ajuste':
        return AppTheme.sand;
      default:
        return AppTheme.forestGreen;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type) {
      case 'Entrada':
        return Icons.arrow_downward;
      case 'Saída':
        return Icons.arrow_upward;
      case 'Ajuste':
        return Icons.sync;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Histórico',
          style: TextStyle(
            color: AppTheme.forestGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.forestGreen),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movimentações realizadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Acompanhe as entradas, saídas e ajustes do estoque.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Entrada', 'Saída', 'Ajuste'].map((filter) {
                  final isSelected = selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppTheme.forestGreen,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.forestGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de movimentações
            Expanded(
              child: filteredHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 55,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma movimentação encontrada.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredHistory.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];
                        final color = getTypeColor(item['type']);

                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        getTypeIcon(item['type']),
                                        color: color,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['material'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppTheme.forestGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['type'],
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${item['type'] == 'Saída' ? '-' : '+'}${item['quantity']}',
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                  Icons.person_outline,
                                  'Responsável',
                                  item['responsible'],
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.calendar_today_outlined,
                                  'Data e horário',
                                  '${item['date']} às ${item['time']}',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.description_outlined,
                                  'Descrição',
                                  item['description'],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.sageGreen),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.forestGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
