# flutter_blue_ultra — Backlog

Initial backlog of fixes and improvements identified ahead of the `2.1.0` pub.dev release. Items are grouped by theme and tagged with a rough priority (P0 highest). Where an item has a clear scope, it's worded as something a contributor could pick up directly.

> **Visibility decision pending.** Once the team decides whether the public GitHub repo's Issues tab is the system of record, the items below should be migrated there 1:1 (P0/P1 first), with this file either deleted or kept as a high-level roadmap snapshot.

---

## Release & publishing

- **[P0] Verify pana score after first publish.** Several pana failures in the pre-publish run were caused by sub-packages not yet existing on pub.dev (cascading `pub get` failure). Re-run pana on `flutter_blue_ultra` after all 6 packages are live and confirm score climbs above the badge threshold.
- **[P0] Confirm `documentation:` URLs resolve.** Each pubspec points to `https://pub.dev/documentation/<pkg>/latest/`. Verify each is reachable post-publish; remove the field if pub.dev's default already covers it.
- **[P1] Federated publish script.** Add `scripts/publish.sh` that publishes the 6 packages in dependency order (`platform_interface` → `android`/`darwin`/`linux`/`web` → `flutter_blue_ultra`), with each step waiting for pub.dev index propagation and temporarily moving `pubspec_overrides.yaml` aside to silence the publish-time hint.
- **[P2] Migrate to Dart workspaces.** Replace `pubspec_overrides.yaml` files with a top-level workspace `pubspec.yaml` listing all packages. Removes the publish hint permanently and is the modern federated-plugin pattern.

## Static analysis & docs (pana points)

- **[P1] Dartdoc coverage ≥20% on public API.** Pana awarded 0/10 for documentation due to dep-resolution failure, but once that's fixed the next gate is dartdoc coverage. Audit `lib/flutter_blue_ultra.dart` and the platform interface for undocumented public symbols.
- **[P2] Tighten dependency lower bounds.** Run `dart pub upgrade --tighten` per [dart.dev/go/downgrade-testing](https://dart.dev/go/downgrade-testing) so `flutter pub downgrade` resolves cleanly. Currently failing the lower-bound check.
- **[P2] Resolve outdated transitive deps.** `matcher`, `meta`, `test_api`, `vector_math` have newer versions blocked by constraints — investigate which constraint is the choke point.

## API surface & deprecations

- **[P1] Retire `flutter_blue_plus` compat layer on a defined cadence.** Deprecated typedefs `FlutterBluePlusException`, `FbpErrorCode`, `FbpError`, and `ErrorPlatform.fbp` exist for migration. Pick a target release (3.0.0?) to remove them and document the deadline in CHANGELOG.
- **[P2] Audit remaining `FBP` / `flutter_blue_plus` string references** in logs, comments, and docs. The [TEST_PUB_DEV.md](TEST_PUB_DEV.md) checklist already calls this out; track any stragglers here.

## Federation & versioning

- **[P1] Version-alignment policy.** All 6 packages are pinned to `2.1.0` for this release. Decide whether future patches bump all packages in lockstep or independently, and document the rule so contributors don't have to guess.
- **[P2] Reconsider exact pin for `flutter_blue_ultra_platform_interface`.** Currently `^2.1.0`. If platform-interface changes are always breaking, consider `>=2.1.0 <2.2.0`-style constraints to enforce coordinated updates.

## Platform-specific

- **[P2] Darwin: review archive contents.** The `flutter_blue_ultra_darwin` package archive may pick up Xcode build artifacts (`Pods/`, `*.xcworkspace`); add a `.pubignore` if so. Confirmed during dry-run.
- **[P2] Linux: bluez constraint review.** `bluez: '>=0.7.8 <0.9.0'` — confirm this range is still current and that the package builds against the latest 0.8.x.
- **[P2] Web: SDK floor justification.** Web package requires `sdk: ^3.3.0` / `flutter: '>=3.19.0'` (higher than other packages). Document why in [docs/versioning.md](docs/versioning.md).

## Example app & docs

- **[P2] Example app smoke matrix.** Document which platforms the example has been manually verified on for the 2.1.0 release (it's currently behind a flag for Android).
- **[P2] Accessory-setup TODO carryover.** [TODO.md](packages/flutter_blue_ultra_accessory_setup/TODO.md) lists open items (Pigeon migration, WiFi setup, migration sequence). Decide whether those belong in this backlog or stay scoped to that sub-package.

## Tooling

- **[P3] CI for publish dry-run.** Add a GH Action that runs `flutter pub publish --dry-run` per package on every PR touching `packages/**/pubspec.yaml`, catching warnings before release time.
- **[P3] Move ad-hoc release notes out of `TEST_PUB_DEV.md`.** That file blends a checklist with prose; split into a `CONTRIBUTING.md` release section + a regenerable checklist.
