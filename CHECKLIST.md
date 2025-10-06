# MangaFlow - Deployment Checklist

Use this checklist to ensure all components are properly configured before going live.

## Pre-Deployment

### Local Development Setup

- [ ] Node.js 18+ installed
- [ ] Dependencies installed (`npm install`)
- [ ] `.env.local` created from `.env.example`
- [ ] All required environment variables configured
- [ ] Development server runs successfully (`npm run dev`)
- [ ] Can create an account and sign in
- [ ] Can upload test images locally

### Database Setup

- [ ] Supabase project created
- [ ] Database migration executed (`supabase/migrations/0001_init.sql`)
- [ ] All tables visible in Supabase Table Editor
- [ ] RLS policies enabled on all tables
- [ ] Auth trigger created (`handle_new_user()`)
- [ ] Test user created successfully
- [ ] Admin user role set (if needed)

### Storage Setup

- [ ] Vercel Blob storage created
- [ ] `BLOB_READ_WRITE_TOKEN` obtained
- [ ] Test upload to Blob successful
- [ ] Images accessible via public URL

### API Keys Configured

- [ ] Supabase URL and keys configured
- [ ] At least one translation provider configured:
  - [ ] Anthropic Claude API key
  - OR [ ] OpenAI API key
  - OR [ ] DeepL API key
- [ ] (Optional) Google Vision API key
- [ ] (Optional) OpenAI Moderation API key
- [ ] (Optional) Stripe API keys

### Testing

- [ ] All unit tests pass (`npm test`)
- [ ] Type checking passes (`npm run type-check`)
- [ ] Build succeeds (`npm run build`)
- [ ] Manual upload flow tested
- [ ] Manual job processing tested
- [ ] Translation output verified
- [ ] Rendered images correct

## Deployment to Vercel

### Repository Setup

- [ ] Code pushed to GitHub
- [ ] Repository is public or accessible by Vercel
- [ ] `.gitignore` excludes sensitive files
- [ ] `vercel.json` configured for cron jobs

### Vercel Project Configuration

- [ ] Project imported from GitHub
- [ ] Framework preset: Next.js
- [ ] Build command: `npm run build`
- [ ] Output directory: (default)
- [ ] Node.js version: 18.x

### Environment Variables in Vercel

**Required:**
- [ ] `NEXT_PUBLIC_SUPABASE_URL`
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- [ ] `SUPABASE_SERVICE_ROLE_KEY` (⚠️ mark as sensitive)
- [ ] `SUPABASE_PROJECT_ID`
- [ ] `BLOB_READ_WRITE_TOKEN` (⚠️ mark as sensitive)
- [ ] Translation API key (one of):
  - [ ] `ANTHROPIC_API_KEY`
  - [ ] `OPENAI_API_KEY`
  - [ ] `DEEPL_API_KEY`

**Optional but Recommended:**
- [ ] `STRIPE_SECRET_KEY`
- [ ] `STRIPE_WEBHOOK_SECRET`
- [ ] `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
- [ ] `GOOGLE_VISION_API_KEY`
- [ ] `OPENAI_MODERATION_API_KEY`
- [ ] `ADMIN_EMAILS`

**Configuration:**
- [ ] `NEXT_PUBLIC_APP_URL` (set to your Vercel URL)
- [ ] `DEFAULT_TRANSLATION_PROVIDER`
- [ ] `DEFAULT_OCR_PROVIDER`
- [ ] Plan limit variables (optional)

### Initial Deployment

- [ ] First deployment successful
- [ ] No build errors
- [ ] Deployment URL accessible
- [ ] Homepage loads correctly
- [ ] Static assets loading

## Post-Deployment Configuration

### Supabase Integration

- [ ] Site URL updated in Supabase Auth settings
- [ ] Redirect URLs configured:
  - [ ] `https://your-app.vercel.app/**`
- [ ] OAuth providers configured (if using):
  - [ ] Google OAuth redirect URL added
  - [ ] GitHub OAuth redirect URL added (if applicable)

### Stripe Configuration (if using)

- [ ] Webhook endpoint created: `/api/webhooks/stripe`
- [ ] Webhook events selected:
  - [ ] `checkout.session.completed`
  - [ ] `customer.subscription.updated`
  - [ ] `customer.subscription.deleted`
- [ ] Webhook signing secret added to Vercel env vars
- [ ] Test webhook delivery successful
- [ ] Stripe customer portal link configured

### Cron Jobs

- [ ] `vercel.json` includes cron configuration
- [ ] Cron job visible in Vercel dashboard
- [ ] First cron execution successful (check logs)
- [ ] Jobs processing correctly
- [ ] No timeout errors

### Domain Configuration (if custom domain)

- [ ] Custom domain added in Vercel
- [ ] DNS configured correctly
- [ ] SSL certificate issued
- [ ] Site accessible via custom domain
- [ ] Redirect from www working (if applicable)

## Functionality Testing (Production)

### Authentication

- [ ] Email magic link sign-up works
- [ ] Email verification received
- [ ] Sign in successful
- [ ] Session persists across page reloads
- [ ] Sign out works correctly
- [ ] (Optional) Google OAuth works

### Upload Flow

- [ ] Can access "New Project" page
- [ ] Single image upload works
- [ ] Multiple image upload works
- [ ] ZIP file upload and extraction works
- [ ] Plan limits enforced (try exceeding)
- [ ] Error handling for invalid files

### Processing Pipeline

- [ ] Jobs created after upload
- [ ] Cron job processes pending jobs
- [ ] OCR job completes successfully
- [ ] Text blocks created in database
- [ ] Translation job triggered
- [ ] Translations appear in database
- [ ] Render job completes
- [ ] Processed images uploaded to Blob
- [ ] Project status updates to 'ready'

### Content Moderation

- [ ] Low confidence blocks flagged for review
- [ ] Age gate working (if content_rating set)
- [ ] OpenAI moderation filtering (if enabled)
- [ ] Flagged content appears in review queue
- [ ] Admin can resolve review items

### User Experience

- [ ] Dashboard shows user's projects
- [ ] Project details page loads
- [ ] Page thumbnails visible
- [ ] Translation editor accessible
- [ ] Text blocks editable
- [ ] Re-render after edit works
- [ ] Online reader functional
- [ ] Export ZIP download works

### Billing (if Stripe enabled)

- [ ] Free tier limits enforced
- [ ] Upgrade flow works
- [ ] Stripe checkout successful
- [ ] Subscription status reflects in database
- [ ] Billing usage recorded
- [ ] Credits deducted correctly
- [ ] Subscription cancellation works

### Admin Features (if configured)

- [ ] Admin user can access admin routes
- [ ] Review queue visible
- [ ] Can resolve flagged items
- [ ] Reports page accessible
- [ ] Can view all projects (admin only)

## Performance & Monitoring

### Performance

- [ ] Page load time < 3s
- [ ] Images load quickly (CDN working)
- [ ] OCR processing time reasonable
- [ ] No function timeouts
- [ ] Database query performance acceptable

### Monitoring

- [ ] Vercel Analytics enabled
- [ ] Function logs accessible
- [ ] Error tracking set up (optional: Sentry)
- [ ] Database monitoring enabled in Supabase
- [ ] Slow queries identified and indexed

### Error Handling

- [ ] 404 page displays correctly
- [ ] Error boundaries catch React errors
- [ ] API errors return proper status codes
- [ ] Failed jobs retry with backoff
- [ ] User-friendly error messages shown

## Security

### Access Control

- [ ] RLS policies tested (try accessing other user's data)
- [ ] API routes verify authentication
- [ ] Service role key not exposed client-side
- [ ] No sensitive data in client bundle
- [ ] CORS configured correctly

### Content Security

- [ ] Content moderation active
- [ ] Age verification working
- [ ] No bypass mechanisms
- [ ] User reports processed
- [ ] Copyright declaration required

### Data Protection

- [ ] HTTPS enforced
- [ ] Environment variables marked sensitive
- [ ] Database backups enabled
- [ ] Blob storage access controlled
- [ ] API rate limiting (optional: implement)

## Documentation

- [ ] README.md up to date
- [ ] DEPLOYMENT.md accurate
- [ ] Environment variables documented
- [ ] API endpoints documented (if public API)
- [ ] Changelog maintained

## Legal & Compliance

- [ ] Terms of Service page
- [ ] Privacy Policy page
- [ ] Cookie consent (if in EU)
- [ ] DMCA takedown process
- [ ] Data retention policy
- [ ] User data export feature (GDPR)

## Marketing & Launch

- [ ] Landing page polished
- [ ] Demo/tutorial available
- [ ] Pricing page clear
- [ ] Support email configured
- [ ] Social media sharing working
- [ ] Analytics tracking (Google Analytics, etc.)

## Post-Launch Monitoring

### First 24 Hours

- [ ] Monitor error rates
- [ ] Check function execution times
- [ ] Verify cron jobs running
- [ ] Review user sign-ups
- [ ] Check database performance
- [ ] Monitor API costs

### First Week

- [ ] Review user feedback
- [ ] Analyze usage patterns
- [ ] Optimize slow queries
- [ ] Fix critical bugs
- [ ] Adjust rate limits if needed
- [ ] Scale resources if necessary

### Ongoing

- [ ] Weekly backup verification
- [ ] Monthly cost review
- [ ] Security updates
- [ ] Dependency updates
- [ ] Performance optimization
- [ ] Feature requests tracking

## Emergency Procedures

### Rollback Plan

- [ ] Previous deployment tagged in Git
- [ ] Know how to revert in Vercel
- [ ] Database backup before migrations
- [ ] Rollback tested in staging

### Incident Response

- [ ] Status page set up (optional)
- [ ] Emergency contacts listed
- [ ] Escalation procedure defined
- [ ] Postmortem template ready

## Sign-Off

- [ ] All critical items checked
- [ ] Team reviewed checklist
- [ ] Stakeholders approved
- [ ] Launch date scheduled
- [ ] Monitoring dashboard ready
- [ ] Support team briefed

---

**Launch Ready**: ☐ YES / ☐ NO

**Launched By**: _______________
**Date**: _______________
**Version**: _______________

---

**Notes:**

[Add any deployment-specific notes or deviations from standard procedure]
