import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ibadahku/screens/login_screen.dart';
import 'package:ibadahku/state/app_state.dart';

void main() {
  testWidgets('Login screen menampilkan opsi masuk & mode demo', (tester) async {
    final state = AppState()..loaded = true;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('IbadahKu'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.textContaining('Coba tanpa akun'), findsOneWidget);
  });

  testWidgets('Mode demo langsung masuk tanpa onboarding', (tester) async {
    final state = AppState()..loaded = true;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    final demoBtn = find.textContaining('Coba tanpa akun');
    await tester.ensureVisible(demoBtn);
    await tester.pumpAndSettle();
    await tester.tap(demoBtn);
    await tester.pump(const Duration(seconds: 1));
    expect(state.user, isNotNull);
    expect(state.user!.loginMethod, 'demo');
  });
}
