CREATE TYPE public.track_status AS ENUM ('demo', 'recorded', 'mix_review', 'mastered');

CREATE TABLE public.tracks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  track_number INTEGER NOT NULL DEFAULT 1,
  bpm INTEGER,
  key TEXT,
  status public.track_status NOT NULL DEFAULT 'demo',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.tracks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients can view tracks from own projects"
ON public.tracks FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = tracks.project_id
      AND (p.client_id = auth.uid() OR public.is_admin())
  )
);

CREATE POLICY "Admins can manage tracks"
ON public.tracks FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());
