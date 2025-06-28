@echo off
REM Mobile Store Management - Web Runner Script for Windows
REM This script makes it easy to run the Flutter project on web

echo 🚀 Starting Mobile Store Management on Web...
echo ==============================================

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check if web support is enabled
flutter config --list | findstr "enable-web: true" >nul
if errorlevel 1 (
    echo ⚠️  Web support is not enabled. Enabling now...
    flutter config --enable-web
)

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Check for any issues
echo 🔍 Checking for issues...
flutter analyze

REM Run on web
echo 🌐 Starting web server...
echo 📱 The app will open in your default browser
echo 🔗 Local URL: http://localhost:3000
echo 🛑 Press Ctrl+C to stop the server
echo.

REM Run the app on web with specific port and host
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0

pause 