// 🧠 TELA: Chat com Agente IA - Interface de Conversação

import 'package:flutter/material.dart';
import '../../models/ai_agent_config.dart';
import '../../models/user_profile.dart';
import '../../services/ai_agent_service.dart';

class AIChatScreen extends StatefulWidget {
  final UserProfile userProfile;
  final AIAgentConfig? agentConfig;

  const AIChatScreen({
    super.key,
    required this.userProfile,
    this.agentConfig,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _agentService = AIAgentService();

  final List<AIMessage> _messages = [];
  bool _isLoading = false;
  late AIAgentConfig _config;

  @override
  void initState() {
    super.initState();
    // TODO: Carregar configuração padrão se não fornecida
    _config = widget.agentConfig ?? _createDefaultConfig();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  AIAgentConfig _createDefaultConfig() {
    // Configuração padrão temporária
    return AIAgentConfig(
      id: 'default',
      agentName: 'Copiloto Financeiro',
      provider: LLMProvider.gemini,
      modelName: 'gemini-pro',
      systemPrompt: AIAgentConfig.defaultSystemPrompt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _addWelcomeMessage() {
    _messages.add(AIMessage(
      role: 'assistant',
      content: '👋 Olá! Sou seu Copiloto Financeiro Nexialista.\n\n'
          'Posso ajudar você a:\n'
          '• Analisar seus gastos e receitas\n'
          '• Classificar transações automaticamente\n'
          '• Gerar relatórios personalizados\n'
          '• Oferecer insights sobre suas finanças\n'
          '• Responder suas dúvidas financeiras\n\n'
          'Como posso ajudar você hoje?',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Adicionar mensagem do usuário
    setState(() {
      _messages.add(AIMessage(
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Gerar resposta do agente
      final response = await _agentService.generateResponse(
        config: _config,
        userMessage: text,
        conversationHistory: _messages.take(_messages.length - 1).toList(),
      );

      // Adicionar resposta do agente
      setState(() {
        _messages.add(AIMessage(
          role: 'assistant',
          content: response,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(AIMessage(
          role: 'assistant',
          content: '❌ Erro ao processar sua mensagem: $e\n\n'
              'Verifique se a API está configurada corretamente no painel de administração.',
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_config.agentName),
            Text(
              _providerLabel(_config.provider),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Limpar conversa',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(width: 12),
                  Text(
                    'Pensando...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Input Field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF00C853),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF00C853) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                widget.userProfile.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: const Color(0xFF00C853),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Conversa'),
        content: const Text(
            'Tem certeza que deseja limpar toda a conversa? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
              Navigator.pop(context);
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Gerar Relatório Mensal'),
              onTap: () {
                Navigator.pop(context);
                _requestReport('monthly');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Solicitar Insights'),
              onTap: () {
                Navigator.pop(context);
                _requestInsights();
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Classificar Transações Pendentes'),
              onTap: () {
                Navigator.pop(context);
                _requestClassification();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _requestReport(String type) {
    _messageController.text = 'Gere um relatório $type das minhas finanças';
    _sendMessage();
  }

  void _requestInsights() {
    _messageController.text =
        'Analise meus dados e me dê insights sobre meus gastos';
    _sendMessage();
  }

  void _requestClassification() {
    _messageController.text =
        'Classifique minhas transações pendentes automaticamente';
    _sendMessage();
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Como Usar o Agente'),
        content: const SingleChildScrollView(
          child: Text(
            'PERGUNTAS SUGERIDAS:\n\n'
            '• Qual foi meu gasto total este mês?\n'
            '• Em que categoria eu gastei mais?\n'
            '• Como está meu orçamento?\n'
            '• Gere um relatório dos últimos 30 dias\n'
            '• Quais insights você tem sobre meus gastos?\n'
            '• Classifique minhas transações\n'
            '• Me dê dicas para economizar\n\n'
            'FUNCIONALIDADES:\n\n'
            '📊 Análise de Dados\n'
            '🏷️ Classificação Automática\n'
            '📈 Relatórios Personalizados\n'
            '💡 Insights Inteligentes\n'
            '🎯 Recomendações Acionáveis',
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _providerLabel(LLMProvider provider) {
    switch (provider) {
      case LLMProvider.gemini:
        return 'Google Gemini';
      case LLMProvider.openai:
        return 'OpenAI GPT';
      case LLMProvider.openrouter:
        return 'OpenRouter';
    }
  }
}
