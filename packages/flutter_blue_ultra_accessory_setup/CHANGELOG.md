## 0.0.4

* Prepare package metadata for pub.dev release.
* Pin `objective_c` to `>=4.0.0 <4.1.0` — the generated FFI bindings reference
  pre-`DOBJC_` symbol names introduced in 4.1.0.
* Exclude local build and development files from published archives.
* Make the event stream a broadcast controller so multiple listeners can
  subscribe.
* Complete pending picker/rename/remove/authorization futures with a
  `StateError` on `dispose()` instead of leaking them.
* Reject overlapping `showPickerForDevice` / `showPickerForItems` calls instead
  of orphaning the previous `Completer`.
* Guard `renameAccessory`, `removeAccessory`, and `finishAuthorization` against
  concurrent invocations.
* Respect `ByteData.offsetInBytes` and `lengthInBytes` when converting to
  `NSData`.
* iOS: serialize the internal log buffer through a serial `DispatchQueue` to
  remove a data race.

## 0.0.3

* Migration to dart:ffi
* Add support for WiFi

## 0.0.2

* Minor readme updates

## 0.0.1

* Introduce basic support for AccessorySetupKit for BLE
