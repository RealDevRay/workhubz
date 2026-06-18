-- =====================================================
-- WorkHubz Supabase Schema - User Profiles
-- Run AFTER 001_hubs.sql
-- =====================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name text,
    avatar_url text,
    email text,
    phone text,
    preferred_neighborhood text,
    dark_mode boolean DEFAULT false,
    notifications_enabled boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can create own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.email),
        NEW.raw_user_meta_data ->> 'avatar_url',
        NEW.email
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Saved spaces (wishlist)
CREATE TABLE IF NOT EXISTS public.saved_spaces (
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    hub_id uuid REFERENCES public.hubs(id) ON DELETE CASCADE,
    saved_at timestamptz DEFAULT now(),
    PRIMARY KEY (user_id, hub_id)
);

ALTER TABLE public.saved_spaces ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own saved spaces"
    ON public.saved_spaces FOR ALL
    USING (auth.uid() = user_id);

-- Bookings already exists in 001_hubs.sql

-- Reviews for spaces
CREATE TABLE IF NOT EXISTS public.reviews (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    hub_id uuid REFERENCES public.hubs(id) ON DELETE CASCADE,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment text,
    created_at timestamptz DEFAULT now(),
    UNIQUE (hub_id, user_id)
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read reviews"
    ON public.reviews FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can create reviews"
    ON public.reviews FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own reviews"
    ON public.reviews FOR UPDATE
    USING (auth.uid() = user_id);

-- Payments / transactions log
CREATE TABLE IF NOT EXISTS public.payments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id uuid REFERENCES public.bookings(id) ON DELETE SET NULL,
    user_id uuid NOT NULL,
    amount numeric NOT NULL,
    currency text DEFAULT 'KES',
    payment_method text DEFAULT 'mpesa',
    mpesa_receipt_number text,
    mpesa_checkout_request_id text,
    status text DEFAULT 'pending',
    created_at timestamptz DEFAULT now()
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own payments"
    ON public.payments FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage payments"
    ON public.payments FOR ALL
    USING (auth.role() = 'service_role');

-- Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles (email);
CREATE INDEX IF NOT EXISTS idx_saved_spaces_user ON public.saved_spaces (user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_hub ON public.reviews (hub_id);
CREATE INDEX IF NOT EXISTS idx_payments_user ON public.payments (user_id);
CREATE INDEX IF NOT EXISTS idx_payments_booking ON public.payments (booking_id);
