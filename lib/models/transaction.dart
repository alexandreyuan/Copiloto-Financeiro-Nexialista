// 🧬 MODELO: Transação - Fluxos de Energia Econômica
// Inspiração Física: Dinheiro como energia que flui, se transforma e nunca se perde (conservação)
// Inspiração Biológica: Transações como sinapses - conexões que formam padrões adaptativos

import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  expense, // Saída de energia
  income, // Entrada de energia
  transfer, // Transformação energética
}

class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final DateTime transactionDate;
  final DateTime processedDate;
  final double originalAmount;
  final String originalCurrency;
  final double convertedAmount; // Em moeda base do usuário
  final double? exchangeRate;
  final String rawDescription;
  final String normalizedDescription;
  final String? categoryId;
  final String? subcategoryId;
  final String? merchantId;
  final String? merchantCategory; // MCC code
  final TransactionType type;
  final double classificationConfidence;
  final bool isRecurring;
  final String deduplicationHash;
  final String importSource;
  final Map<String, dynamic> metadata;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.transactionDate,
    required this.processedDate,
    required this.originalAmount,
    this.originalCurrency = 'BRL',
    required this.convertedAmount,
    this.exchangeRate,
    required this.rawDescription,
    required this.normalizedDescription,
    this.categoryId,
    this.subcategoryId,
    this.merchantId,
    this.merchantCategory,
    this.type = TransactionType.expense,
    this.classificationConfidence = 0.0,
    this.isRecurring = false,
    required this.deduplicationHash,
    this.importSource = 'manual',
    this.metadata = const {},
  });

  // 🧬 Construtor a partir de Firestore
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      accountId: data['account_id'] as String? ?? '',
      transactionDate: (data['transaction_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedDate: (data['processed_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      originalAmount: (data['original_amount'] as num?)?.toDouble() ?? 0.0,
      originalCurrency: data['original_currency'] as String? ?? 'BRL',
      convertedAmount: (data['converted_amount'] as num?)?.toDouble() ?? 0.0,
      exchangeRate: (data['exchange_rate'] as num?)?.toDouble(),
      rawDescription: data['raw_description'] as String? ?? '',
      normalizedDescription: data['normalized_description'] as String? ?? '',
      categoryId: data['category_id'] as String?,
      subcategoryId: data['subcategory_id'] as String?,
      merchantId: data['merchant_id'] as String?,
      merchantCategory: data['merchant_category'] as String?,
      type: TransactionType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'expense'),
        orElse: () => TransactionType.expense,
      ),
      classificationConfidence: (data['classification_confidence'] as num?)?.toDouble() ?? 0.0,
      isRecurring: data['is_recurring'] as bool? ?? false,
      deduplicationHash: data['deduplication_hash'] as String? ?? '',
      importSource: data['import_source'] as String? ?? 'manual',
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // 🧬 Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'transaction_date': Timestamp.fromDate(transactionDate),
      'processed_date': Timestamp.fromDate(processedDate),
      'original_amount': originalAmount,
      'original_currency': originalCurrency,
      'converted_amount': convertedAmount,
      'exchange_rate': exchangeRate,
      'raw_description': rawDescription,
      'normalized_description': normalizedDescription,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'merchant_id': merchantId,
      'merchant_category': merchantCategory,
      'type': type.name,
      'classification_confidence': classificationConfidence,
      'is_recurring': isRecurring,
      'deduplication_hash': deduplicationHash,
      'import_source': importSource,
      'metadata': metadata,
    };
  }

  // 🧬 Mutação adaptativa
  Transaction copyWith({
    String? accountId,
    DateTime? transactionDate,
    double? originalAmount,
    String? originalCurrency,
    double? convertedAmount,
    double? exchangeRate,
    String? rawDescription,
    String? normalizedDescription,
    String? categoryId,
    String? subcategoryId,
    String? merchantId,
    String? merchantCategory,
    TransactionType? type,
    double? classificationConfidence,
    bool? isRecurring,
    String? importSource,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId ?? this.accountId,
      transactionDate: transactionDate ?? this.transactionDate,
      processedDate: processedDate,
      originalAmount: originalAmount ?? this.originalAmount,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      rawDescription: rawDescription ?? this.rawDescription,
      normalizedDescription: normalizedDescription ?? this.normalizedDescription,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      merchantId: merchantId ?? this.merchantId,
      merchantCategory: merchantCategory ?? this.merchantCategory,
      type: type ?? this.type,
      classificationConfidence: classificationConfidence ?? this.classificationConfidence,
      isRecurring: isRecurring ?? this.isRecurring,
      deduplicationHash: deduplicationHash,
      importSource: importSource ?? this.importSource,
      metadata: metadata ?? this.metadata,
    );
  }

  // 🧬 Análise energética
  bool get isEnergyGain => type == TransactionType.income;
  bool get isEnergyLoss => type == TransactionType.expense;
  bool get isWellClassified => classificationConfidence > 0.75;
  
  // 🧬 Impacto energético (positivo ou negativo)
  double get energyImpact {
    switch (type) {
      case TransactionType.income:
        return convertedAmount.abs();
      case TransactionType.expense:
        return -convertedAmount.abs();
      case TransactionType.transfer:
        return 0.0;
    }
  }
}
