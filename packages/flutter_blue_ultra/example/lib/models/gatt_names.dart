// Bluetooth SIG 16-bit assigned-number lookups used to render friendly names
// for well-known services and characteristics.
// See: https://www.bluetooth.com/specifications/assigned-numbers/

const Map<String, String> kGattServiceNames = {
  '1800': 'Generic Access',
  '1801': 'Generic Attribute',
  '180A': 'Device Information',
  '180F': 'Battery Service',
  '180D': 'Heart Rate',
  '181A': 'Environmental Sensing',
  '1818': 'Cycling Power',
};

const Map<String, String> kGattCharacteristicNames = {
  '2A00': 'Device Name',
  '2A01': 'Appearance',
  '2A19': 'Battery Level',
  '2A24': 'Model Number',
  '2A25': 'Serial Number',
  '2A26': 'Firmware Revision',
  '2A27': 'Hardware Revision',
  '2A29': 'Manufacturer Name',
  '2A37': 'Heart Rate Measurement',
  '2A38': 'Body Sensor Location',
  '2A39': 'HR Control Point',
  '2A6D': 'Pressure',
  '2A6E': 'Temperature',
  '2A6F': 'Humidity',
};

/// Matches the standard SIG-base 128-bit UUID prefix and captures the 16-bit
/// short alias when present (e.g. `0000180F-0000-1000-8000-00805F9B34FB` → `180F`).
final RegExp kShortUuidPattern = RegExp(r'^0000([0-9a-fA-F]{4})-');

/// Returns the uppercase 16-bit alias of [uuid] when [uuid] follows the SIG
/// base UUID, otherwise null.
String? shortUuid(String uuid) =>
    kShortUuidPattern.firstMatch(uuid)?.group(1)?.toUpperCase();
