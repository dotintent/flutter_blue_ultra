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

### 2. Run Linter Checks

```bash
cd packages/flutter_blue_ultra
flutter analyze
```

This checks for:
- Dart analysis issues
- Linter rule violations
- Code style problems

### 3. Verify pubspec.yaml

Check that your `pubspec.yaml` has:
- ✅ `name`: `flutter_blue_ultra` (lowercase, underscores)
- ✅ `version`: Semantic version (e.g., `2.0.0`)
- ✅ `description`: Clear, concise description
- ✅ `homepage`: Valid URL
- ✅ `environment`: SDK and Flutter constraints
- ✅ All dependencies are available on pub.dev

### 4. Check Dependencies

Verify all dependencies exist on pub.dev:
- `flutter_blue_ultra_platform_interface: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_android: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_darwin: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_linux: 8.0.0` - **Must be published first**
- `flutter_blue_ultra_web: 8.0.0` - **Must be published first**

**⚠️ IMPORTANT**: You must publish the platform packages **before** publishing the main package!

### 5. Dry Run Publishing

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

### 6. Test Example App

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

### 7. Verify Documentation

Check that documentation files exist and are complete:
- ✅ `README.md` - Main documentation
- ✅ `CHANGELOG.md` - Version history
- ✅ `LICENSE` - License file
- ✅ `docs/` - Additional documentation

### 8. Check File Structure

Ensure the package structure follows pub.dev requirements:
- ✅ `lib/` directory with Dart code
- ✅ `example/` directory (optional but recommended)
- ✅ No unnecessary files (use `.gitignore`)

### 9. Test Platform Packages First

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

### 10. Verify After Publishing

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
**Solution**: Use `.gitignore` to exclude unnecessary files

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
  flutter analyze
  flutter pub publish --dry-run
  cd ../..
done
```

## Final Checklist Before Publishing

- [ ] All platform packages published successfully
- [ ] All dependencies resolve correctly
- [ ] `flutter analyze` passes with no errors
- [ ] `flutter pub publish --dry-run` passes
- [ ] Example app builds and runs
- [ ] README.md is complete and accurate
- [ ] CHANGELOG.md is up to date
- [ ] LICENSE file exists
- [ ] Version numbers are correct and consistent
- [ ] All renaming from `flutter_blue_plus` to `flutter_blue_ultra` is complete

## Publishing Command

When ready to publish:

```bash
cd packages/flutter_blue_ultra
flutter pub publish
```

You'll be prompted for:
- OAuth2 authentication (pub.dev account)
- Confirmation of the package details

