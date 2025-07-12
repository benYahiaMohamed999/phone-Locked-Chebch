# Vercel Deployment Guide

This guide explains how to deploy your Flutter web app to Vercel.

## Prerequisites

- A Vercel account
- Your Flutter project connected to a Git repository (GitHub, GitLab, or Bitbucket)

## Deployment Steps

### 1. Connect to Vercel

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click "New Project"
3. Import your Git repository
4. Vercel will automatically detect the project structure

### 2. Configure Build Settings

The project is already configured with the following settings in `vercel.json`:

```json
{
    "buildCommand": "npm run build",
    "outputDirectory": "build/web",
    "installCommand": "npm install",
    "rewrites": [
        {
            "source": "/(.*)",
            "destination": "/index.html"
        }
    ]
}
```

### 3. Environment Variables (if needed)

If your app uses environment variables (like Firebase config), add them in the Vercel dashboard:

1. Go to your project settings in Vercel
2. Navigate to "Environment Variables"
3. Add any required environment variables

### 4. Deploy

1. Click "Deploy" in the Vercel dashboard
2. Vercel will automatically:
   - Install Node.js dependencies
   - Run the build script (`build.sh`)
   - Install Flutter
   - Build the web app
   - Deploy to a live URL

## Build Process

The build process works as follows:

1. **Install Command**: `npm install` - Installs Node.js dependencies
2. **Build Command**: `npm run build` - Runs the build script
3. **Build Script**: 
   - Detects Vercel environment
   - Installs Flutter if needed
   - Runs `flutter pub get`
   - Builds the web app with `flutter build web --release --web-renderer html`
4. **Output**: The built files are in `build/web/`

## Troubleshooting

### Common Issues

1. **"flutter: command not found"**
   - The build script should handle this automatically
   - Make sure the `build.sh` file is executable

2. **Build timeout**
   - Vercel has a 15-minute build timeout
   - The Flutter installation might take time on first build
   - Subsequent builds should be faster

3. **Memory issues**
   - If you encounter memory issues, try using `--web-renderer html` (already configured)

### Manual Deployment

If automatic deployment fails, you can:

1. Build locally: `flutter build web --release`
2. Upload the `build/web` folder to Vercel manually

## Custom Domain

After deployment, you can:

1. Go to your project settings in Vercel
2. Navigate to "Domains"
3. Add your custom domain

## Continuous Deployment

Vercel automatically deploys when you push to your main branch. Each push creates a new deployment with a unique URL.

## Support

If you encounter issues:

1. Check the build logs in Vercel dashboard
2. Ensure all files are committed to your repository
3. Verify the `vercel.json` configuration
4. Check that `build.sh` is executable 