# Deployment Guide

## GitHub Pages Deployment

This project can be deployed to GitHub Pages using the automated GitHub Action workflow.

### Prerequisites

- Repository must have GitHub Pages enabled
- GitHub Actions must be allowed to run in the repository
- Workflow must have write permissions to deploy

### Deployment Steps

#### Automatic Deployment (Default)

The app automatically deploys to GitHub Pages whenever you push to the `main` branch.

**Simply:**
1. Make your code changes
2. Commit and push to `main` branch
3. GitHub Actions automatically builds and deploys the app
4. Wait 2-3 minutes for the deployment to complete

The workflow will:
- Set up Flutter environment
- Install dependencies
- Build the Flutter web app in release mode with optimizations
- Deploy the built app to GitHub Pages
- Display the GitHub Pages URL in the workflow summary

#### Manual Deployment (Optional)

You can also manually trigger a deployment via GitHub Actions UI:

1. Go to the repository on GitHub
2. Navigate to **Actions** tab
3. Select **Deploy to GitHub Pages** workflow
4. Click **Run workflow** button
5. Select the branch (usually `main`)
6. Click **Run workflow** to start the deployment

Or deploy manually from the command line:

```bash
# Install dependencies
flutter pub get

# Build for web (release mode)
flutter build web --release --base-href /ubiquitous-octo-disco/

# The built files will be in build/web/
# Upload these files to your hosting provider
```

### Configuration

The GitHub Action workflow is configured in `.github/workflows/deploy-pages.yml`.

Key configuration options:
- **Base href**: Set to `/ubiquitous-octo-disco/` to match the repository name
- **Build mode**: Release mode with optimizations
- **Triggers**: 
  - Automatic: On push to `main` branch
  - Manual: Via workflow dispatch in GitHub Actions UI

### GitHub Pages URL

After successful deployment, the app will be available at:
```
https://aerodk.github.io/ubiquitous-octo-disco/
```

### Troubleshooting

**Build fails:**
- Check Flutter version compatibility
- Ensure all dependencies are correctly specified in `pubspec.yaml`
- Review build logs in GitHub Actions

**404 Error on GitHub Pages:**
- Verify GitHub Pages is enabled in repository settings
- Check that the base-href matches your repository name
- Ensure the workflow completed successfully

**Workflow permission denied:**
- Go to repository Settings → Actions → General
- Under "Workflow permissions", select "Read and write permissions"
- Save the settings and re-run the workflow
