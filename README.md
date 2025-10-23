# 🧠 Nexial Finance

## Ecossistema Financeiro Adaptativo - Organismo Digital Nexialista

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Web-lightgrey)

---

## 🌟 Visão Nexialista

**Nexial Finance** não é apenas um app de finanças. É um **organismo digital** que transcende as limitações dos gestores financeiros tradicionais, aplicando princípios transmitemáticos de múltiplos domínios do conhecimento:

- **🧬 Biologia**: Sistema que aprende e evolui como organismo vivo
- **⚛️ Física**: Dinheiro tratado como energia que flui e se conserva
- **🧠 Psicologia**: Mudanças comportamentais através de nudges empáticos
- **💹 Economia**: Otimização inteligente de recursos financeiros

---

## ✨ Características Principais

### 🔄 **Sistema Híbrido Resiliente**
- ✅ **Offline-First**: Funciona 100% sem internet
- ✅ **Sincronização Cloud**: Firebase ready para backup automático
- ✅ **Persistência Local**: Hive database para armazenamento rápido
- ✅ **Zero Latência**: Respostas instantâneas

### 🧬 **Arquitetura Adaptativa**
```
Sistema Nervoso Digital
├─ Models (DNA)
│  ├─ UserProfile (identidade)
│  ├─ FinancialAccount (órgãos)
│  ├─ Transaction (fluxos energéticos)
│  ├─ Category (taxonomia)
│  ├─ Budget (homeostase)
│  └─ AIInsight (sinapses inteligentes)
├─ Services (metabolismo)
│  ├─ LocalStorageService
│  ├─ AuthServiceLocal
│  └─ Firebase (quando configurado)
└─ UI (percepção)
   ├─ Autenticação
   ├─ Dashboard
   └─ Visualizações
```

### 🎯 **Funcionalidades Implementadas**

#### ✅ **V1.0 - Sistema Base (Atual)**
- [x] Autenticação local segura
- [x] Gerenciamento de usuários
- [x] Persistência offline (Hive)
- [x] Dashboard funcional
- [x] Arquitetura de dados completa
- [x] Modelos nexialistas (6 entidades)

#### ⏳ **Roadmap Evolutivo**

**V1.1 - Dados Reais**
- [ ] Adicionar contas financeiras
- [ ] Criar transações manuais
- [ ] Visualizar saldos e fluxos
- [ ] Orçamentos básicos

**V1.2 - Inteligência**
- [ ] Classificação ML de transações
- [ ] Detecção de padrões
- [ ] Insights automáticos
- [ ] Previsões financeiras

**V1.3 - Import**
- [ ] Upload de extratos (CSV/OFX)
- [ ] Parser inteligente
- [ ] Deduplicação automática
- [ ] Normalização de dados

**V2.0 - Cloud Sync**
- [ ] Configuração Firebase
- [ ] Sincronização automática
- [ ] Backup em nuvem
- [ ] Multi-dispositivo

---

## 🚀 Quick Start

### **Pré-requisitos**
- Flutter 3.35.4+
- Dart 3.9.2+
- Android SDK (para build Android)

### **Instalação**

```bash
# Clone o repositório
git clone https://github.com/alexandreyuan/Copiloto-Financeiro-Nexialista.git
cd Copiloto-Financeiro-Nexialista

# Instalar dependências
flutter pub get

# Executar em modo debug
flutter run

# Ou build para web
flutter build web --release --no-tree-shake-icons
```

### **Modo Demo**
Ao abrir o app, clique em **"Experimentar como Demo"** para acesso imediato com usuário pré-configurado.

---

## 🧬 Arquitetura Técnica

### **Stack**
```yaml
Frontend:
  - Flutter 3.35.4
  - Material Design 3
  - Provider (state management)

Persistência:
  - Hive 2.2.3 (local database)
  - SharedPreferences (session)

Backend Ready:
  - Firebase Core 3.6.0
  - Cloud Firestore 5.4.3
  - Firebase Auth 5.3.1

Visualização:
  - FL Chart 0.69.0
  - Google Fonts 6.3.2

Utilitários:
  - UUID 4.5.1
  - Crypto 3.0.6
  - Intl 0.19.0
```

### **Estrutura de Diretórios**
```
lib/
├── models/              # DNA digital (entidades)
│   ├── user_profile.dart
│   ├── financial_account.dart
│   ├── transaction.dart
│   ├── category.dart
│   ├── budget.dart
│   ├── ai_insight.dart
│   └── hive_adapters.dart
├── services/            # Metabolismo (lógica)
│   ├── local_storage_service.dart
│   ├── auth_service_local.dart
│   └── auth_service.dart (Firebase)
├── providers/           # Estado reativo
│   └── auth_provider.dart
├── screens/             # Interface
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       └── dashboard_screen.dart
└── main.dart            # Inicialização
```

---

## 🔐 Segurança

### **Autenticação Local**
- 🔒 Senhas hasheadas (SHA-256)
- 🔒 Tokens de sessão únicos
- 🔒 Validações rigorosas
- 🔒 SharedPreferences seguro

### **Dados**
- 🔒 Persistência local criptografada
- 🔒 Isolamento por usuário
- 🔒 Limpeza completa no logout
- 🔒 LGPD/GDPR ready

---

## 🧪 Testes

```bash
# Testes unitários
flutter test

# Análise de código
flutter analyze

# Formato de código
dart format .
```

---

## 📊 Modelos de Dados

### **UserProfile**
```dart
- id, email, name
- timezone, baseCurrency
- riskProfile, financialGoals
- createdAt, lastActive
```

### **Transaction**
```dart
- Fluxos de energia econômica
- Classificação ML
- Multi-moeda
- Deduplicação automática
```

### **Budget**
```dart
- Homeostase financeira
- Tipos: fixed/flexible/adaptive
- Alertas inteligentes
- Projeções adaptativas
```

### **AIInsight**
```dart
- 7 tipos de insights
- Confiança probabilística
- Ações sugeridas
- Ciclo de vida temporal
```

---

## 🎨 Design System

### **Paleta Nexialista**
```dart
Primary:   #00C853 (Verde energia vital)
Secondary: #2196F3 (Azul fluxo)
Tertiary:  #FF6D00 (Laranja alerta)
Error:     #D32F2F (Vermelho crítico)
```

### **Princípios**
- Material Design 3
- Componentes orgânicos
- Feedback imediato
- Acessibilidade

---

## 🔥 Firebase (Opcional)

Para ativar sincronização em nuvem:

1. Criar projeto no [Firebase Console](https://console.firebase.google.com/)
2. Baixar `google-services.json` (Android)
3. Configurar `firebase_options.dart`
4. Ativar Authentication e Firestore
5. Descomentar código Firebase em `main.dart`

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Este é um projeto nexialista - pensamento transmitemático é encorajado.

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Yuan** - Criador de Conteúdo, Idealista, Perfeccionista, Empreendedor Digital

- GitHub: [@alexandreyuan](https://github.com/alexandreyuan)

---

## 🙏 Agradecimentos

- Inspiração em sistemas biológicos adaptativos
- Princípios de física de sistemas
- Psicologia comportamental aplicada
- Economia de recursos otimizada

---

## 🧠 Filosofia Nexialista

> "Não é apenas software - é um organismo digital que aprende, adapta e evolui junto com você."

**Princípios Core:**
- 🌊 **Fluxos Energéticos** (Física aplicada)
- 🌱 **Homeostase Adaptativa** (Biologia sistêmica)
- 💡 **Nudges Empáticos** (Psicologia comportamental)

---

**🧬 Construído com Pensamento Nexialista** ✨
