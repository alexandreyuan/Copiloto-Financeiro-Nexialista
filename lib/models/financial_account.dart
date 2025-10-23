// 🧬 MODELO: Conta Financeira - Órgãos do Sistema Econômico
// Inspiração Biológica: Contas são como órgãos - cada uma com função específica no metabolismo financeiro

import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType {
  checking, // Conta corrente - circulação diária
  savings, // Poupança - reserva energética
  investment, // Investimentos - crescimento celular
  credit, // Crédito - dívida metabólica
  wallet, // Carteira - energia imediata
}

enum AccountStatus {
  active, // Funcionamento pleno
  inactive, // Dormente
  archived, // Desativado
}

class FinancialAccount {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final String currency;
  final String? institution;
  final double currentBalance;
  final double? creditLimit;
  final AccountStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  FinancialAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.currency = 'BRL',
    this.institution,
    this.currentBalance = 0.0,
    this.creditLimit,
    this.status = AccountStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  // 🧬 Construtor a partir de Firestore
  factory FinancialAccount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialAccount(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'checking'),
        orElse: () => AccountType.checking,
      ),
      currency: data['currency'] as String? ?? 'BRL',
      institution: data['institution'] as String?,
      currentBalance: (data['current_balance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (data['credit_limit'] as num?)?.toDouble(),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'active'),
        orElse: () => AccountStatus.active,
      ),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // 🧬 Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'name': name,
      'type': type.name,
      'currency': currency,
      'institution': institution,
      'current_balance': currentBalance,
      'credit_limit': creditLimit,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  // 🧬 Mutação adaptativa
  FinancialAccount copyWith({
    String? name,
    AccountType? type,
    String? currency,
    String? institution,
    double? currentBalance,
    double? creditLimit,
    AccountStatus? status,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FinancialAccount(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      institution: institution ?? this.institution,
      currentBalance: currentBalance ?? this.currentBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  // 🧬 Saúde do órgão (disponibilidade financeira)
  double get availableBalance {
    if (type == AccountType.credit && creditLimit != null) {
      return creditLimit! + currentBalance; // Crédito é negativo
    }
    return currentBalance;
  }

  // 🧬 Status de saúde
  bool get isHealthy => currentBalance >= 0 || type == AccountType.credit;
}
