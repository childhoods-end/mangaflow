# MangaFlow Quick Start

Get MangaFlow running locally in under 10 minutes.

## Prerequisites

- Node.js 18+ ([Download](https://nodejs.org/))
- A Supabase account ([Sign up](https://supabase.com))
- At least one translation API key (see below)

## Step 1: Clone and Install

```bash
cd mangaflow
npm install
```

## Step 2: Get API Keys

### Supabase (Required)

1. Create project at https://supabase.com
2. Go to Project Settings → API
3. Copy:
   - Project URL
   - `anon` public key
   - `service_role` key

### Translation Provider (Choose one)

**Option A: Anthropic Claude** (Recommended)
```bash
# Get key at https://console.anthropic.com
ANTHROPIC_API_KEY=sk-ant-...
```

**Option B: OpenAI**
```bash
# Get key at https://platform.openai.com
OPENAI_API_KEY=sk-...
```

**Option C: DeepL**
```bash
# Get key at https://www.deepl.com/pro-api
DEEPL_API_KEY=...
```

### Vercel Blob (Required for uploads)

```bash
# Create at https://vercel.com/dashboard/stores
BLOB_READ_WRITE_TOKEN=vercel_blob_rw_...
```

## Step 3: Configure Environment

Create `.env.local`:

```bash
cp .env.example .env.local
```

Edit `.env.local` with your keys:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbG...
SUPABASE_SERVICE_ROLE_KEY=eyJhbG...

# Vercel Blob
BLOB_READ_WRITE_TOKEN=vercel_blob_rw_...

# Translation (choose one)
ANTHROPIC_API_KEY=sk-ant-...
# OR
OPENAI_API_KEY=sk-...
# OR
DEEPL_API_KEY=...

# Optional
DEFAULT_TRANSLATION_PROVIDER=claude
```

## Step 4: Setup Database

1. Go to Supabase SQL Editor
2. Copy entire contents of `supabase/migrations/0001_init.sql`
3. Paste and click "RUN"
4. Verify tables created in Table Editor

## Step 5: Run Development Server

```bash
npm run dev
```

Open http://localhost:3000

## Step 6: Create Account

1. Click "Sign In"
2. Enter your email
3. Check email for magic link
4. Click link to verify

## Step 7: Upload Test Project

1. Click "Get Started" → "New Project"
2. Upload 1-3 manga page images
3. Set:
   - Title: "Test Project"
   - Source: Japanese
   - Target: English
4. Click "Upload"

## Step 8: Process Jobs (Manual)

Since cron jobs don't run locally, manually trigger processing:

```bash
# In another terminal
curl -X POST http://localhost:3000/api/jobs/process
```

Run this 3 times (once for OCR, once for translation, once for render).

## Step 9: View Results

1. Go to Dashboard
2. Click on your project
3. View processed pages with translations

## Troubleshooting

### "Supabase connection failed"

- Double-check URL and keys in `.env.local`
- Ensure migration was run successfully
- Check Supabase project is active

### "Upload failed"

- Verify `BLOB_READ_WRITE_TOKEN` is set
- Check Vercel Blob storage is created
- Ensure images are valid format (JPG/PNG)

### "OCR not working"

- Wait 30 seconds for Tesseract to download language files
- Check browser console for errors
- Try smaller images first

### "Translation failed"

- Verify API key is correct
- Check API quota/billing is active
- Review error in Vercel Function logs

## Next Steps

- Read [README.md](./README.md) for full features
- See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deploy
- Check [ARCHITECTURE.md](./ARCHITECTURE.md) for technical details

## Development Commands

```bash
# Start dev server
npm run dev

# Run tests
npm test

# Type checking
npm run type-check

# Build for production
npm run build

# Start production server
npm start
```

## Common Development Tasks

### Add new shadcn component

```bash
npx shadcn@latest add button
npx shadcn@latest add dialog
```

### Generate Supabase types

```bash
# Set project ID first
export SUPABASE_PROJECT_ID=xxx
npm run supabase:types
```

### Run specific test

```bash
npm test -- ocr.test.ts
```

### Clear Vercel Blob storage

```bash
# Install Vercel CLI
npm i -g vercel

# List blobs
vercel blob list

# Delete all (careful!)
vercel blob delete --all
```

## Tips

1. **Use small images first**: Start with 800x1200px images
2. **Check logs often**: Vercel Function logs show detailed errors
3. **Monitor API usage**: Translation APIs can get expensive
4. **Test incrementally**: Upload → OCR → Translate → Render

## Getting Help

- GitHub Issues: [Your repo]/issues
- Supabase Docs: https://supabase.com/docs
- Vercel Docs: https://vercel.com/docs
- Discord: [Your community server]

---

**Happy translating! 🚀**
