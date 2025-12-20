# Test/Develop Deployment Guide

This guide explains how to use the test deployment workflow to validate changes before deploying to production.

## Overview

The project now supports two deployment environments:

1. **Production** (`main` branch → `gh-pages` branch)
   - URL: `https://aerodk.github.io/ubiquitous-octo-disco/`
   - Triggered by: Manual workflow dispatch on main branch
   - Purpose: Live production site

2. **Test** (`develop` branch → `gh-pages-test` branch)
   - URL: `https://aerodk.github.io/ubiquitous-octo-disco/test/`
   - Triggered by: Push to `develop` branch or manual workflow dispatch
   - Purpose: Testing and validation before production deployment

## Using the Test Environment

### Setup (One-time)

1. **Create a `develop` branch** (if it doesn't exist):
   ```bash
   git checkout -b develop
   git push -u origin develop
   ```

2. **Configure workflow permissions**:
   - Go to repository Settings → Actions → General
   - Under "Workflow permissions", select "Read and write permissions"
   - Save the settings

### Development Workflow

#### Option 1: Automatic deployment on push to develop

```bash
# Make your changes on a feature branch
git checkout -b feature/my-new-feature

# ... make changes ...

# Commit your changes
git add .
git commit -m "Add new feature"

# Merge to develop branch
git checkout develop
git merge feature/my-new-feature

# Push to trigger test deployment
git push origin develop
```

The test deployment will automatically:
- Build the Flutter web app with test configuration
- Deploy to `gh-pages-test` branch
- Make it available at the test URL (after 2-3 minutes)

#### Option 2: Manual test deployment

1. Go to GitHub repository → Actions tab
2. Select "Deploy to Test Environment" workflow
3. Click "Run workflow"
4. Select the branch to deploy (default: `develop`)
5. Click "Run workflow" button

### Testing Your Changes

1. Wait for the workflow to complete (check Actions tab)
2. Visit the test URL: `https://aerodk.github.io/ubiquitous-octo-disco/test/`
3. Verify your changes work as expected
4. Test all functionality thoroughly

### Promoting to Production

Once you've verified changes in the test environment:

```bash
# Merge develop into main
git checkout main
git merge develop

# Push to main (production will be deployed manually)
git push origin main

# Go to GitHub Actions and manually trigger "Deploy to GitHub Pages" workflow
```

## Important Notes

### GitHub Pages Limitation

**Note:** GitHub Pages officially supports only one site per repository. The test deployment creates a separate branch (`gh-pages-test`), but GitHub Pages will only serve content from the configured source.

**Workarounds:**

1. **Use branch-based access** (if GitHub Pages is set to deploy from a branch):
   - You can temporarily switch the Pages source to `gh-pages-test` branch to view test deployments
   - Settings → Pages → Source → Branch: `gh-pages-test`
   - **Remember to switch back to `gh-pages` for production!**

2. **Local testing** (recommended):
   ```bash
   # Build with test configuration
   flutter build web --release --base-href /ubiquitous-octo-disco/test/
   
   # Serve locally
   cd build/web
   python3 -m http.server 8080
   # or
   dhttpd --path=build/web --port=8080
   ```
   
   Visit: `http://localhost:8080`

3. **Use a separate repository** for test deployments (advanced):
   - Create a `ubiquitous-octo-disco-test` repository
   - Deploy test builds there
   - Accessible at: `https://aerodk.github.io/ubiquitous-octo-disco-test/`

## Workflow Configuration

### Test Deployment Triggers

The test workflow (`.github/workflows/deploy-test.yml`) triggers on:

- **Automatic**: Push to `develop` branch
- **Manual**: Workflow dispatch (can specify any branch)

### Production Deployment Triggers

The production workflow (`.github/workflows/deploy-pages.yml`) triggers on:

- **Manual**: Workflow dispatch only (for controlled production releases)

## Branch Strategy

```
main (production)
  ↑
  │ (merge after testing)
  │
develop (test/staging)
  ↑
  │ (merge features)
  │
feature/* (local development)
```

### Recommended Workflow

1. **Develop features** on `feature/*` branches
2. **Merge to develop** and test on test environment
3. **After validation**, merge to `main`
4. **Deploy to production** manually

## Troubleshooting

### Test deployment succeeds but URL doesn't work

- **Cause**: GitHub Pages can only serve one branch at a time
- **Solution**: 
  - Test locally instead (see "Local testing" above)
  - Or temporarily switch Pages source to `gh-pages-test` branch
  - Or use a separate test repository

### Workflow fails with permission error

- **Cause**: Insufficient workflow permissions
- **Solution**:
  1. Go to Settings → Actions → General
  2. Workflow permissions → "Read and write permissions"
  3. Save and re-run workflow

### Changes don't appear on test site

- **Cause**: GitHub Pages caching or wrong branch served
- **Solution**:
  - Wait 2-3 minutes for Pages to update
  - Clear browser cache or use incognito mode
  - Verify correct branch is being served in Settings → Pages

## Best Practices

1. **Always test on develop** before merging to main
2. **Use descriptive commit messages** for tracking changes
3. **Test locally first** when possible to save GitHub Actions minutes
4. **Review workflow logs** if deployment fails
5. **Keep develop branch in sync** with main after production deployments

## Next Steps

- Consider setting up a separate test repository for true dual-environment deployment
- Add automated testing to the workflows
- Implement deployment notifications (Slack, email, etc.)
- Add environment-specific configuration files

## Summary

- ✅ Test environment workflow created
- ✅ Automatic deployment on push to `develop` branch
- ✅ Manual deployment option available
- ⚠️  Test URL requires workaround due to GitHub Pages limitation
- ✅ Recommended: Use local testing for quick validation
