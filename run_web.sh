#!/bin/bash

# Mobile Store Management - Web Runner Script
# This script makes it easy to run the Flutter project on web

echo "🚀 Starting Mobile Store Management on Web..."
echo "=============================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if web support is enabled
if ! flutter config --list | grep -q "enable-web: true"; then
    echo "⚠️  Web support is not enabled. Enabling now..."
    flutter config --enable-web
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Checking for issues..."
flutter analyze

# Run on web
echo "🌐 Starting web server..."
echo "📱 The app will open in your default browser"
echo "🔗 Local URL: http://localhost:3000"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Run the app on web with specific port and host
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0 