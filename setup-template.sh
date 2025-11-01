#!/bin/bash

# AudioKit AUv3 Instrument Template Setup Script
# This script creates a new project based on the AudioKit AUv3 Instrument template

set -e

echo "🎵 AudioKit AUv3 Instrument Template Setup"
echo "=========================================="
echo ""

# Get project details from user
read -p "Enter your project name (e.g., MySynth): " PROJECT_NAME
read -p "Enter bundle identifier prefix (e.g., com.yourcompany): " BUNDLE_PREFIX
read -p "Enter manufacturer code (4 chars, e.g., TEST): " MANUFACTURER_CODE
read -p "Enter subtype code (4 chars, e.g., syn1): " SUBTYPE_CODE
read -p "Enter destination directory (default: ~/Desktop): " DEST_DIR

# Set default destination
DEST_DIR=${DEST_DIR:-~/Desktop}
DEST_DIR="${DEST_DIR/#\~/$HOME}"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

PROJECT_DIR="$DEST_DIR/$PROJECT_NAME"

echo ""
echo "Creating project at: $PROJECT_DIR"
echo ""

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "❌ Error: Directory $PROJECT_DIR already exists"
    exit 1
fi

# Clone the template
echo "📥 Downloading template from GitHub..."
git clone --branch SwiftUI_AUv3 --depth 1 https://github.com/hagenkaiser/AudioKitTemplate.git "$PROJECT_DIR"

cd "$PROJECT_DIR"

# Remove git history
rm -rf .git
echo "✅ Template downloaded"

# Rename directories
echo "🔧 Renaming project files..."
mv Instrument "$PROJECT_NAME"
mv InstrumentAUv3 "${PROJECT_NAME}AUv3"
mv InstrumentTests "${PROJECT_NAME}Tests"
mv InstrumentUITests "${PROJECT_NAME}UITests"
mv Instrument.xcodeproj "${PROJECT_NAME}.xcodeproj"

# Update file names
mv "$PROJECT_NAME/InstrumentApp.swift" "$PROJECT_NAME/${PROJECT_NAME}App.swift"
mv "$PROJECT_NAME/InstrumentEXS.swift" "$PROJECT_NAME/${PROJECT_NAME}EXS.swift"
mv "${PROJECT_NAME}AUv3/Audio Unit/InstrumentAUv3AudioUnit.swift" "${PROJECT_NAME}AUv3/Audio Unit/${PROJECT_NAME}AUv3AudioUnit.swift"
mv "${PROJECT_NAME}AUv3/UI/InstrumentEXSAUv3View.swift" "${PROJECT_NAME}AUv3/UI/${PROJECT_NAME}EXSAUv3View.swift"
mv "${PROJECT_NAME}Tests/InstrumentTests.swift" "${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift"
mv "${PROJECT_NAME}UITests/InstrumentUITests.swift" "${PROJECT_NAME}UITests/${PROJECT_NAME}UITests.swift"
mv "${PROJECT_NAME}UITests/InstrumentUITestsLaunchTests.swift" "${PROJECT_NAME}UITests/${PROJECT_NAME}UITestsLaunchTests.swift"

# Replace in all files
echo "✏️  Updating project configuration..."
find . -type f \( -name "*.swift" -o -name "*.plist" -o -name "*.pbxproj" -o -name "*.storyboard" \) -exec sed -i '' "s/Instrument/$PROJECT_NAME/g" {} \;
find . -type f -name "Info.plist" -exec sed -i '' "s/TEST/$MANUFACTURER_CODE/g" {} \;
find . -type f -name "Info.plist" -exec sed -i '' "s/test/$SUBTYPE_CODE/g" {} \;

echo "✅ Project structure updated"

# Initialize new git repo
echo "📦 Initializing git repository..."
git init
git add .
git commit -m "Initial commit: $PROJECT_NAME based on AudioKit AUv3 Instrument template"

echo ""
echo "✨ Success! Your project has been created at:"
echo "   $PROJECT_DIR"
echo ""
echo "📝 Project Details:"
echo "   • Name: $PROJECT_NAME"
echo "   • Bundle ID: $BUNDLE_PREFIX.$PROJECT_NAME"
echo "   • Manufacturer Code: $MANUFACTURER_CODE"
echo "   • Subtype Code: $SUBTYPE_CODE"
echo ""
echo "🚀 Next Steps:"
echo "   1. Open ${PROJECT_NAME}.xcodeproj in Xcode"
echo "   2. Update bundle identifiers in project settings"
echo "   3. Build and run!"
echo ""
