#!/bin/bash
# Test script for pub.dev readiness
# Run this from the repository root: ./test_pub_dev.sh

set -e  # Exit on error

echo "🔍 Testing flutter_blue_ultra packages for pub.dev readiness..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"
echo ""

# Test packages in dependency order
PACKAGES=(
  "flutter_blue_ultra_platform_interface"
  "flutter_blue_ultra_android"
  "flutter_blue_ultra_darwin"
  "flutter_blue_ultra_linux"
  "flutter_blue_ultra_web"
  "flutter_blue_ultra"
)

FAILED=0

for package in "${PACKAGES[@]}"; do
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}Testing: $package${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  
  cd "packages/$package"
  
  # Run pub get
  echo "📦 Running flutter pub get..."
  if flutter pub get > /dev/null 2>&1; then
    echo -e "${GREEN}✅ pub get successful${NC}"
  else
    echo -e "${RED}❌ pub get failed${NC}"
    flutter pub get
    FAILED=1
    cd ../..
    continue
  fi
  
  # Run analyzer
  echo "🔍 Running flutter analyze..."
  if flutter analyze > /tmp/analyze_output.txt 2>&1; then
    echo -e "${GREEN}✅ Analysis passed${NC}"
  else
    echo -e "${RED}❌ Analysis failed:${NC}"
    cat /tmp/analyze_output.txt
    FAILED=1
  fi
  
  # Run dry-run publish
  echo "📤 Testing flutter pub publish --dry-run..."
  if flutter pub publish --dry-run > /tmp/publish_output.txt 2>&1; then
    echo -e "${GREEN}✅ Dry-run publish passed${NC}"
  else
    echo -e "${RED}❌ Dry-run publish failed:${NC}"
    cat /tmp/publish_output.txt | tail -20
    FAILED=1
  fi
  
  cd ../..
  echo ""
done

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed! Packages are ready for pub.dev${NC}"
  echo ""
  echo "📋 Next steps:"
  echo "   1. Publish packages in this order:"
  for package in "${PACKAGES[@]}"; do
    echo "      - $package"
  done
  echo "   2. For each package, run:"
  echo "      cd packages/$package"
  echo "      flutter pub publish"
else
  echo -e "${RED}❌ Some tests failed. Please fix the issues above.${NC}"
fi
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

exit $FAILED

