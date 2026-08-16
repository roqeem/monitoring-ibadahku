import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ibadahku/models/models.dart';
import 'package:ibadahku/screens/pengaturan/pengaturan_screen.dart';
import 'package:ibadahku/state/app_state.dart';

void main() {
  testWidgets('Sheet profil menampilkan 4 opsi jenis kelamin termasuk Lainnya',
      (tester) async {
    final state = AppState()
      ..loaded = true
      ..user = UserProfile(
        id: 'x',
        displayName: 'Ahmad',
        email: '',
        gender: '',
        loginMethod: 'demo',
        createdAt: DateTime.now(),
      );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: PengaturanScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ahmad'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    final chips = find.byType(ChoiceChip);
    expect(chips, findsNWidgets(4));
    expect(
      find.widgetWithText(ChoiceChip, 'Lainnya'),
      findsOneWidget,
      reason: 'opsi Lainnya harus tampil',
    );
  });
}
