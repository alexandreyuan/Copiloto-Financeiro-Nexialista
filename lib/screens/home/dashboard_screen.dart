// 🧬 TELA: Dashboard - Centro de Controle do Organismo Financeiro

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../chat/ai_chat_screen.dart';
import '../admin/agent_config_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AIChatScreen(userProfile: user),
              ),
            );
          }
        },
        icon: const Icon(Icons.psychology),
        label: const Text('Copiloto IA'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, user),

              const SizedBox(height: 32),

              // Bem-vindo
              _buildWelcomeCard(context, user?.name ?? 'Usuário'),

              const SizedBox(height: 24),

              // Status Cards
              _buildStatusCards(context),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context),

              const SizedBox(height: 24),

              // Sistema Híbrido Info
              _buildSystemInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ecossistema Financeiro',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_vert),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ai_config',
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Color(0xFF00C853)),
                  const SizedBox(width: 12),
                  const Text('Agente IA (Admin)', style: TextStyle(color: Color(0xFF00C853))),
                ],
              ),
              onTap: () {
                // Captura user e navigator do contexto antes do async gap
                final userProfile = user;
                final navigator = Navigator.of(context);
                Future.delayed(Duration.zero, () {
                  if (userProfile != null) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => AgentConfigScreen(userProfile: userProfile),
                      ),
                    );
                  }
                });
              },
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outlined),
                  SizedBox(width: 12),
                  Text('Perfil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: 12),
                  Text('Configurações'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Sair', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00E676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waving_hand, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Olá, $userName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Seu ecossistema financeiro está ativo e funcionando 100% offline.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Contas',
            value: '0',
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            context,
            icon: Icons.receipt_long,
            title: 'Transações',
            value: '0',
            color: const Color(0xFF00C853),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context,
          icon: Icons.add,
          title: 'Adicionar Conta',
          subtitle: 'Crie sua primeira conta financeira',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Em desenvolvimento')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.receipt_outlined,
          title: 'Nova Transação',
          subtitle: 'Adicione uma receita ou despesa',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Em desenvolvimento')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.category_outlined,
          title: 'Gerenciar Categorias',
          subtitle: 'Configure categorias personalizadas',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Em desenvolvimento')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF00C853)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Text(
                'Sistema Híbrido Ativo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '✅ Armazenamento local (Hive) funcionando\n'
            '✅ Dados persistidos no dispositivo\n'
            '⏳ Firebase: Configure para sincronização em nuvem',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[800],
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
