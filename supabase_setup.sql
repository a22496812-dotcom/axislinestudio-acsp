-- ═══════════════════════════════════════════════════════════
-- ACSP 軸心線工作室 — Supabase 資料庫初始化腳本
-- 在 Supabase SQL Editor 貼上全部內容後按 Run
-- ═══════════════════════════════════════════════════════════

-- ── 課程表 ──
CREATE TABLE IF NOT EXISTS public.acsp_courses (
  id          BIGINT PRIMARY KEY,
  name        TEXT    NOT NULL DEFAULT '',
  sub         TEXT    DEFAULT '',
  type        TEXT    DEFAULT '實體課程',
  type_class  TEXT    DEFAULT 'gold',
  price       TEXT    DEFAULT 'TBD',
  orig_price  TEXT    DEFAULT '',
  status      TEXT    DEFAULT '草稿',
  status_class TEXT   DEFAULT 'amber',
  date        TEXT    DEFAULT '',
  location    TEXT    DEFAULT '',
  description TEXT    DEFAULT '',
  cover_img   TEXT    DEFAULT '',
  banner_img  TEXT    DEFAULT '',
  link        TEXT    DEFAULT 'course.html',
  sort_order  INT     DEFAULT 0,
  -- 課程詳細頁欄位
  duration    TEXT    DEFAULT '',
  seats       TEXT    DEFAULT '',
  highlights  TEXT    DEFAULT '',
  modules     TEXT    DEFAULT '',
  audience    TEXT    DEFAULT '',
  enroll_url  TEXT    DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Banner 表 ──
CREATE TABLE IF NOT EXISTS public.acsp_banners (
  id          BIGINT  PRIMARY KEY,
  title       TEXT    DEFAULT '',
  img_url     TEXT    DEFAULT '',
  link        TEXT    DEFAULT '',
  is_visible  BOOLEAN DEFAULT true,
  sort_order  INT     DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── 常見問題表 ──
CREATE TABLE IF NOT EXISTS public.acsp_faqs (
  id          TEXT    PRIMARY KEY,
  question    TEXT    NOT NULL DEFAULT '',
  answer      TEXT    DEFAULT '',
  is_visible  BOOLEAN DEFAULT true,
  sort_order  INT     DEFAULT 0
);

-- ── 學員評價表 ──
CREATE TABLE IF NOT EXISTS public.acsp_reviews (
  id          TEXT    PRIMARY KEY,
  author      TEXT    DEFAULT '',
  role        TEXT    DEFAULT '',
  body        TEXT    DEFAULT '',
  stars       INT     DEFAULT 5,
  is_visible  BOOLEAN DEFAULT true,
  sort_order  INT     DEFAULT 0
);

-- ── 文章表 ──
CREATE TABLE IF NOT EXISTS public.acsp_articles (
  id          BIGSERIAL   PRIMARY KEY,
  title       TEXT        DEFAULT '',
  subtitle    TEXT        DEFAULT '',
  summary     TEXT        DEFAULT '',
  content     TEXT        DEFAULT '',
  cover_img   TEXT        DEFAULT '',
  category    TEXT        DEFAULT '知識文章',
  visibility  TEXT        DEFAULT 'public',
  status      TEXT        DEFAULT '草稿',
  tags        TEXT        DEFAULT '',
  sort_order  INT         DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── ACSP 測驗結果表 ──
CREATE TABLE IF NOT EXISTS public.acsp_results (
  id               BIGSERIAL   PRIMARY KEY,
  name             TEXT        DEFAULT '',
  email            TEXT        DEFAULT '',
  role             TEXT        DEFAULT '',
  dominant         TEXT        DEFAULT '',
  secondary        TEXT        DEFAULT '',
  dominant_display TEXT        DEFAULT '',
  tie_type         TEXT        DEFAULT 'none',
  top_tied         TEXT        DEFAULT '[]',
  pct_a            INT         DEFAULT 0,
  pct_c            INT         DEFAULT 0,
  pct_s            INT         DEFAULT 0,
  pct_p            INT         DEFAULT 0,
  source           TEXT        DEFAULT '前台測驗',
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ── 開放公開讀取 + anon 寫入（後台用） ──
ALTER TABLE public.acsp_courses  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acsp_banners  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acsp_faqs     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acsp_reviews  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acsp_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.acsp_results  ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_courses"  ON public.acsp_courses  FOR SELECT USING (true);
CREATE POLICY "public_read_banners"  ON public.acsp_banners  FOR SELECT USING (true);
CREATE POLICY "public_read_faqs"     ON public.acsp_faqs     FOR SELECT USING (true);
CREATE POLICY "public_read_reviews"  ON public.acsp_reviews  FOR SELECT USING (true);
CREATE POLICY "public_read_articles" ON public.acsp_articles FOR SELECT USING (true);
CREATE POLICY "public_read_results"  ON public.acsp_results  FOR SELECT USING (true);

CREATE POLICY "anon_write_courses"   ON public.acsp_courses  FOR ALL    USING (true) WITH CHECK (true);
CREATE POLICY "anon_write_banners"   ON public.acsp_banners  FOR ALL    USING (true) WITH CHECK (true);
CREATE POLICY "anon_write_faqs"      ON public.acsp_faqs     FOR ALL    USING (true) WITH CHECK (true);
CREATE POLICY "anon_write_reviews"   ON public.acsp_reviews  FOR ALL    USING (true) WITH CHECK (true);
CREATE POLICY "anon_write_articles"  ON public.acsp_articles FOR ALL    USING (true) WITH CHECK (true);
CREATE POLICY "anon_write_results"   ON public.acsp_results  FOR ALL    USING (true) WITH CHECK (true);

-- ── 圖片儲存桶（Storage Bucket）──
-- 說明：這段需要在 Storage 頁面手動建立（或用以下 SQL）
INSERT INTO storage.buckets (id, name, public)
VALUES ('acsp-images', 'acsp-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "public_read_storage"  ON storage.objects FOR SELECT USING (bucket_id = 'acsp-images');
CREATE POLICY "anon_upload_storage"  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'acsp-images');
CREATE POLICY "anon_update_storage"  ON storage.objects FOR UPDATE USING (bucket_id = 'acsp-images');
CREATE POLICY "anon_delete_storage"  ON storage.objects FOR DELETE USING (bucket_id = 'acsp-images');

-- ── 預設常見問題資料 ──
INSERT INTO public.acsp_faqs (id, question, answer, is_visible, sort_order) VALUES
  ('f1', '這個測驗和 MBTI 或 DISC 有什麼不同？',
   'ACSP 四型溝通風格框架專注於「溝通行為」而非廣泛的人格特質，更強調實際互動中的應用策略。相比 MBTI 或 DISC，ACSP 的報告提供更具體的場景化建議，幫助你在真實的溝通情境中立即應用。',
   true, 1),
  ('f2', '完成測驗需要多長時間？',
   '測驗問卷約需 15–20 分鐘完成。完整課程（含測驗解讀與應用模組）總計約 5 小時，可依自己的步調自由安排。',
   true, 2),
  ('f3', '我會得到什麼樣的測驗報告？',
   '完成測驗後，你將獲得一份個人化的 ACSP 四型分佈報告，包含主導風格分析、溝通優勢、潛在盲點，以及針對職場、關係等場景的具體建議。',
   true, 3),
  ('f4', '課程可以團體報名嗎？',
   '是的！我們提供企業團體方案，適合 5 人以上的團隊。團報方案包含專屬的「團隊溝通地圖」報告，協助主管了解整體團隊的風格組成與最佳協作策略。請聯繫我們獲取報價。',
   true, 4)
ON CONFLICT (id) DO NOTHING;

-- ── 預設學員評價資料 ──
INSERT INTO public.acsp_reviews (id, author, role, body, stars, is_visible, sort_order) VALUES
  ('r1', '林雅婷', '行銷經理', '透過 ACSP 測驗，我終於理解為什麼和某些同事溝通總是特別費力。課程給了我非常具體的應對策略，不是那種「要多理解對方」的空話，而是真的可以馬上用的方法。', 5, true, 1),
  ('r2', '陳建宏', '創業者', '我是個典型的控制型，以前常覺得別人效率太低。上完課才發現，不是別人慢，是我沒有用對方聽得進去的方式說話。這個洞察對我的團隊管理幫助很大。', 5, true, 2),
  ('r3', '王淑芬', '人資主管', '我們全團隊一起上了企業工作坊，做完團隊溝通地圖之後，才發現我們部門幾乎都是支持型和推廣型，難怪執行力一直是弱點。現在我們在招募時也會參考 ACSP 的分析。', 5, true, 3)
ON CONFLICT (id) DO NOTHING;
