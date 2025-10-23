// 🧬 HIVE ADAPTERS - Codificação Genética Local
// Permite persistência offline dos modelos do ecossistema

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'financial_account.dart';
import 'transaction.dart';
import 'category.dart';
import 'budget.dart';
import 'ai_insight.dart';

// 🧬 UserProfile Adapter
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    return UserProfile(
      id: reader.read(),
      email: reader.read(),
      name: reader.read(),
      timezone: reader.read(),
      baseCurrency: CurrencyPreference.values[reader.readByte()],
      riskProfile: RiskProfile.values[reader.readByte()],
      financialGoals: List<String>.from(reader.read()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      lastActive: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      metadata: Map<String, dynamic>.from(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.write(obj.id);
    writer.write(obj.email);
    writer.write(obj.name);
    writer.write(obj.timezone);
    writer.writeByte(obj.baseCurrency.index);
    writer.writeByte(obj.riskProfile.index);
    writer.write(obj.financialGoals);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.lastActive.millisecondsSinceEpoch);
    writer.write(obj.metadata);
  }
}

// 🧬 FinancialAccount Adapter
class FinancialAccountAdapter extends TypeAdapter<FinancialAccount> {
  @override
  final int typeId = 1;

  @override
  FinancialAccount read(BinaryReader reader) {
    return FinancialAccount(
      id: reader.read(),
      userId: reader.read(),
      name: reader.read(),
      type: AccountType.values[reader.readByte()],
      currency: reader.read(),
      institution: reader.read(),
      currentBalance: reader.readDouble(),
      creditLimit: reader.read(),
      status: AccountStatus.values[reader.readByte()],
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      metadata: Map<String, dynamic>.from(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, FinancialAccount obj) {
    writer.write(obj.id);
    writer.write(obj.userId);
    writer.write(obj.name);
    writer.writeByte(obj.type.index);
    writer.write(obj.currency);
    writer.write(obj.institution);
    writer.writeDouble(obj.currentBalance);
    writer.write(obj.creditLimit);
    writer.writeByte(obj.status.index);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);
    writer.write(obj.metadata);
  }
}

// 🧬 Transaction Adapter
class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 2;

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(
      id: reader.read(),
      userId: reader.read(),
      accountId: reader.read(),
      transactionDate: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      processedDate: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      originalAmount: reader.readDouble(),
      originalCurrency: reader.read(),
      convertedAmount: reader.readDouble(),
      exchangeRate: reader.read(),
      rawDescription: reader.read(),
      normalizedDescription: reader.read(),
      categoryId: reader.read(),
      subcategoryId: reader.read(),
      merchantId: reader.read(),
      merchantCategory: reader.read(),
      type: TransactionType.values[reader.readByte()],
      classificationConfidence: reader.readDouble(),
      isRecurring: reader.readBool(),
      deduplicationHash: reader.read(),
      importSource: reader.read(),
      metadata: Map<String, dynamic>.from(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.id);
    writer.write(obj.userId);
    writer.write(obj.accountId);
    writer.write(obj.transactionDate.millisecondsSinceEpoch);
    writer.write(obj.processedDate.millisecondsSinceEpoch);
    writer.writeDouble(obj.originalAmount);
    writer.write(obj.originalCurrency);
    writer.writeDouble(obj.convertedAmount);
    writer.write(obj.exchangeRate);
    writer.write(obj.rawDescription);
    writer.write(obj.normalizedDescription);
    writer.write(obj.categoryId);
    writer.write(obj.subcategoryId);
    writer.write(obj.merchantId);
    writer.write(obj.merchantCategory);
    writer.writeByte(obj.type.index);
    writer.writeDouble(obj.classificationConfidence);
    writer.writeBool(obj.isRecurring);
    writer.write(obj.deduplicationHash);
    writer.write(obj.importSource);
    writer.write(obj.metadata);
  }
}

// 🧬 Category Adapter
class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 3;

  @override
  Category read(BinaryReader reader) {
    return Category(
      id: reader.read(),
      userId: reader.read(),
      name: reader.read(),
      parentId: reader.read(),
      color: Color(reader.read()),
      icon: IconData(reader.read(), fontFamily: 'MaterialIcons'),
      type: CategoryType.values[reader.readByte()],
      order: reader.read(),
      isActive: reader.readBool(),
      mlKeywords: List<String>.from(reader.read()),
      autoClassificationRules: Map<String, dynamic>.from(reader.read()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.write(obj.id);
    writer.write(obj.userId);
    writer.write(obj.name);
    writer.write(obj.parentId);
    writer.write(obj.color.withValues().toARGB32());
    writer.write(obj.icon.codePoint);
    writer.writeByte(obj.type.index);
    writer.write(obj.order);
    writer.writeBool(obj.isActive);
    writer.write(obj.mlKeywords);
    writer.write(obj.autoClassificationRules);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);
  }
}

// 🧬 Budget Adapter
class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 4;

  @override
  Budget read(BinaryReader reader) {
    return Budget(
      id: reader.read(),
      userId: reader.read(),
      categoryId: reader.read(),
      periodStart: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      plannedAmount: reader.readDouble(),
      spentAmount: reader.readDouble(),
      currency: reader.read(),
      budgetType: BudgetType.values[reader.readByte()],
      period: BudgetPeriod.values[reader.readByte()],
      alertsConfig: Map<String, dynamic>.from(reader.read()),
      isActive: reader.readBool(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer.write(obj.id);
    writer.write(obj.userId);
    writer.write(obj.categoryId);
    writer.write(obj.periodStart.millisecondsSinceEpoch);
    writer.write(obj.periodEnd.millisecondsSinceEpoch);
    writer.writeDouble(obj.plannedAmount);
    writer.writeDouble(obj.spentAmount);
    writer.write(obj.currency);
    writer.writeByte(obj.budgetType.index);
    writer.writeByte(obj.period.index);
    writer.write(obj.alertsConfig);
    writer.writeBool(obj.isActive);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);
  }
}

// 🧬 AIInsight Adapter
class AIInsightAdapter extends TypeAdapter<AIInsight> {
  @override
  final int typeId = 5;

  @override
  AIInsight read(BinaryReader reader) {
    final seenAtMs = reader.read();
    final appliedAtMs = reader.read();
    
    return AIInsight(
      id: reader.read(),
      userId: reader.read(),
      type: InsightType.values[reader.readByte()],
      priority: InsightPriority.values[reader.readByte()],
      title: reader.read(),
      description: reader.read(),
      supportingData: Map<String, dynamic>.from(reader.read()),
      confidence: reader.readDouble(),
      suggestedAction: reader.read(),
      actionMetadata: reader.read(),
      status: InsightStatus.values[reader.readByte()],
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
      seenAt: seenAtMs != null ? DateTime.fromMillisecondsSinceEpoch(seenAtMs) : null,
      appliedAt: appliedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(appliedAtMs) : null,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, AIInsight obj) {
    writer.write(obj.seenAt?.millisecondsSinceEpoch);
    writer.write(obj.appliedAt?.millisecondsSinceEpoch);
    writer.write(obj.id);
    writer.write(obj.userId);
    writer.writeByte(obj.type.index);
    writer.writeByte(obj.priority.index);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.supportingData);
    writer.writeDouble(obj.confidence);
    writer.write(obj.suggestedAction);
    writer.write(obj.actionMetadata);
    writer.writeByte(obj.status.index);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.expiresAt.millisecondsSinceEpoch);
  }
}
