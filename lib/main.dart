// 🧠 NEXIAL FINANCE - Ecossistema Financeiro Adaptativo
// Arquitetura Nexialista: Organismo Digital que Aprende, Adapta e Evolui

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';

// TODO: Descomentar quando Firebase estiver configurado
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧬 Inicializar Sistema de Armazenamento Local
  final storage = LocalStorageService();
  await storage.initialize();

  // TODO: Inicializar Firebase quando configurado
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const NexialFinanceApp());
}

class NexialFinanceApp extends StatelessWidget {
  const NexialFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'Nexial Finance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 🎨 Design System Nexialista - Inspirado em Organismos Vivos
          useMaterial3: true,
          
          // Paleta Biológica: Tons que representam energia e vitalidade
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00C853), // Verde energia vital
            brightness: Brightness.light,
            primary: const Color(0xFF00C853),
            secondary: const Color(0xFF2196F3), // Azul fluxo
            tertiary: const Color(0xFFFF6D00), // Laranja alerta
            error: const Color(0xFFD32F2F),
          ),

          // Tipografia Orgânica
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          // Cards com aspecto orgânico
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),

          // AppBar minimalista
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),

          // Botões orgânicos
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Input fields naturais
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: const AuthSplashScreen(),
      ),
    );
  }
}

// 🧬 Splash Screen - Verificação de Autenticação
class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Aguardar inicialização
        if (authProvider.status == AuthStatus.uninitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
              ),
            ),
          );
        }

        // Redirecionar baseado no status
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
