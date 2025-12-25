#!/bin/bash

# Run Tests Script for Livesport Claude
# This script runs all tests and generates coverage reports

set -e

echo "🧪 Running Livesport Claude Tests..."

# Change to project directory
cd "$(dirname "$0")"

# Clean build folder
echo "🧹 Cleaning build folder..."
xcodebuild clean \
  -project LivesportClaude.xcodeproj \
  -scheme LivesportClaude \
  > /dev/null 2>&1 || true

# Run tests with coverage
echo "🏃 Running tests..."
xcodebuild test \
  -project LivesportClaude.xcodeproj \
  -scheme LivesportClaude \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# Generate coverage report
echo "📊 Generating coverage report..."
xcrun xccov view --report TestResults.xcresult > coverage.txt
xcrun xccov view --report --json TestResults.xcresult > coverage.json

# Display coverage
echo ""
echo "✅ Tests completed!"
echo ""
echo "📊 Coverage Report:"
echo "=================="
cat coverage.txt

# Extract overall coverage percentage
COVERAGE=$(xcrun xccov view --report TestResults.xcresult | grep -E "^\s*LivesportClaude" | awk '{print $2}' | sed 's/%//')

echo ""
echo "Overall Coverage: $COVERAGE%"

# Check threshold
THRESHOLD=70
if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
  echo "❌ Coverage is below threshold ($THRESHOLD%)"
  exit 1
else
  echo "✅ Coverage meets threshold ($THRESHOLD%)"
fi
