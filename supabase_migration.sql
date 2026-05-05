-- ═══════════════════════════════════════════════════════════
-- ACSP 資料庫升級腳本（Migration）
-- 如果你已經跑過 supabase_setup.sql，請在 SQL Editor 跑這個
-- 如果是全新資料庫，跑 supabase_setup.sql 即可，不需要這個
-- ═══════════════════════════════════════════════════════════

-- ── 課程表：新增課程詳細頁欄位 ──
ALTER TABLE public.acsp_courses ADD COLUMN IF NOT EXISTS duration    TEXT DEFAULT '';
ALTER TABLE public.acsp_courses ADD COLUMN IF NOT EXISTS seats       TEXT DEFAULT '';
ALTER TABLE public.acsp_courses ADD COLUMN IF NOT EXISTS highlights  TEXT DEFAULT '';
ALTER TABLE public.acsp_courses ADD COLUMN IF NOT EXISTS modules     TEXT DEFAULT '';
ALTER TABLE public.acsp_courses ADD COLUMN IF NOT EXISTS audience    TEXT DEFAULT '';
ALTER TABLE public.acsp_courses ADD COLUMN IF NOT EXISTS enroll_url  TEXT DEFAULT '';

-- ── Banner 表：修正欄位名稱 img → img_url ──
-- 如果 img 欄位已存在才需要執行：
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'acsp_banners' AND column_name = 'img'
  ) THEN
    ALTER TABLE public.acsp_banners RENAME COLUMN img TO img_url;
  END IF;
END $$;

-- ── Banner 表：確保 id 欄位是 BIGINT（舊版可能是 TEXT）──
-- 注意：如果 id 已是 TEXT 且有資料，這行可能要先清空 banner 資料再跑
-- ALTER TABLE public.acsp_banners ALTER COLUMN id TYPE BIGINT USING id::BIGINT;
