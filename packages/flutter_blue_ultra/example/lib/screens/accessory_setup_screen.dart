import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';
import 'package:flutter_blue_ultra_example/gen/assets.gen.dart';

import '../theme/app_theme.dart';
import '../utils/ble_manager.dart';
import '../widgets/atoms.dart';

class AccessorySetupScreen extends StatefulWidget {
  const AccessorySetupScreen({super.key});

  @override
  State<AccessorySetupScreen> createState() => _AccessorySetupScreenState();
}

class _AccessorySetupScreenState extends State<AccessorySetupScreen> {
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
    await FlutterBlueUltra.stopScan();
    await tearDownBleManager();
    setState(() => _isPickerLoading = true);
    try {
      await _accessorySetup?.showPickerForDevice(
        'My BLE Device',
        Assets.images.ble.path,
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
      await _accessorySetup?.removeAccessory(accessory);
      setState(() => _accessories = _accessorySetup?.accessories ?? []);
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
    if (mounted) {
      setState(() => _eventLog.insert(0, '[$time] $message'));
    } else {
      _eventLog.insert(0, '[$time] $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);

    return Scaffold(
      backgroundColor: it.bg,
      body: Column(
        children: [
          const IntentAppBar(brand: true),
          _buildStatusBanner(it),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeroSection(it),
                SectionHeader(
                  label: 'Paired Accessories',
                  count: _accessories.length,
                  trailing: _accessories.isNotEmpty
                      ? IntentChip(
                          label: '${_accessories.length}',
                          kind: ChipKind.accent,
                          small: true,
                        )
                      : null,
                ),
                if (_accessories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Text(
                      'No accessories paired yet',
                      style: IntentTextStyles.sans(13, it.textDim),
                    ),
                  )
                else
                  ..._accessories.map((a) => _buildAccessoryTile(it, a)),
                SectionHeader(
                  label: 'Event Log',
                  count: _eventLog.length,
                  trailing: _eventLog.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() => _eventLog.clear()),
                          child: Text('CLEAR',
                              style:
                                  IntentTextStyles.monoLabel(10, it.accent)),
                        )
                      : null,
                ),
                if (_eventLog.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Text(
                      'No events yet',
                      style: IntentTextStyles.sans(13, it.textDim),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _eventLog
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                e,
                                style:
                                    IntentTextStyles.mono(11, it.textDim),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildActionBar(it),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(IntentTheme it) {
    final color = _initError != null
        ? it.accent
        : _isActivated
            ? it.success
            : it.warn;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: it.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.5), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _initError != null
                  ? 'SETUP KIT UNAVAILABLE'
                  : _isActivated
                      ? 'SESSION ACTIVATED'
                      : 'ACTIVATING SESSION',
              style: IntentTextStyles.monoLabel(10.5, color),
            ),
          ),
          if (_connectedId != null) ...[
            const SizedBox(width: 10),
            Text('·', style: IntentTextStyles.mono(10.5, it.textFaint)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _connectedId!,
                style: IntentTextStyles.mono(10.5, it.textDim),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroSection(IntentTheme it) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -60,
            child: Opacity(
              opacity: 0.5,
              child: ConcentricDecor(
                size: 240,
                strokeOpacity: it.isDark ? 0.18 : 0.22,
                dot: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConnectionDot(
                  state: _connectedId != null
                      ? ConnectionDotState.connected
                      : ConnectionDotState.disconnected,
                ),
                const SizedBox(height: 12),
                Text(
                  '· ACCESSORY SETUP KIT',
                  style: IntentTextStyles.monoLabel(11, it.textFaint),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: IntentTextStyles.serifDisplay(
                        40, it.textPrimary,
                        letterSpacing: -1.5),
                    children: [
                      const TextSpan(text: 'Accessory '),
                      TextSpan(
                        text: 'setup.',
                        style: TextStyle(
                            color: it.accent, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pair accessories via AccessorySetupKit',
                  style: IntentTextStyles.sans(13, it.textDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryTile(IntentTheme it, ASAccessory accessory) {
    final id = accessory.dartBluetoothIdentifier ?? 'No Bluetooth ID';
    final authorized =
        accessory.state == ASAccessoryState.ASAccessoryStateAuthorized;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: it.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: authorized ? it.accentSoft : it.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: it.border),
            ),
            child: Icon(
              Icons.bluetooth,
              size: 20,
              color: authorized ? it.accent : it.textDim,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: IntentTextStyles.mono(11, it.textPrimary)),
                const SizedBox(height: 3),
                Text(
                  authorized ? 'Authorized' : 'Awaiting authorization',
                  style: IntentTextStyles.sans(
                    12.5,
                    authorized ? it.success : it.warn,
                  ),
                ),
              ],
            ),
          ),
          IntentIconBtn(
            onTap: () => _removeAccessory(accessory),
            child: Icon(Icons.close, size: 16, color: it.textDim),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(IntentTheme it) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: it.border)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: IntentButton(
          label: _isPickerLoading ? 'Opening picker…' : 'Show picker',
          icon: Icons.add_circle_outline,
          onTap: (_isActivated && !_isPickerLoading && _initError == null)
              ? _showPicker
              : null,
        ),
      ),
    );
  }
}
