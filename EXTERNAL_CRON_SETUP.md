# External Cron Service Setup Guide

Since Vercel Hobby plan limits cron jobs to once per day, we'll use a free external cron service to trigger job processing every 5 minutes.

## 🎯 Recommended Service: cron-job.org

**Why cron-job.org?**
- ✅ Completely free
- ✅ Supports intervals down to 1 minute
- ✅ Reliable and well-maintained
- ✅ Email notifications on failures
- ✅ Execution history and logs
- ✅ No credit card required

## 📝 Step-by-Step Setup

### Step 1: Get Your Vercel Deployment URL

After deploying to Vercel, you'll get a URL like:
```
https://mangaflow-xxx.vercel.app
```

Or your custom domain:
```
https://mangaflow.yourdomain.com
```

### Step 2: Create cron-job.org Account

1. Visit https://cron-job.org/en/
2. Click "Sign up" (top right)
3. Enter your email and create password
4. Verify your email address
5. Log in to dashboard

### Step 3: Create a Cron Job

1. In the dashboard, click **"Create cronjob"**

2. **Title**: `MangaFlow Job Processor`

3. **URL**: `https://your-app.vercel.app/api/jobs/process`
   - Replace `your-app.vercel.app` with your actual Vercel URL

4. **Schedule**:
   - Select **"Every 5 minutes"**
   - Or use custom: `*/5 * * * *`

5. **Request method**: `POST`

6. **Request settings** (click "Advanced"):
   - **Request timeout**: `60 seconds`
   - **Request headers** (optional - for security):
     ```
     X-Cron-Key: your-secret-key-here
     ```

7. **Notification settings**:
   - ✅ Enable "Notify on failure"
   - Set your email

8. **Save settings**

9. Click **"Create cronjob"**

### Step 4: Secure the Endpoint (Recommended)

Add authentication to prevent unauthorized access to your job processor.

#### Option A: Simple Secret Key (Quick)

Add this environment variable in Vercel:
```env
CRON_SECRET_KEY=your-random-secret-key-here
```

Update the API route to check for this key:

```typescript
// app/api/jobs/process/route.ts
export async function POST(request: NextRequest) {
  // Verify cron secret
  const cronKey = request.headers.get('x-cron-key')
  if (cronKey !== process.env.CRON_SECRET_KEY) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // ... rest of the code
}
```

Then in cron-job.org, add the header:
```
X-Cron-Key: your-random-secret-key-here
```

#### Option B: Vercel Cron Secret (More Secure)

Vercel provides automatic cron authentication. Update your route:

```typescript
import { verifySignature } from '@vercel/cron'

export async function POST(request: NextRequest) {
  const isValid = await verifySignature(request)
  if (!isValid) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 401 })
  }
  // ... rest
}
```

### Step 5: Test the Setup

1. In cron-job.org dashboard, find your job
2. Click **"Run now"** (play button)
3. Check execution log - should show `200 OK`
4. Verify in your Vercel Function logs that the endpoint was called

### Step 6: Monitor Execution

**In cron-job.org:**
- View execution history
- Check success/failure status
- See response times
- Review error logs

**In Vercel:**
- Go to your project → Functions
- Click on `/api/jobs/process`
- View invocation logs
- Check for errors

## 🔄 Alternative Free Cron Services

### Option 2: EasyCron

**Free tier**:
- 30 cron jobs
- 1-minute intervals
- Unlimited executions

**Setup**:
1. Visit https://www.easycron.com/user/register
2. Verify email
3. Create cron job:
   - URL: `https://your-app.vercel.app/api/jobs/process`
   - Cron expression: `*/5 * * * *`
   - HTTP method: POST

### Option 3: Render Cron Jobs

**If you also deploy a service on Render**:
- Free tier includes cron jobs
- Can trigger external URLs
- Reliable and simple

### Option 4: UptimeRobot (Creative Solution)

**Not a cron service, but works**:
- Free website monitoring
- Can ping URLs every 5 minutes
- Side effect: triggers your endpoint

**Setup**:
1. Visit https://uptimerobot.com
2. Add new monitor:
   - Type: HTTP(s)
   - URL: `https://your-app.vercel.app/api/jobs/process`
   - Monitoring interval: 5 minutes

**Caveat**: Uses GET by default (you'd need to modify your API to accept GET)

## 🔒 Security Best Practices

### 1. Rate Limiting

Add rate limiting to prevent abuse:

```typescript
import { Ratelimit } from '@upstash/ratelimit'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(12, '1 h'), // 12 requests per hour
})

export async function POST(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1'
  const { success } = await ratelimit.limit(ip)

  if (!success) {
    return NextResponse.json({ error: 'Too many requests' }, { status: 429 })
  }
  // ... rest
}
```

### 2. IP Whitelist (Advanced)

Only allow requests from known IPs:

```typescript
const ALLOWED_IPS = ['cron-job.org-ip-here']

export async function POST(request: NextRequest) {
  const ip = request.ip
  if (!ALLOWED_IPS.includes(ip)) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }
  // ... rest
}
```

### 3. Logging and Monitoring

Log all cron executions:

```typescript
import logger from '@/lib/logger'

export async function POST(request: NextRequest) {
  logger.info({
    source: 'external-cron',
    ip: request.ip,
    headers: Object.fromEntries(request.headers),
  }, 'Cron job triggered')

  // ... process jobs

  logger.info({ processed: results.length }, 'Cron job completed')
}
```

## 📊 Monitoring Dashboard

Create a simple status page to monitor cron health:

```typescript
// app/api/jobs/status/route.ts
export async function GET() {
  const { data: jobs } = await supabaseAdmin
    .from('jobs')
    .select('state, job_type, updated_at')
    .order('updated_at', { ascending: false })
    .limit(100)

  const stats = {
    pending: jobs.filter(j => j.state === 'pending').length,
    running: jobs.filter(j => j.state === 'running').length,
    done: jobs.filter(j => j.state === 'done').length,
    failed: jobs.filter(j => j.state === 'failed').length,
    lastProcessed: jobs[0]?.updated_at,
  }

  return NextResponse.json(stats)
}
```

Visit: `https://your-app.vercel.app/api/jobs/status`

## 🐛 Troubleshooting

### Cron not triggering

1. **Check URL is correct**
   - Must be full HTTPS URL
   - Must include `/api/jobs/process`

2. **Verify POST method**
   - Some services default to GET
   - Change to POST

3. **Check response codes**
   - 200 = Success
   - 401 = Authentication failed
   - 500 = Server error

### Jobs not processing

1. **Check Vercel logs**
   - Functions → `/api/jobs/process`
   - Look for errors

2. **Verify database connection**
   - Check Supabase is accessible
   - Verify environment variables

3. **Check job queue**
   - Query database: `SELECT * FROM jobs WHERE state = 'pending'`
   - Should have pending jobs

### High costs/usage

1. **Reduce frequency**
   - Change to every 10 or 15 minutes
   - Still much better than 6 hours

2. **Add processing limits**
   - Limit jobs per execution
   - Currently: `.limit(10)`

## 📈 Recommended Configuration

**For Development**:
- Frequency: Every 15 minutes
- Security: Secret key header
- Monitoring: Email on failure

**For Production**:
- Frequency: Every 5 minutes
- Security: Secret key + rate limiting
- Monitoring: Email alerts + status dashboard
- Backup: Second cron service as failover

## 🔄 Migration from Vercel Cron

We've already removed the Vercel cron configuration from `vercel.json`. No further action needed on Vercel side.

## ✅ Quick Setup Checklist

- [ ] Deploy app to Vercel and get URL
- [ ] Sign up for cron-job.org
- [ ] Create cron job with your Vercel URL
- [ ] Set interval to 5 minutes
- [ ] Set method to POST
- [ ] Add secret key header (optional but recommended)
- [ ] Add CRON_SECRET_KEY to Vercel environment variables
- [ ] Test with "Run now" button
- [ ] Verify in Vercel function logs
- [ ] Enable failure notifications
- [ ] Monitor first few executions

---

**Setup complete! Your jobs will now process every 5 minutes automatically.** 🎉

## 📞 Support

If cron-job.org has issues:
- **Status**: https://status.cron-job.org/
- **Support**: support@cron-job.org
- **Community**: https://cron-job.org/en/forum/

For MangaFlow issues:
- Check Vercel function logs
- Review Supabase database
- Monitor job execution history
