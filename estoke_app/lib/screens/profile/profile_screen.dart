import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Meu perfil',
          style: TextStyle(
            color: AppTheme.forestGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.forestGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),

            // Foto e identificação do usuário
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.lightGreen,
              child: const Icon(
                Icons.person,
                size: 55,
                color: AppTheme.forestGreen,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Maria Oliveira',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestGreen,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Responsável pelo estoque',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            // Dados da conta
            _buildSectionTitle('Dados da conta'),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.person_outline,
              title: 'Nome completo',
              subtitle: 'Maria Oliveira',
            ),

            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'E-mail',
              subtitle: 'maria@empresa.com.br',
            ),

            _buildInfoCard(
              icon: Icons.badge_outlined,
              title: 'Perfil de acesso',
              subtitle: 'Responsável pelo estoque',
            ),

            const SizedBox(height: 24),

            // Configurações
            _buildSectionTitle('Configurações'),

            const SizedBox(height: 12),

            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
              subtitle: 'Gerenciar avisos do estoque',
              onTap: () {
                _showMessage(context, 'Notificações');
              },
            ),

            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Alterar senha',
              subtitle: 'Atualizar sua senha de acesso',
              onTap: () {
                _showMessage(context, 'Alterar senha');
              },
            ),

            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Sobre o Estokê',
              subtitle: 'Informações sobre o aplicativo',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Estokê',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Aplicativo de gerenciamento de estoque.',
                );
              },
            ),

            const SizedBox(height: 30),

            // Sair da conta
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Estokê • Versão 1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.forestGreen,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.sageGreen, size: 23),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.sageGreen),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.forestGreen,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.sageGreen),
        onTap: onTap,
      ),
    );
  }

  void _showMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estará disponível em breve.')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Deseja realmente sair do aplicativo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showMessage(context, 'Encerramento da sessão');
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
