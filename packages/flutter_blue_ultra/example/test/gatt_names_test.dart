import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_example/models/gatt_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('well-known GATT names resolve from Guid.str', () {
    for (final u in ['1800', '180A', '180F', '180D']) {
      final str = Guid(u).str;
      expect(kGattServiceNames[shortUuid(str)], isNotNull, reason: '$u -> $str');
    }
    for (final u in ['2A37', '2A19', '2A00']) {
      final str = Guid(u).str;
      expect(kGattCharacteristicNames[shortUuid(str)], isNotNull, reason: '$u -> $str');
    }
    expect(shortUuid(Guid('0000180D-0000-1000-8000-00805F9B34FB').str128), '180D');
    expect(shortUuid('D4F2A81C-6E3B-4A57-9C08-2B71E5A6D390'), isNull);
  });
}
