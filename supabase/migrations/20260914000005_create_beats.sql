CREATE TABLE public.beats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  producer TEXT,
  producer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  price NUMERIC(10,2) NOT NULL,
  audio_url TEXT NOT NULL,
  preview_url TEXT,
  cover_url TEXT,
  bpm INTEGER,
  key TEXT,
  genre TEXT,
  available BOOLEAN NOT NULL DEFAULT true,
  plays_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.beats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view available beats"
ON public.beats FOR SELECT
TO public
USING (available = true OR public.is_admin());

CREATE POLICY "Admins can manage beats"
ON public.beats FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());
