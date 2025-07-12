#!/bin/bash

# Exit on any error
set -e

echo "🔄 Updating build/web folder..."

# Build the Flutter web app
echo "🔨 Building Flutter web app..."
flutter build web --release

# Ensure build/web is tracked in git
echo "📝 Adding build/web to git..."
git add build/web/

# Show status
echo "✅ Build/web folder updated and added to git"
echo "📁 Contents of build/web:"
ls -la build/web/

echo ""
echo "🚀 Ready for deployment!"
echo "   - For Netlify: push to git and connect repository"
echo "   - For Vercel: push to git and connect repository"
echo "   - For manual: upload build/web/ folder" 