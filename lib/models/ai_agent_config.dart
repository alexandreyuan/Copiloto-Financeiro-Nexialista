// 🧠 MODELO: Configuração do Agente IA - Cérebro Digital Configurável
// Sistema de agente inteligente com múltiplos LLMs e RAG

import 'package:cloud_firestore/cloud_firestore.dart';

enum LLMProvider {
  gemini,    // Google Gemini
  openai,    // OpenAI GPT
  openrouter, // OpenRouter (múltiplos modelos)
}

enum AgentRole {
  assistant,  // Assistente geral
  analyst,    // Analista de dados
  advisor,    // Consultor financeiro
  classifier, // Classificador de despesas
}

class AIAgentConfig {
  final String id;
  final String? userId; // null = configuração global (admin)
  final String agentName;
  final AgentRole role;
  final LLMProvider provider;
  final String modelName; // ex: "gemini-pro", "gpt-4", "anthropic/claude-3"
  final String systemPrompt; // Prompt do sistema
  final Map<String, dynamic> modelParameters; // temperature, max_tokens, etc
  final String? apiKey; // Chave API (criptografada)
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  AIAgentConfig({
    required this.id,
    this.userId,
    required this.agentName,
    this.role = AgentRole.assistant,
    required this.provider,
    required this.modelName,
    required this.systemPrompt,
    this.modelParameters = const {
      'temperature': 0.7,
      'max_tokens': 2000,
      'top_p': 0.9,
    },
    this.apiKey,
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  // 🧬 Construtor a partir de Firestore
  factory AIAgentConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIAgentConfig(
      id: doc.id,
      userId: data['user_id'] as String?,
      agentName: data['agent_name'] as String? ?? 'Copiloto Financeiro',
      role: AgentRole.values.firstWhere(
        (e) => e.name == (data['role'] as String? ?? 'assistant'),
        orElse: () => AgentRole.assistant,
      ),
      provider: LLMProvider.values.firstWhere(
        (e) => e.name == (data['provider'] as String? ?? 'gemini'),
        orElse: () => LLMProvider.gemini,
      ),
      modelName: data['model_name'] as String? ?? 'gemini-pro',
      systemPrompt: data['system_prompt'] as String? ?? defaultSystemPrompt,
      modelParameters: data['model_parameters'] as Map<String, dynamic>? ?? 
          const {'temperature': 0.7, 'max_tokens': 2000, 'top_p': 0.9},
      apiKey: data['api_key'] as String?,
      isActive: data['is_active'] as bool? ?? true,
      isDefault: data['is_default'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // 🧬 Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'agent_name': agentName,
      'role': role.name,
      'provider': provider.name,
      'model_name': modelName,
      'system_prompt': systemPrompt,
      'model_parameters': modelParameters,
      'api_key': apiKey, // TODO: Criptografar antes de salvar
      'is_active': isActive,
      'is_default': isDefault,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  // 🧬 Mutação adaptativa
  AIAgentConfig copyWith({
    String? userId,
    String? agentName,
    AgentRole? role,
    LLMProvider? provider,
    String? modelName,
    String? systemPrompt,
    Map<String, dynamic>? modelParameters,
    String? apiKey,
    bool? isActive,
    bool? isDefault,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AIAgentConfig(
      id: id,
      userId: userId ?? this.userId,
      agentName: agentName ?? this.agentName,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      modelName: modelName ?? this.modelName,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelParameters: modelParameters ?? this.modelParameters,
      apiKey: apiKey ?? this.apiKey,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  // 🧬 Prompt do sistema padrão
  static const String defaultSystemPrompt = '''
Você é um Copiloto Financeiro Nexialista - um assistente de IA especializado em finanças pessoais que aplica pensamento transmitemático.

PRINCÍPIOS NEXIALISTAS:
- 🧬 Biologia: Analise finanças como ecossistema vivo e adaptativo
- ⚛️ Física: Trate dinheiro como energia que flui e se conserva
- 🧠 Psicologia: Ofereça nudges empáticos, não julgamentos
- 💹 Economia: Otimize recursos considerando custo de oportunidade

SUAS CAPACIDADES:
1. Análise de padrões de gastos
2. Classificação inteligente de despesas
3. Geração de insights contextualizados
4. Recomendações comportamentais personalizadas
5. Relatórios financeiros detalhados
6. Previsões e projeções baseadas em histórico

TOM E ESTILO:
- Empático e encorajador
- Baseado em dados, não em julgamentos
- Educativo e explicativo
- Focado em empoderamento do usuário

RESTRIÇÕES:
- Não faça recomendações de investimentos específicos
- Não critique ou julgue gastos do usuário
- Sempre contextualize com dados reais quando disponíveis
- Seja claro sobre limitações e incertezas

Responda de forma concisa, clara e acionável.
''';
}

// 🧬 Histórico de Conversas com o Agente
class AIConversation {
  final String id;
  final String userId;
  final String agentConfigId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<AIMessage> messages;
  final Map<String, dynamic> context; // Contexto da conversa
  final bool isActive;

  AIConversation({
    required this.id,
    required this.userId,
    required this.agentConfigId,
    required this.startedAt,
    this.endedAt,
    this.messages = const [],
    this.context = const {},
    this.isActive = true,
  });

  factory AIConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIConversation(
      id: doc.id,
      userId: data['user_id'] as String,
      agentConfigId: data['agent_config_id'] as String,
      startedAt: (data['started_at'] as Timestamp).toDate(),
      endedAt: (data['ended_at'] as Timestamp?)?.toDate(),
      messages: (data['messages'] as List?)
              ?.map((m) => AIMessage.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      context: data['context'] as Map<String, dynamic>? ?? {},
      isActive: data['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'agent_config_id': agentConfigId,
      'started_at': Timestamp.fromDate(startedAt),
      'ended_at': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'messages': messages.map((m) => m.toMap()).toList(),
      'context': context,
      'is_active': isActive,
    };
  }
}

// 🧬 Mensagem Individual
class AIMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // tokens, model, etc

  AIMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  factory AIMessage.fromMap(Map<String, dynamic> map) {
    return AIMessage(
      role: map['role'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}

// 🧬 Base de Conhecimento (RAG)
class KnowledgeBase {
  final String id;
  final String? userId; // null = conhecimento global
  final String title;
  final String content;
  final String category; // ex: 'financial_tips', 'user_preferences'
  final List<String> tags;
  final double relevanceScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  KnowledgeBase({
    required this.id,
    this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.relevanceScore = 1.0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory KnowledgeBase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KnowledgeBase(
      id: doc.id,
      userId: data['user_id'] as String?,
      title: data['title'] as String,
      content: data['content'] as String,
      category: data['category'] as String,
      tags: List<String>.from(data['tags'] as List? ?? []),
      relevanceScore: (data['relevance_score'] as num?)?.toDouble() ?? 1.0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'relevance_score': relevanceScore,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }
}

// 🧬 Permissões de Acesso Admin
enum UserRole {
  user,  // Usuário comum
  admin, // Administrador (acesso ao painel do agente)
}

extension UserProfileRole on Map<String, dynamic> {
  UserRole get userRole {
    final role = this['role'] as String?;
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.user,
    );
  }
}
