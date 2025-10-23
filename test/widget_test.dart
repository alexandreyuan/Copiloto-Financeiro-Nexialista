// 🧬 TESTES: Nexial Finance - Validação de Organismo Digital

import 'package:flutter_test/flutter_test.dart';
import 'package:nexial_finance/main.dart';

void main() {
  testWidgets('Nexial Finance app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NexialFinanceApp());

    // Verify that Nexial Finance title appears
    expect(find.text('Nexial Finance'), findsOneWidget);
    
    // Verify that Ecossistema subtitle appears
    expect(find.text('Ecossistema Financeiro Adaptativo'), findsOneWidget);
    
    // Verify CTA button exists
    expect(find.text('Começar Jornada'), findsOneWidget);
  });
}
