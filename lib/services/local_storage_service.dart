// 🧬 SERVIÇO: Armazenamento Local - Memória Celular do Organismo
// Sistema híbrido: funciona offline, sincroniza quando Firebase disponível

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/financial_account.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/ai_insight.dart';
import '../models/hive_adapters.dart';

class LocalStorageService {
  // 🧬 Singleton Pattern (único sistema nervoso)
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // 🧬 Box names (compartimentos celulares)
  static const String _userBox = 'users';
  static const String _accountsBox = 'accounts';
  static const String _transactionsBox = 'transactions';
  static const String _categoriesBox = 'categories';
  static const String _budgetsBox = 'budgets';
  static const String _insightsBox = 'insights';
  static const String _currentUserBox = 'current_user';

  final _uuid = const Uuid();

  // 🧬 Inicializar sistema nervoso local
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Registrar adapters (DNA digital)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FinancialAccountAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(BudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AIInsightAdapter());
    }

    // Abrir boxes (ativar compartimentos)
    await Hive.openBox(_currentUserBox);
    await Hive.openBox<UserProfile>(_userBox);
    await Hive.openBox<FinancialAccount>(_accountsBox);
    await Hive.openBox<Transaction>(_transactionsBox);
    await Hive.openBox<Category>(_categoriesBox);
    await Hive.openBox<Budget>(_budgetsBox);
    await Hive.openBox<AIInsight>(_insightsBox);
  }

  // ========================================
  // 🧬 USER PROFILE OPERATIONS
  // ========================================

  Future<UserProfile?> getCurrentUser() async {
    final box = Hive.box(_currentUserBox);
    final userId = box.get('current_user_id') as String?;
    if (userId == null) return null;

    final userBox = Hive.box<UserProfile>(_userBox);
    return userBox.get(userId);
  }

  Future<void> setCurrentUser(UserProfile user) async {
    final box = Hive.box(_currentUserBox);
    await box.put('current_user_id', user.id);

    final userBox = Hive.box<UserProfile>(_userBox);
    await userBox.put(user.id, user);
  }

  Future<void> clearCurrentUser() async {
    final box = Hive.box(_currentUserBox);
    await box.delete('current_user_id');
  }

  Future<UserProfile> createUser({
    required String email,
    required String name,
  }) async {
    final user = UserProfile(
      id: _uuid.v4(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    final box = Hive.box<UserProfile>(_userBox);
    await box.put(user.id, user);
    await setCurrentUser(user);

    return user;
  }

  Future<void> updateUser(UserProfile user) async {
    final box = Hive.box<UserProfile>(_userBox);
    await box.put(user.id, user.copyWith(lastActive: DateTime.now()));
  }

  // ========================================
  // 🧬 FINANCIAL ACCOUNT OPERATIONS
  // ========================================

  Future<List<FinancialAccount>> getAccounts(String userId) async {
    final box = Hive.box<FinancialAccount>(_accountsBox);
    return box.values.where((account) => account.userId == userId).toList();
  }

  Future<FinancialAccount> createAccount(FinancialAccount account) async {
    final box = Hive.box<FinancialAccount>(_accountsBox);
    final accountWithId = account.id.isEmpty
        ? account.copyWith(updatedAt: DateTime.now())
        : account;
    
    final id = accountWithId.id.isEmpty ? _uuid.v4() : accountWithId.id;
    final finalAccount = FinancialAccount(
      id: id,
      userId: accountWithId.userId,
      name: accountWithId.name,
      type: accountWithId.type,
      currency: accountWithId.currency,
      institution: accountWithId.institution,
      currentBalance: accountWithId.currentBalance,
      creditLimit: accountWithId.creditLimit,
      status: accountWithId.status,
      createdAt: accountWithId.createdAt,
      updatedAt: DateTime.now(),
      metadata: accountWithId.metadata,
    );

    await box.put(finalAccount.id, finalAccount);
    return finalAccount;
  }

  Future<void> updateAccount(FinancialAccount account) async {
    final box = Hive.box<FinancialAccount>(_accountsBox);
    await box.put(account.id, account.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteAccount(String accountId) async {
    final box = Hive.box<FinancialAccount>(_accountsBox);
    await box.delete(accountId);
  }

  // ========================================
  // 🧬 TRANSACTION OPERATIONS
  // ========================================

  Future<List<Transaction>> getTransactions(String userId) async {
    final box = Hive.box<Transaction>(_transactionsBox);
    final transactions = box.values.where((t) => t.userId == userId).toList();
    transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return transactions;
  }

  Future<List<Transaction>> getTransactionsByAccount(String accountId) async {
    final box = Hive.box<Transaction>(_transactionsBox);
    final transactions = box.values.where((t) => t.accountId == accountId).toList();
    transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return transactions;
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(_transactionsBox);
    final id = transaction.id.isEmpty ? _uuid.v4() : transaction.id;
    
    final finalTransaction = Transaction(
      id: id,
      userId: transaction.userId,
      accountId: transaction.accountId,
      transactionDate: transaction.transactionDate,
      processedDate: DateTime.now(),
      originalAmount: transaction.originalAmount,
      originalCurrency: transaction.originalCurrency,
      convertedAmount: transaction.convertedAmount,
      exchangeRate: transaction.exchangeRate,
      rawDescription: transaction.rawDescription,
      normalizedDescription: transaction.normalizedDescription,
      categoryId: transaction.categoryId,
      subcategoryId: transaction.subcategoryId,
      merchantId: transaction.merchantId,
      merchantCategory: transaction.merchantCategory,
      type: transaction.type,
      classificationConfidence: transaction.classificationConfidence,
      isRecurring: transaction.isRecurring,
      deduplicationHash: transaction.deduplicationHash,
      importSource: transaction.importSource,
      metadata: transaction.metadata,
    );

    await box.put(finalTransaction.id, finalTransaction);
    return finalTransaction;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(_transactionsBox);
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    final box = Hive.box<Transaction>(_transactionsBox);
    await box.delete(transactionId);
  }

  // ========================================
  // 🧬 CATEGORY OPERATIONS
  // ========================================

  Future<List<Category>> getCategories(String? userId) async {
    final box = Hive.box<Category>(_categoriesBox);
    final categories = box.values
        .where((c) => c.userId == userId || c.userId == null)
        .where((c) => c.isActive)
        .toList();
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }

  Future<Category> createCategory(Category category) async {
    final box = Hive.box<Category>(_categoriesBox);
    final id = category.id.isEmpty ? _uuid.v4() : category.id;
    
    final finalCategory = Category(
      id: id,
      userId: category.userId,
      name: category.name,
      parentId: category.parentId,
      color: category.color,
      icon: category.icon,
      type: category.type,
      order: category.order,
      isActive: category.isActive,
      mlKeywords: category.mlKeywords,
      autoClassificationRules: category.autoClassificationRules,
      createdAt: category.createdAt,
      updatedAt: DateTime.now(),
    );

    await box.put(finalCategory.id, finalCategory);
    return finalCategory;
  }

  Future<void> updateCategory(Category category) async {
    final box = Hive.box<Category>(_categoriesBox);
    await box.put(category.id, category.copyWith(updatedAt: DateTime.now()));
  }

  // ========================================
  // 🧬 BUDGET OPERATIONS
  // ========================================

  Future<List<Budget>> getBudgets(String userId) async {
    final box = Hive.box<Budget>(_budgetsBox);
    return box.values.where((b) => b.userId == userId && b.isActive).toList();
  }

  Future<Budget> createBudget(Budget budget) async {
    final box = Hive.box<Budget>(_budgetsBox);
    final id = budget.id.isEmpty ? _uuid.v4() : budget.id;
    
    final finalBudget = Budget(
      id: id,
      userId: budget.userId,
      categoryId: budget.categoryId,
      periodStart: budget.periodStart,
      periodEnd: budget.periodEnd,
      plannedAmount: budget.plannedAmount,
      spentAmount: budget.spentAmount,
      currency: budget.currency,
      budgetType: budget.budgetType,
      period: budget.period,
      alertsConfig: budget.alertsConfig,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
      updatedAt: DateTime.now(),
    );

    await box.put(finalBudget.id, finalBudget);
    return finalBudget;
  }

  Future<void> updateBudget(Budget budget) async {
    final box = Hive.box<Budget>(_budgetsBox);
    await box.put(budget.id, budget.copyWith(updatedAt: DateTime.now()));
  }

  // ========================================
  // 🧬 AI INSIGHT OPERATIONS
  // ========================================

  Future<List<AIInsight>> getInsights(String userId) async {
    final box = Hive.box<AIInsight>(_insightsBox);
    final now = DateTime.now();
    return box.values
        .where((i) => i.userId == userId && i.expiresAt.isAfter(now))
        .toList();
  }

  Future<AIInsight> createInsight(AIInsight insight) async {
    final box = Hive.box<AIInsight>(_insightsBox);
    final id = insight.id.isEmpty ? _uuid.v4() : insight.id;
    
    final finalInsight = AIInsight(
      id: id,
      userId: insight.userId,
      type: insight.type,
      priority: insight.priority,
      title: insight.title,
      description: insight.description,
      supportingData: insight.supportingData,
      confidence: insight.confidence,
      suggestedAction: insight.suggestedAction,
      actionMetadata: insight.actionMetadata,
      status: insight.status,
      createdAt: insight.createdAt,
      seenAt: insight.seenAt,
      appliedAt: insight.appliedAt,
      expiresAt: insight.expiresAt,
    );

    await box.put(finalInsight.id, finalInsight);
    return finalInsight;
  }

  Future<void> updateInsight(AIInsight insight) async {
    final box = Hive.box<AIInsight>(_insightsBox);
    await box.put(insight.id, insight);
  }

  // ========================================
  // 🧬 UTILITY OPERATIONS
  // ========================================

  Future<void> clearAllData() async {
    await Hive.box(_currentUserBox).clear();
    await Hive.box<UserProfile>(_userBox).clear();
    await Hive.box<FinancialAccount>(_accountsBox).clear();
    await Hive.box<Transaction>(_transactionsBox).clear();
    await Hive.box<Category>(_categoriesBox).clear();
    await Hive.box<Budget>(_budgetsBox).clear();
    await Hive.box<AIInsight>(_insightsBox).clear();
  }
}
