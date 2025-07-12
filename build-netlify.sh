#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Flutter web build for Netlify..."

# Check if we're in a Netlify environment
if [ -n "$NETLIFY" ] || [ -n "$CI" ]; then
    echo "📦 Netlify environment detected, installing Flutter..."
    
    # Install Flutter
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:`pwd`/flutter/bin"
    
    # Pre-download Dart SDK
    flutter precache
    
    echo "✅ Flutter installed successfully"
else
    echo "✅ Local environment detected"
fi

# Get Flutter dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Build the web app
echo "🔨 Building web app..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web"

# Check if build was successful
if [ -d "build/web" ] && [ -f "build/web/index.html" ]; then
    echo "✅ Build verification passed"
    exit 0
else
    echo "❌ Build verification failed"
    exit 1
fi 