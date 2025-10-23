// 🧠 TELA: Configuração do Agente IA - Painel Administrativo
// Apenas usuários admin podem acessar

import 'package:flutter/material.dart';
import '../../models/ai_agent_config.dart';
import '../../models/user_profile.dart';

class AgentConfigScreen extends StatefulWidget {
  final UserProfile userProfile;

  const AgentConfigScreen({super.key, required this.userProfile});

  @override
  State<AgentConfigScreen> createState() => _AgentConfigScreenState();
}

class _AgentConfigScreenState extends State<AgentConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _agentNameController;
  late TextEditingController _systemPromptController;
  late TextEditingController _apiKeyController;
  late TextEditingController _temperatureController;
  late TextEditingController _maxTokensController;

  // Estado
  LLMProvider _selectedProvider = LLMProvider.gemini;
  AgentRole _selectedRole = AgentRole.assistant;
  String _selectedModel = 'gemini-pro';
  bool _isActive = true;
  bool _isDefault = true;

  // Modelos disponíveis por provider
  final Map<LLMProvider, List<String>> _availableModels = {
    LLMProvider.gemini: [
      'gemini-pro',
      'gemini-pro-vision',
      'gemini-1.5-pro',
      'gemini-1.5-flash',
    ],
    LLMProvider.openai: [
      'gpt-4',
      'gpt-4-turbo',
      'gpt-3.5-turbo',
      'gpt-4o',
    ],
    LLMProvider.openrouter: [
      'anthropic/claude-3-opus',
      'anthropic/claude-3-sonnet',
      'meta-llama/llama-3-70b-instruct',
      'google/gemini-pro-1.5',
      'openai/gpt-4-turbo',
    ],
  };

  @override
  void initState() {
    super.initState();
    _agentNameController = TextEditingController(text: 'Copiloto Financeiro Nexialista');
    _systemPromptController = TextEditingController(text: AIAgentConfig.defaultSystemPrompt);
    _apiKeyController = TextEditingController();
    _temperatureController = TextEditingController(text: '0.7');
    _maxTokensController = TextEditingController(text: '2000');
  }

  @override
  void dispose() {
    _agentNameController.dispose();
    _systemPromptController.dispose();
    _apiKeyController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  // Verificar se usuário é admin
  bool get isAdmin => widget.userProfile.isAdmin;

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Apenas administradores podem acessar\nesta funcionalidade',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração do Agente IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Nome do Agente
              _buildTextField(
                controller: _agentNameController,
                label: 'Nome do Agente',
                icon: Icons.psychology,
                hint: 'Ex: Copiloto Financeiro Nexialista',
              ),
              const SizedBox(height: 24),

              // Papel do Agente
              _buildRoleSelector(),
              const SizedBox(height: 24),

              // Provider LLM
              _buildProviderSelector(),
              const SizedBox(height: 24),

              // Modelo
              _buildModelSelector(),
              const SizedBox(height: 24),

              // API Key
              _buildTextField(
                controller: _apiKeyController,
                label: 'API Key',
                icon: Icons.key,
                hint: 'Cole sua API key aqui',
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'API Key é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // System Prompt
              _buildSystemPromptEditor(),
              const SizedBox(height: 24),

              // Parâmetros do Modelo
              _buildModelParameters(),
              const SizedBox(height: 24),

              // Switches
              _buildSwitches(),
              const SizedBox(height: 32),

              // Botões de Ação
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF2196F3)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.smart_toy, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agente IA Nexialista',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure o cérebro artificial do sistema',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Papel do Agente',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AgentRole.values.map((role) {
            final isSelected = _selectedRole == role;
            return ChoiceChip(
              label: Text(_roleLabel(role)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedRole = role);
              },
              avatar: Icon(
                _roleIcon(role),
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProviderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provedor LLM',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LLMProvider.values.map((provider) {
            final isSelected = _selectedProvider == provider;
            return ChoiceChip(
              label: Text(_providerLabel(provider)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedProvider = provider;
                    _selectedModel = _availableModels[provider]![0];
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    final models = _availableModels[_selectedProvider]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modelo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedModel,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.model_training),
          ),
          items: models.map((model) {
            return DropdownMenuItem(
              value: model,
              child: Text(model),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedModel = value);
          },
        ),
      ],
    );
  }

  Widget _buildSystemPromptEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'System Prompt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.restore, size: 16),
              label: const Text('Restaurar Padrão'),
              onPressed: () {
                setState(() {
                  _systemPromptController.text = AIAgentConfig.defaultSystemPrompt;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _systemPromptController,
          maxLines: 15,
          decoration: const InputDecoration(
            hintText: 'Defina a personalidade e comportamento do agente...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'System prompt é obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModelParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parâmetros do Modelo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _temperatureController,
                label: 'Temperature',
                icon: Icons.thermostat,
                hint: '0.0 - 1.0',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _maxTokensController,
                label: 'Max Tokens',
                icon: Icons.numbers,
                hint: '1000 - 4000',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitches() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Agente Ativo'),
          subtitle: const Text('Permitir uso do agente no sistema'),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
        ),
        SwitchListTile(
          title: const Text('Configuração Padrão'),
          subtitle: const Text('Usar como agente padrão do sistema'),
          value: _isDefault,
          onChanged: (value) => setState(() => _isDefault = value),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _saveConfiguration,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Salvar Configuração',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _testConfiguration,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Testar Configuração'),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Salvar no Firestore/Hive
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Configuração salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testConfiguration() {
    // TODO: Fazer chamada de teste ao LLM
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🧪 Teste do Agente'),
        content: const Text('Enviando mensagem de teste ao modelo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ℹ️ Sobre o Agente IA'),
        content: const SingleChildScrollView(
          child: Text(
            'O Agente IA Nexialista é um sistema inteligente que:\n\n'
            '• Analisa seus dados financeiros\n'
            '• Classifica despesas automaticamente\n'
            '• Gera relatórios personalizados\n'
            '• Oferece insights e recomendações\n'
            '• Responde perguntas sobre suas finanças\n\n'
            'Configure o provider, modelo e comportamento\n'
            'do agente para personalizar a experiência.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String _roleLabel(AgentRole role) {
    switch (role) {
      case AgentRole.assistant:
        return 'Assistente';
      case AgentRole.analyst:
        return 'Analista';
      case AgentRole.advisor:
        return 'Consultor';
      case AgentRole.classifier:
        return 'Classificador';
    }
  }

  IconData _roleIcon(AgentRole role) {
    switch (role) {
      case AgentRole.assistant:
        return Icons.support_agent;
      case AgentRole.analyst:
        return Icons.analytics;
      case AgentRole.advisor:
        return Icons.lightbulb;
      case AgentRole.classifier:
        return Icons.category;
    }
  }

  String _providerLabel(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.gemini:
        return 'Google Gemini';
      case LLMProvider.openai:
        return 'OpenAI';
      case LLMProvider.openrouter:
        return 'OpenRouter';
    }
  }
}
