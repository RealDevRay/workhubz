-- =====================================================
-- WorkHubz Supabase Schema - Hubs / Coworking Spaces
-- Run this in the Supabase SQL Editor (or via supabase CLI)
-- Requires: Postgres + PostGIS extension
-- =====================================================

-- 1. Enable PostGIS (for fast geo queries)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Core hubs table
CREATE TABLE IF NOT EXISTS public.hubs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    slug text UNIQUE,
    UNIQUE (name, neighborhood),
    description text,
    neighborhood text NOT NULL,           -- e.g. 'kilimani', 'westlands', 'cbd'
    address text,
    latitude double precision,
    longitude double precision,
    location geography(Point, 4326),      -- PostGIS geography for radius queries

    -- Pricing (simple for v1; can normalize later)
    price_hourly numeric,
    price_daily numeric,
    price_monthly numeric,
    currency text DEFAULT 'KES',

    rating numeric DEFAULT 0,
    review_count integer DEFAULT 0,
    is_verified boolean DEFAULT false,

    -- Source / freshness
    source text DEFAULT 'pipeline',       -- 'pipeline', 'manual', 'owner_claim'
    source_url text,                      -- URL the data was scraped from
    external_id text,                     -- e.g. Bing/Firecrawl source id or Google place_id
    last_scraped_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 3. Contact information (one-to-one or flexible)
CREATE TABLE IF NOT EXISTS public.hub_contacts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    hub_id uuid REFERENCES public.hubs(id) ON DELETE CASCADE UNIQUE,
    phone text,
    whatsapp text,
    email text,
    website text,
    preferred_method text,                -- 'phone' | 'whatsapp' | 'email'
    created_at timestamptz DEFAULT now()
);

-- 4. Amenities (many-to-many)
CREATE TABLE IF NOT EXISTS public.hub_amenities (
    hub_id uuid REFERENCES public.hubs(id) ON DELETE CASCADE,
    amenity_id text NOT NULL,             -- matches AmenityModel.id (wifi, parking, etc.)
    PRIMARY KEY (hub_id, amenity_id)
);

-- 5. Photos (Supabase Storage references)
CREATE TABLE IF NOT EXISTS public.hub_photos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    hub_id uuid REFERENCES public.hubs(id) ON DELETE CASCADE,
    url text NOT NULL,                    -- Supabase Storage public URL or signed
    is_primary boolean DEFAULT false,
    sort_order integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- 6. Simple scrape / pipeline audit log (optional but very useful)
CREATE TABLE IF NOT EXISTS public.hub_scrape_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    run_at timestamptz DEFAULT now(),
    source text,
    neighborhoods text[],
    hubs_found integer,
    hubs_inserted integer,
    hubs_updated integer,
    error text,
    raw_response jsonb
);

ALTER TABLE public.hub_scrape_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role can manage scrape logs" 
    ON public.hub_scrape_logs FOR ALL 
    USING (auth.role() = 'service_role');

-- =====================================================
-- Indexes (critical for performance)
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_hubs_neighborhood ON public.hubs (neighborhood);
CREATE INDEX IF NOT EXISTS idx_hubs_location ON public.hubs USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_hubs_rating ON public.hubs (rating DESC);
CREATE INDEX IF NOT EXISTS idx_hub_contacts_hub_id ON public.hub_contacts (hub_id);

-- =====================================================
-- Row Level Security (RLS) - Start restrictive
-- =====================================================
ALTER TABLE public.hubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hub_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hub_amenities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hub_photos ENABLE ROW LEVEL SECURITY;

-- Public read access (for the app using anon key)
CREATE POLICY "Public can read hubs" 
    ON public.hubs FOR SELECT 
    USING (true);

CREATE POLICY "Public can read hub_contacts" 
    ON public.hub_contacts FOR SELECT 
    USING (true);

CREATE POLICY "Public can read hub_amenities" 
    ON public.hub_amenities FOR SELECT 
    USING (true);

CREATE POLICY "Public can read hub_photos" 
    ON public.hub_photos FOR SELECT 
    USING (true);

-- Only service role (pipeline) can insert/update for now
-- (We will tighten this later when we add owner claims)
CREATE POLICY "Service role can write hubs" 
    ON public.hubs FOR ALL 
    USING (auth.role() = 'service_role');

CREATE POLICY "Service role can write contacts" 
    ON public.hub_contacts FOR ALL 
    USING (auth.role() = 'service_role');

CREATE POLICY "Service role can write amenities" 
    ON public.hub_amenities FOR ALL 
    USING (auth.role() = 'service_role');

CREATE POLICY "Service role can write photos" 
    ON public.hub_photos FOR ALL 
    USING (auth.role() = 'service_role');

-- =====================================================
-- Updated at trigger (nice to have)
-- =====================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER hubs_updated_at
    BEFORE UPDATE ON public.hubs
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- Helpful view for the app (optional but recommended)
-- =====================================================
CREATE OR REPLACE VIEW public.hubs_with_contacts AS
SELECT 
    h.*,
    c.phone,
    c.whatsapp,
    c.email,
    c.website,
    c.preferred_method
FROM public.hubs h
LEFT JOIN public.hub_contacts c ON c.hub_id = h.id;

-- =====================================================
-- 7. Bookings table (for the app)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.bookings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    space_id uuid REFERENCES public.hubs(id),
    space_name text NOT NULL,
    space_address text,
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    total_amount numeric NOT NULL,
    payment_status text DEFAULT 'pending',
    booking_status text DEFAULT 'upcoming',
    mpesa_receipt_number text,
    check_in_code text,
    checked_in_at timestamptz,
    checked_out_at timestamptz,
    is_rated boolean DEFAULT false,
    duration_hours integer DEFAULT 1,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings (booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_start ON public.bookings (start_time);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own bookings"
    ON public.bookings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own bookings"
    ON public.bookings FOR UPDATE
    USING (auth.uid() = user_id);

CREATE TRIGGER bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- Done.
-- Next: Run this script in Supabase SQL Editor, then give the pipeline the SERVICE_ROLE key.
-- =====================================================