-- MangaFlow Demo Data Seed Script
-- Run this in Supabase SQL Editor to create demo data for testing

-- Note: This assumes you have already created a user account
-- Replace 'YOUR_USER_ID' with your actual user ID from auth.users

-- 1. Create demo admin user (optional)
-- First, sign up through the app, then run this to make yourself an admin:
-- UPDATE profiles SET role = 'admin' WHERE email = 'your-email@example.com';

-- 2. Create a demo project
INSERT INTO projects (
  id,
  owner_id,
  title,
  status,
  source_language,
  target_language,
  total_pages,
  processed_pages,
  content_rating,
  rights_declaration,
  metadata
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'YOUR_USER_ID', -- Replace with your actual user ID
  'Demo Manga Project',
  'ready',
  'ja',
  'en',
  3,
  3,
  'general',
  'This is a demo project for testing purposes.',
  '{"description": "Sample manga translation project"}'::jsonb
);

-- 3. Create demo pages
INSERT INTO pages (
  id,
  project_id,
  page_index,
  width,
  height,
  original_blob_url,
  processed_blob_url,
  thumbnail_blob_url
) VALUES
(
  '00000000-0000-0000-0000-000000000011',
  '00000000-0000-0000-0000-000000000001',
  0,
  1200,
  1800,
  'https://example.com/placeholder-page-1.jpg',
  'https://example.com/placeholder-page-1-processed.png',
  'https://example.com/placeholder-page-1-thumb.jpg'
),
(
  '00000000-0000-0000-0000-000000000012',
  '00000000-0000-0000-0000-000000000001',
  1,
  1200,
  1800,
  'https://example.com/placeholder-page-2.jpg',
  'https://example.com/placeholder-page-2-processed.png',
  'https://example.com/placeholder-page-2-thumb.jpg'
),
(
  '00000000-0000-0000-0000-000000000013',
  '00000000-0000-0000-0000-000000000001',
  2,
  1200,
  1800,
  'https://example.com/placeholder-page-3.jpg',
  'https://example.com/placeholder-page-3-processed.png',
  'https://example.com/placeholder-page-3-thumb.jpg'
);

-- 4. Create demo text blocks
INSERT INTO text_blocks (
  id,
  page_id,
  bbox,
  ocr_text,
  translated_text,
  confidence,
  status,
  font_family,
  font_size,
  text_align,
  is_vertical
) VALUES
(
  '00000000-0000-0000-0000-000000000021',
  '00000000-0000-0000-0000-000000000011',
  '{"x": 100, "y": 150, "width": 300, "height": 80, "rotation": 0}'::jsonb,
  'こんにちは',
  'Hello',
  0.95,
  'translated',
  'Arial',
  18,
  'center',
  false
),
(
  '00000000-0000-0000-0000-000000000022',
  '00000000-0000-0000-0000-000000000011',
  '{"x": 500, "y": 300, "width": 250, "height": 100, "rotation": 0}'::jsonb,
  'いい天気ですね',
  'Nice weather, isn''t it?',
  0.88,
  'translated',
  'Arial',
  16,
  'center',
  false
),
(
  '00000000-0000-0000-0000-000000000023',
  '00000000-0000-0000-0000-000000000012',
  '{"x": 200, "y": 200, "width": 280, "height": 70, "rotation": 0}'::jsonb,
  'ありがとう',
  'Thank you',
  0.92,
  'translated',
  'Arial',
  20,
  'center',
  false
);

-- 5. Create demo jobs (completed)
INSERT INTO jobs (
  id,
  project_id,
  job_type,
  state,
  attempts,
  metadata
) VALUES
(
  '00000000-0000-0000-0000-000000000031',
  '00000000-0000-0000-0000-000000000001',
  'ocr',
  'done',
  1,
  '{"pages_processed": 3}'::jsonb
),
(
  '00000000-0000-0000-0000-000000000032',
  '00000000-0000-0000-0000-000000000001',
  'translate',
  'done',
  1,
  '{"blocks_translated": 3, "provider": "claude"}'::jsonb
),
(
  '00000000-0000-0000-0000-000000000033',
  '00000000-0000-0000-0000-000000000001',
  'render',
  'done',
  1,
  '{"pages_rendered": 3}'::jsonb
);

-- 6. Create a demo review item (low confidence)
INSERT INTO review_items (
  id,
  text_block_id,
  reason,
  resolved,
  reviewer_notes
) VALUES (
  '00000000-0000-0000-0000-000000000041',
  '00000000-0000-0000-0000-000000000022',
  'low_conf',
  false,
  NULL
);

-- 7. Create demo billing usage
INSERT INTO billing_usage (
  id,
  user_id,
  project_id,
  tokens,
  pages,
  amount_cents,
  description
) VALUES (
  '00000000-0000-0000-0000-000000000051',
  'YOUR_USER_ID', -- Replace with your actual user ID
  '00000000-0000-0000-0000-000000000001',
  1500,
  3,
  15,
  'Demo project translation'
);

-- Verify the data was created
SELECT
  'Projects' as table_name,
  COUNT(*) as count
FROM projects
WHERE id = '00000000-0000-0000-0000-000000000001'
UNION ALL
SELECT 'Pages', COUNT(*)
FROM pages
WHERE project_id = '00000000-0000-0000-0000-000000000001'
UNION ALL
SELECT 'Text Blocks', COUNT(*)
FROM text_blocks
WHERE page_id IN (
  SELECT id FROM pages
  WHERE project_id = '00000000-0000-0000-0000-000000000001'
)
UNION ALL
SELECT 'Jobs', COUNT(*)
FROM jobs
WHERE project_id = '00000000-0000-0000-0000-000000000001'
UNION ALL
SELECT 'Review Items', COUNT(*)
FROM review_items
WHERE text_block_id IN (
  SELECT id FROM text_blocks
  WHERE page_id IN (
    SELECT id FROM pages
    WHERE project_id = '00000000-0000-0000-0000-000000000001'
  )
);

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Demo data created successfully!';
  RAISE NOTICE '📝 Remember to replace YOUR_USER_ID with your actual user ID';
  RAISE NOTICE '🔍 Query: SELECT id FROM auth.users WHERE email = ''your-email@example.com'';';
END $$;
