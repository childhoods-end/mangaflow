# MangaFlow

AI-powered manga translation platform built with Next.js 14, Supabase, and Vercel.

## Features

- 📖 **Batch Upload**: Upload folders or ZIP files containing multiple manga pages
- 🔍 **OCR Processing**: Extract text from manga panels using Tesseract.js or Google Vision
- 🌐 **AI Translation**: Translate using Claude, GPT-4, or DeepL
- ✏️ **Visual Editor**: Edit translations with bounding box adjustments
- 🎨 **Smart Rendering**: Render translated text over original images with customizable fonts
- 🛡️ **Content Moderation**: Multi-layer content filtering and age-gating
- 💳 **Stripe Integration**: Subscription management and usage-based billing
- 📊 **Admin Dashboard**: Review flagged content and manage reports

## Tech Stack

- **Framework**: Next.js 14 (App Router) + TypeScript
- **Database & Auth**: Supabase (PostgreSQL + Row Level Security)
- **Storage**: Vercel Blob
- **Queue**: Simplified queue system (upgradeable to Vercel Queue/Upstash)
- **OCR**: Tesseract.js (with optional Google Vision)
- **Translation**: Claude API, OpenAI, DeepL
- **UI**: Tailwind CSS + shadcn/ui
- **Testing**: Jest + React Testing Library

## Project Structure

```
mangaflow/
├── app/                      # Next.js app directory
│   ├── api/                  # API routes
│   │   ├── upload/           # Upload endpoint
│   │   ├── projects/         # Project CRUD
│   │   └── jobs/             # Job processing
│   ├── dashboard/            # User dashboard
│   ├── projects/             # Project pages
│   └── page.tsx              # Homepage
├── lib/                      # Core libraries
│   ├── ocr/                  # OCR providers
│   ├── translate/            # Translation providers
│   ├── render/               # Rendering engine
│   ├── moderation/           # Content moderation
│   ├── queue/                # Job queue system
│   └── supabase/             # Supabase clients
├── components/               # React components
│   └── ui/                   # shadcn/ui components
├── supabase/
│   └── migrations/           # Database migrations
└── __tests__/                # Test files
```

## Setup

### 1. Prerequisites

- Node.js 18+
- Supabase account
- Vercel account (for deployment)
- API keys for translation providers (Anthropic, OpenAI, or DeepL)

### 2. Install Dependencies

```bash
cd mangaflow
npm install
```

### 3. Environment Variables

Copy `.env.example` to `.env.local` and fill in your credentials:

```bash
cp .env.example .env.local
```

Required variables:
- `NEXT_PUBLIC_SUPABASE_URL`: Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase anonymous key
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase service role key (server-side only)
- `BLOB_READ_WRITE_TOKEN`: Vercel Blob storage token
- `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` or `DEEPL_API_KEY`: Translation API key

Optional:
- `STRIPE_SECRET_KEY`: For billing
- `GOOGLE_VISION_API_KEY`: For Google Vision OCR
- `OPENAI_MODERATION_API_KEY`: For content moderation

### 4. Database Setup

Run the migration in your Supabase SQL editor:

```bash
# Copy contents of supabase/migrations/0001_init.sql
# and run in Supabase SQL Editor
```

Or use Supabase CLI:

```bash
npx supabase db push
```

### 5. Run Development Server

```bash
npm run dev
```

Visit http://localhost:3000

## Deployment

### Vercel Deployment

1. Push your code to GitHub

2. Connect to Vercel:
   ```bash
   vercel
   ```

3. Configure environment variables in Vercel dashboard

4. Set up Cron Job for background processing:
   - Create `vercel.json`:
     ```json
     {
       "crons": [{
         "path": "/api/jobs/process",
         "schedule": "*/5 * * * *"
       }]
     }
     ```

5. Deploy:
   ```bash
   vercel --prod
   ```

## Usage

### Creating a Project

1. Sign in with your Supabase account
2. Click "New Project"
3. Upload manga pages (images or ZIP)
4. Set source/target languages
5. Declare content rating and rights
6. Submit and wait for processing

### Processing Pipeline

1. **Upload**: Images uploaded to Vercel Blob
2. **OCR**: Text extracted from each page
3. **Translation**: Text blocks translated via AI
4. **Moderation**: Content checked for policy compliance
5. **Render**: Translated text rendered over images
6. **Export**: Download as ZIP or read online

### Editing Translations

1. Navigate to project page
2. Click on a page thumbnail
3. Select text blocks to edit
4. Adjust text, position, or font
5. Re-render the page

## API Reference

### POST /api/upload

Upload manga pages

**Body** (multipart/form-data):
- `title`: Project title
- `files`: Image files or ZIP
- `sourceLang`: Source language code
- `targetLang`: Target language code
- `contentRating`: general | teen | mature | explicit
- `rightsDeclaration`: User's rights statement

**Response**:
```json
{
  "projectId": "uuid",
  "pageCount": 10
}
```

### GET /api/projects/:id

Get project details including all pages

### PATCH /api/projects/:id

Update project metadata

### DELETE /api/projects/:id

Delete project and all associated data

### POST /api/jobs/process

Process pending jobs (triggered by cron)

## Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Type checking
npm run type-check
```

## Content Policy

MangaFlow includes built-in content moderation:

1. **Keyword Filter**: Blocks prohibited terms
2. **Age Gate**: Enforces age restrictions based on content rating
3. **AI Moderation**: Optional integration with OpenAI Moderation API
4. **Manual Review**: Admins can review flagged content

**Important**: This system enforces policies and does not provide any bypass mechanisms.

## Billing & Plans

- **Free**: 3 projects, 50 pages/project, 100 credits/month
- **Pro ($19/mo)**: 50 projects, 500 pages/project, 1000 credits/month
- **Enterprise**: Unlimited, custom pricing

Credits are consumed by:
- OCR processing
- Translation tokens
- Rendering operations

## Admin Features

Admins (configured via `ADMIN_EMAILS`) can:
- View all projects
- Review flagged content
- Manage user reports
- Adjust user quotas
- Access analytics

## License

MIT License - See LICENSE file for details

## Support

For issues and feature requests, please use GitHub Issues.

---

Built with ❤️ using Next.js, Supabase, and AI
