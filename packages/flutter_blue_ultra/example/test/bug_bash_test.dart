import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_blue_ultra_example/cubits/scan_cubit.dart';
import 'package:flutter_blue_ultra_example/models/ble_error_text.dart';
import 'package:flutter_blue_ultra_example/widgets/app_snack_bar.dart';
import 'package:flutter_blue_ultra_example/widgets/scan_status_card.dart';
import 'package:flutter_blue_ultra_example/widgets/value_field.dart';

FlutterBlueUltraException _android(int code, [String? description]) =>
    FlutterBlueUltraException(
      ErrorPlatform.android,
      'connect',
      code,
      description,
    );

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DsTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('connect error text', () {
    test('the flaky Android connect codes are worth retrying', () {
      expect(isRetryableBleError(_android(133)), isTrue);
      expect(isRetryableBleError(_android(147)), isTrue);
      expect(isRetryableBleError(_android(62)), isTrue);
    });

    test('a rejected request is not retried', () {
      expect(isRetryableBleError(_android(3)), isFalse);
      expect(isRetryableBleError(Exception('nope')), isFalse);
    });

    test('known codes read as a sentence, not as a stack of identifiers', () {
      expect(
        describeBleError(_android(147, 'GATT_CONNECTION_TIMEOUT')),
        'The device stopped responding during connect.',
      );
      expect(describeBleError(_android(133)), contains('133'));
    });

    test('an unmapped code falls back to a humanised description', () {
      expect(
        describeBleError(_android(999, 'GATT_WRITE_NOT_PERMITTED')),
        'Gatt write not permitted',
      );
    });
  });

  group('scan progress', () {
    test('sweeps across the scan window while scanning', () {
      const state = ScanState(scanning: true, hasScanned: true, elapsed: 6);
      expect(state.progress, closeTo(0.5, 0.001));
    });

    test('lands full when the scan ends instead of freezing part-way', () {
      const state = ScanState(scanning: false, hasScanned: true, elapsed: 7);
      expect(state.progress, 1.0);
    });

    test('is absent before the first scan', () {
      expect(const ScanState().progress, isNull);
    });

    test('never overshoots when the scan runs long', () {
      const state = ScanState(scanning: true, hasScanned: true, elapsed: 30);
      expect(state.progress, 1.0);
    });
  });

  testWidgets('the scan control is inert while a command is in flight',
      (tester) async {
    var taps = 0;
    await _pump(
      tester,
      ScanStatusCard(
        phase: ScanStatusPhase.scanning,
        deviceCount: 0,
        busy: true,
        onPrimaryAction: () => taps++,
      ),
    );

    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('a quick-fill chip clears the 44 px touch target',
      (tester) async {
    await _pump(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 120,
          child: QuickFillChip(label: 'FF', onTap: () {}),
        ),
      ),
    );

    expect(tester.getSize(find.byType(QuickFillChip)).height,
        greaterThanOrEqualTo(44));
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('the same message does not stack up', (tester) async {
    await _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showAppMessage(
            context,
            const AppMessage.error('Write failed. Gatt write not permitted'),
          ),
          child: const Text('go'),
        ),
      ),
    );

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('go'));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 750));

    expect(
      find.text('Write failed. Gatt write not permitted'),
      findsOneWidget,
    );

    // Nothing is queued behind it: once the first one times out the screen is
    // clear, rather than replaying the other three taps.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Write failed. Gatt write not permitted'), findsNothing);
  });
}
