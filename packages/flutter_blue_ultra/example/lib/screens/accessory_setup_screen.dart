import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';
import 'package:flutter_blue_ultra_example/gen/assets.gen.dart';

class AccessorySetupScreen extends StatefulWidget {
  const AccessorySetupScreen({super.key});

  @override
  State<AccessorySetupScreen> createState() => _AccessorySetupScreenState();
}

class _AccessorySetupScreenState extends State<AccessorySetupScreen> {
  // Keep one session per screen instance so native delegate callbacks have a
  // stable Dart owner until the route is popped.
  final _accessorySetup = FlutterAccessorySetup();
  StreamSubscription<ASAccessoryEvent>? _eventsSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  bool _isActivated = false;
  bool _isPickerLoading = false;
  String _deviceStatus = 'Disconnected';
  ASAccessory? _pendingAccessory;
  List<ASAccessory> _accessories = [];
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    // Subscribe before activation so the initial Activated event is not missed.
    _eventsSubscription = _accessorySetup.eventStream.listen(_onEvent);
    _accessorySetup.activate();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _accessorySetup.dispose();
    super.dispose();
  }

  void _onEvent(ASAccessoryEvent event) {
    _log('event: ${event.dartDescription}');
    setState(() {
      _accessories = _accessorySetup.accessories;
      // AccessorySetupKit reports picker progress and accessory changes through
      // the same delegate stream, so keep all session state transitions here.
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
    // The picked accessory usually arrives as AccessoryChanged/AccessoryAdded
    // before PickerDidDismiss, then PickerDidDismiss is the cue to connect.
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

  // AccessorySetupKit requires no active CBCentralManager scan when showing
  // the picker. Stop scanning first, then present.
  Future<void> _showPicker() async {
    await FlutterBlueUltra.stopScan();
    setState(() => _isPickerLoading = true);
    try {
      // NSAccessorySetupBluetoothServices UUID in Info.plist must match the
      // serviceID passed here for the picker to filter correctly.
      await _accessorySetup.showPickerForDevice(
        'My BLE Device',
        Assets.images.ble.path,
        // Replace this with the BLE service UUID advertised by your accessory.
        // It must match NSAccessorySetupBluetoothServices in iOS Info.plist.
        '58C39754-835C-4AAD-9496-5502A4250229',
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
      await _accessorySetup.removeAccessory(accessory);
      // Refresh from the native session after the removal callback completes.
      setState(() => _accessories = _accessorySetup.accessories);
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
    // If Bluetooth is still turning on, wait once and connect as soon as the
    // adapter becomes available.
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
      if (mounted) setState(() => _deviceStatus = 'Connected ($id)');
      _log('connected to $id');
    } catch (e) {
      _log('connect error: $e');
    }
  }

  void _log(String message) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    if (mounted) {
      setState(() => _eventLog.insert(0, '[$time] $message'));
    } else {
      _eventLog.insert(0, '[$time] $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessory Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: 'Print native logs',
            onPressed: _accessorySetup.printNativeSessionLogs,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: 'Device',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.bluetooth_connected,
                      color: _deviceStatus.startsWith('Connected')
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    title: Text(_deviceStatus),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Paired Accessories (${_accessories.length})',
                  child: _accessories.isEmpty
                      ? _buildEmptyState('No accessories paired yet')
                      : Column(
                          children:
                              _accessories.map(_buildAccessoryTile).toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Event Log',
                  trailing: _eventLog.isNotEmpty
                      ? TextButton(
                          onPressed: () => setState(() => _eventLog.clear()),
                          child: const Text('Clear'),
                        )
                      : null,
                  child: _eventLog.isEmpty
                      ? _buildEmptyState('No events yet')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _eventLog
                              .map(
                                (e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return ColoredBox(
      color: _isActivated ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              _isActivated ? Icons.check_circle_outline : Icons.hourglass_top,
              size: 16,
              color:
                  _isActivated ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              _isActivated ? 'Session activated' : 'Activating session…',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _isActivated
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  Widget _buildAccessoryTile(ASAccessory accessory) {
    final id = accessory.dartBluetoothIdentifier ?? 'No Bluetooth ID';
    final authorized =
        accessory.state == ASAccessoryState.ASAccessoryStateAuthorized;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.bluetooth,
            color: authorized ? Colors.green : Colors.orange),
        title: Text(id,
            style: const TextStyle(fontSize: 13, fontFamily: 'Courier')),
        subtitle: Text(
          authorized ? 'Authorized' : 'Awaiting authorization',
          style: TextStyle(
            fontSize: 12,
            color: authorized ? Colors.green.shade700 : Colors.orange.shade700,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Remove',
          onPressed: () => _removeAccessory(accessory),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton(
          onPressed: (_isActivated && !_isPickerLoading) ? _showPicker : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
          child: _isPickerLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('SHOW PICKER'),
        ),
      ),
    );
  }
}
