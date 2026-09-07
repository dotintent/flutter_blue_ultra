import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_blue_ultra_accessory_setup_example/widgets/accessory_row.dart';
import 'package:flutter_blue_ultra_accessory_setup_example/widgets/event_console.dart';
import 'package:flutter_blue_ultra_accessory_setup_example/widgets/session_status_card.dart';
import 'package:flutter_blue_ultra_accessory_setup_example/widgets/setup_nav.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DsTheme.dark(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('session card renders in every phase', (tester) async {
    for (final phase in SessionPhase.values) {
      await _pump(
        tester,
        SessionStatusCard(phase: phase, accessoryCount: 1),
      );
      expect(find.byType(DsStatusRing), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
    }
  });

  testWidgets('accessory row renders in every authorization state',
      (tester) async {
    for (final state in AccessoryState.values) {
      var removed = false;
      await _pump(
        tester,
        AccessoryRow(
          accessory: Accessory(
            bluetoothIdentifier: '58C39754-835C-4AAD-9496-5502A4250229',
            displayName: 'My BLE Device',
            state: state,
          ),
          onRemove: () => removed = true,
        ),
      );

      expect(find.text('My BLE Device'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    }
  });

  testWidgets('accessory row falls back to the identifier', (tester) async {
    await _pump(
      tester,
      AccessoryRow(
        accessory: Accessory(
          bluetoothIdentifier: 'ABCD-1234',
          displayName: '',
          state: AccessoryState.authorized,
        ),
        onRemove: () {},
      ),
    );

    expect(find.text('ABCD-1234'), findsOneWidget);
  });

  testWidgets('event console splits timestamps out of log lines',
      (tester) async {
    await _pump(
      tester,
      const EventConsole(
        entries: [
          '[12:04:08] connected to 58C39754-835C',
          '[12:04:07] event: accessoryAdded',
          'line without a timestamp',
        ],
      ),
    );

    expect(find.text('12:04:08'), findsOneWidget);
    expect(find.text('connected to 58C39754-835C'), findsOneWidget);
    expect(find.text('line without a timestamp'), findsOneWidget);
  });

  testWidgets('nav renders title, subtitle and trailing action',
      (tester) async {
    await _pump(
      tester,
      SetupNav(
        title: 'Accessory SetupKit',
        subtitle: 'iOS pairing picker',
        trailing: SetupNavButton(
          icon: Icons.bug_report_outlined,
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Accessory SetupKit'), findsOneWidget);
    expect(find.text('iOS pairing picker'), findsOneWidget);
    expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
  });

  testWidgets('setup empty states render', (tester) async {
    await _pump(
      tester,
      Column(
        children: [
          DsEmptyState(
            icon: Icons.bluetooth_disabled,
            title: 'No accessories paired yet.',
            titleStyle: DsTextStyles.monoMd(color: DsColors.dark.textDim),
          ),
          DsEmptyState(
            icon: Icons.subject,
            title: 'No events yet.',
            titleStyle: DsTextStyles.monoMd(color: DsColors.dark.textDim),
          ),
          const DsEmptyState(
            icon: Icons.block,
            title: 'AccessorySetupKit is only available on iOS',
            description: 'This screen uses Apple’s AccessorySetupKit, which '
                'has no Android/web equivalent.',
          ),
        ],
      ),
    );

    expect(find.text('No events yet.'), findsOneWidget);
    expect(find.byIcon(Icons.block), findsOneWidget);
  });
}
