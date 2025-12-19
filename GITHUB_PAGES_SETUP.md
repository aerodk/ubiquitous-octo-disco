# GitHub Pages Setup Guide - Flutter App Deployment

## 🎯 Goal
Deploy the Flutter application to GitHub Pages so it can be accessed in a browser at:
```
https://aerodk.github.io/ubiquitous-octo-disco/
```

## ⚠️ Critical: Why You See README.md Instead of the App

If GitHub Pages shows the README.md file instead of your Flutter app, it's because **GitHub Pages source is not configured correctly**.

**The Problem:**
- The workflow uses `actions/deploy-pages@v4` (GitHub Actions deployment method)
- But GitHub Pages is set to "Deploy from a branch" (old method)
- These two don't work together - you must use "GitHub Actions" as the source

## 📋 Step-by-Step Setup (Do This Once)

### Step 1: Configure GitHub Pages Source ⭐ MOST IMPORTANT

1. **Go to Repository Settings**
   - Navigate to: `https://github.com/aerodk/ubiquitous-octo-disco/settings/pages`
   - Or: Click "Settings" tab → "Pages" in sidebar

2. **Change the Source**
   ```
   Build and deployment
   ┌─────────────────────────────────────┐
   │ Source: [GitHub Actions ▼]          │  ← Select this!
   └─────────────────────────────────────┘
   
   ❌ Do NOT select "Deploy from a branch"
   ✅ DO select "GitHub Actions"
   ```

3. **No Save Button Needed**
   - The setting is saved automatically when you select it
   - You should see a confirmation message

**What This Does:**
- Tells GitHub Pages to accept deployments from GitHub Actions workflow
- Without this, GitHub Pages ignores your workflow and shows README.md

---

### Step 2: Configure Workflow Permissions

1. **Go to Actions Settings**
   - Navigate to: `https://github.com/aerodk/ubiquitous-octo-disco/settings/actions`
   - Or: Click "Settings" tab → "Actions" → "General"

2. **Set Workflow Permissions**
   - Scroll down to "Workflow permissions" section
   - Select: ✅ **"Read and write permissions"**
   - Check: ✅ **"Allow GitHub Actions to create and approve pull requests"**
   - Click **"Save"**

**What This Does:**
- Allows the workflow to deploy to GitHub Pages
- Without this, deployment will fail with "permission denied" error

---

### Step 3: Trigger First Deployment

1. **Go to Actions Tab**
   - Click "Actions" tab in your repository
   - Click "Deploy to GitHub Pages" workflow in the left sidebar

2. **Run the Workflow**
   - Click **"Run workflow"** button (top right)
   - Branch: `main` (should be selected by default)
   - Click **"Run workflow"** (green button)

3. **Monitor Progress**
   - Watch the workflow run (takes 2-3 minutes)
   - Wait for green checkmark ✅
   - If it fails, check the logs for errors

---

### Step 4: Verify Deployment

1. **Wait 2-3 Minutes**
   - After workflow shows green checkmark
   - GitHub Pages needs time to update

2. **Visit Your App**
   - Open: `https://aerodk.github.io/ubiquitous-octo-disco/`
   - You should see the Flutter app, NOT the README

3. **Troubleshooting if README Still Shows**
   - Clear browser cache (Ctrl+Shift+Delete)
   - Try incognito/private mode
   - Verify Step 1 is correct (Source = "GitHub Actions")
   - Re-run the workflow from Actions tab

---

## 🔄 After Initial Setup

Once configured, deployment is automatic:

```
You push to main branch
        ↓
GitHub Actions triggers automatically
        ↓
Builds Flutter web app (release mode)
        ↓
Deploys to GitHub Pages
        ↓
App updated at https://aerodk.github.io/ubiquitous-octo-disco/
```

**No manual steps needed after initial setup!**

---

## 🐛 Common Issues & Solutions

### Issue: "GitHub Pages shows README.md, not the app"

**Cause:** GitHub Pages source is not set to "GitHub Actions"

**Solution:**
1. Go to Settings → Pages
2. Source: Change to "GitHub Actions"
3. Re-run deployment workflow
4. Wait 2-3 minutes
5. Clear browser cache and reload

---

### Issue: "Workflow runs but nothing deploys"

**Cause:** Missing permissions or wrong Pages source

**Solution:**
1. Check Settings → Pages → Source = "GitHub Actions" ✅
2. Check Settings → Actions → Workflow permissions = "Read and write" ✅
3. Re-run the workflow

---

### Issue: "404 Error when visiting the URL"

**Possible Causes:**
- Deployment hasn't completed yet (wait 2-3 minutes)
- Wrong URL (check it matches: `https://aerodk.github.io/ubiquitous-octo-disco/`)
- base-href mismatch in build command

**Solution:**
- Wait a few minutes after deployment completes
- Check workflow logs for any errors
- Verify the URL path matches your repository name

---

## 📚 Additional Resources

- **Main Deployment Guide:** See `deployment.MD` in repository root
- **Technical Specification:** See `docs/SPECIFICATION.md` (Feature F-2.5)
- **Workflow File:** `.github/workflows/deploy-pages.yml`

---

## ✅ Checklist

Before asking for help, verify:

- [ ] GitHub Pages source is set to "GitHub Actions" (Settings → Pages)
- [ ] Workflow permissions are "Read and write" (Settings → Actions → General)
- [ ] Deployment workflow has run successfully (Actions tab shows ✅)
- [ ] Waited 2-3 minutes after workflow completion
- [ ] Tried in incognito/private browser window
- [ ] URL is correct: `https://aerodk.github.io/ubiquitous-octo-disco/`

If all checked and still showing README.md, there may be a GitHub Pages caching issue. Wait 10 minutes and try again.
