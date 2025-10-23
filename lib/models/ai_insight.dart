// 🧬 MODELO: Insights de IA - Sinapses Inteligentes do Sistema
// Inspiração Neurociência: Insights como conexões neurais que emergem de padrões detectados
// Inspiração Psicologia: Nudges comportamentais baseados em ciência cognitiva

import 'package:cloud_firestore/cloud_firestore.dart';

enum InsightType {
  anomalyDetection, // Sistema Imunológico: Detectou padrão suspeito
  spendingPattern, // Padrão comportamental identificado
  savingsOpportunity, // Oportunidade de otimização energética
  budgetAlert, // Alerta de homeostase
  prediction, // Previsão baseada em padrões históricos
  recommendation, // Recomendação comportamental personalizada
  milestone, // Conquista/marco alcançado
}

enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

enum InsightStatus {
  new_, // Novo insight não visualizado
  seen, // Visualizado mas não aplicado
  applied, // Ação foi tomada
  dismissed, // Descartado pelo usuário
}

class AIInsight {
  final String id;
  final String userId;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String description;
  final Map<String, dynamic> supportingData; // Dados que justificam o insight
  final double confidence; // Confiança da IA (0.0 a 1.0)
  final String? suggestedAction; // Ação sugerida ao usuário
  final Map<String, dynamic>? actionMetadata; // Dados para executar ação
  final InsightStatus status;
  final DateTime createdAt;
  final DateTime? seenAt;
  final DateTime? appliedAt;
  final DateTime expiresAt; // Insights têm validade temporal

  AIInsight({
    required this.id,
    required this.userId,
    required this.type,
    this.priority = InsightPriority.medium,
    required this.title,
    required this.description,
    this.supportingData = const {},
    this.confidence = 0.0,
    this.suggestedAction,
    this.actionMetadata,
    this.status = InsightStatus.new_,
    required this.createdAt,
    this.seenAt,
    this.appliedAt,
    required this.expiresAt,
  });

  // 🧬 Construtor a partir de Firestore
  factory AIInsight.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIInsight(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      type: InsightType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'recommendation'),
        orElse: () => InsightType.recommendation,
      ),
      priority: InsightPriority.values.firstWhere(
        (e) => e.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => InsightPriority.medium,
      ),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      supportingData: data['supporting_data'] as Map<String, dynamic>? ?? {},
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      suggestedAction: data['suggested_action'] as String?,
      actionMetadata: data['action_metadata'] as Map<String, dynamic>?,
      status: InsightStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'new_'),
        orElse: () => InsightStatus.new_,
      ),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seenAt: (data['seen_at'] as Timestamp?)?.toDate(),
      appliedAt: (data['applied_at'] as Timestamp?)?.toDate(),
      expiresAt: (data['expires_at'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
    );
  }

  // 🧬 Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'supporting_data': supportingData,
      'confidence': confidence,
      'suggested_action': suggestedAction,
      'action_metadata': actionMetadata,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
      'seen_at': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
      'applied_at': appliedAt != null ? Timestamp.fromDate(appliedAt!) : null,
      'expires_at': Timestamp.fromDate(expiresAt),
    };
  }

  // 🧬 Mutação adaptativa
  AIInsight copyWith({
    InsightPriority? priority,
    String? title,
    String? description,
    Map<String, dynamic>? supportingData,
    double? confidence,
    String? suggestedAction,
    Map<String, dynamic>? actionMetadata,
    InsightStatus? status,
    DateTime? seenAt,
    DateTime? appliedAt,
    DateTime? expiresAt,
  }) {
    return AIInsight(
      id: id,
      userId: userId,
      type: type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      supportingData: supportingData ?? this.supportingData,
      confidence: confidence ?? this.confidence,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      actionMetadata: actionMetadata ?? this.actionMetadata,
      status: status ?? this.status,
      createdAt: createdAt,
      seenAt: seenAt ?? this.seenAt,
      appliedAt: appliedAt ?? this.appliedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // 🧬 Verificações de estado
  bool get isNew => status == InsightStatus.new_;
  bool get isSeen => status == InsightStatus.seen;
  bool get isApplied => status == InsightStatus.applied;
  bool get isDismissed => status == InsightStatus.dismissed;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isHighConfidence => confidence >= 0.75;
  bool get isActionable => suggestedAction != null;

  // 🧬 Marcar como visto
  AIInsight markAsSeen() {
    return copyWith(
      status: InsightStatus.seen,
      seenAt: DateTime.now(),
    );
  }

  // 🧬 Marcar como aplicado
  AIInsight markAsApplied() {
    return copyWith(
      status: InsightStatus.applied,
      appliedAt: DateTime.now(),
    );
  }

  // 🧬 Descartar insight
  AIInsight dismiss() {
    return copyWith(status: InsightStatus.dismissed);
  }
}

// 🧬 GERADOR DE INSIGHTS NEXIALISTAS
class InsightGenerator {
  // 🧬 Detectar anomalias (Sistema Imunológico)
  static AIInsight createAnomalyInsight({
    required String userId,
    required String title,
    required String description,
    required Map<String, dynamic> anomalyData,
    double confidence = 0.8,
  }) {
    return AIInsight(
      id: '', // Será gerado pelo Firestore
      userId: userId,
      type: InsightType.anomalyDetection,
      priority: InsightPriority.high,
      title: title,
      description: description,
      supportingData: anomalyData,
      confidence: confidence,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
    );
  }

  // 🧬 Oportunidade de economia (Otimização Energética)
  static AIInsight createSavingsOpportunity({
    required String userId,
    required String title,
    required String description,
    required double potentialSavings,
    String? suggestedAction,
    double confidence = 0.7,
  }) {
    return AIInsight(
      id: '',
      userId: userId,
      type: InsightType.savingsOpportunity,
      priority: InsightPriority.medium,
      title: title,
      description: description,
      supportingData: {'potential_savings': potentialSavings},
      confidence: confidence,
      suggestedAction: suggestedAction,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  // 🧬 Alerta de orçamento (Homeostase)
  static AIInsight createBudgetAlert({
    required String userId,
    required String categoryName,
    required double percentageUsed,
    required String alertMessage,
  }) {
    return AIInsight(
      id: '',
      userId: userId,
      type: InsightType.budgetAlert,
      priority: percentageUsed >= 100 ? InsightPriority.critical : InsightPriority.high,
      title: '⚠️ Alerta de Orçamento: $categoryName',
      description: alertMessage,
      supportingData: {
        'category': categoryName,
        'percentage_used': percentageUsed,
      },
      confidence: 1.0,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 2)),
    );
  }

  // 🧬 Marco alcançado (Reforço Positivo)
  static AIInsight createMilestoneInsight({
    required String userId,
    required String achievement,
    required Map<String, dynamic> milestoneData,
  }) {
    return AIInsight(
      id: '',
      userId: userId,
      type: InsightType.milestone,
      priority: InsightPriority.low,
      title: '🎉 Conquista Desbloqueada!',
      description: achievement,
      supportingData: milestoneData,
      confidence: 1.0,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }
}
