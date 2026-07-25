-- =================================================
-- SNC 2026 Barranquilla — Supabase Database Setup
-- Re-ejecutable: usa IF NOT EXISTS y DROP IF EXISTS
-- =================================================

-- Tablas
CREATE TABLE IF NOT EXISTS public.asistentes (
  id         uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  cedula     text    UNIQUE NOT NULL,
  nombre     text    NOT NULL,
  apellidos  text    NOT NULL DEFAULT '',
  capitulo   text    DEFAULT '',
  codigo     text    UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.jornadas (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre     text NOT NULL,
  fecha      date NOT NULL,
  hora       time NOT NULL,
  tipo       text DEFAULT 'jornada',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.registros (
  id              uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  cedula          text NOT NULL,
  jornada_id      uuid,
  ts              timestamptz DEFAULT now(),
  minutos_retraso integer DEFAULT 0,
  multa_base      integer DEFAULT 0,
  multa_extra     integer DEFAULT 0,
  multa_total     integer DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.multas_extra (
  id       uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  cedula   text NOT NULL,
  monto    integer DEFAULT 0,
  concepto text DEFAULT '',
  nota     text DEFAULT '',
  ts       timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.config (
  id        integer PRIMARY KEY DEFAULT 1,
  multa_min integer DEFAULT 600,
  multa_kit integer DEFAULT 900,
  CONSTRAINT single_row CHECK (id = 1)
);
-- Agregar columna pin (funciona tanto en tabla nueva como existente)
ALTER TABLE public.config ADD COLUMN IF NOT EXISTS pin text DEFAULT '2026';
INSERT INTO public.config (id, multa_min, multa_kit, pin)
VALUES (1, 600, 900, '2026') ON CONFLICT DO NOTHING;
UPDATE public.config SET pin = '2026' WHERE pin IS NULL;

-- ─── Row Level Security ───
ALTER TABLE public.asistentes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jornadas     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registros    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.multas_extra ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.config       ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas previas si existen, luego recrearlas
DROP POLICY IF EXISTS "open" ON public.asistentes;
DROP POLICY IF EXISTS "open" ON public.jornadas;
DROP POLICY IF EXISTS "open" ON public.registros;
DROP POLICY IF EXISTS "open" ON public.multas_extra;
DROP POLICY IF EXISTS "open" ON public.config;

CREATE POLICY "open" ON public.asistentes   FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.jornadas     FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.registros    FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.multas_extra FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.config       FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ─── Habilitar Realtime (ignora si ya está agregada) ───
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.registros;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.asistentes;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
