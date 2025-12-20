# Deployment Workflows - Quick Reference

This document provides a quick comparison of the two deployment workflows.

## Workflows Overview

### 1. Production Deployment (deploy-pages.yml)

**File:** `.github/workflows/deploy-pages.yml`

**Trigger:**
- Manual workflow dispatch only (no automatic deployment)
- Default branch: `main`

**Deployment:**
- Uses GitHub's official Pages deployment action (`actions/deploy-pages@v4`)
- Requires GitHub Pages to be configured with "GitHub Actions" as source
- Deploys to the official GitHub Pages site
- Base href: `/ubiquitous-octo-disco/`

**URL:** `https://aerodk.github.io/ubiquitous-octo-disco/`

**Permissions:**
```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

**Key Features:**
- Two-job workflow (build + deploy)
- Uses Pages artifact upload
- Environment protection available
- Official GitHub Pages deployment

---

### 2. Test Deployment (deploy-test.yml)

**File:** `.github/workflows/deploy-test.yml`

**Trigger:**
- Automatic on push to `develop` branch
- Manual workflow dispatch (can select any branch)
- Default branch: `develop`

**Deployment:**
- Uses third-party action (`peaceiris/actions-gh-pages@v4`)
- Deploys to `gh-pages-test` branch
- Base href: `/ubiquitous-octo-disco/test/`

**URL (note limitations):** `https://aerodk.github.io/ubiquitous-octo-disco/test/`
- ⚠️ May not be directly accessible due to GitHub Pages limitations (see below)

**Permissions:**
```yaml
permissions:
  contents: write
```

**Key Features:**
- Single-job workflow (build + deploy)
- Direct branch deployment
- Automatic on develop branch push
- Separate from production

---

## Key Differences

| Feature | Production | Test |
|---------|-----------|------|
| **Workflow File** | `deploy-pages.yml` | `deploy-test.yml` |
| **Trigger** | Manual only | Auto (develop) + Manual |
| **Target** | GitHub Pages (official) | `gh-pages-test` branch |
| **Base Href** | `/ubiquitous-octo-disco/` | `/ubiquitous-octo-disco/test/` |
| **Deployment Action** | `actions/deploy-pages@v4` | `peaceiris/actions-gh-pages@v4` |
| **Jobs** | 2 (build + deploy) | 1 (combined) |
| **URL Access** | ✅ Direct | ⚠️ Limited (see below) |

---

## Important Limitation: GitHub Pages Single Site

**Issue:** GitHub Pages officially supports only **one site per repository**.

This means:
- Only one branch can be served by GitHub Pages at a time
- The test deployment creates a `gh-pages-test` branch but it won't be automatically served
- You cannot have both production and test URLs active simultaneously with standard GitHub Pages

### Workarounds for Testing

**Option 1: Local Testing (Recommended)**
```bash
# Build with test configuration
flutter build web --release --base-href /ubiquitous-octo-disco/test/

# Serve locally
cd build/web
python3 -m http.server 8080

# Visit http://localhost:8080
```

**Option 2: Temporarily Switch Pages Source**
- Go to Settings → Pages
- Change source from `gh-pages` to `gh-pages-test`
- Test your changes
- ⚠️ **Remember to switch back to `gh-pages` for production!**

**Option 3: Use a Separate Test Repository (Advanced)**
- Create `ubiquitous-octo-disco-test` repository
- Configure test workflow to push to that repository
- Access at `https://aerodk.github.io/ubiquitous-octo-disco-test/`

---

## When to Use Each Workflow

### Use Production Deployment When:
- ✅ Changes have been tested and validated
- ✅ Ready for end users to see
- ✅ Merging to main branch
- ✅ Creating a release

### Use Test Deployment When:
- ✅ Testing new features before production
- ✅ Validating changes on develop branch
- ✅ Creating a backup deployment artifact
- ✅ Continuous integration testing

### Recommended: Use Local Testing
- ✅ Quick iteration during development
- ✅ No GitHub Actions minutes consumed
- ✅ Instant feedback
- ✅ No deployment delays

---

## Workflow Commands

### Production Deployment
```bash
# Via GitHub UI
1. Go to Actions tab
2. Select "Deploy to GitHub Pages"
3. Click "Run workflow"
4. Select branch (usually main)
5. Click "Run workflow"

# Via git
git checkout main
# Make changes
git commit -am "Update feature"
git push origin main
# Then manually trigger workflow in GitHub UI
```

### Test Deployment
```bash
# Automatic (on develop push)
git checkout develop
git merge feature/my-feature
git push origin develop
# Workflow runs automatically

# Manual (any branch)
1. Go to Actions tab
2. Select "Deploy to Test Environment"
3. Click "Run workflow"
4. Select branch to test
5. Click "Run workflow"
```

### Local Testing
```bash
# Build
flutter build web --release --base-href /ubiquitous-octo-disco/test/

# Serve (choose one)
cd build/web
python3 -m http.server 8080
# or
dhttpd --path=build/web --port=8080

# Visit http://localhost:8080
```

---

## Monitoring Deployments

### Check Workflow Status
1. Go to repository on GitHub
2. Click **Actions** tab
3. See recent workflow runs
4. Click on a run to see detailed logs

### Check GitHub Pages Status
1. Go to repository on GitHub
2. Click **Settings** tab
3. Click **Pages** in sidebar
4. See current deployment status and URL

### View Deployed Branches
```bash
git branch -r | grep gh-pages
# Should show:
# origin/gh-pages (production)
# origin/gh-pages-test (test)
```

---

## Troubleshooting

### "Test URL doesn't work"
**Cause:** GitHub Pages can only serve one branch
**Solution:** Use local testing or temporarily switch Pages source

### "Production deployment failed"
**Cause:** Missing permissions or Pages not configured
**Solution:** Check Settings → Pages → Source should be set to "GitHub Actions"

### "Workflow triggers but nothing happens"
**Cause:** Permissions issue
**Solution:** Settings → Actions → Workflow permissions should be set to "Read and write"

### "Base href causes 404 errors"
**Cause:** Mismatch between base-href and actual deployment path
**Solution:** Ensure base-href matches repository name exactly

---

## Summary

- ✅ **Two workflows** for different deployment needs
- ✅ **Production**: Manual, controlled releases
- ✅ **Test**: Automatic, continuous deployment from develop
- ⚠️ **Limitation**: GitHub Pages serves one site (use local testing)
- 📖 **Documentation**: See `docs/TEST_DEPLOYMENT.md` for detailed guide
