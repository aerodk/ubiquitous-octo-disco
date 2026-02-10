# Android Release Workflow

This document describes how to build and release Android APK files using the automated GitHub Actions workflow.

## Overview

The Android release workflow automates the process of:
1. Bumping the semantic version (major, minor, or patch)
2. Running tests to ensure code quality
3. Building a release APK
4. Creating a Git tag and GitHub release
5. Making the APK available for download

## How to Trigger a Release

### Step 1: Navigate to Actions
1. Go to the [GitHub repository](https://github.com/aerodk/ubiquitous-octo-disco)
2. Click on the **Actions** tab
3. Select **Build Android Release APK** from the workflows list

### Step 2: Run Workflow
1. Click the **Run workflow** button (top right)
2. Select the version bump type:
   - **patch** (1.0.0 → 1.0.1) - Bug fixes and minor changes
   - **minor** (1.0.0 → 1.1.0) - New features, backward compatible
   - **major** (1.0.0 → 2.0.0) - Breaking changes
3. Click **Run workflow** to start the build

### Step 3: Monitor Progress
- The workflow typically takes 5-10 minutes to complete
- Watch the progress in the Actions tab
- All tests must pass before the APK is built

### Step 4: Download the APK
After the workflow completes successfully:

#### Option A: From GitHub Release
1. Go to the [Releases page](https://github.com/aerodk/ubiquitous-octo-disco/releases)
2. Find the latest release (e.g., "Star Cano v1.0.1")
3. Download the APK file from the Assets section

#### Option B: From Workflow Artifacts
1. Go to the completed workflow run
2. Scroll down to the **Artifacts** section
3. Download the APK artifact (available for 90 days)

## Semantic Versioning Guide

Follow [Semantic Versioning](https://semver.org/) principles:

### Patch (x.x.X)
Use for backward-compatible bug fixes:
- Bug fixes
- Performance improvements
- Documentation updates
- Code refactoring without functionality changes

### Minor (x.X.x)
Use for backward-compatible new features:
- New features
- Enhancements to existing features
- Deprecations (with backward compatibility)

### Major (X.x.x)
Use for incompatible API changes:
- Breaking changes
- Removal of deprecated features
- Major architectural changes
- Changes that require user action

## Version and Build Numbers

- **Version number**: Follows semantic versioning (e.g., 1.2.3)
- **Build number**: Automatically incremented with each build (e.g., +5)
- **Full version**: Displayed as `1.2.3+5` in `pubspec.yaml`

## Installing the APK on Android Devices

### Prerequisites
1. Enable "Unknown Sources" or "Install unknown apps" in Android settings
2. Download the APK file to your device

### Installation Steps
1. Locate the downloaded APK file (usually in Downloads folder)
2. Tap on the APK file
3. If prompted, allow installation from this source
4. Tap **Install**
5. Wait for installation to complete
6. Tap **Open** to launch the app

## Workflow Details

### What Happens During the Workflow

1. **Version Calculation**: Reads current version from `pubspec.yaml` and calculates new version based on bump type
2. **Build Number Increment**: Automatically increments the build number
3. **Update pubspec.yaml**: Updates version in the project file
4. **Install Dependencies**: Runs `flutter pub get`
5. **Run Tests**: Executes `flutter test` (must pass to continue)
6. **Build APK**: Runs `flutter build apk --release`
7. **Create Tag**: Creates a Git tag (e.g., `v1.0.1`)
8. **Create Release**: Creates a GitHub release with the APK attached
9. **Commit Version**: Commits the version bump to the main branch

### Workflow File Location
`.github/workflows/android-release.yml`

## Troubleshooting

### Build Fails
- Check the workflow logs in the Actions tab
- Common issues:
  - Tests failing (fix tests and try again)
  - Build errors (check Flutter/Dart code)
  - Dependency issues (verify `pubspec.yaml`)

### Can't Install APK
- Ensure "Install unknown apps" is enabled for your browser/file manager
- Check that you downloaded the complete file (should be ~20-50 MB)
- Try downloading again if the file is corrupted

### Wrong Version Number
- The workflow automatically calculates versions
- If incorrect, manually edit `pubspec.yaml` and run workflow again
- Ensure you select the correct bump type (patch/minor/major)

## Best Practices

1. **Test Locally First**: Run `flutter test` and `flutter build apk` locally before triggering the workflow
2. **Choose Bump Type Carefully**: Follow semantic versioning guidelines
3. **Update Changelog**: Consider maintaining a CHANGELOG.md file
4. **Release Notes**: Edit the GitHub release after creation to add detailed release notes
5. **Version Strategy**: 
   - Use patch for most bug fixes
   - Use minor for feature releases
   - Reserve major for significant changes

## Example Release Flow

1. Develop and test new feature locally
2. Merge feature to main branch
3. Go to Actions → Build Android Release APK
4. Select "minor" (new feature)
5. Run workflow
6. Wait for completion
7. Download APK from Releases page
8. Test installation on device
9. Share release link with users

## Related Documentation

- [Flutter Build and Release](https://docs.flutter.dev/deployment/android)
- [Semantic Versioning](https://semver.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
