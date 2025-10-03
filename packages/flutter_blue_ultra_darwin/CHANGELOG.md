## 8.0.0
* Fix buffer overrun protection in filter data matching to prevent crashes
* Fix missing else-if chain in getAdapterState handler
* Simplify disconnect peripheral lookup logic
* Add macOS 14+ support for auto-reconnect option (previously iOS 17+ only)
* Fix incorrect error code in readCharacteristic handler
* Fix invalid string literal syntax in disconnect response
* Fix CCCD descriptor to use correct 2-byte uint16_t type per BLE spec
* Simplify CCCD notification/indication value logic
* Fix write-without-response data type (NSData instead of NSString)
* Fix default filter masks to use 0xFF (all bits) instead of 0x01 (LSB only)

## 4.0.1
* fix unrecognized selector sent to instance (regression from 4.0.0)

## 4.0.0
* Use bytes instead of hex for platform communication (#1130)

## 3.0.0
* Update platform interface version to 3.0.0

## 2.0.1
* Add log color

## 2.0.0
* Combine the packages previously published as flutter_blue_plus_ios and flutter_blue_plus_macos
* Add support for Swift Package Manager
* Replace void return types with bool return types
