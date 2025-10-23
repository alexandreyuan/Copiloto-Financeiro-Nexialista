// 🧬 MODELO: Perfil de Usuário - Identidade do Organismo Digital
// Inspiração Biológica: Cada usuário é um organismo único com metabolismo financeiro próprio

import 'package:cloud_firestore/cloud_firestore.dart';

enum RiskProfile {
  conservative, // Homeostase rigorosa - evita flutuações
  moderate, // Equilíbrio adaptativo - aceita variações controladas
  aggressive, // Evolução acelerada - busca crescimento rápido
}

enum CurrencyPreference {
  brl, // Real Brasileiro
  eur, // Euro
  usd, // Dólar Americano
  mixed, // Multi-moeda adaptativa
}

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String timezone;
  final CurrencyPreference baseCurrency;
  final RiskProfile riskProfile;
  final List<String> financialGoals;
  final DateTime createdAt;
  final DateTime lastActive;
  final Map<String, dynamic> metadata;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.timezone = 'America/Sao_Paulo',
    this.baseCurrency = CurrencyPreference.brl,
    this.riskProfile = RiskProfile.moderate,
    this.financialGoals = const [],
    required this.createdAt,
    required this.lastActive,
    this.metadata = const {},
  });

  // 🧬 Construtor a partir de Firestore (nascimento digital)
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      timezone: data['timezone'] as String? ?? 'America/Sao_Paulo',
      baseCurrency: CurrencyPreference.values.firstWhere(
        (e) => e.name == (data['base_currency'] as String? ?? 'brl'),
        orElse: () => CurrencyPreference.brl,
      ),
      riskProfile: RiskProfile.values.firstWhere(
        (e) => e.name == (data['risk_profile'] as String? ?? 'moderate'),
        orElse: () => RiskProfile.moderate,
      ),
      financialGoals: List<String>.from(data['financial_goals'] as List? ?? []),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['last_active'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // 🧬 Conversão para Firestore (replicação digital)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'timezone': timezone,
      'base_currency': baseCurrency.name,
      'risk_profile': riskProfile.name,
      'financial_goals': financialGoals,
      'created_at': Timestamp.fromDate(createdAt),
      'last_active': Timestamp.fromDate(lastActive),
      'metadata': metadata,
    };
  }

  // 🧬 Cópia com mutação adaptativa
  UserProfile copyWith({
    String? email,
    String? name,
    String? timezone,
    CurrencyPreference? baseCurrency,
    RiskProfile? riskProfile,
    List<String>? financialGoals,
    DateTime? lastActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      riskProfile: riskProfile ?? this.riskProfile,
      financialGoals: financialGoals ?? this.financialGoals,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      metadata: metadata ?? this.metadata,
    );
  }
}
