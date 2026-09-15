CREATE TYPE public.file_type AS ENUM ('multitrack', 'stem', 'rough_mix', 'master', 'reference');

CREATE TABLE public.files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  track_id UUID REFERENCES public.tracks(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_size BIGINT,
  mime_type TEXT,
  file_type public.file_type NOT NULL DEFAULT 'stem',
  version INTEGER NOT NULL DEFAULT 1,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients can view files from own projects"
ON public.files FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = files.project_id
      AND (p.client_id = auth.uid() OR public.is_admin())
  )
);

CREATE POLICY "Admins can manage files"
ON public.files FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());
