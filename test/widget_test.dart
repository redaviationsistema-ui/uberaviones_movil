import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redskyg_aeroquote/screens/shared/widgets/role_ui_components.dart';

void main() {
  testWidgets('renders premium plan comparison flow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: PlanComparisonSection()),
        ),
      ),
    );

    expect(find.text('Demo 15 dias'), findsOneWidget);
    expect(find.text('Plan Basico'), findsOneWidget);
    expect(find.text('Plan Pro'), findsOneWidget);
    expect(find.text('Empresarial'), findsOneWidget);
  });
  // DEMOSTRACION
}

