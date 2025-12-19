# Deployment Guide

## GitHub Pages Deployment

This project can be deployed to GitHub Pages using the automated GitHub Action workflow.

### ⚠️ Important: GitHub Pages Configuration Required

**Before the workflow can deploy your app, you MUST configure GitHub Pages to use GitHub Actions as the source.**

If you skip this step, GitHub Pages will show the README.md file instead of your Flutter application.

### Initial Setup (One-Time Configuration)

Follow these steps to configure your repository for GitHub Pages deployment:

#### Step 1: Enable GitHub Pages with GitHub Actions

1. Go to your repository on GitHub: `https://github.com/aerodk/ubiquitous-octo-disco`
2. Click on **Settings** tab
3. In the left sidebar, click on **Pages**
4. Under **Build and deployment** section:
   - **Source**: Select **"GitHub Actions"** from the dropdown
   - (Do NOT use "Deploy from a branch" - this is the old method)
5. Save the configuration

**Why this matters:** The workflow uses `actions/deploy-pages@v4` which requires GitHub Pages to be configured to accept deployments from GitHub Actions. Without this setting, GitHub Pages will ignore the deployment and show the default README.md file.

#### Step 2: Configure Workflow Permissions

1. Go to **Settings** → **Actions** → **General**
2. Scroll down to **Workflow permissions**
3. Select **"Read and write permissions"**
4. Check ✅ **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**

#### Step 3: Run the Deployment Workflow

Now that GitHub Pages is configured, trigger the deployment:

1. Go to the **Actions** tab
2. Click on **"Deploy to GitHub Pages"** workflow
3. Click **"Run workflow"** button
4. Select `main` branch
5. Click **"Run workflow"**

The workflow will:
- Build the Flutter web app in release mode
- Deploy to GitHub Pages
- Make it available at: `https://aerodk.github.io/ubiquitous-octo-disco/`

⏱️ **Wait 2-3 minutes** for the deployment to complete, then visit the URL above.

### Prerequisites

- Repository must have GitHub Pages configured to use "GitHub Actions" as source (see setup above)
- GitHub Actions must be allowed to run in the repository
- Workflow must have write permissions to deploy (see setup above)

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

**GitHub Pages shows README.md instead of the Flutter app:**
- ⚠️ **Most common issue**: GitHub Pages source is set to "Deploy from a branch" instead of "GitHub Actions"
- **Fix**: Go to Settings → Pages → Source → Select **"GitHub Actions"**
- After changing, re-run the deployment workflow from the Actions tab
- Wait 2-3 minutes and refresh the page

**Build fails:**
- Check Flutter version compatibility
- Ensure all dependencies are correctly specified in `pubspec.yaml`
- Review build logs in GitHub Actions

**404 Error on GitHub Pages:**
- Verify GitHub Pages source is set to "GitHub Actions" (see above)
- Check that the base-href matches your repository name
- Ensure the workflow completed successfully (green checkmark in Actions tab)

**Workflow permission denied:**
- Go to repository Settings → Actions → General
- Under "Workflow permissions", select "Read and write permissions"
- Save the settings and re-run the workflow

**Deployment succeeds but changes don't appear:**
- Clear your browser cache or open in incognito/private mode
- GitHub Pages can take 1-2 minutes to update after deployment completes
- Check that you're visiting the correct URL: `https://aerodk.github.io/ubiquitous-octo-disco/`
