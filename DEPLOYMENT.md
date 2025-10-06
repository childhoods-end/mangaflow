# MangaFlow Deployment Guide

Complete guide to deploying MangaFlow to Vercel with Supabase backend.

## Prerequisites

1. **Accounts**:
   - GitHub account
   - Vercel account (connected to GitHub)
   - Supabase account
   - At least one translation API key (Anthropic Claude, OpenAI, or DeepL)

2. **Tools**:
   - Node.js 18+ installed locally
   - Git installed

## Step 1: Supabase Setup

### 1.1 Create Supabase Project

1. Go to https://supabase.com
2. Click "New Project"
3. Choose organization and set:
   - Project name: `mangaflow`
   - Database password: (save this securely)
   - Region: Choose closest to your users

### 1.2 Run Database Migration

1. In your Supabase project, go to SQL Editor
2. Copy the entire contents of `supabase/migrations/0001_init.sql`
3. Paste and run the SQL
4. Verify tables were created in Table Editor

### 1.3 Configure Authentication

1. Go to Authentication > Providers
2. Enable **Email** provider (Magic Link)
3. Optional: Enable **Google** OAuth:
   - Get Client ID/Secret from Google Cloud Console
   - Add to Supabase Auth settings
   - Add redirect URL: `https://your-project.supabase.co/auth/v1/callback`

### 1.4 Get API Keys

1. Go to Project Settings > API
2. Copy these values:
   - `Project URL` → `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `service_role` key → `SUPABASE_SERVICE_ROLE_KEY` (⚠️ Keep secret!)
   - `Project ID` → `SUPABASE_PROJECT_ID`

## Step 2: Vercel Blob Setup

### 2.1 Create Blob Store

1. Go to Vercel Dashboard
2. Select your project (or create placeholder)
3. Go to Storage tab
4. Create new Blob Store
5. Copy the token → `BLOB_READ_WRITE_TOKEN`

## Step 3: Translation API Setup

Choose at least one provider:

### Option A: Anthropic Claude (Recommended)

1. Go to https://console.anthropic.com
2. Create API key
3. Copy key → `ANTHROPIC_API_KEY`

### Option B: OpenAI

1. Go to https://platform.openai.com
2. Create API key
3. Copy key → `OPENAI_API_KEY`

### Option C: DeepL

1. Go to https://www.deepl.com/pro-api
2. Sign up for API access
3. Copy key → `DEEPL_API_KEY`

## Step 4: Optional Services

### Stripe (for billing)

1. Go to https://stripe.com
2. Get API keys:
   - `STRIPE_SECRET_KEY`
   - `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
3. Set up webhook endpoint (after deployment)
4. Copy webhook secret → `STRIPE_WEBHOOK_SECRET`

### Google Vision (advanced OCR)

1. Go to Google Cloud Console
2. Enable Vision API
3. Create API key → `GOOGLE_VISION_API_KEY`

### OpenAI Moderation

1. Use same OpenAI account
2. Copy API key → `OPENAI_MODERATION_API_KEY`

## Step 5: Deploy to Vercel

### 5.1 Push to GitHub

```bash
cd mangaflow
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/mangaflow.git
git push -u origin main
```

### 5.2 Import to Vercel

1. Go to https://vercel.com
2. Click "New Project"
3. Import your GitHub repository
4. Configure project:
   - Framework Preset: Next.js
   - Root Directory: `./` (or `./mangaflow` if nested)
   - Build Command: `npm run build`
   - Output Directory: (leave default)

### 5.3 Add Environment Variables

In Vercel project settings > Environment Variables, add:

**Required:**
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhb...
SUPABASE_SERVICE_ROLE_KEY=eyJhb... (⚠️ sensitive!)
SUPABASE_PROJECT_ID=xxx
BLOB_READ_WRITE_TOKEN=vercel_blob_rw_...
ANTHROPIC_API_KEY=sk-ant-... (or OPENAI_API_KEY or DEEPL_API_KEY)
```

**Optional:**
```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
GOOGLE_VISION_API_KEY=AIza...
OPENAI_MODERATION_API_KEY=sk-...
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-...
NEXT_PUBLIC_ADSENSE_ENABLED=false
```

**Configuration:**
```env
NEXT_PUBLIC_APP_URL=https://your-app.vercel.app
DEFAULT_TRANSLATION_PROVIDER=claude
DEFAULT_OCR_PROVIDER=tesseract
FREE_TIER_MAX_PROJECTS=3
FREE_TIER_MAX_PAGES_PER_PROJECT=50
FREE_TIER_MAX_CONCURRENT_JOBS=2
ADMIN_EMAILS=admin@example.com
```

### 5.4 Deploy

Click "Deploy" - Vercel will build and deploy your app.

## Step 6: Configure Cron Jobs

### 6.1 Create vercel.json

In your project root, create `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/jobs/process",
      "schedule": "*/5 * * * *"
    }
  ]
}
```

This runs job processing every 5 minutes.

### 6.2 Commit and Redeploy

```bash
git add vercel.json
git commit -m "Add cron job for background processing"
git push
```

Vercel will automatically redeploy.

## Step 7: Post-Deployment Configuration

### 7.1 Update Supabase Redirect URLs

1. In Supabase > Authentication > URL Configuration
2. Add your Vercel domain:
   - Site URL: `https://your-app.vercel.app`
   - Redirect URLs: `https://your-app.vercel.app/**`

### 7.2 Configure Stripe Webhooks

If using Stripe:

1. Go to Stripe Dashboard > Developers > Webhooks
2. Add endpoint: `https://your-app.vercel.app/api/webhooks/stripe`
3. Select events:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
4. Copy webhook signing secret to `STRIPE_WEBHOOK_SECRET`

### 7.3 Create Admin User

1. Sign up through your app
2. In Supabase SQL Editor, run:
   ```sql
   UPDATE profiles
   SET role = 'admin'
   WHERE email = 'your-admin@email.com';
   ```

## Step 8: Testing

### 8.1 Test Upload Flow

1. Visit `https://your-app.vercel.app`
2. Sign in
3. Create new project
4. Upload test images
5. Verify:
   - Images appear in Vercel Blob dashboard
   - Project appears in Supabase `projects` table
   - Jobs created in `jobs` table

### 8.2 Test Background Processing

1. Wait 5 minutes for cron job
2. Check Vercel Functions logs
3. Verify job state changes in Supabase
4. Check for OCR text in `text_blocks` table

### 8.3 Test Translation

1. Ensure OCR jobs complete
2. Create translation job manually if needed
3. Verify translated text appears

## Troubleshooting

### Build Failures

**Error: Missing environment variables**
- Solution: Add all required env vars in Vercel settings

**Error: Module not found**
- Solution: Check package.json dependencies
- Run `npm install` locally first

### Runtime Errors

**Error: Supabase connection failed**
- Check `SUPABASE_URL` and `ANON_KEY` are correct
- Verify RLS policies allow access

**Error: Blob upload failed**
- Verify `BLOB_READ_WRITE_TOKEN` is set
- Check Vercel Blob quota

**Error: OCR timeout**
- Tesseract can be slow on large images
- Consider increasing function timeout
- Or switch to Google Vision API

**Error: Translation API error**
- Verify API key is valid
- Check API quota/billing
- Review API error message in logs

### Performance Issues

**Slow OCR processing**
- Reduce image resolution before processing
- Use Google Vision API instead of Tesseract
- Increase concurrent job limit

**High Vercel costs**
- Optimize image sizes
- Cache rendered results
- Implement rate limiting

## Monitoring

### Vercel Analytics

1. Enable Vercel Analytics in project settings
2. Monitor function execution times
3. Track errors and warnings

### Supabase Monitoring

1. Go to Database > Query Performance
2. Monitor slow queries
3. Check connection pool usage

### Custom Logging

- All operations log via pino logger
- View logs in Vercel Functions dashboard
- Filter by severity level

## Scaling Considerations

### Database

- Supabase free tier: 500MB database, 2GB bandwidth
- Upgrade to Pro for better performance
- Add database indexes for frequently queried fields

### Storage

- Vercel Blob pricing: $0.15/GB stored, $0.30/GB transferred
- Implement image compression
- Delete old projects to save space

### Compute

- Free tier: 100GB-hours function execution
- Optimize OCR/translation batch sizes
- Consider dedicated background workers for Pro plan

### Queue System

For production, upgrade from basic queue to:
- **Vercel Queue** (native integration)
- **Upstash Redis Queue** (more features)
- **AWS SQS** or **Google Cloud Tasks**

## Security Checklist

- ✅ Never expose `SUPABASE_SERVICE_ROLE_KEY` client-side
- ✅ All tables have RLS policies enabled
- ✅ API routes validate user authentication
- ✅ Content moderation is enforced
- ✅ Rate limiting implemented for uploads
- ✅ Stripe webhooks verify signatures
- ✅ HTTPS everywhere (handled by Vercel)
- ✅ Environment variables marked as sensitive

## Backup & Recovery

### Database Backups

Supabase provides:
- Daily backups (last 7 days on free tier)
- Point-in-time recovery on Pro tier

### Blob Storage

Vercel Blob:
- No built-in backup
- Implement custom backup script if needed
- Or use Vercel Pro backup features

## Cost Estimation

**Minimum Monthly Cost (excluding usage):**
- Vercel: $0 (Hobby tier)
- Supabase: $0 (Free tier)
- **Total: $0/month + usage costs**

**Recommended Monthly Cost:**
- Vercel Pro: $20/month
- Supabase Pro: $25/month
- Translation API: ~$10-50/month (depending on usage)
- **Total: ~$55-95/month**

## Support

For deployment issues:
- Vercel: https://vercel.com/support
- Supabase: https://supabase.com/support
- MangaFlow Issues: https://github.com/YOUR_USERNAME/mangaflow/issues

---

**Congratulations! Your MangaFlow instance is now live! 🎉**
