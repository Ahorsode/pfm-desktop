// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poultry_pms_desktop/main.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/data/sync_engine.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    final db = AppDatabase();
    final sync = SyncEngine(db);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          ChangeNotifierProvider<SyncEngine>.value(value: sync),
        ],
        child: const MyApp(isBound: false),
      ),
    );

    // Verify that the dashboard title is present.
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

