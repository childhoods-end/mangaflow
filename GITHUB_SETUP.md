# GitHub Setup Guide for MangaFlow

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository settings:
   - **Repository name**: `mangaflow`
   - **Description**: AI-powered manga translation platform built with Next.js 14 and Supabase
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)

3. Click "Create repository"

## Step 2: Push to GitHub

After creating the repository, run these commands from the `mangaflow` directory:

```bash
# If you don't have a remote yet
git remote add origin https://github.com/YOUR_USERNAME/mangaflow.git

# Or if you're using SSH
git remote add origin git@github.com:YOUR_USERNAME/mangaflow.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

**Replace `YOUR_USERNAME` with your actual GitHub username!**

## Step 3: Verify Upload

Visit your repository at:
```
https://github.com/YOUR_USERNAME/mangaflow
```

You should see:
- ✅ 45 files
- ✅ README.md displayed on homepage
- ✅ All documentation files
- ✅ Source code organized in folders

## Step 4: Configure Repository Settings (Optional)

### Add Topics

In your repository, click "⚙️ Settings" → scroll to "Topics"

Add these topics:
```
nextjs, typescript, supabase, vercel, ai, translation, ocr, manga
stripe, tesseract, claude-ai, openai, deepl
```

### Update Repository Description

Click "About" (right sidebar) and add:
- Description: `AI-powered manga translation platform with OCR, AI translation, and smart rendering`
- Website: `https://your-app.vercel.app` (after deployment)
- Topics: (add the topics above)

### Add GitHub Actions (Optional)

Create `.github/workflows/ci.yml` for automated testing:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Type check
      run: npm run type-check

    - name: Run tests
      run: npm test

    - name: Build
      run: npm run build
```

## Step 5: Create Initial Release (Optional)

1. Go to your repository
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Title: `MangaFlow v1.0.0 - Initial Release`
5. Description:
```markdown
## 🎉 MangaFlow v1.0.0

First stable release of MangaFlow - AI-powered manga translation platform.

### Features
- ✅ Batch upload (images/ZIP)
- ✅ OCR processing (Tesseract.js + Google Vision)
- ✅ AI translation (Claude, OpenAI, DeepL)
- ✅ Smart text rendering
- ✅ Content moderation
- ✅ Stripe integration
- ✅ Admin dashboard

### Tech Stack
- Next.js 14 (App Router)
- Supabase (PostgreSQL + Auth + RLS)
- Vercel (Hosting + Blob Storage)
- TypeScript

### Getting Started
See [QUICKSTART.md](./QUICKSTART.md) for setup instructions.

### Deployment
See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deployment guide.

🤖 Generated with Claude Code
```

6. Click "Publish release"

## Step 6: Protect Main Branch (Recommended)

1. Go to "Settings" → "Branches"
2. Click "Add rule"
3. Branch name pattern: `main`
4. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
5. Save changes

## Step 7: Add Collaborators (Optional)

If working with a team:

1. Go to "Settings" → "Collaborators"
2. Click "Add people"
3. Enter their GitHub username or email
4. Choose permission level (Read/Write/Admin)

## Quick Command Reference

```bash
# Check current remote
git remote -v

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/mangaflow.git

# Change remote URL (if needed)
git remote set-url origin https://github.com/YOUR_USERNAME/mangaflow.git

# Push to GitHub
git push -u origin main

# Check status
git status

# View commit history
git log --oneline

# Create new branch
git checkout -b feature/new-feature

# Push new branch
git push -u origin feature/new-feature
```

## Troubleshooting

### "remote origin already exists"

```bash
# Remove existing remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/YOUR_USERNAME/mangaflow.git
```

### Authentication Issues

If using HTTPS and prompted for password:
1. Use a Personal Access Token instead
2. Generate at: Settings → Developer settings → Personal access tokens
3. Or switch to SSH authentication

### Large File Warning

If you get warnings about large files:
```bash
# Check file sizes
find . -type f -size +50M

# Remove from git if needed
git rm --cached path/to/large/file
```

## Next Steps After Pushing

1. ✅ Code is on GitHub
2. 📝 Update README.md with your actual repository URL
3. 🚀 Connect to Vercel for automatic deployments
4. 📊 Enable GitHub Actions (if you added CI workflow)
5. 🔒 Configure branch protection rules
6. 🎉 Share your project!

## Vercel Deployment from GitHub

Once your code is on GitHub:

1. Go to https://vercel.com
2. Click "New Project"
3. Import your GitHub repository
4. Configure environment variables
5. Deploy!

Vercel will automatically:
- Build your Next.js app
- Deploy to production
- Set up automatic deployments on push
- Provide preview deployments for PRs

---

**Your repository is ready! 🎉**

Share it at: `https://github.com/YOUR_USERNAME/mangaflow`
