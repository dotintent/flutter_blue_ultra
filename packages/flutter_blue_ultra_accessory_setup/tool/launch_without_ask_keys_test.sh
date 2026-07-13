#!/usr/bin/env bash
#
# Regression test for the lazy-ASAccessorySession fix (see CHANGELOG 0.1.1).
#
# An app that depends on flutter_blue_ultra_accessory_setup — so the plugin gets
# registered — but that never calls into AccessorySetupKit and ships no ASK
# Info.plist keys must launch WITHOUT crashing. Before the fix, the plugin
# created ASAccessorySession eagerly at registration, which fatal-errors at
# launch when NSAccessorySetupKitSupports is absent, taking down every app that
# merely embedded the plugin.
#
# The test generates a throwaway host app, embeds this plugin by path, builds it
# for the iOS Simulator (no code signing — CI-safe), launches it, and asserts
# the process is still alive a few seconds later. It contains nothing
# machine-specific and is safe to run in a public CI.
#
# Requirements: macOS, Xcode, Flutter on PATH, and an iOS 18+ Simulator
# (a booted one is reused; otherwise the first available device is booted).
#
# Usage: tool/launch_without_ask_keys_test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_NAME="ask_launch_probe"
ORG="com.example"
BUNDLE_ID="com.example.askLaunchProbe"
WORK_DIR="$(mktemp -d)"
APP_DIR="$WORK_DIR/$APP_NAME"

log() { printf '\n[ask-launch-test] %s\n' "$*"; }

cleanup() {
  xcrun simctl uninstall booted "$BUNDLE_ID" >/dev/null 2>&1 || true
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# 1. Ensure a booted simulator (reuse one if already booted).
if ! xcrun simctl list devices booted | grep -q "Booted"; then
  UDID="$(xcrun simctl list devices available | grep -i "iPhone" | grep -oE '[0-9A-F]{8}-[0-9A-F-]{27}' | head -1)"
  [ -n "$UDID" ] || { echo "No available iPhone Simulator to boot."; exit 1; }
  log "Booting simulator $UDID"
  xcrun simctl boot "$UDID"
  open -a Simulator >/dev/null 2>&1 || true
fi

# 2. Generate a throwaway host app. `flutter create` adds no ASK plist keys.
log "Generating throwaway host app"
flutter create --platforms=ios --org "$ORG" --project-name "$APP_NAME" "$APP_DIR" >/dev/null

# The plugin targets iOS 18; raise the generated app's deployment target to match.
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*;/IPHONEOS_DEPLOYMENT_TARGET = 18.0;/g' \
  "$APP_DIR/ios/Runner.xcodeproj/project.pbxproj"

# 3. Depend on the plugin by path so it registers — the default counter app
#    never calls into AccessorySetupKit, which is exactly the scenario we guard.
log "Embedding flutter_blue_ultra_accessory_setup by path"
( cd "$APP_DIR" && flutter pub add "flutter_blue_ultra_accessory_setup:{\"path\":\"$PACKAGE_DIR\"}" >/dev/null )

# Guard: the host app must NOT declare ASK keys — that is the whole point.
if grep -q "NSAccessorySetupKitSupports\|NSAccessorySetupSupports" "$APP_DIR/ios/Runner/Info.plist"; then
  echo "Unexpected: the generated host app already declares ASK plist keys."; exit 1
fi

# 4. Build for the simulator (no code signing).
log "Building for the iOS Simulator"
( cd "$APP_DIR" && flutter build ios --simulator --debug >/dev/null )

# 5. Install, launch, and assert the process survived startup.
APP="$APP_DIR/build/ios/iphonesimulator/Runner.app"
log "Installing and launching"
xcrun simctl uninstall booted "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install booted "$APP"
# `|| true`: a launch that races a fast crash can itself exit non-zero; let the
# liveness check below decide PASS/FAIL rather than aborting under `set -e`.
xcrun simctl launch booted "$BUNDLE_ID" >/dev/null || true

# A registration crash disappears within a second; settle well past that, then
# poll for the process (a healthy app can be slow to register on a loaded/CI
# machine). Alive at any poll => PASS; never seen => FAIL.
sleep 8
alive=0
for _ in 1 2 3 4 5; do
  if xcrun simctl spawn booted launchctl list 2>/dev/null | grep -q "$BUNDLE_ID"; then
    alive=1
    break
  fi
  sleep 2
done
if [ "$alive" -eq 1 ]; then
  log "PASS — plugin embedded, no ASK keys, app launched and stayed alive."
  exit 0
else
  log "FAIL — app crashed at launch; ASAccessorySession is likely created eagerly at registration."
  exit 1
fi
