import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_blue_ultra_example/models/ble_models.dart';
import 'package:flutter_blue_ultra_example/screens/splash_screen.dart';
import 'package:flutter_blue_ultra_example/widgets/brand_header.dart';
import 'package:flutter_blue_ultra_example/widgets/connection_dot.dart';
import 'package:flutter_blue_ultra_example/widgets/device_row.dart';
import 'package:flutter_blue_ultra_example/widgets/footer_message.dart';
import 'package:flutter_blue_ultra_example/widgets/format_segments.dart';
import 'package:flutter_blue_ultra_example/widgets/notify_toggle.dart';
import 'package:flutter_blue_ultra_example/widgets/permission_row.dart';
import 'package:flutter_blue_ultra_example/widgets/scan_status_card.dart';
import 'package:flutter_blue_ultra_example/widgets/screen_nav.dart';
import 'package:flutter_blue_ultra_example/widgets/screen_tab_bar.dart';
import 'package:flutter_blue_ultra_example/widgets/skeleton_row.dart';
import 'package:flutter_blue_ultra_example/widgets/stat_card.dart';
import 'package:flutter_blue_ultra_example/widgets/value_field.dart';

ScanResult _result({String name = 'Tobiasz’s Laptop', int services = 1}) {
  return ScanResult(
    device: BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB:CC:DD')),
    advertisementData: AdvertisementData(
      advName: name,
      txPowerLevel: null,
      appearance: null,
      connectable: true,
      manufacturerData: const {},
      serviceData: const {},
      serviceUuids: [for (var i = 0; i < services; i++) Guid('180F')],
    ),
    rssi: -47,
    timeStamp: DateTime(2026, 1, 1),
  );
}

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
  testWidgets('splash lays out at phone size', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: DsTheme.dark(), home: const SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('FLUTTER BLUE ULTRA'), findsOneWidget);
    expect(find.byType(DsRadarSweep), findsOneWidget);
  });

  testWidgets('permission pieces render', (tester) async {
    await _pump(
      tester,
      const Column(
        children: [
          BrandHeader(),
          PermissionRow(
            index: 1,
            label: 'BLUETOOTH_SCAN',
            description: 'Discover advertising peripherals',
          ),
          PermissionRow(
            index: 2,
            label: 'BLUETOOTH_CONNECT',
            description: 'Connect & exchange GATT data',
            denied: true,
          ),
          FooterMessage(message: 'You can change this anytime in Settings.'),
          FooterMessage(message: 'Bluetooth is blocked.', tone: Colors.red),
        ],
      ),
    );

    expect(find.text('BLUETOOTH_SCAN'), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
  });

  testWidgets('scan pieces render in every phase', (tester) async {
    for (final phase in ScanStatusPhase.values) {
      await _pump(
        tester,
        Column(
          children: [
            ScanStatusCard(
              phase: phase,
              deviceCount: 4,
              onPrimaryAction: () {},
            ),
            DeviceRow(result: _result(), onTap: () {}),
            DeviceRow(result: _result(name: '', services: 0), onTap: () {}),
          ],
        ),
      );
      expect(find.byType(ScanStatusCard), findsOneWidget);
    }
  });

  testWidgets('device pieces render in every phase', (tester) async {
    for (final phase in ConnectionPhase.values) {
      for (final failure in DeviceFailure.values) {
        await _pump(
          tester,
          Column(
            children: [
              ScreenNav(
                actions: [NavPillButton(label: 'Disconnect', onPressed: () {})],
              ),
              ConnectionDot(phase: phase, failure: failure),
              const SkeletonRow(),
              const TelemetryRow(
                stats: [
                  StatCardData(label: 'RSSI', value: '-47', unit: 'dBm'),
                  StatCardData(label: 'MTU', value: '247', unit: 'byte'),
                  StatCardData(label: 'LATENCY', value: '12', unit: 'ms'),
                ],
              ),
            ],
          ),
        );
        expect(find.byType(TelemetryRow), findsOneWidget);
      }
    }
  });

  testWidgets('characteristic pieces render', (tester) async {
    final controller = TextEditingController(text: '01');
    addTearDown(controller.dispose);

    for (final format in ValueFormat.values) {
      await _pump(
        tester,
        Column(
          children: [
            ScreenTabBar(
              tabs: const ['Read', 'Write', 'Notify'],
              currentIndex: 1,
              onSelected: (_) {},
            ),
            FormatSegments(value: format, onChanged: (_) {}),
            ReadonlyValueField(value: format.format(const [1, 162, 255])),
            QuickFillChip(label: '0A0B0C', onTap: () {}),
            PayloadField(
              controller: controller,
              label: 'PAYLOAD (HEX)',
              onChanged: (_) {},
              footerLeft: '1 byte · max 20',
              footerRight: 'WRITE_REQUEST',
            ),
            NotifyToggle(value: true, onChanged: (_) {}),
            NotifyToggle(value: false, onChanged: (_) {}),
            const EventLogRow(value: '0x 01 A2 FF 3C', time: '12:04:31'),
          ],
        ),
      );
      expect(find.byType(FormatSegments), findsOneWidget);
    }
  });

  testWidgets('empty states render with and without an action', (tester) async {
    await _pump(
      tester,
      Column(
        children: [
          const DsEmptyState(
            icon: Icons.search_off,
            title: 'No devices found',
            description: 'Nothing advertised during the scan.',
          ),
          DsEmptyState(
            icon: Icons.link_off,
            title: 'The connection was lost',
            description: 'Retry to reconnect.',
            action: DsButton(label: 'Retry', expand: false, onPressed: () {}),
          ),
          const DsEmptyState(
            iconWidget: DsSpinner(size: DsSize.iconXXLarge),
            title: 'Establishing GATT...',
          ),
        ],
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(DsSpinner), findsOneWidget);
  });
}
