# Netlify Deployment Guide

This guide explains how to deploy your Flutter web app to Netlify.

## Prerequisites

- A Netlify account
- Your Flutter project connected to a Git repository (GitHub, GitLab, or Bitbucket)

## Deployment Steps

### 1. Connect to Netlify

1. Go to [netlify.com](https://netlify.com) and sign in
2. Click "New site from Git"
3. Choose your Git provider (GitHub, GitLab, or Bitbucket)
4. Select your repository

### 2. Configure Build Settings

The project is already configured with the following settings in `netlify.toml`:

```toml
[build]
  command = "npm run build"
  publish = "build/web"

[build.environment]
  NODE_VERSION = "18"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

**Build Settings in Netlify Dashboard:**
- **Build command**: `npm run build`
- **Publish directory**: `build/web`
- **Node version**: 18 (or higher)

### 3. Environment Variables (if needed)

If your app uses environment variables (like Firebase config), add them in the Netlify dashboard:

1. Go to your site settings in Netlify
2. Navigate to "Environment variables"
3. Add any required environment variables

### 4. Deploy

1. Click "Deploy site" in the Netlify dashboard
2. Netlify will automatically:
   - Install Node.js dependencies
   - Run the build script (`build-netlify.sh`)
   - Install Flutter
   - Build the web app
   - Deploy to a live URL

## Build Process

The build process works as follows:

1. **Install Command**: `npm install` - Installs Node.js dependencies
2. **Build Command**: `npm run build` - Runs the build script
3. **Build Script**: 
   - Detects Netlify environment
   - Installs Flutter if needed
   - Runs `flutter pub get`
   - Builds the web app with `flutter build web --release --web-renderer html`
4. **Output**: The built files are in `build/web/`

## Netlify Features

### Automatic Deployments

- **Branch Deploys**: Every push to your main branch triggers a new deployment
- **Preview Deploys**: Pull requests get their own preview URLs
- **Rollback**: Easy rollback to previous deployments

### Custom Domain

After deployment, you can:

1. Go to your site settings in Netlify
2. Navigate to "Domain management"
3. Add your custom domain

### Form Handling

If your app has forms, Netlify can handle form submissions automatically.

## Troubleshooting

### Common Issues

1. **"flutter: command not found"**
   - The build script should handle this automatically
   - Make sure the `build-netlify.sh` file is executable

2. **Build timeout**
   - Netlify has a 15-minute build timeout
   - The Flutter installation might take time on first build
   - Subsequent builds should be faster

3. **Memory issues**
   - If you encounter memory issues, try using `--web-renderer html` (already configured)

4. **404 errors on refresh**
   - The `netlify.toml` redirects should handle this
   - Make sure the redirect rule is properly configured

### Manual Deployment

If automatic deployment fails, you can:

1. Build locally: `flutter build web --release`
2. Drag and drop the `build/web` folder to Netlify

### Build Logs

Check the build logs in Netlify dashboard for detailed error information.

## Performance Optimization

### Netlify Optimizations

The `netlify.toml` includes several optimizations:

```toml
[build.processing.css]
  bundle = true
  minify = true

[build.processing.js]
  bundle = true
  minify = true

[build.processing.html]
  pretty_urls = true

[build.processing.images]
  compress = true
```

### Flutter Web Optimizations

- Using `--web-renderer html` for better compatibility
- Release build for optimal performance
- Service worker for offline functionality

## Continuous Deployment

Netlify automatically deploys when you push to your main branch. Each push creates a new deployment with a unique URL.

## Support

If you encounter issues:

1. Check the build logs in Netlify dashboard
2. Ensure all files are committed to your repository
3. Verify the `netlify.toml` configuration
4. Check that `build-netlify.sh` is executable
5. Review the Netlify documentation: https://docs.netlify.com 