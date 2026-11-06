# Fastlane Instructions for BalloonPop

## What is Fastlane?

Fastlane is an automation tool for iOS and Android app development. It automates tedious tasks like building apps, running tests, taking screenshots, and deploying to TestFlight or the App Store. Instead of clicking through Xcode menus repeatedly, you can run a single command to perform complex workflows.

## Why Use Fastlane?

- **Saves Time**: Automate repetitive tasks
- **Consistency**: Same process every time, reducing errors
- **Professional Practice**: Industry-standard tool used by development teams
- **Easy Deployment**: Deploy to TestFlight or App Store with one command

## Prerequisites

Before using Fastlane, ensure you have:

1. **Ruby** installed (comes with macOS)
2. **Bundler** installed (run `gem install bundler` if needed)
3. **Xcode** installed with command line tools
4. **Apple Developer Account** (for TestFlight/App Store features)

## Initial Setup

The project already has Fastlane configured, but you need to install the dependencies:

```bash
# Navigate to the project directory
cd /path/to/BalloonPop

# Install Fastlane and dependencies
bundle install
```

This command installs Fastlane and all required gems using Bundler.

## Available Commands (Lanes)

All Fastlane commands follow this format:
```bash
bundle exec fastlane ios [lane_name]
```

### Development & Testing Lanes

#### 1. Build the App (Debug)
```bash
bundle exec fastlane ios build
```
Builds the app in Debug configuration for local testing. Faster than Xcode's build process.

#### 2. Run Tests
```bash
bundle exec fastlane ios test
```
Runs your test suite on iPhone 17 simulator. Great for continuous integration.

#### 3. Build Release Version
```bash
bundle exec fastlane ios build_release
```
Creates a release build of your app with optimizations enabled.

### Version Management Lanes

#### 4. Increment Build Number
```bash
bundle exec fastlane ios bump_build
```
Automatically increments the build number (e.g., 1 → 2 → 3). Required before each TestFlight upload.

#### 5. Increment Version Number
```bash
bundle exec fastlane ios bump_version
```
Increments the patch version number (e.g., 1.0.0 → 1.0.1). Use when releasing new features or fixes.

### TestFlight Deployment Lanes

#### 6. Upload to TestFlight (Quick)
```bash
bundle exec fastlane ios beta
```
**Most commonly used for TestFlight deployment!**

This lane performs:

1. Increments build number automatically
2. Builds release version of the app
3. Uploads to TestFlight
4. Returns immediately (doesn't wait for processing)

#### 7. Upload to TestFlight (Wait for Processing)
```bash
bundle exec fastlane ios beta_wait
```
Same as `beta`, but waits for Apple to finish processing your build. Takes longer but confirms the build is ready for testing.

#### 8. Upload Pre-built App
```bash
bundle exec fastlane ios upload_testflight
```
Only uploads an existing IPA file to TestFlight. Use this if you've already built the app separately.

### Other Lanes

#### 9. Capture Screenshots
```bash
bundle exec fastlane ios screenshots
```
Automatically captures screenshots of your app. Useful for App Store submissions.

## Certificate & Provisioning Profile Management with Match

### What is Match and Why Do You Need It?

One of the most frustrating parts of iOS development is dealing with **code signing**: certificates and provisioning profiles. Every iOS app must be signed with a certificate to run on a device or be uploaded to the App Store. Here's the typical problem:

**The Traditional Problem:**

- Certificates expire and need to be renewed
- Provisioning profiles must be downloaded manually from Apple Developer Portal
- Team members have different certificates, causing "code signing failed" errors
- Xcode's automatic signing sometimes creates duplicate profiles
- When you switch computers, you have to set everything up again
- Confusing error messages like "No signing certificate found" or "Provisioning profile doesn't match"

**How Match Solves This:**

Match is Fastlane's solution for code signing. It stores all your certificates and provisioning profiles in a private Git repository. When you (or your teammates) need to build the app, Match automatically downloads the correct certificates and installs them on your Mac.

**Benefits:**

- **One Source of Truth**: All certificates stored in one Git repo
- **Team Collaboration**: Everyone on the team uses the same certificates
- **No Manual Configuration**: Match handles everything automatically
- **Easy Setup on New Computers**: Clone the repo and run one command
- **Version Control**: Track changes to certificates over time

### Understanding Match Concepts

- **Development Certificate**: Used to run apps on physical devices during development
- **App Store Certificate**: Used to submit apps to TestFlight and the App Store
- **Provisioning Profile**: Links your app ID, certificate, and allowed devices
- **Match Git Repo**: A private repository where encrypted certificates are stored
- **Passphrase**: Password used to encrypt/decrypt certificates in the repo

### Match Setup (One-Time Process)

#### Step 1: Create a Private Git Repository

You need a **private** Git repository to store certificates. You can create one on:

- **GitHub**: Go to github.com, create a new repository, and mark it as Private
- **GitLab**: Go to gitlab.com, create a new repository with Private visibility
- **Bitbucket**: Go to bitbucket.org, create a new repository as Private

**Important**: This repository must be private for security! It will contain your certificates.

Example repository name: `BalloonPop-certificates` or `ios-certificates`

#### Step 2: Set the Match Git Repository URL

Set the `MATCH_GIT_URL` environment variable with your private repository URL:

```bash
export MATCH_GIT_URL="https://github.com/yourusername/BalloonPop-certificates"
```

Replace `yourusername` with your actual GitHub username and repository name.

**Tip**: To make this permanent, add this line to your shell profile (`~/.zshrc` or `~/.bash_profile`):
```bash
echo 'export MATCH_GIT_URL="https://github.com/yourusername/BalloonPop-certificates"' >> ~/.zshrc
```

#### Step 3: Run Match Setup

The first time you set up Match, run:

```bash
bundle exec fastlane ios setup_match
```

Match will ask you:

1. **Git Repository URL** (if not in Matchfile): Enter your private repo URL
2. **Passphrase**: Create a strong password to encrypt certificates (save this somewhere safe!)
3. **Apple ID**: Authenticates with your Apple Developer account
4. **Create New Certificates?**: Answer "yes" if this is the first time

Match will:

- Generate or download certificates from Apple
- Create provisioning profiles
- Encrypt them with your passphrase
- Upload them to your Git repository

**Save your passphrase!** You'll need it every time you sync certificates.

### Match Lanes

#### Setup Match (First Time Only)
```bash
bundle exec fastlane ios setup_match
```
Creates new certificates and uploads them to your Git repo. Run this once when setting up the project.

#### Sync App Store Certificates
```bash
bundle exec fastlane ios sync_appstore_certs
```
Downloads and installs App Store certificates from your Git repo. Use this on new computers or if certificates were updated.

#### Sync Development Certificates
```bash
bundle exec fastlane ios sync_dev_certs
```
Downloads and installs development certificates for testing on physical devices.

#### Create New Certificates (Admin Only)
```bash
bundle exec fastlane ios match_new
```
Generates brand new certificates and profiles. Only use this if certificates expire or are revoked.

### How Match Works with Beta Deployment

The good news: **Match is already integrated into the beta lane!**

When you run:
```bash
bundle exec fastlane ios beta
```

The beta lane automatically:

1. Checks if `MATCH_GIT_URL` is set
2. If set: Syncs App Store certificates from your Match repo (using `readonly: true`)
3. If not set: Uses Xcode's automatic code signing with a warning message
4. Increments build number
5. Builds and signs the app with the correct certificate
6. Uploads to TestFlight

**This means Match is optional!** You can deploy to TestFlight without Match, but using Match eliminates most code signing issues and makes team collaboration easier.

You don't need to manually sync certificates before deploying—it's done automatically if Match is configured!

### Using Match on a New Computer

When you clone this project on a new Mac:

```bash
# Navigate to project
cd /path/to/BalloonPop

# Install dependencies
bundle install

# Set the Match Git URL environment variable
export MATCH_GIT_URL="https://github.com/yourusername/BalloonPop-certificates"

# Sync certificates (you'll be asked for the passphrase)
bundle exec fastlane ios sync_appstore_certs

# Now you're ready to deploy!
bundle exec fastlane ios beta
```

Match downloads the certificates and installs them in your keychain automatically.

**Note**: The beta lane will automatically use Match if `MATCH_GIT_URL` is set, otherwise it will fall back to Xcode's automatic code signing.

### Match Troubleshooting

#### Issue: "Please set MATCH_GIT_URL environment variable first!"

**Solution**: You haven't set the Match Git repository URL. Set it with:
```bash
export MATCH_GIT_URL="https://github.com/yourusername/BalloonPop-certificates"
```

#### Issue: "Could not decrypt the repo"

**Solution**: You entered the wrong passphrase. Try again with the correct passphrase you set during setup.

#### Issue: "Certificate has expired"

**Solution**: Generate new certificates:
```bash
bundle exec fastlane ios match_new
```

This creates new certificates and updates the Match repo. Team members will need to sync again.

#### Issue: "No provisioning profiles found"

**Solution**:

1. Make sure the Matchfile has the correct `git_url`
2. Run `bundle exec fastlane ios sync_appstore_certs`
3. If still failing, check that you have access to the private Git repository

#### Issue: "Couldn't find Team ID"

**Solution**: Add your Team ID to the Matchfile:
```ruby
team_id("YOUR_TEAM_ID")
```

Find your Team ID in Apple Developer Portal → Membership section.

#### Issue: Git authentication fails

**Solution**:

- Make sure you have Git credentials configured
- For GitHub, you might need a Personal Access Token instead of a password
- Run `git config --global credential.helper osxkeychain` to save credentials

### Match Best Practices

1. **Keep Passphrase Safe**: Store it in a password manager; share it securely with teammates
2. **Private Repository Only**: Never make the certificates repo public
3. **Use Readonly Mode**: Most team members should use `readonly: true` (already set in beta lane)
4. **One Person Creates**: Typically, one team lead runs `setup_match` initially
5. **Everyone Syncs**: All other team members just sync existing certificates
6. **Rotate Certificates**: If a certificate is compromised, generate new ones with `match_new`

### Why Match Matters for Students

As a student learning iOS development, you'll likely encounter code signing errors. Match eliminates 90% of these issues by:
- Automatically managing certificates and profiles
- Ensuring consistency across team projects
- Preventing "works on my machine" problems
- Teaching you professional development practices

Once Match is set up, you rarely think about code signing again—it just works!

## Common Workflows

### Workflow 1: Deploy to TestFlight

The simplest way to get your app to TestFlight:

```bash
bundle exec fastlane ios beta
```

That's it! This single command handles everything.

### Workflow 2: Update Version and Deploy

When releasing a new version with features:

```bash
# Increment version number (1.0.0 → 1.0.1)
bundle exec fastlane ios bump_version

# Build and upload to TestFlight
bundle exec fastlane ios beta
```

### Workflow 3: Just Build Locally

For quick local testing:

```bash
bundle exec fastlane ios build
```

### Workflow 4: Run Tests Before Deploying

Good practice before TestFlight deployment:

```bash
# Run tests first
bundle exec fastlane ios test

# If tests pass, deploy
bundle exec fastlane ios beta
```

## First-Time Authentication

The first time you run a TestFlight lane, Fastlane will ask you to authenticate:

1. **Enter Apple ID Password**: Use your Apple Developer account credentials
2. **Two-Factor Authentication**: Enter the 6-digit code sent to your device
3. **Session Storage**: Fastlane saves your session for 30 days

After initial authentication, subsequent runs won't require re-authentication.

## Understanding the Output

Fastlane provides detailed output showing:

- Green text: Successful steps
- Yellow text: Warnings or information
- Red text: Errors

Each step is clearly labeled (e.g., "Step: increment_build_number").

## Troubleshooting

### Issue: "Command not found: bundle"

**Solution**: Install Bundler
```bash
gem install bundler
```

### Issue: "Could not find gem 'fastlane'"

**Solution**: Install dependencies
```bash
bundle install
```

### Issue: Code Signing Errors

**Solution**: Ensure you have:

1. Valid Apple Developer account
2. Certificates and provisioning profiles configured in Xcode
3. Signed in to Xcode with your Apple ID

### Issue: Build Fails

**Solution**:

1. Try building in Xcode first to see detailed errors
2. Clean build folder in Xcode: Product > Clean Build Folder
3. Run the build lane again

### Issue: Authentication Fails

**Solution**:

1. Verify your Apple ID and password are correct
2. Check that your Apple Developer account is active
3. Ensure two-factor authentication is enabled

## Tips for Students

1. **Start Simple**: Try `bundle exec fastlane ios build` first before attempting TestFlight deployment
2. **Read the Output**: Fastlane tells you exactly what it's doing at each step
3. **Use Version Control**: Commit your code before running deployment lanes
4. **Test Locally First**: Always test your app in the simulator before deploying
5. **Check TestFlight**: After uploading, log in to App Store Connect to verify your build

## Configuration Files

The Fastlane setup consists of:

- **Gemfile**: Lists Fastlane as a dependency
- **fastlane/Appfile**: Contains app identifier and Apple ID
- **fastlane/Fastfile**: Defines all available lanes (commands)

You generally don't need to modify these files, but you can customize lanes if needed.

## Getting Help

- **List all available lanes**: `bundle exec fastlane lanes`
- **Fastlane documentation**: https://docs.fastlane.tools
- **Fastlane actions**: https://docs.fastlane.tools/actions

## Quick Reference

| Task | Command |
|------|---------|
| Build app | `bundle exec fastlane ios build` |
| Run tests | `bundle exec fastlane ios test` |
| Deploy to TestFlight | `bundle exec fastlane ios beta` |
| Increment build number | `bundle exec fastlane ios bump_build` |
| Increment version | `bundle exec fastlane ios bump_version` |
| Setup Match (first time) | `bundle exec fastlane ios setup_match` |
| Sync certificates | `bundle exec fastlane ios sync_appstore_certs` |
| List all commands | `bundle exec fastlane lanes` |

## Example Session

Here's what a typical TestFlight deployment looks like:

```bash
# Navigate to project
cd /path/to/BalloonPop

# Install dependencies (first time only)
bundle install

# Deploy to TestFlight
bundle exec fastlane ios beta

# Fastlane will:
# - Increment build number (e.g., 5 → 6)
# - Build the app in Release mode
# - Create an IPA file
# - Upload to TestFlight
# - Display success message

# Check App Store Connect to see your build
```

## Best Practices

1. **Always commit your code** before deploying to TestFlight
2. **Test in simulator** before deploying
3. **Run tests** before deploying if you have them
4. **Document changes** in version control commit messages
5. **Use meaningful version numbers** (e.g., 1.0.0 for first release, 1.1.0 for new features)

---

## Summary

Fastlane makes iOS development more efficient by automating repetitive tasks. The two most important features for this class are:

### 1. Match for Code Signing
```bash
bundle exec fastlane ios setup_match
```
Solves the most frustrating part of iOS development—certificate management. Set this up once and forget about code signing errors.

### 2. Beta Deployment
```bash
bundle exec fastlane ios beta
```
This single command will sync certificates, build your app, and upload it to TestFlight, making it available for testing.

Once Match is configured, deploying to TestFlight becomes a one-command operation!

Happy building!
