CREATE TYPE public.order_product_type AS ENUM ('beat', 'service', 'booking');
CREATE TYPE public.order_payment_status AS ENUM ('pending', 'paid', 'cancelled', 'refunded');

CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  client_name TEXT,
  client_phone TEXT,
  product_type public.order_product_type NOT NULL,
  product_id UUID NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  payment_status public.order_payment_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients can view own orders"
ON public.orders FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Anyone can insert an order"
ON public.orders FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Admins can manage orders"
ON public.orders FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());
