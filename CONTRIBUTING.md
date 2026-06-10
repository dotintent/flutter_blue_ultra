# Contributing to flutter_blue_ultra

Thanks for your interest in contributing. This document covers the practical "how" — repo layout, local development, testing, and release flow. For "what to work on," see the open [issues](https://github.com/dotintent/flutter_blue_ultra/issues).

---

## Repository layout

`flutter_blue_ultra` is a [federated Flutter plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins). The repo is a monorepo of six packages plus an add-on:

```
packages/
├── flutter_blue_ultra/                       # The umbrella package users depend on.
├── flutter_blue_ultra_platform_interface/    # Shared method-channel contract.
├── flutter_blue_ultra_android/               # Android implementation.
├── flutter_blue_ultra_darwin/                # iOS + macOS implementation.
├── flutter_blue_ultra_linux/                 # Linux (BlueZ) implementation.
├── flutter_blue_ultra_web/                   # Web (Web Bluetooth) implementation.
└── flutter_blue_ultra_accessory_setup/       # Optional iOS AccessorySetupKit add-on.
```

Users only ever depend on `flutter_blue_ultra` — the platform implementations are resolved automatically.

## Local development

### Prerequisites

- **Flutter SDK** managed via [FVM](https://fvm.app/). The pinned version lives in `.fvmrc`.
- **Dart SDK** comes with Flutter.
- Platform-specific toolchains for any platform you intend to test (Xcode for iOS/macOS, Android Studio SDK for Android, etc.).

### Setup

```sh
git clone https://github.com/dotintent/flutter_blue_ultra.git
cd flutter_blue_ultra
fvm install
fvm flutter pub get
```

Each package has a `pubspec_overrides.yaml` that points sibling dependencies at the local paths. You do not need to touch these — `flutter pub get` picks them up automatically. They are stripped from published archives.

### Running the example app

```sh
cd packages/flutter_blue_ultra/example
fvm flutter run
```

### Running tests

```sh
# From the repo root, runs tests in every package.
for pkg in packages/*/; do
  (cd "$pkg" && fvm flutter test)
done
```

Or in a single package:

```sh
cd packages/flutter_blue_ultra
fvm flutter test
```

### Static analysis

```sh
fvm flutter analyze
```

The repo uses `flutter_lints`. CI runs analyze on every PR — make sure your branch is clean before opening one.

## Code style

- **Public API** — new public symbols must have dartdoc comments. We track dartdoc coverage as part of the pana score; please don't regress it.
- **Naming** — the historical `flutter_blue_plus` / `FBP` names exist only inside the compat layer. Anything new should use `flutter_blue_ultra` / `FBU` / `FlutterBlueUltra`.
- **Breaking changes** — any change to the public API of `flutter_blue_ultra_platform_interface` is a breaking change for all platform packages. Coordinate the version bumps in your PR (see Versioning below).

## Pull request flow

1. Fork the repo and create a feature branch off `main`.
2. Make your change. Keep PRs focused — one logical change per PR.
3. Add or update tests for behavior changes.
4. Update the relevant package's `CHANGELOG.md`. Add a bullet under the heading for the next planned version (use the package's existing format — `* **[Improve]** ...`, `* **[Fix]** ...`, `* **[Breaking Change]** ...`). If no next-version heading exists yet, add one above the most recent release with the version you expect to ship under.
5. Run `fvm flutter analyze` and the test suite locally.
6. Open a PR. The `CODEOWNERS` file will auto-request reviewers.

For larger changes (new public API, native platform additions, behavior changes that affect existing users), please open an issue first to discuss the approach.

## Versioning

All six packages move in lockstep — they share a single version number (currently `2.1.0`). This keeps reasoning about compatibility simple at the cost of occasional "no-op" version bumps.

- **Patch bump** (`2.1.0` → `2.1.1`): bug fixes only, no API changes.
- **Minor bump** (`2.1.0` → `2.2.0`): additive API changes.
- **Major bump** (`2.1.0` → `3.0.0`): breaking API changes, or removal of deprecated symbols.

## Release process (maintainers)

Publishing is irreversible — pub.dev permits unpublishing only within 7 days of upload and only via Dart team intervention. Treat releases accordingly.

1. Verify CI is green on `main`.
2. Confirm every package's `CHANGELOG.md` has an entry under a `## X.Y.Z` heading describing the changes shipping in this release.
3. Bump the `version:` field in every package's `pubspec.yaml` to `X.Y.Z`.
4. Run `fvm flutter pub publish --dry-run` in each package and confirm `0 warnings` (the `pubspec_overrides.yaml` hint is expected and harmless).
5. Publish in dependency order, waiting ~60s between each for pub.dev to index:

   ```
   1. flutter_blue_ultra_platform_interface
   2. flutter_blue_ultra_android, flutter_blue_ultra_darwin,
      flutter_blue_ultra_linux, flutter_blue_ultra_web   (any order, can be parallel)
   3. flutter_blue_ultra                                  (last)
   ```

6. Tag the release: `git tag vX.Y.Z && git push --tags`.
7. Create a GitHub Release with the consolidated changelog as the body.

## Reporting issues

Please use the issue templates under [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/). The bug template asks for platform, Flutter version, and reproduction steps — including these up front saves significant back-and-forth.

For security issues, do **not** open a public issue. Email [matteo.crippa@withintent.com](mailto:matteo.crippa@withintent.com) directly.

## License

By contributing, you agree that your contributions will be licensed under the [BSD 3-Clause License](LICENSE) that covers this project.
