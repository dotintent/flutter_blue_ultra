# Testing Checklist for pub.dev Publishing

This guide helps you verify that `flutter_blue_ultra` is ready for publishing to pub.dev.

## Prerequisites

1. **Flutter SDK**: Ensure you have the latest stable Flutter SDK installed
2. **pub.dev account**: You need a verified pub.dev publisher account
3. **GitHub repository**: The package should be in a public GitHub repository

## Step-by-Step Testing Process

### 1. Fix Version Dependencies ✅
All platform packages must use the same version of `flutter_blue_ultra_platform_interface` as the main package.

**Status**: Fixed - All packages now use `8.0.0`

### 2. Check for Leftover Rename References

Since this is a fork of `flutter_blue_plus`, verify no stale references remain:

```bash
grep -r "flutter_blue_plus" packages/ --include="*.dart" --include="*.yaml" --include="*.md"
```

All results should be zero. Any hits must be renamed to `flutter_blue_ultra`.

### 3. Apply Automated Fixes

Run Dart's automated migration tool to fix any auto-fixable deprecations:

```bash
cd packages/flutter_blue_ultra
dart fix --apply
```

Repeat for each platform package.

### 4. Run Linter Checks

```bash
cd packages/flutter_blue_ultra
flutter analyze
```

This checks for:
- Dart analysis issues
- Linter rule violations
- Code style problems

### 5. Run Tests

```bash
cd packages/flutter_blue_ultra
flutter test
```

Repeat for each platform package that has tests.

### 6. Verify pubspec.yaml

Check that your `pubspec.yaml` has:
- ✅ `name`: `flutter_blue_ultra` (lowercase, underscores)
- ✅ `version`: Semantic version (e.g., `2.0.0`)
- ✅ `description`: Clear, concise description
- ✅ `homepage`: Valid URL
- ✅ `repository`: GitHub repo URL
- ✅ `issue_tracker`: GitHub issues URL
- ✅ `topics`: Relevant tags for discoverability (e.g., `bluetooth`, `ble`)
- ✅ `environment`: SDK and Flutter constraints
- ✅ All dependencies are available on pub.dev

### 7. Check Dependencies

Verify all dependencies exist on pub.dev:
- `flutter_blue_ultra_platform_interface: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_android: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_darwin: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_linux: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_web: 8.0.0` - **Must be published first**

**⚠️ IMPORTANT**: You must publish the platform packages **before** publishing the main package!

### 8. Check .pubignore

Ensure a `.pubignore` file exists in each package root to exclude files that should not be uploaded to pub.dev (native build artifacts, test fixtures, CI config, etc.). Note: `.pubignore` takes precedence over `.gitignore` for pub uploads.

### 9. Verify API Documentation

Public APIs need dartdoc comments for full pub points. Generate and validate docs:

```bash
cd packages/flutter_blue_ultra
dart doc --validate-links
```

Fix any broken links or missing documentation warnings before publishing.

### 10. Preview pub.dev Score with pana

`pana` simulates the exact score pub.dev will assign your package. Run it before publishing to catch issues early:

```bash
dart pub global activate pana
cd packages/flutter_blue_ultra
pana .
```

Target score: **130/130**. Address any reported issues — common point losses are missing API docs, missing `repository` field, and platform support gaps.

### 11. Dry Run Publishing

Test the publishing process without actually publishing:

```bash
cd packages/flutter_blue_ultra
flutter pub publish --dry-run
```

This will check for:
- Missing required fields
- Invalid version numbers
- Dependency issues
- File size limits
- Missing LICENSE file
- Missing CHANGELOG.md

### 12. Test Example App

Build and run the example app on at least one platform:

```bash
cd packages/flutter_blue_ultra/example
flutter pub get
flutter run
```

Test on:
- ✅ Android (if available)
- ✅ iOS (if available)
- ✅ macOS (if available)
- ✅ Linux (if available)
- ✅ Web (if available)

### 13. Verify Documentation

Check that documentation files exist and are complete:
- ✅ `README.md` - Main documentation
- ✅ `CHANGELOG.md` - Version history
- ✅ `LICENSE` - License file
- ✅ `docs/` - Additional documentation

### 14. Check File Structure

Ensure the package structure follows pub.dev requirements:
- ✅ `lib/` directory with Dart code
- ✅ `example/` directory (optional but recommended)
- ✅ No unnecessary files (use `.pubignore`)

### 15. Test Platform Packages First

**Publish in this order:**

1. `flutter_blue_ultra_platform_interface` (8.0.0)
2. `flutter_blue_ultra_android` (8.0.0)
3. `flutter_blue_ultra_darwin` (8.0.0)
4. `flutter_blue_ultra_linux` (8.0.0)
5. `flutter_blue_ultra_web` (8.0.0)
6. `flutter_blue_ultra` (2.0.0) - **Last**

For each package:
```bash
cd packages/<package_name>
flutter pub publish --dry-run  # Test first
flutter pub publish            # Then publish
```

### 16. Verify After Publishing

After publishing each package:
1. Check it appears on pub.dev
2. Verify the version number is correct
3. Check that dependencies resolve correctly
4. Test installing it in a fresh project

## Common Issues

### Issue: "Package not found" errors
**Solution**: Ensure all platform packages are published first

### Issue: Version conflict
**Solution**: Check that all packages use consistent version numbers

### Issue: Missing LICENSE file
**Solution**: Ensure LICENSE file exists in the package root

### Issue: Large file sizes
**Solution**: Use `.pubignore` to exclude unnecessary files

### Issue: Low pub.dev score
**Solution**: Run `pana .` locally to identify and fix specific point losses before publishing

### Issue: Leftover `flutter_blue_plus` references
**Solution**: Run the grep command in step 2 and rename all occurrences

## Quick Test Script

Run this script to test all packages:

```bash
#!/bin/bash
# Test all packages for pub.dev readiness

PACKAGES=(
  "flutter_blue_ultra_platform_interface"
  "flutter_blue_ultra_android"
  "flutter_blue_ultra_darwin"
  "flutter_blue_ultra_linux"
  "flutter_blue_ultra_web"
  "flutter_blue_ultra"
)

for package in "${PACKAGES[@]}"; do
  echo "Testing $package..."
  cd "packages/$package"
  dart fix --apply
  flutter analyze
  flutter test
  flutter pub publish --dry-run
  cd ../..
done
```

## Final Checklist Before Publishing

- [ ] No leftover `flutter_blue_plus` references
- [ ] `dart fix --apply` run on all packages
- [ ] All platform packages published successfully
- [ ] All dependencies resolve correctly
- [ ] `flutter analyze` passes with no errors
- [ ] `flutter test` passes
- [ ] `dart doc --validate-links` passes with no warnings
- [ ] `pana .` scores 130/130 (or known gaps are accepted)
- [ ] `flutter pub publish --dry-run` passes
- [ ] `.pubignore` exists in each package
- [ ] `pubspec.yaml` has `repository`, `issue_tracker`, and `topics` fields
- [ ] Example app builds and runs
- [ ] README.md is complete and accurate
- [ ] CHANGELOG.md is up to date
- [ ] LICENSE file exists
- [ ] Version numbers are correct and consistent

## Publishing Command

When ready to publish:

```bash
cd packages/flutter_blue_ultra
flutter pub publish
```

You'll be prompted for:
- OAuth2 authentication (pub.dev account)
- Confirmation of the package details
