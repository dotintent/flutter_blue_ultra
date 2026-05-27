import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';

const _serviceUuid = '58C39754-835C-4AAD-9496-5502A4250229';
const _deviceName = 'My BLE Device';
const _assetPath = 'assets/images/ble.png';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterBlueUltra.setLogLevel(LogLevel.info);
  runApp(const AccessorySetupExampleApp());
}

class AccessorySetupExampleApp extends StatelessWidget {
  const AccessorySetupExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessory Setup Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3B5C),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AccessorySetupExampleScreen(),
    );
  }
}

class AccessorySetupExampleScreen extends StatefulWidget {
  const AccessorySetupExampleScreen({super.key});

  @override
  State<AccessorySetupExampleScreen> createState() =>
      _AccessorySetupExampleScreenState();
}

class _AccessorySetupExampleScreenState
    extends State<AccessorySetupExampleScreen> {
  FlutterAccessorySetup? _accessorySetup;
  StreamSubscription<ASAccessoryEvent>? _eventsSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  bool _isActivated = false;
  bool _isPickerLoading = false;
  String? _connectedId;
  String? _initError;
  ASAccessory? _pendingAccessory;
  List<ASAccessory> _accessories = [];
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    try {
      _accessorySetup = FlutterAccessorySetup();
      _eventsSubscription = _accessorySetup!.eventStream.listen(_onEvent);
      _accessorySetup!.activate();
    } catch (e) {
      _initError = '$e';
      _log('setup init error: $e');
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _accessorySetup?.dispose();
    super.dispose();
  }

  void _onEvent(ASAccessoryEvent event) {
    _log('event: ${event.dartDescription}');
    if (!mounted) return;

    setState(() {
      _accessories = _accessorySetup?.accessories ?? [];
      switch (event.eventType) {
        case ASAccessoryEventType.ASAccessoryEventTypeActivated:
          _isActivated = true;
        case ASAccessoryEventType.ASAccessoryEventTypeAccessoryAdded:
        case ASAccessoryEventType.ASAccessoryEventTypeAccessoryChanged:
          _pendingAccessory = event.accessory;
        case ASAccessoryEventType.ASAccessoryEventTypePickerDidDismiss:
          _isPickerLoading = false;
          _onPickerDismissed();
        case ASAccessoryEventType.ASAccessoryEventTypeAccessoryRemoved:
          _pendingAccessory = null;
        default:
          break;
      }
    });
  }

  void _onPickerDismissed() {
    final accessory = _pendingAccessory;
    _pendingAccessory = null;

    final id = accessory?.dartBluetoothIdentifier;
    if (accessory == null || id == null) {
      _log('picker dismissed without a picked accessory');
      return;
    }
    if (accessory.state != ASAccessoryState.ASAccessoryStateAuthorized) {
      _log('accessory not authorized, state: ${accessory.state}');
      return;
    }
    _connectWithoutScanning(id);
  }

  Future<void> _showPicker() async {
    setState(() => _isPickerLoading = true);
    try {
      await FlutterBlueUltra.stopScan();
      await _accessorySetup?.showPickerForDevice(
        _deviceName,
        _assetPath,
        _serviceUuid,
      );
    } on NativeCodeError catch (e) {
      _log('picker error (native): $e');
      if (mounted) setState(() => _isPickerLoading = false);
    } catch (e) {
      _log('picker error: $e');
      if (mounted) setState(() => _isPickerLoading = false);
    }
  }

  Future<void> _removeAccessory(ASAccessory accessory) async {
    _log('removing accessory ${accessory.dartBluetoothIdentifier}');
    try {
      await _accessorySetup?.removeAccessory(accessory);
      if (mounted) {
        setState(() => _accessories = _accessorySetup?.accessories ?? []);
      }
    } catch (e) {
      _log('remove error: $e');
    }
  }

  Future<void> _connectWithoutScanning(String id) async {
    _log('connecting to $id');
    if (await FlutterBlueUltra.isSupported == false) {
      _log('Bluetooth not supported');
      return;
    }
    if (FlutterBlueUltra.adapterStateNow == BluetoothAdapterState.on) {
      await _connectDevice(id);
      return;
    }

    await _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBlueUltra.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _adapterStateSubscription?.cancel();
        _connectDevice(id);
      }
    });
  }

  Future<void> _connectDevice(String id) async {
    final device = BluetoothDevice.fromId(id);
    try {
      await device.connect();
      if (mounted) setState(() => _connectedId = id);
      _log('connected to $id');
    } catch (e) {
      _log('connect error: $e');
    }
  }

  void _log(String message) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    if (!mounted) {
      _eventLog.insert(0, '[$time] $message');
      return;
    }
    setState(() => _eventLog.insert(0, '[$time] $message'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canOpenPicker =
        _isActivated && !_isPickerLoading && _initError == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessory SetupKit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: 'Print native logs',
            onPressed: _accessorySetup?.printNativeSessionLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusBanner(
            color: _initError != null
                ? colors.error
                : _isActivated
                    ? Colors.greenAccent
                    : Colors.amberAccent,
            status: _initError != null
                ? 'SetupKit unavailable'
                : _isActivated
                    ? 'Session activated'
                    : 'Activating session',
            connectedId: _connectedId,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Pair an accessory',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This app only exercises the AccessorySetupKit path. '
                  'The picker filters for $_serviceUuid, which must also be '
                  'listed in ios/Runner/Info.plist.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Paired accessories',
                  child: _accessories.isEmpty
                      ? const Text('No accessories paired yet.')
                      : Column(
                          children: [
                            for (final accessory in _accessories)
                              _AccessoryTile(
                                accessory: accessory,
                                onRemove: () => _removeAccessory(accessory),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Event log',
                  trailing: _eventLog.isEmpty
                      ? null
                      : TextButton(
                          onPressed: () => setState(_eventLog.clear),
                          child: const Text('Clear'),
                        ),
                  child: _eventLog.isEmpty
                      ? const Text('No events yet.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final entry in _eventLog)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  entry,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                onPressed: canOpenPicker ? _showPicker : null,
                icon: _isPickerLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                label:
                    Text(_isPickerLoading ? 'Opening picker' : 'Show picker'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.color,
    required this.status,
    this.connectedId,
  });

  final Color color;
  final String status;
  final String? connectedId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 10),
            Flexible(child: Text(status)),
            if (connectedId != null) ...[
              const SizedBox(width: 10),
              const Text('·'),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  connectedId!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AccessoryTile extends StatelessWidget {
  const _AccessoryTile({
    required this.accessory,
    required this.onRemove,
  });

  final ASAccessory accessory;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final authorized =
        accessory.state == ASAccessoryState.ASAccessoryStateAuthorized;
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.bluetooth,
        color: authorized ? Colors.greenAccent : Colors.amberAccent,
      ),
      title: Text(accessory.dartBluetoothIdentifier ?? 'No Bluetooth ID'),
      subtitle: Text(authorized ? 'Authorized' : 'Awaiting authorization'),
      trailing: IconButton(
        icon: Icon(Icons.close, color: colors.error),
        tooltip: 'Remove',
        onPressed: onRemove,
      ),
    );
  }
}
