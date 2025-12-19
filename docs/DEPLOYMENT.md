# Deployment Guide - GitHub Pages
## Automated Flutter Web Deployment med GitHub Actions

---

## Oversigt

Denne guide viser hvordan du sætter automatisk deployment op til GitHub Pages, så hver gang du pusher til `main` branch, bygges og deployes din Flutter app automatisk.

**Perfekt til:**
- ✅ Test/staging environment
- ✅ Demo til stakeholders
- ✅ Beta testing med rigtige brugere
- ✅ Preview af nye features
- ✅ 100% gratis hosting

**URL efter setup:** `https://[dit-github-brugernavn].github.io/padel_tournament_app/`

---

## Forudsætninger

- ✅ Flutter projekt på GitHub
- ✅ Repository er public (eller GitHub Pro for private)
- ✅ GitHub account

---

## Del 1: Manual Deployment (Test først)

Før vi laver automatisk deployment, lad os teste at det virker manuelt.

### Step 1: Byg Flutter Web App

```powershell
# Byg til production med korrekt base href
flutter build web --release --base-href "/padel_tournament_app/"
```

**Vigtigt:** `--base-href` skal matche dit repository navn!
- Repository: `padel_tournament_app`
- Base href: `/padel_tournament_app/`

### Step 2: Test Build Lokalt

```powershell
# Installer en simpel webserver (første gang)
dart pub global activate dhttpd

# Serve build lokalt
dhttpd --path=build/web --port=8080
```

Åbn browser: `http://localhost:8080`

Verificer at:
- [ ] Appen loader
- [ ] Navigation virker
- [ ] Ingen console errors

### Step 3: Manual Deploy til GitHub Pages

```powershell
# Naviger til build output
cd build\web

# Initialize git i build folder
git init
git add .
git commit -m "Initial deployment"

# Opret gh-pages branch og push
git branch -M gh-pages
git remote add origin https://github.com/[DIT-BRUGERNAVN]/padel_tournament_app.git
git push -f origin gh-pages

# Gå tilbage til projekt root
cd ..\..
```

### Step 4: Enable GitHub Pages

1. Gå til `https://github.com/[DIT-BRUGERNAVN]/padel_tournament_app`
2. Klik **Settings** tab
3. Scroll ned til **Pages** i venstre menu
4. Under **Source**, vælg:
   - Branch: `gh-pages`
   - Folder: `/ (root)`
5. Klik **Save**
6. Vent 1-2 minutter

**Din app er nu live på:**
`https://[dit-brugernavn].github.io/padel_tournament_app/`

---

## Del 2: Automatisk Deployment med GitHub Actions

Nu sætter vi automatisk deployment op, så du bare kan pushe kode og den deployes automatisk.

### Step 1: Opret GitHub Actions Workflow

**Via GitHub Copilot (Anbefalet):**

1. Åbn VS Code i dit projekt
2. Åbn Copilot Chat (`Ctrl+Alt+I`)
3. Skriv følgende prompt:

```
@workspace Create a GitHub Actions workflow for automated deployment to GitHub Pages.

Requirements:
- Workflow file: .github/workflows/deploy.yml
- Trigger: Push to main branch
- Steps:
  1. Checkout code
  2. Setup Flutter (stable channel)
  3. Install dependencies (flutter pub get)
  4. Build web with --release and --base-href "/padel_tournament_app/"
  5. Deploy to gh-pages branch using peaceiris/actions-gh-pages@v3

Make sure to:
- Use flutter-action for Flutter setup
- Cache Flutter dependencies for faster builds
- Use proper working directory (build/web) for deployment
- Add appropriate comments explaining each step
```

Copilot vil generere filen. **Accepter den** og den oprettes i `.github/workflows/deploy.yml`.

**Eller manuelt (hvis du vil lave den selv):**

```powershell
# Opret mapper
mkdir .github
mkdir .github\workflows
```

Opret fil `.github\workflows\deploy.yml` med følgende indhold:

```yaml
name: Deploy to GitHub Pages

# Trigger workflow ved push til main branch
on:
  push:
    branches: [ main ]
  
  # Tillad manuel trigger fra Actions tab
  workflow_dispatch:

# Permissions nødvendige for deployment
permissions:
  contents: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      # Step 1: Checkout kode
      - name: Checkout repository
        uses: actions/checkout@v4
      
      # Step 2: Setup Flutter
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'  # Eller 'stable' for nyeste
          channel: 'stable'
          cache: true  # Cache for hurtigere builds
      
      # Step 3: Verificer Flutter installation
      - name: Verify Flutter
        run: |
          flutter --version
          flutter doctor -v
      
      # Step 4: Install dependencies
      - name: Install dependencies
        run: flutter pub get
      
      # Step 5: Run tests (optional - kan kommenteres ud)
      - name: Run tests
        run: flutter test
        continue-on-error: true  # Fortsæt selv hvis tests fejler
      
      # Step 6: Build web app
      - name: Build Flutter web
        run: |
          flutter build web --release --base-href "/padel_tournament_app/"
      
      # Step 7: Deploy til GitHub Pages
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
          # Optional: Custom commit message
          commit_message: 'Deploy from GitHub Actions'
```

### Step 2: Konfigurer Repository Settings

**Enable GitHub Actions:**
1. Gå til repository på GitHub
2. **Settings** → **Actions** → **General**
3. Under "Actions permissions", vælg **Allow all actions and reusable workflows**
4. Under "Workflow permissions", vælg **Read and write permissions**
5. Klik **Save**

### Step 3: Commit og Push Workflow

```powershell
# Tilføj workflow fil
git add .github\workflows\deploy.yml
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

### Step 4: Verificer Deployment

1. Gå til dit repository på GitHub
2. Klik på **Actions** tab
3. Du skulle se "Deploy to GitHub Pages" workflow køre
4. Klik på workflow run for at se logs
5. Vent til den er færdig (grøn checkmark ✅)
6. Gå til din site: `https://[brugernavn].github.io/padel_tournament_app/`

**Første deployment tager ~3-5 minutter**
**Efterfølgende deployments tager ~2-3 minutter**

---

## Del 3: Workflow Forklaring

### Hvad sker der når du pusher?

```
1. Push til main branch
   ↓
2. GitHub Actions trigger
   ↓
3. Spin up Ubuntu Linux server
   ↓
4. Install Flutter SDK
   ↓
5. Download dependencies (cached)
   ↓
6. Run tests (optional)
   ↓
7. Build web app
   ↓
8. Deploy til gh-pages branch
   ↓
9. GitHub Pages opdaterer site
   ↓
10. Din app er live! 🚀
```

### Workflow Triggers

**Automatisk:**
- Hver gang du `git push origin main`

**Manuel:**
- Gå til **Actions** tab
- Vælg "Deploy to GitHub Pages"
- Klik **Run workflow** → **Run workflow**

---

## Del 4: Testing & Debugging

### Test Deployment Lokalt Før Push

```powershell
# Build præcis som GitHub Actions vil
flutter build web --release --base-href "/padel_tournament_app/"

# Test lokalt
dhttpd --path=build/web --port=8080
```

Åbn: `http://localhost:8080` og verificer alt virker.

### Debugging Failed Deployments

**Hvis workflow fejler:**

1. **Check Actions logs:**
   - GitHub → Actions tab
   - Klik på fejlet workflow
   - Udvid step der fejlede
   - Læs error message

2. **Common issues:**

**Issue: "Flutter command not found"**
```yaml
# Fix: Verificer flutter-action version
uses: subosito/flutter-action@v2  # Sørg for v2
```

**Issue: "Permission denied"**
```yaml
# Fix: Tjek permissions i workflow
permissions:
  contents: write
```

**Issue: "Base href forkert"**
```yaml
# Fix: Match repository navn præcis
--base-href "/padel_tournament_app/"  # Med slashes!
```

**Issue: "Tests failing"**
```yaml
# Midlertidig fix: Skip tests
# Kommenter denne sektion ud:
# - name: Run tests
#   run: flutter test
```

### View Deployment Logs

GitHub Pages deployment status:
1. Settings → Pages
2. Se "Your site is live at..." status
3. Hvis der er problemer, vil de vises her

---

## Del 5: Advanced Configuration

### Deploy Kun På Tag Release

Hvis du kun vil deploye ved releases:

```yaml
on:
  push:
    tags:
      - 'v*.*.*'  # Trigger på v1.0.0, v2.1.0, etc.
```

Deploy med:
```powershell
git tag v1.0.0
git push origin v1.0.0
```

### Deploy Preview for Pull Requests

For at teste ændringer før merge:

**Brug Copilot:**
```
@workspace Add a second workflow .github/workflows/preview.yml that:
- Triggers on pull_request
- Builds the Flutter web app
- Uploads build artifact
- Comments on PR with download link

This allows testing changes before merging to main.
```

### Custom Domain

Hvis du senere vil bruge eget domain:

1. **Opret CNAME fil:**
```powershell
# I build/web/CNAME
echo "padel.yourdomain.com" > build/web/CNAME
```

2. **Eller tilføj til workflow:**
```yaml
- name: Add CNAME
  run: echo "padel.yourdomain.com" > ./build/web/CNAME
```

3. **Konfigurer DNS:**
```
Type: CNAME
Name: padel
Value: [brugernavn].github.io
```

4. **Enable i GitHub:**
   - Settings → Pages
   - Custom domain: `padel.yourdomain.com`

---

## Del 6: Maintenance & Monitoring

### Monitor Deployment Status

**Email notifikationer:**
- GitHub → Settings (din profil)
- Notifications
- Enable "Actions" notifications

**Status badge i README:**

Tilføj til `README.md`:
```markdown
[![Deploy](https://github.com/[BRUGERNAVN]/padel_tournament_app/actions/workflows/deploy.yml/badge.svg)](https://github.com/[BRUGERNAVN]/padel_tournament_app/actions/workflows/deploy.yml)
```

### Rollback til Tidligere Version

Hvis noget går galt:

```powershell
# Find tidligere commit
git log --oneline

# Revert til tidligere version
git revert [COMMIT_HASH]
git push origin main

# Eller force push tidligere state
git reset --hard [COMMIT_HASH]
git push -f origin main
```

Deployment kører automatisk efter push.

### Cache Management

**GitHub Actions cache:**
- Automatisk cached: Flutter SDK, pub dependencies
- Max cache size: 10GB per repository
- Expires efter 7 dage uden brug

**Clear cache hvis problemer:**
- GitHub → Actions → Caches
- Delete specifikke caches

---

## Del 7: Version 1.5 Feature - Automatic Staging

Som en feature til Version 1.5, kan du forbedre workflowet:

### Multi-Environment Setup

**Brug Copilot til dette:**

```
@workspace Create an enhanced deployment setup for Version 1.5:

1. Update .github/workflows/deploy.yml to deploy to production (gh-pages)
2. Create .github/workflows/staging.yml that:
   - Triggers on push to 'develop' branch
   - Deploys to 'gh-pages-staging' branch
   - Uses base-href "/padel_tournament_app/staging/"
3. Add environment variables for different configs

This gives us:
- Production: https://[user].github.io/padel_tournament_app/
- Staging: https://[user].github.io/padel_tournament_app/staging/

Include proper documentation comments in the workflow files.
```

### Branch Strategy

```
main         → Production deployment
  ↓
develop      → Staging deployment
  ↓
feature/*    → Local testing only
```

**Workflow:**
```powershell
# Udvikle feature
git checkout -b feature/new-feature
# ... kode ...
git commit -am "Add feature"

# Test på staging
git checkout develop
git merge feature/new-feature
git push origin develop
# → Deployes automatisk til staging URL

# Efter test, merge til production
git checkout main
git merge develop
git push origin main
# → Deployes automatisk til production URL
```

---

## Del 8: Quick Reference

### Daily Workflow

```powershell
# 1. Lav ændringer
code .

# 2. Test lokalt
flutter run -d chrome

# 3. Commit
git add .
git commit -m "Implement feature X"

# 4. Push (trigger auto-deployment)
git push origin main

# 5. Vent 2-3 minutter
# 6. Check: https://[brugernavn].github.io/padel_tournament_app/
```

### Useful Commands

```powershell
# Test build lokalt
flutter build web --release --base-href "/padel_tournament_app/"
dhttpd --path=build/web --port=8080

# Force re-run workflow
# GitHub → Actions → Re-run jobs

# Check deployment status
# GitHub → Settings → Pages

# View live site
start https://[BRUGERNAVN].github.io/padel_tournament_app/
```

### Troubleshooting Checklist

Hvis deployment ikke virker:

- [ ] Repository er public (eller GitHub Pro)?
- [ ] Actions enabled i Settings → Actions?
- [ ] Workflow permissions set til "Read and write"?
- [ ] `--base-href` matcher repository navn?
- [ ] gh-pages branch eksisterer?
- [ ] Pages enabled i Settings → Pages?
- [ ] Waited 2-3 minutter efter push?

---

## Del 9: Cost & Limitations

### GitHub Pages Limits

**Gratis tier inkluderer:**
- ✅ 1 GB storage
- ✅ 100 GB bandwidth/måned
- ✅ 10 builds/time (GitHub Actions)

**Soft limits:**
- Max site size: 1 GB
- Max file size: 100 MB
- Max builds: 10/time (parallel)

**For en Flutter web app som denne:**
- Build size: ~5-15 MB compressed
- Bandwidth: Meget sjældent over limit
- **Du vil ikke ramme limits**

### GitHub Actions Minutes

**Gratis tier:**
- 2,000 minutes/måned for public repos
- Hver deployment bruger ~3-5 minutter

**Estimate:**
- 5 deployments/dag = 150 minutter/måned
- **Masser af margin!**

---

## Del 10: Next Steps

### After Version 1.0 Deployment

1. **Share test URL** med beta testers
2. **Gather feedback** gennem issues
3. **Iterate quickly** - push opdateringer hele tiden
4. **Monitor** Actions tab for failed builds

### Before Version 2.0

Consider:
- [ ] Setup staging environment (develop branch)
- [ ] Add deployment notifications (Slack/Discord)
- [ ] Setup analytics (Google Analytics)
- [ ] Create CHANGELOG.md

### Production Ready

When ready for "real" users:
- [ ] Custom domain setup
- [ ] Update README med live URL
- [ ] Create proper releases (tags)
- [ ] Setup error tracking (Sentry)

---

## Summary: From Zero to Deployed

**Complete process:**

1. ✅ Manual test deploy (10 min)
2. ✅ Setup GitHub Actions (5 min via Copilot)
3. ✅ Configure repository settings (2 min)
4. ✅ Push and verify (3 min)

**Total time: ~20 minutter**
**Future deploys: Automatic! Just `git push`**

---

## Getting Help

### GitHub Actions Issues
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Action Repo](https://github.com/subosito/flutter-action)

### Deployment Issues
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- Stack Overflow: `[github-actions] [flutter-web]`

### Ask Copilot
```
@workspace My GitHub Actions deployment is failing with error: [ERROR].
Check .github/workflows/deploy.yml and help me fix it.
```

---

## Ready to Deploy? 🚀

**Start her:**

1. Test manuel deployment (Del 1)
2. Verificer det virker
3. Lad Copilot lave Actions workflow (Del 2)
4. Push og se magien ✨

**Din app vil være live om 20 minutter!**