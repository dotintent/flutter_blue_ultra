import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

void main() {
  group('ScanResult', () {
    test('equality is based on device identity', () {
      final a = ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF')),
        advertisementData: AdvertisementData(
          advName: 'Device A',
          txPowerLevel: null,
          appearance: null,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: -60,
        timeStamp: DateTime.now(),
      );

      final b = ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF')),
        advertisementData: AdvertisementData(
          advName: 'Device B',
          txPowerLevel: null,
          appearance: null,
          connectable: false,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: -80,
        timeStamp: DateTime.now(),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different devices are not equal', () {
      final a = ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF')),
        advertisementData: AdvertisementData(
          advName: '',
          txPowerLevel: null,
          appearance: null,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: -60,
        timeStamp: DateTime.now(),
      );

      final b = ScanResult(
        device: BluetoothDevice(remoteId: const DeviceIdentifier('11:22:33:44:55:66')),
        advertisementData: AdvertisementData(
          advName: '',
          txPowerLevel: null,
          appearance: null,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: -60,
        timeStamp: DateTime.now(),
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('AdvertisementData', () {
    test('localName returns advName', () {
      final ad = AdvertisementData(
        advName: 'TestDevice',
        txPowerLevel: null,
        appearance: null,
        connectable: true,
        manufacturerData: {},
        serviceData: {},
        serviceUuids: [],
      );
      expect(ad.localName, equals('TestDevice')); // ignore: deprecated_member_use_from_same_package
    });

    test('msd encodes manufacturer data as raw bytes', () {
      final ad = AdvertisementData(
        advName: '',
        txPowerLevel: null,
        appearance: null,
        connectable: true,
        manufacturerData: {0x004C: [0x01, 0x02]},
        serviceData: {},
        serviceUuids: [],
      );
      expect(ad.msd, hasLength(1));
      expect(ad.msd.first, equals([0x4C, 0x00, 0x01, 0x02]));
    });
  });

  group('FbuError', () {
    test('stores errorCode and errorString', () {
      final err = FbuError(4, 'connection failed');
      expect(err.errorCode, equals(4));
      expect(err.errorString, equals('connection failed'));
    });
  });

  group('FlutterBlueUltraException', () {
    test('toString includes platform, function, code, description', () {
      final ex = FlutterBlueUltraException(ErrorPlatform.fbu, 'connect', 133, 'gatt error');
      expect(ex.toString(), contains('FlutterBlueUltraException'));
      expect(ex.toString(), contains('connect'));
      expect(ex.toString(), contains('133'));
      expect(ex.toString(), contains('gatt error'));
    });

    test('platform name is fbu not fbp', () {
      final ex = FlutterBlueUltraException(ErrorPlatform.fbu, 'test', null, null);
      expect(ex.toString(), contains('fbu'));
      expect(ex.toString(), isNot(contains('fbp')));
    });
  });

  group('ErrorPlatform', () {
    test('fbu is a valid value', () {
      expect(ErrorPlatform.values, contains(ErrorPlatform.fbu));
    });

    test('deprecated fbp value still exists for compat', () {
      expect(ErrorPlatform.values, contains(ErrorPlatform.fbp)); // ignore: deprecated_member_use_from_same_package
    });
  });

  group('Compat typedefs', () {
    test('FlutterBluePlusException is FlutterBlueUltraException', () {
      final ex = FlutterBluePlusException(ErrorPlatform.fbu, 'test', null, null); // ignore: deprecated_member_use_from_same_package
      expect(ex, isA<FlutterBlueUltraException>());
    });

    test('FbpErrorCode is FbuErrorCode', () {
      expect(FbpErrorCode.timeout, equals(FbuErrorCode.timeout)); // ignore: deprecated_member_use_from_same_package
    });

    test('FbpError is FbuError', () {
      final err = FbpError(1, 'test'); // ignore: deprecated_member_use_from_same_package
      expect(err, isA<FbuError>());
    });
  });

  group('MsdFilter', () {
    test('empty mask is valid', () {
      final filter = MsdFilter(0x004C);
      expect(filter.manufacturerId, equals(0x004C));
      expect(filter.mask, isEmpty);
    });
  });

  group('ServiceDataFilter', () {
    test('stores service guid', () {
      final guid = Guid('0000180D-0000-1000-8000-00805F9B34FB');
      final filter = ServiceDataFilter(guid);
      expect(filter.service, equals(guid));
    });
  });
}
