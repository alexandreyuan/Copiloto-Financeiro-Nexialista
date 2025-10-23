// 🧬 MODELO: Orçamento - Homeostase Financeira Desejada
// Inspiração Biológica: Orçamentos como set-point fisiológico - o sistema busca manter equilíbrio

import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetType {
  fixed, // Limite rígido - homeostase rigorosa
  flexible, // Limite suave - permite variações adaptativas
  adaptive, // Aprende e ajusta automaticamente com IA
}

enum BudgetPeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum AlertLevel {
  info, // 50% do orçamento
  warning, // 75% do orçamento
  critical, // 90% do orçamento
  exceeded, // > 100% do orçamento
}

class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double plannedAmount;
  final double spentAmount;
  final String currency;
  final BudgetType budgetType;
  final BudgetPeriod period;
  final Map<String, dynamic> alertsConfig;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.periodStart,
    required this.periodEnd,
    required this.plannedAmount,
    this.spentAmount = 0.0,
    this.currency = 'BRL',
    this.budgetType = BudgetType.fixed,
    this.period = BudgetPeriod.monthly,
    this.alertsConfig = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // 🧬 Construtor a partir de Firestore
  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      categoryId: data['category_id'] as String? ?? '',
      periodStart: (data['period_start'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodEnd: (data['period_end'] as Timestamp?)?.toDate() ?? DateTime.now(),
      plannedAmount: (data['planned_amount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (data['spent_amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'BRL',
      budgetType: BudgetType.values.firstWhere(
        (e) => e.name == (data['budget_type'] as String? ?? 'fixed'),
        orElse: () => BudgetType.fixed,
      ),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == (data['period'] as String? ?? 'monthly'),
        orElse: () => BudgetPeriod.monthly,
      ),
      alertsConfig: data['alerts_config'] as Map<String, dynamic>? ?? {},
      isActive: data['is_active'] as bool? ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🧬 Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'period_start': Timestamp.fromDate(periodStart),
      'period_end': Timestamp.fromDate(periodEnd),
      'planned_amount': plannedAmount,
      'spent_amount': spentAmount,
      'currency': currency,
      'budget_type': budgetType.name,
      'period': period.name,
      'alerts_config': alertsConfig,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // 🧬 Mutação adaptativa
  Budget copyWith({
    String? categoryId,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? plannedAmount,
    double? spentAmount,
    String? currency,
    BudgetType? budgetType,
    BudgetPeriod? period,
    Map<String, dynamic>? alertsConfig,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      currency: currency ?? this.currency,
      budgetType: budgetType ?? this.budgetType,
      period: period ?? this.period,
      alertsConfig: alertsConfig ?? this.alertsConfig,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 🧬 Análise de Homeostase (Estado do Orçamento)
  
  // Percentual gasto
  double get percentageUsed {
    if (plannedAmount == 0) return 0;
    return (spentAmount / plannedAmount * 100).clamp(0, 200);
  }

  // Valor restante
  double get remaining => (plannedAmount - spentAmount).clamp(0, plannedAmount);

  // Dias restantes no período
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(periodEnd)) return 0;
    return periodEnd.difference(now).inDays;
  }

  // Dias totais do período
  int get totalDays => periodEnd.difference(periodStart).inDays;

  // Percentual de tempo decorrido
  double get timeElapsedPercentage {
    final now = DateTime.now();
    if (now.isBefore(periodStart)) return 0;
    if (now.isAfter(periodEnd)) return 100;
    
    final elapsed = now.difference(periodStart).inDays;
    final total = totalDays;
    return (elapsed / total * 100).clamp(0, 100);
  }

  // Projeção de gasto ao final do período (baseado no ritmo atual)
  double get projectedSpending {
    if (timeElapsedPercentage == 0) return 0;
    return spentAmount / (timeElapsedPercentage / 100);
  }

  // Nível de alerta baseado no percentual gasto
  AlertLevel get alertLevel {
    final percentage = percentageUsed;
    if (percentage >= 100) return AlertLevel.exceeded;
    if (percentage >= 90) return AlertLevel.critical;
    if (percentage >= 75) return AlertLevel.warning;
    if (percentage >= 50) return AlertLevel.info;
    return AlertLevel.info;
  }

  // Verificação de saúde do orçamento
  bool get isHealthy => percentageUsed < 90;
  
  // Taxa de queima diária média
  double get dailyBurnRate {
    final daysElapsed = totalDays - daysRemaining;
    if (daysElapsed == 0) return 0;
    return spentAmount / daysElapsed;
  }

  // Taxa de queima sustentável (para não estourar o orçamento)
  double get sustainableDailyRate {
    if (daysRemaining == 0) return 0;
    return remaining / daysRemaining;
  }

  // Verificação se está no caminho certo (spending pace)
  bool get isOnTrack => percentageUsed <= timeElapsedPercentage + 10; // Margem de 10%
}
