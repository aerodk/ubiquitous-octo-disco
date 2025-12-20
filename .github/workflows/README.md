# GitHub Actions Workflows

This directory contains automated deployment workflows for the Flutter app.

## Available Workflows

### 1. Deploy to GitHub Pages (deploy-pages.yml)
**Purpose:** Production deployment to the official GitHub Pages site

**Triggers:**
- Manual workflow dispatch only

**Target:**
- Branch: main
- URL: https://aerodk.github.io/ubiquitous-octo-disco/

**Use:** For deploying tested, production-ready releases

---

### 2. Deploy to Test Environment (deploy-test.yml)
**Purpose:** Test/staging deployment for validation before production

**Triggers:**
- Automatic: Push to `develop` branch
- Manual: Workflow dispatch (any branch)

**Target:**
- Branch: gh-pages-test
- Base href: /ubiquitous-octo-disco/test/

**Use:** For testing changes before merging to main

---

## Quick Start

### To deploy to production:
1. Ensure your changes are on the `main` branch
2. Go to Actions → "Deploy to GitHub Pages"
3. Click "Run workflow"

### To deploy to test:
1. Push to the `develop` branch, or
2. Go to Actions → "Deploy to Test Environment"
3. Click "Run workflow" and select your branch

---

## Documentation

For detailed information, see:
- [docs/TEST_DEPLOYMENT.md](../docs/TEST_DEPLOYMENT.md) - Test deployment guide
- [docs/DEPLOYMENT_WORKFLOWS.md](../docs/DEPLOYMENT_WORKFLOWS.md) - Workflow comparison
- [deployment.MD](../deployment.MD) - Full deployment guide

## Important Notes

⚠️ **GitHub Pages Limitation:** GitHub Pages can only serve one site per repository. The test deployment creates a separate branch but may not be directly accessible. Use local testing for quick validation.

✅ **Recommended Workflow:**
1. Develop on feature branches
2. Merge to `develop` (triggers test deployment)
3. Test locally: `flutter build web --release --base-href /ubiquitous-octo-disco/test/`
4. Merge to `main` when ready
5. Manually deploy to production
