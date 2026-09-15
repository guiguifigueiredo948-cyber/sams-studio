-- Grade de horários e disponibilidade
CREATE TABLE public.availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.availability ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active availability"
ON public.availability FOR SELECT
TO public
USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins and producers can manage availability"
ON public.availability FOR ALL
TO authenticated
USING (public.is_admin() OR (producer_id = auth.uid()))
WITH CHECK (public.is_admin() OR (producer_id = auth.uid()));
