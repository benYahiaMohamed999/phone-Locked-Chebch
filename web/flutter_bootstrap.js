// This script loads the Flutter app correctly in the web environment
if (window.location.pathname.endsWith('/')) {
  // Make sure service worker is properly registered
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('flutter_service_worker.js');
    });
  }
}

// Load main.dart.js
var scriptTag = document.createElement('script');
scriptTag.src = 'main.dart.js';
scriptTag.type = 'application/javascript';
document.body.appendChild(scriptTag);
