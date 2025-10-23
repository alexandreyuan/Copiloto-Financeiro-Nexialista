// 🧬 MODELO: Categoria - Sistema de Classificação Orgânica
// Inspiração Biológica: Taxonomia adaptativa - categorias evoluem com o comportamento do usuário

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoryType {
  expense, // Consumo de energia
  income, // Produção de energia
}

class Category {
  final String id;
  final String? userId; // null = categoria global do sistema
  final String name;
  final String? parentId; // Para subcategorias (hierarquia orgânica)
  final Color color;
  final IconData icon;
  final CategoryType type;
  final int order;
  final bool isActive;
  final List<String> mlKeywords; // Palavras-chave para ML
  final Map<String, dynamic> autoClassificationRules;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    this.userId,
    required this.name,
    this.parentId,
    this.color = Colors.blue,
    this.icon = Icons.category,
    this.type = CategoryType.expense,
    this.order = 0,
    this.isActive = true,
    this.mlKeywords = const [],
    this.autoClassificationRules = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  // 🧬 Construtor a partir de Firestore
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      userId: data['user_id'] as String?,
      name: data['name'] as String? ?? '',
      parentId: data['parent_id'] as String?,
      color: Color(data['color'] as int? ?? 0xFF2196F3),
      icon: IconData(
        data['icon_code_point'] as int? ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      type: CategoryType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'expense'),
        orElse: () => CategoryType.expense,
      ),
      order: data['order'] as int? ?? 0,
      isActive: data['is_active'] as bool? ?? true,
      mlKeywords: List<String>.from(data['ml_keywords'] as List? ?? []),
      autoClassificationRules: data['auto_classification_rules'] as Map<String, dynamic>? ?? {},
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🧬 Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'name': name,
      'parent_id': parentId,
      'color': color.withValues().toARGB32(),
      'icon_code_point': icon.codePoint,
      'type': type.name,
      'order': order,
      'is_active': isActive,
      'ml_keywords': mlKeywords,
      'auto_classification_rules': autoClassificationRules,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // 🧬 Mutação adaptativa
  Category copyWith({
    String? userId,
    String? name,
    String? parentId,
    Color? color,
    IconData? icon,
    CategoryType? type,
    int? order,
    bool? isActive,
    List<String>? mlKeywords,
    Map<String, dynamic>? autoClassificationRules,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      mlKeywords: mlKeywords ?? this.mlKeywords,
      autoClassificationRules: autoClassificationRules ?? this.autoClassificationRules,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 🧬 Verificação se é categoria raiz
  bool get isRoot => parentId == null;
  
  // 🧬 Verificação se é subcategoria
  bool get isSubcategory => parentId != null;
  
  // 🧬 Verificação se é categoria global do sistema
  bool get isSystemCategory => userId == null;
}

// 🧬 CATEGORIAS GLOBAIS DO SISTEMA (DNA padrão)
class SystemCategories {
  // Categorias de Despesa (Consumo Energético)
  static final List<Map<String, dynamic>> expenseCategories = [
    {
      'name': '🍔 Alimentação',
      'color': Colors.orange.withValues().toARGB32(),
      'icon': Icons.restaurant.codePoint,
      'keywords': ['restaurante', 'ifood', 'uber eats', 'mercado', 'supermercado', 'padaria', 'lanchonete', 'bar', 'café'],
    },
    {
      'name': '🏠 Moradia',
      'color': Colors.brown.withValues().toARGB32(),
      'icon': Icons.home.codePoint,
      'keywords': ['aluguel', 'condominio', 'condomínio', 'iptu', 'energia', 'água', 'gás', 'internet'],
    },
    {
      'name': '🚗 Transporte',
      'color': Colors.blue.withValues().toARGB32(),
      'icon': Icons.directions_car.codePoint,
      'keywords': ['uber', '99', 'gasolina', 'combustível', 'estacionamento', 'pedágio', 'ônibus', 'metrô'],
    },
    {
      'name': '🏥 Saúde',
      'color': Colors.red.withValues().toARGB32(),
      'icon': Icons.medical_services.codePoint,
      'keywords': ['farmácia', 'médico', 'hospital', 'plano de saúde', 'consulta', 'exame', 'remédio'],
    },
    {
      'name': '🎓 Educação',
      'color': Colors.purple.withValues().toARGB32(),
      'icon': Icons.school.codePoint,
      'keywords': ['curso', 'faculdade', 'escola', 'livro', 'material escolar', 'mensalidade'],
    },
    {
      'name': '🎮 Lazer',
      'color': Colors.pink.withValues().toARGB32(),
      'icon': Icons.sports_esports.codePoint,
      'keywords': ['cinema', 'netflix', 'spotify', 'streaming', 'jogo', 'show', 'teatro', 'parque'],
    },
    {
      'name': '👕 Vestuário',
      'color': Colors.teal.withValues().toARGB32(),
      'icon': Icons.checkroom.codePoint,
      'keywords': ['roupa', 'sapato', 'calçado', 'acessório', 'moda', 'zara', 'renner'],
    },
    {
      'name': '💼 Trabalho',
      'color': Colors.indigo.withValues().toARGB32(),
      'icon': Icons.work.codePoint,
      'keywords': ['material', 'escritório', 'equipamento', 'ferramenta', 'software'],
    },
    {
      'name': '💳 Finanças',
      'color': Colors.green.withValues().toARGB32(),
      'icon': Icons.attach_money.codePoint,
      'keywords': ['banco', 'taxa', 'tarifa', 'anuidade', 'juros', 'empréstimo'],
    },
    {
      'name': '❓ Outros',
      'color': Colors.grey.withValues().toARGB32(),
      'icon': Icons.more_horiz.codePoint,
      'keywords': [],
    },
  ];

  // Categorias de Receita (Produção Energética)
  static final List<Map<String, dynamic>> incomeCategories = [
    {
      'name': '💰 Salário',
      'color': Colors.green.withValues().toARGB32(),
      'icon': Icons.payments.codePoint,
      'keywords': ['salário', 'salario', 'pagamento', 'vencimento', 'remuneração'],
    },
    {
      'name': '📈 Investimentos',
      'color': Colors.blue.withValues().toARGB32(),
      'icon': Icons.trending_up.codePoint,
      'keywords': ['dividendo', 'rendimento', 'lucro', 'renda', 'ação', 'fundo'],
    },
    {
      'name': '🎁 Extra',
      'color': Colors.purple.withValues().toARGB32(),
      'icon': Icons.card_giftcard.codePoint,
      'keywords': ['bônus', 'bonus', 'freelance', 'extra', 'presente', 'reembolso'],
    },
    {
      'name': '💼 Negócio',
      'color': Colors.orange.withValues().toARGB32(),
      'icon': Icons.business_center.codePoint,
      'keywords': ['venda', 'serviço', 'consultoria', 'negócio', 'empresa'],
    },
  ];
}
