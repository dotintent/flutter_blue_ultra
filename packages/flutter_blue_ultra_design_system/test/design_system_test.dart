import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _gallery() {
  return Scaffold(
    appBar: const DsAppBar(title: 'Device', subtitle: 'AA:BB:CC', brand: false),
    body: ListView(
      children: [
        const DsBrandMark(),
        const DsSectionHeader(label: 'nearby', count: 4),
        DsCard(child: const Text('card')),
        const DsChip(label: 'READ'),
        const DsChip(label: 'NOTIFY', variant: DsChipVariant.notify),
        const DsChip(label: 'IDLE', variant: DsChipVariant.muted),
        const DsChip(label: 'LIVE', variant: DsChipVariant.accent),
        DsButton(label: 'Connect', onPressed: () {}),
        DsButton(
          label: 'Loading',
          loading: true,
          onPressed: () {},
        ),
        DsButton(
          label: 'Outlined',
          icon: Icons.link,
          variant: DsButtonVariant.outlined,
          size: DsButtonSize.small,
          onPressed: () {},
        ),
        DsButton(
          label: 'Text',
          variant: DsButtonVariant.text,
          size: DsButtonSize.medium,
          onPressed: () {},
        ),
        DsIconButton.icon(icon: Icons.close, onPressed: () {}),
        DsIconButton.icon(
          icon: Icons.add,
          variant: DsIconButtonVariant.filled,
          onPressed: () {},
        ),
        DsIconButton.icon(
          icon: Icons.more_vert,
          variant: DsIconButtonVariant.plain,
          onPressed: () {},
        ),
        const DsListRow(
          leading: DsAvatar(child: Icon(Icons.bluetooth)),
          title: Text('Lightcam'),
          subtitle: Text('21E88408'),
          trailing: DsSignalBars(level: 3),
        ),
        DsSignalBars.rssi(rssi: -47),
        const DsUuidText(uuid: '0000180d-0000-1000-8000-00805f9b34fb', short: true),
        const DsStatusIndicator(label: 'connected', color: Colors.green),
        const DsStatusIndicator(
          label: 'connecting',
          color: Colors.amber,
          pulsing: true,
        ),
        const SizedBox(height: 96, child: DsPulseBeacon(active: true)),
        const SizedBox(height: 96, child: DsPulseBeacon(active: false)),
        const DsConcentricRings(size: 120),
        const DsSunburst(size: 120),
        const DsBluetoothGlyph(),
        const DsEmptyState(title: 'Nothing here', icon: Icons.search),
      ],
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final name in <String>['dark', 'light']) {
    testWidgets('gallery renders in $name theme', (tester) async {
      final theme = name == 'dark' ? DsTheme.dark() : DsTheme.light();
      await tester.pumpWidget(MaterialApp(theme: theme, home: _gallery()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Connect'), findsOneWidget);
    });
  }

  testWidgets('theme exposes the design system extensions', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.dark(),
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        }),
      ),
    );
    expect(DsColors.of(ctx).isDark, isTrue);
    expect(DsDimensions.of(ctx).screenPadding, DsSpace.s20);
    expect(DsTypography.of(ctx).display.fontSize, DsFontSize.display);
  });

  testWidgets('token overrides flow through to components', (tester) async {
    const cyan = Color(0xFF00E5FF);
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.dark(
          colors: DsColors.dark.copyWith(accent: cyan),
          dimensions: DsDimensions.standard.copyWith(screenPadding: 4),
        ),
        home: Builder(builder: (context) {
          ctx = context;
          return Scaffold(body: DsButton(label: 'Go', onPressed: () {}));
        }),
      ),
    );
    expect(DsColors.of(ctx).accent, cyan);
    expect(DsDimensions.of(ctx).screenPadding, 4);
    expect(Theme.of(ctx).colorScheme.primary, cyan);
  });

  testWidgets('per-instance style beats the theme default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.dark(),
        home: Scaffold(
          body: DsButton(
            label: 'Go',
            style: FilledButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {},
          ),
        ),
      ),
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final resolved = button.style!.backgroundColor!.resolve(<WidgetState>{});
    expect(resolved, Colors.purple);
  });
}
