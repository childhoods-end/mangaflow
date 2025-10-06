# MangaFlow Architecture

This document describes the technical architecture and design decisions for MangaFlow.

## System Overview

MangaFlow is a serverless SaaS application built on the Vercel + Supabase stack, providing automated manga translation through a multi-stage processing pipeline.

```
┌─────────────┐
│   Browser   │
│  (Next.js)  │
└──────┬──────┘
       │
       ├─ API Routes (Next.js)
       │  ├─ /api/upload
       │  ├─ /api/projects/*
       │  └─ /api/jobs/process
       │
       ├─ Supabase (Auth + DB + RLS)
       │  └─ PostgreSQL Database
       │
       ├─ Vercel Blob (Storage)
       │  ├─ Original images
       │  ├─ Rendered images
       │  └─ Thumbnails
       │
       └─ External APIs
          ├─ Claude/OpenAI/DeepL (Translation)
          ├─ Tesseract.js/Google Vision (OCR)
          └─ OpenAI Moderation (Content Policy)
```

## Key Design Decisions

### 1. Database: Supabase vs Prisma

**Decision**: Use Supabase directly with SQL migrations instead of Prisma ORM.

**Rationale**:
- **Row Level Security (RLS)**: Supabase RLS provides database-level security that works seamlessly with authentication
- **Real-time subscriptions**: Native support for live updates (future feature)
- **Built-in auth**: Integrated authentication eliminates need for separate auth service
- **Simplified deployment**: No need to run migrations separately
- **Direct SQL control**: Better performance optimization and complex queries
- **Edge compatibility**: Supabase client works in Edge Runtime

**Trade-offs**:
- Manual type generation (using `supabase gen types`)
- No automatic schema validation
- More verbose queries compared to Prisma's fluent API

### 2. Storage: Vercel Blob

**Decision**: Use Vercel Blob for all image storage.

**Rationale**:
- **Zero configuration**: Automatic CDN distribution
- **Native integration**: Works seamlessly with Vercel functions
- **Cost-effective**: Pay-per-use pricing
- **Fast uploads**: Direct from API routes
- **Global distribution**: Automatic edge caching

**Alternatives considered**:
- **S3**: More complex setup, requires signed URLs
- **Supabase Storage**: Adds dependency, quota limitations on free tier

### 3. Queue System: Simplified Custom Queue

**Decision**: Implement basic queue using Supabase jobs table + Vercel Cron.

**Rationale**:
- **Simplicity**: No additional services required
- **Cost**: Free tier friendly
- **Sufficient for MVP**: Handles moderate load
- **Easy to upgrade**: Can swap for Vercel Queue or Upstash later

**Future migration path**:
```typescript
// Current: lib/queue/index.ts
// Future: Swap with Vercel Queue
import { Queue } from '@vercel/queue'
```

### 4. OCR: Tesseract.js + Optional Google Vision

**Decision**: Default to Tesseract.js with pluggable Google Vision.

**Rationale**:
- **Cost**: Tesseract is free, Google Vision is paid
- **Privacy**: Tesseract runs locally, no data sent to Google
- **Flexibility**: Users can upgrade to Vision for better accuracy
- **Multi-language**: Both support Japanese/Chinese/Korean

**Performance**:
- Tesseract: ~3-5 seconds per page (CPU-bound)
- Google Vision: ~0.5-1 second per page (API latency)

### 5. Translation: Multi-Provider Strategy

**Decision**: Support Claude, OpenAI, and DeepL with hot-swappable providers.

**Rationale**:
- **Flexibility**: Different models for different use cases
- **Cost optimization**: Users can choose based on budget
- **Fallback**: If one API fails, can switch to another
- **Quality**: Claude excels at context-aware translation

**Provider comparison**:
| Provider | Cost/1M tokens | Quality | Speed | Context window |
|----------|---------------|---------|-------|----------------|
| Claude 3.5 | $3/$15 | ⭐⭐⭐⭐⭐ | Fast | 200k |
| GPT-4o | $5/$15 | ⭐⭐⭐⭐ | Fast | 128k |
| DeepL | $25/500k chars | ⭐⭐⭐ | Very fast | N/A |

### 6. Rendering: Server-side SVG Compositing

**Decision**: Use Sharp + SVG overlay for text rendering.

**Rationale**:
- **Quality**: Vector text remains crisp at any zoom level
- **Performance**: Sharp is highly optimized C++ library
- **Flexibility**: Easy to adjust fonts, colors, positioning
- **Server-side**: No client-side computation needed

**Alternative considered**:
- **Canvas API**: Would require browser or headless browser
- **Image editing libraries**: Less flexible for text

## Data Flow

### Upload Flow

```
User uploads images/ZIP
       ↓
POST /api/upload
       ↓
Check user plan limits
       ↓
Create project record (Supabase)
       ↓
For each image:
  - Get dimensions (Sharp)
  - Upload to Blob
  - Create page record
  - Create OCR job
       ↓
Return project ID
```

### Processing Pipeline

```
Cron triggers /api/jobs/process (every 5 min)
       ↓
Fetch pending jobs (state='pending')
       ↓
For each job:
  ┌─ OCR Job ──────────────────┐
  │ 1. Fetch image from Blob   │
  │ 2. Run Tesseract.js        │
  │ 3. Extract text blocks     │
  │ 4. Store in text_blocks    │
  │ 5. Flag low confidence     │
  │ 6. Create translate job    │
  └────────────────────────────┘
       ↓
  ┌─ Translate Job ────────────┐
  │ 1. Batch text blocks       │
  │ 2. Call translation API    │
  │ 3. Run moderation check    │
  │ 4. Update text_blocks      │
  │ 5. Create render jobs      │
  └────────────────────────────┘
       ↓
  ┌─ Render Job ───────────────┐
  │ 1. Fetch original image    │
  │ 2. Generate SVG overlay    │
  │ 3. Composite with Sharp    │
  │ 4. Upload to Blob          │
  │ 5. Update page record      │
  └────────────────────────────┘
       ↓
Project status → 'ready'
```

## Security Architecture

### Multi-Layer Authorization

```
1. Network Layer (HTTPS)
   ↓
2. Authentication (Supabase Auth)
   - Email Magic Link
   - OAuth (Google)
   ↓
3. Row Level Security (RLS)
   - Database-level access control
   - Automatic per-query filtering
   ↓
4. API Route Validation
   - Verify JWT token
   - Check user plan limits
   ↓
5. Business Logic Guards
   - Content rating checks
   - Age verification
   - Moderation gateway
```

### RLS Policy Examples

**Projects Table**:
```sql
-- Users can only read their own projects
CREATE POLICY "Users can read own projects"
  ON projects FOR SELECT
  USING (owner_id = auth.uid());

-- Admins can read all projects
CREATE POLICY "Admins can read all projects"
  ON projects FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Secret Management

- **Client-side**: Only `NEXT_PUBLIC_*` variables exposed
- **Server-side**: API keys stored in Vercel environment
- **Service role**: Used ONLY in server contexts, never exposed
- **Rotation**: All secrets can be rotated without code changes

## Content Moderation

### Three-Layer Approach

```
1. Keyword Filter (Fast, Local)
   - Regex-based pattern matching
   - Immediate blocking
   ↓
2. Age Gate (Fast, Database)
   - Check content_rating vs user age
   - Enforced at view time
   ↓
3. AI Moderation (Slow, External API)
   - OpenAI Moderation API
   - Scores: 0.0-1.0 per category
   - Actions:
     * < 0.5: Allow
     * 0.5-0.8: Mask (••• text)
     * > 0.8: Block + flag for review
```

**Important**: No bypass mechanisms. All flagged content goes to admin review queue.

## Performance Optimizations

### Database

- **Indexes**: Added on frequently queried columns (`owner_id`, `status`, `created_at`)
- **Cascading deletes**: `ON DELETE CASCADE` reduces cleanup queries
- **JSONB**: Used for flexible metadata without schema migrations
- **Connection pooling**: Handled by Supabase (default 15 connections)

### Image Processing

- **Lazy thumbnail generation**: Created during OCR, not upload
- **Format optimization**: JPEG for photos, PNG for text
- **Dimension checks**: Reject overly large images
- **Sharp optimization**: Use libvips for fast operations

### API Routes

- **Parallel processing**: Upload pages concurrently
- **Batch translation**: Group text blocks (default 20/batch)
- **Edge runtime**: Where possible (auth checks)
- **Streaming**: Not implemented yet (future optimization)

## Scalability Considerations

### Current Limits (Free Tier)

- **Supabase**:
  - 500 MB database
  - 1 GB file storage
  - 2 GB bandwidth/month
  - 50,000 monthly active users

- **Vercel**:
  - 100 GB-hours compute
  - 1 GB Blob storage
  - 100 GB bandwidth

### Scale-Up Path

**Phase 1: Optimize existing** (0-1k users)
- Add Redis caching (Upstash)
- Implement edge caching for images
- Optimize OCR batch sizes

**Phase 2: Upgrade services** (1k-10k users)
- Supabase Pro ($25/mo)
- Vercel Pro ($20/mo)
- Increase function memory/timeout

**Phase 3: Dedicated infrastructure** (10k+ users)
- Separate OCR workers (Fly.io, Railway)
- Replace cron with Vercel Queue
- CDN for Blob storage (Cloudflare R2)
- Database read replicas

## Testing Strategy

### Unit Tests

- OCR module (`lib/ocr`)
- Translation providers (`lib/translate`)
- Moderation gateway (`lib/moderation`)
- Rendering engine (`lib/render`)

### Integration Tests

- API routes with mock Supabase
- Queue processing with test jobs
- End-to-end upload flow

### Manual Testing Checklist

- [ ] Upload single image
- [ ] Upload ZIP file
- [ ] Process OCR job
- [ ] Translate text
- [ ] Render translated image
- [ ] Export project
- [ ] Delete project (cascade)
- [ ] Test RLS policies (try accessing other user's data)
- [ ] Test moderation (upload flagged content)
- [ ] Test plan limits (exceed quota)

## Monitoring & Observability

### Application Logging

```typescript
import logger from '@/lib/logger'

logger.info({ projectId, pageCount }, 'Upload completed')
logger.error({ error, jobId }, 'Job processing failed')
```

### Key Metrics to Track

- **Upload success rate**: `uploads_succeeded / uploads_total`
- **OCR accuracy**: `avg(text_blocks.confidence)`
- **Translation cost**: `sum(billing_usage.amount_cents)`
- **Job latency**: Time from `created_at` to `done`
- **Error rate**: `jobs.state='failed' / jobs.total`

### Alerts

Recommended Vercel alerts:
- Function timeout > 30 seconds
- Error rate > 5%
- Blob storage > 80% quota

## Future Enhancements

### Planned Features

1. **Real-time progress updates**: Supabase subscriptions
2. **Collaborative editing**: Multi-user projects
3. **Custom fonts**: Upload .ttf files
4. **Batch export**: Download multiple projects
5. **API access**: Public API for programmatic access
6. **Webhook notifications**: Project completion alerts

### Technical Debt

- Replace simplified queue with Vercel Queue
- Add request rate limiting (Upstash Rate Limit)
- Implement caching layer for frequently accessed projects
- Add comprehensive error tracking (Sentry)
- Create admin dashboard UI (currently database-only)

## Contributing

See `CONTRIBUTING.md` for:
- Code style guidelines
- Testing requirements
- Pull request process
- Development environment setup

---

**Last Updated**: 2025-01-10
**Version**: 1.0.0
