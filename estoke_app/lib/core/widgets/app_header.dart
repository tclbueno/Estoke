import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String subtitle;

  const AppHeader({super.key, this.subtitle = 'CONTROLE DE MATERIAIS'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 48, 22, 24),
      decoration: const BoxDecoration(
        color: AppTheme.forestGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 27,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Estokê',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Notificações',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Você não possui novas notificações.'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}
