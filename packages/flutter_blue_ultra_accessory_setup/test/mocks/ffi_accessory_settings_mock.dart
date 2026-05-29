import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';

class FFIASAccessorySettingsMock implements ASAccessorySettings {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(invocation.memberName.toString().split('"')[1]);
  }
}
