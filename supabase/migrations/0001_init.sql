-- MangaFlow Database Schema with Row Level Security

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
  credits INTEGER DEFAULT 100,
  age_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for efficient lookups
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_role ON profiles(role);

-- ============================================================================
-- PROJECTS TABLE
-- ============================================================================
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'ready', 'failed')),
  source_language TEXT DEFAULT 'ja',
  target_language TEXT DEFAULT 'en',
  total_pages INTEGER DEFAULT 0,
  processed_pages INTEGER DEFAULT 0,
  content_rating TEXT DEFAULT 'general' CHECK (content_rating IN ('general', 'teen', 'mature', 'explicit')),
  rights_declaration TEXT, -- User's copyright declaration
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_projects_owner ON projects(owner_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);

-- ============================================================================
-- PAGES TABLE
-- ============================================================================
CREATE TABLE pages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  page_index INTEGER NOT NULL,
  width INTEGER NOT NULL,
  height INTEGER NOT NULL,
  original_blob_url TEXT NOT NULL,
  processed_blob_url TEXT,
  thumbnail_blob_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, page_index)
);

-- Indexes
CREATE INDEX idx_pages_project ON pages(project_id, page_index);

-- ============================================================================
-- TEXT_BLOCKS TABLE
-- ============================================================================
CREATE TABLE text_blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  page_id UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  bbox JSONB NOT NULL, -- {x, y, width, height, rotation}
  ocr_text TEXT,
  translated_text TEXT,
  confidence FLOAT DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'ocr_done', 'translated', 'reviewed', 'flagged')),
  font_family TEXT DEFAULT 'manga',
  font_size INTEGER DEFAULT 14,
  text_align TEXT DEFAULT 'center',
  is_vertical BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_text_blocks_page ON text_blocks(page_id);
CREATE INDEX idx_text_blocks_status ON text_blocks(status);

-- ============================================================================
-- JOBS TABLE
-- ============================================================================
CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  job_type TEXT NOT NULL CHECK (job_type IN ('ocr', 'translate', 'render', 'export')),
  state TEXT NOT NULL DEFAULT 'pending' CHECK (state IN ('pending', 'running', 'done', 'failed')),
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  last_error TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_jobs_project ON jobs(project_id);
CREATE INDEX idx_jobs_state ON jobs(state);
CREATE INDEX idx_jobs_type_state ON jobs(job_type, state);

-- ============================================================================
-- REVIEW_ITEMS TABLE
-- ============================================================================
CREATE TABLE review_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  text_block_id UUID NOT NULL REFERENCES text_blocks(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (reason IN ('low_conf', 'policy_flag', 'user_report')),
  resolved BOOLEAN DEFAULT FALSE,
  reviewer_id UUID REFERENCES profiles(id),
  reviewer_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_review_items_resolved ON review_items(resolved);
CREATE INDEX idx_review_items_created_at ON review_items(created_at DESC);

-- ============================================================================
-- BILLING_USAGE TABLE
-- ============================================================================
CREATE TABLE billing_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  tokens INTEGER DEFAULT 0,
  pages INTEGER DEFAULT 0,
  amount_cents INTEGER DEFAULT 0,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_billing_usage_user ON billing_usage(user_id, created_at DESC);
CREATE INDEX idx_billing_usage_project ON billing_usage(project_id);

-- ============================================================================
-- REPORTS TABLE (for user content reporting)
-- ============================================================================
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES profiles(id),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
  resolved_by UUID REFERENCES profiles(id),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_project ON reports(project_id);

-- ============================================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE text_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PROFILES POLICIES
-- ============================================================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile (except role and plan)
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Admins can read all profiles
CREATE POLICY "Admins can read all profiles"
  ON profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Allow insert during signup (via trigger from auth.users)
CREATE POLICY "Allow profile creation"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- PROJECTS POLICIES
-- ============================================================================

-- Users can read their own projects
CREATE POLICY "Users can read own projects"
  ON projects FOR SELECT
  USING (owner_id = auth.uid());

-- Users can create projects
CREATE POLICY "Users can create projects"
  ON projects FOR INSERT
  WITH CHECK (owner_id = auth.uid());

-- Users can update their own projects
CREATE POLICY "Users can update own projects"
  ON projects FOR UPDATE
  USING (owner_id = auth.uid());

-- Users can delete their own projects
CREATE POLICY "Users can delete own projects"
  ON projects FOR DELETE
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

-- ============================================================================
-- PAGES POLICIES
-- ============================================================================

-- Users can read pages from their own projects
CREATE POLICY "Users can read own project pages"
  ON pages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM projects
      WHERE projects.id = pages.project_id
      AND projects.owner_id = auth.uid()
    )
  );

-- Users can insert pages to their own projects
CREATE POLICY "Users can insert own project pages"
  ON pages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects
      WHERE projects.id = pages.project_id
      AND projects.owner_id = auth.uid()
    )
  );

-- ============================================================================
-- TEXT_BLOCKS POLICIES
-- ============================================================================

-- Users can read text blocks from their own projects
CREATE POLICY "Users can read own text blocks"
  ON text_blocks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pages
      JOIN projects ON projects.id = pages.project_id
      WHERE pages.id = text_blocks.page_id
      AND projects.owner_id = auth.uid()
    )
  );

-- Users can update text blocks in their own projects
CREATE POLICY "Users can update own text blocks"
  ON text_blocks FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM pages
      JOIN projects ON projects.id = pages.project_id
      WHERE pages.id = text_blocks.page_id
      AND projects.owner_id = auth.uid()
    )
  );

-- ============================================================================
-- JOBS POLICIES
-- ============================================================================

-- Users can read jobs for their own projects
CREATE POLICY "Users can read own jobs"
  ON jobs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM projects
      WHERE projects.id = jobs.project_id
      AND projects.owner_id = auth.uid()
    )
  );

-- ============================================================================
-- REVIEW_ITEMS POLICIES
-- ============================================================================

-- Users can read review items for their own content
CREATE POLICY "Users can read own review items"
  ON review_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM text_blocks
      JOIN pages ON pages.id = text_blocks.page_id
      JOIN projects ON projects.id = pages.project_id
      WHERE text_blocks.id = review_items.text_block_id
      AND projects.owner_id = auth.uid()
    )
  );

-- Admins can read all review items
CREATE POLICY "Admins can read all review items"
  ON review_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Admins can update review items
CREATE POLICY "Admins can update review items"
  ON review_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- BILLING_USAGE POLICIES
-- ============================================================================

-- Users can read their own billing usage
CREATE POLICY "Users can read own billing usage"
  ON billing_usage FOR SELECT
  USING (user_id = auth.uid());

-- Admins can read all billing usage
CREATE POLICY "Admins can read all billing usage"
  ON billing_usage FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- REPORTS POLICIES
-- ============================================================================

-- Anyone can create a report
CREATE POLICY "Anyone can create reports"
  ON reports FOR INSERT
  WITH CHECK (true);

-- Users can read their own reports
CREATE POLICY "Users can read own reports"
  ON reports FOR SELECT
  USING (reporter_id = auth.uid());

-- Admins can read all reports
CREATE POLICY "Admins can read all reports"
  ON reports FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Admins can update reports
CREATE POLICY "Admins can update reports"
  ON reports FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, plan, credits)
  VALUES (
    NEW.id,
    NEW.email,
    'user',
    'free',
    100
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on auth.users insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_text_blocks_updated_at BEFORE UPDATE ON text_blocks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
