# 🌐 Mobile Store Management - Web Deployment

This guide will help you run the Mobile Store Management application on the web easily.

## 🚀 Quick Start

### Option 1: Using the provided scripts (Recommended)

#### On macOS/Linux:
```bash
./run_web.sh
```

#### On Windows:
```cmd
run_web.bat
```

### Option 2: Manual commands

1. **Get dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run on web:**
   ```bash
   flutter run -d web-server --web-port 3000
   ```

3. **Open in browser:**
   Navigate to `http://localhost:3000`

## 📋 Prerequisites

- **Flutter SDK** (version 3.0.0 or higher)
- **Chrome/Edge/Firefox** browser
- **Internet connection** (for Firebase services)

### Installing Flutter

1. Download Flutter from: https://flutter.dev/docs/get-started/install
2. Add Flutter to your PATH
3. Run `flutter doctor` to verify installation

## 🔧 Configuration

### Web Support
Ensure web support is enabled:
```bash
flutter config --enable-web
```

### Firebase Configuration
The app is pre-configured with Firebase for:
- Authentication
- Firestore database
- Analytics

Firebase configuration is already set up in `web/index.html`.

## 🌍 Deployment Options

### 1. Local Development
- Use the provided scripts or manual commands
- Access at `http://localhost:3000`
- Hot reload enabled for development

### 2. Production Build
```bash
flutter build web --release
```
The built files will be in `build/web/` directory.

### 3. Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init hosting

# Build the app
flutter build web --release

# Deploy
firebase deploy
```

### 4. Deploy to GitHub Pages
```bash
# Build the app
flutter build web --release --base-href "/your-repo-name/"

# Copy build/web contents to docs/ folder
# Enable GitHub Pages in repository settings
```

## 📱 Features

### Responsive Design
- **Mobile**: Optimized for phones and tablets
- **Desktop**: Full-featured desktop interface
- **Tablet**: Hybrid layout for medium screens

### Progressive Web App (PWA)
- Installable on mobile devices
- Offline capability (basic)
- App-like experience

### Cross-Browser Support
- Chrome (recommended)
- Firefox
- Safari
- Edge

## 🛠️ Troubleshooting

### Common Issues

1. **"Flutter not found"**
   - Ensure Flutter is installed and in PATH
   - Run `flutter doctor` to verify

2. **"Web support not enabled"**
   - Run `flutter config --enable-web`
   - Restart your terminal

3. **"Port 3000 already in use"**
   - Use a different port: `flutter run -d web-server --web-port 3001`
   - Or kill the process using port 3000

4. **"Firebase connection failed"**
   - Check internet connection
   - Verify Firebase configuration in `web/index.html`

5. **"App not loading"**
   - Clear browser cache
   - Try incognito/private mode
   - Check browser console for errors

### Performance Tips

1. **Use Chrome DevTools** for debugging
2. **Enable hardware acceleration** in browser
3. **Close unnecessary tabs** to free up memory
4. **Use production build** for better performance

## 🔒 Security

- Firebase Authentication handles user security
- HTTPS recommended for production
- CORS configured for Firebase services

## 📊 Analytics

Firebase Analytics is integrated to track:
- User engagement
- Feature usage
- Performance metrics

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Flutter web documentation: https://flutter.dev/docs/deployment/web
3. Check Firebase console for service status
4. Review browser console for error messages

## 📝 Notes

- The app requires an internet connection for Firebase services
- Local storage is used for some app preferences
- Responsive design adapts to different screen sizes
- PWA features work best on mobile devices

---

**Happy coding! 🎉** 