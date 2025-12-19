# Deployment Guide

## GitHub Pages Deployment

This project can be deployed to GitHub Pages using the automated GitHub Action workflow.

### Prerequisites

- Repository must have GitHub Pages enabled
- GitHub Actions must be allowed to run in the repository
- Workflow must have write permissions to deploy

### Deployment Steps

#### Automated Deployment (Recommended)

1. Go to the repository on GitHub
2. Navigate to **Actions** tab
3. Select **Deploy to GitHub Pages** workflow
4. Click **Run workflow** button
5. Select the branch (usually `main` or `master`)
6. Click **Run workflow** to start the deployment

The workflow will:
- Set up Flutter environment
- Install dependencies
- Build the Flutter web app in release mode with optimizations
- Deploy the built app to GitHub Pages
- Display the GitHub Pages URL in the workflow summary

#### Manual Deployment

If you need to deploy manually:

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
- **Trigger**: Manual workflow dispatch

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
