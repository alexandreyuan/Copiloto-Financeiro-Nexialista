// 🧠 SERVIÇO: Agente IA - Integração com Múltiplos LLMs
// Sistema inteligente de análise financeira e assessoria

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_agent_config.dart';
import '../models/transaction.dart';

import '../models/category.dart';
import 'local_storage_service.dart';

class AIAgentService {
  final _storage = LocalStorageService();

  // 🧠 Gerar resposta do agente
  Future<String> generateResponse({
    required AIAgentConfig config,
    required String userMessage,
    List<AIMessage>? conversationHistory,
    Map<String, dynamic>? financialContext,
  }) async {
    try {
      // Construir contexto financeiro se fornecido
      final contextPrompt = financialContext != null
          ? _buildFinancialContext(financialContext)
          : '';

      // Construir histórico de conversa
      final messages = <Map<String, dynamic>>[];
      
      // System prompt
      messages.add({
        'role': 'system',
        'content': config.systemPrompt + contextPrompt,
      });

      // Histórico anterior
      if (conversationHistory != null) {
        for (final msg in conversationHistory.take(10)) {
          // Últimas 10 mensagens
          messages.add({
            'role': msg.role,
            'content': msg.content,
          });
        }
      }

      // Mensagem atual do usuário
      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      // Chamar LLM apropriado
      switch (config.provider) {
        case LLMProvider.gemini:
          return await _callGemini(config, messages);
        case LLMProvider.openai:
          return await _callOpenAI(config, messages);
        case LLMProvider.openrouter:
          return await _callOpenRouter(config, messages);
      }
    } catch (e) {
      throw Exception('Erro ao gerar resposta: $e');
    }
  }

  // 🧠 Classificar transação automaticamente
  Future<Map<String, dynamic>> classifyTransaction({
    required AIAgentConfig config,
    required Transaction transaction,
    required List<Category> availableCategories,
  }) async {
    final categoriesText = availableCategories
        .map((c) => '- ${c.name}: ${c.mlKeywords.join(", ")}')
        .join('\n');

    final prompt = '''
Analise esta transação e classifique na categoria mais apropriada:

TRANSAÇÃO:
- Descrição: ${transaction.rawDescription}
- Valor: ${transaction.originalAmount} ${transaction.originalCurrency}
- Data: ${transaction.transactionDate}
- Tipo: ${transaction.type.name}

CATEGORIAS DISPONÍVEIS:
$categoriesText

Responda APENAS com um JSON válido no formato:
{
  "category_name": "nome_da_categoria",
  "confidence": 0.95,
  "reasoning": "breve explicação"
}
''';

    try {
      final response = await generateResponse(
        config: config,
        userMessage: prompt,
      );

      // Extrair JSON da resposta
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }

      throw Exception('Resposta inválida do agente');
    } catch (e) {
      throw Exception('Erro ao classificar transação: $e');
    }
  }

  // 🧠 Gerar relatório financeiro
  Future<String> generateFinancialReport({
    required AIAgentConfig config,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String reportType = 'monthly', // monthly, weekly, annual
  }) async {
    // Buscar dados financeiros do período
    final transactions = await _storage.getTransactions(userId);
    final budgets = await _storage.getBudgets(userId);

    final periodTransactions = transactions.where((t) =>
        t.transactionDate.isAfter(startDate) &&
        t.transactionDate.isBefore(endDate)).toList();

    // Calcular métricas
    final totalIncome = periodTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.convertedAmount);

    final totalExpenses = periodTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.convertedAmount.abs());

    final balance = totalIncome - totalExpenses;

    // Gastos por categoria
    final categoryExpenses = <String, double>{};
    for (final t in periodTransactions
        .where((t) => t.type == TransactionType.expense)) {
      final categoryId = t.categoryId ?? 'sem_categoria';
      categoryExpenses[categoryId] =
          (categoryExpenses[categoryId] ?? 0) + t.convertedAmount.abs();
    }

    final prompt = '''
Gere um relatório financeiro $reportType detalhado com base nestes dados:

PERÍODO: ${startDate.day}/${startDate.month}/${startDate.year} até ${endDate.day}/${endDate.month}/${endDate.year}

RESUMO FINANCEIRO:
- Receitas Totais: R\$ ${totalIncome.toStringAsFixed(2)}
- Despesas Totais: R\$ ${totalExpenses.toStringAsFixed(2)}
- Saldo: R\$ ${balance.toStringAsFixed(2)}
- Número de Transações: ${periodTransactions.length}

DESPESAS POR CATEGORIA:
${categoryExpenses.entries.map((e) => '- ${e.key}: R\$ ${e.value.toStringAsFixed(2)}').join('\n')}

ORÇAMENTOS:
${budgets.map((b) => '- Categoria ${b.categoryId}: ${b.percentageUsed.toStringAsFixed(1)}% usado').join('\n')}

Forneça uma análise nexialista detalhada incluindo:
1. Visão geral do período (física dos fluxos)
2. Análise de padrões de gastos (biologia comportamental)
3. Comparação com orçamentos (homeostase)
4. Insights e oportunidades (economia otimizada)
5. Recomendações acionáveis (psicologia aplicada)

Use formatação Markdown e seja visual e claro.
''';

    return await generateResponse(
      config: config,
      userMessage: prompt,
    );
  }

  // 🧠 Análise de padrões e insights
  Future<List<String>> generateInsights({
    required AIAgentConfig config,
    required String userId,
  }) async {
    final transactions = await _storage.getTransactions(userId);
    final budgets = await _storage.getBudgets(userId);

    if (transactions.isEmpty) {
      return ['Adicione transações para receber insights personalizados.'];
    }

    // Detectar padrões
    final now = DateTime.now();
    final last30Days = transactions.where((t) =>
        t.transactionDate.isAfter(now.subtract(const Duration(days: 30))));

    final avgDailyExpense = last30Days
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.convertedAmount.abs()) /
        30;

    final prompt = '''
Analise os dados financeiros e gere 3-5 insights acionáveis:

DADOS ÚLTIMOS 30 DIAS:
- Transações: ${last30Days.length}
- Gasto médio diário: R\$ ${avgDailyExpense.toStringAsFixed(2)}
- Orçamentos ativos: ${budgets.length}

Gere insights no formato:
1. [Ícone] Título do Insight
   Descrição breve e ação recomendada

Foque em:
- Padrões não óbvios
- Oportunidades de otimização
- Alertas preventivos
- Celebrações de conquistas
''';

    final response = await generateResponse(
      config: config,
      userMessage: prompt,
    );

    // Parsear insights (assumindo uma linha por insight)
    return response
        .split('\n')
        .where((line) => line.trim().isNotEmpty && line.contains('.'))
        .take(5)
        .toList();
  }

  // 🔧 Construir contexto financeiro para prompt
  String _buildFinancialContext(Map<String, dynamic> context) {
    final buffer = StringBuffer('\n\n--- CONTEXTO FINANCEIRO DO USUÁRIO ---\n');

    if (context.containsKey('recent_transactions')) {
      buffer.writeln('\nTRANSAÇÕES RECENTES:');
      final transactions = context['recent_transactions'] as List;
      for (final t in transactions.take(10)) {
        buffer.writeln('- ${t['description']}: ${t['amount']} (${t['date']})');
      }
    }

    if (context.containsKey('budgets')) {
      buffer.writeln('\nORÇAMENTOS:');
      final budgets = context['budgets'] as List;
      for (final b in budgets) {
        buffer.writeln(
            '- ${b['category']}: ${b['spent']}/${b['planned']} (${b['percentage']}%)');
      }
    }

    if (context.containsKey('balance')) {
      buffer.writeln('\nSALDO ATUAL: ${context['balance']}');
    }

    buffer.writeln('--- FIM DO CONTEXTO ---\n');
    return buffer.toString();
  }

  // 🔧 Integração Gemini
  Future<String> _callGemini(
      AIAgentConfig config, List<Map<String, dynamic>> messages) async {
    if (config.apiKey == null || config.apiKey!.isEmpty) {
      throw Exception('API Key do Gemini não configurada');
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${config.modelName}:generateContent?key=${config.apiKey}');

    // Converter mensagens para formato Gemini
    final contents = messages
        .where((m) => m['role'] != 'system')
        .map((m) => {
              'role': m['role'] == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': m['content']}
              ],
            })
        .toList();

    // Adicionar system prompt como primeira mensagem do usuário
    final systemMsg = messages.firstWhere((m) => m['role'] == 'system',
        orElse: () => {'content': ''});
    if (systemMsg['content'].toString().isNotEmpty) {
      contents.insert(0, {
        'role': 'user',
        'parts': [
          {'text': systemMsg['content']}
        ],
      });
    }

    final body = json.encode({
      'contents': contents,
      'generationConfig': {
        'temperature': config.modelParameters['temperature'] ?? 0.7,
        'maxOutputTokens': config.modelParameters['max_tokens'] ?? 2000,
        'topP': config.modelParameters['top_p'] ?? 0.9,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini API Error: ${response.body}');
    }
  }

  // 🔧 Integração OpenAI
  Future<String> _callOpenAI(
      AIAgentConfig config, List<Map<String, dynamic>> messages) async {
    if (config.apiKey == null || config.apiKey!.isEmpty) {
      throw Exception('API Key da OpenAI não configurada');
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final body = json.encode({
      'model': config.modelName,
      'messages': messages,
      'temperature': config.modelParameters['temperature'] ?? 0.7,
      'max_tokens': config.modelParameters['max_tokens'] ?? 2000,
      'top_p': config.modelParameters['top_p'] ?? 0.9,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI API Error: ${response.body}');
    }
  }

  // 🔧 Integração OpenRouter
  Future<String> _callOpenRouter(
      AIAgentConfig config, List<Map<String, dynamic>> messages) async {
    if (config.apiKey == null || config.apiKey!.isEmpty) {
      throw Exception('API Key do OpenRouter não configurada');
    }

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final body = json.encode({
      'model': config.modelName,
      'messages': messages,
      'temperature': config.modelParameters['temperature'] ?? 0.7,
      'max_tokens': config.modelParameters['max_tokens'] ?? 2000,
      'top_p': config.modelParameters['top_p'] ?? 0.9,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
        'HTTP-Referer': 'https://nexialfinance.app',
        'X-Title': 'Nexial Finance',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenRouter API Error: ${response.body}');
    }
  }
}
