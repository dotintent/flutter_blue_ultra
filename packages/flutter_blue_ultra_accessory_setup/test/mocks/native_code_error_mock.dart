import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';

class NativeCodeErrorMock implements NativeCodeError {
  @override
  int code = 1;

  @override
  String description = "NativeCodeErrorMock";

  @override
  String domain = "Tests";

  @override
  StackTrace? get stackTrace => throw UnimplementedError();
}
