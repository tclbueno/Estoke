import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock_materials.dart';

import '../agenda/agenda_screen.dart';
import '../materials/material_register_screen.dart';
import '../movements/entry_screen.dart';
import '../movements/exit_screen.dart';
import '../inventory/inventory_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final totalMaterials = mockMaterials.length;

    final lowStockMaterials = mockMaterials
        .where((material) => material.isLowStock)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Estokê',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.forestGreen,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppTheme.forestGreen,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Bem-vindo ao gerenciamento de estoque.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Materiais cadastrados',
                    value: totalMaterials.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Estoque baixo',
                    value: lowStockMaterials.toString(),
                    icon: Icons.warning_amber_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Acessos rápidos',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _ShortcutCard(
                  title: 'Cadastrar material',
                  icon: Icons.add_box_outlined,
                  onTap: () =>
                      _openScreen(context, const MaterialRegisterScreen()),
                ),

                // Agenda substitui o antigo atalho Lista de materiais.
                _ShortcutCard(
                  title: 'Agenda',
                  icon: Icons.calendar_month_outlined,
                  onTap: () => _openScreen(context, const AgendaScreen()),
                ),

                _ShortcutCard(
                  title: 'Entrada de materiais',
                  icon: Icons.add_circle_outline,
                  onTap: () => _openScreen(context, const EntryScreen()),
                ),

                _ShortcutCard(
                  title: 'Saída de materiais',
                  icon: Icons.remove_circle_outline,
                  onTap: () => _openScreen(context, const ExitScreen()),
                ),

                _ShortcutCard(
                  title: 'Inventário',
                  icon: Icons.fact_check_outlined,
                  onTap: () => _openScreen(context, const InventoryScreen()),
                ),

                _ShortcutCard(
                  title: 'Histórico',
                  icon: Icons.history,
                  onTap: () => _openScreen(context, const HistoryScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.forestGreen, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.lightGreen),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: AppTheme.forestGreen),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.forestGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
