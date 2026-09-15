CREATE TYPE public.project_type AS ENUM ('single', 'ep', 'album', 'beatpack');
CREATE TYPE public.project_status AS ENUM ('pre_production', 'recording', 'mixing', 'mastering', 'completed');

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  producer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  type public.project_type NOT NULL DEFAULT 'single',
  status public.project_status NOT NULL DEFAULT 'pre_production',
  deadline DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients can view own projects"
ON public.projects FOR SELECT
TO authenticated
USING (client_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can manage projects"
ON public.projects FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());
