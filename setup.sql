-- =================================================
-- SNC 2026 Barranquilla — Supabase Database Setup
-- Ejecutar en: Dashboard → SQL Editor → New Query
-- =================================================

-- Asistentes
CREATE TABLE IF NOT EXISTS public.asistentes (
  id         uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  cedula     text    UNIQUE NOT NULL,
  nombre     text    NOT NULL,
  apellidos  text    NOT NULL DEFAULT '',
  capitulo   text    DEFAULT '',
  codigo     text    UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Jornadas
CREATE TABLE IF NOT EXISTS public.jornadas (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre     text NOT NULL,
  fecha      date NOT NULL,
  hora       time NOT NULL,
  tipo       text DEFAULT 'jornada',
  created_at timestamptz DEFAULT now()
);

-- Registros de asistencia
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

-- Multas manuales
CREATE TABLE IF NOT EXISTS public.multas_extra (
  id       uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  cedula   text NOT NULL,
  monto    integer DEFAULT 0,
  concepto text DEFAULT '',
  nota     text DEFAULT '',
  ts       timestamptz DEFAULT now()
);

-- Configuración (fila única)
CREATE TABLE IF NOT EXISTS public.config (
  id        integer PRIMARY KEY DEFAULT 1,
  multa_min integer DEFAULT 600,
  multa_kit integer DEFAULT 900,
  CONSTRAINT single_row CHECK (id = 1)
);
INSERT INTO public.config (id, multa_min, multa_kit)
VALUES (1, 600, 900) ON CONFLICT DO NOTHING;

-- ─── Row Level Security: acceso anónimo total ───
ALTER TABLE public.asistentes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jornadas     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registros    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.multas_extra ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.config       ENABLE ROW LEVEL SECURITY;

CREATE POLICY "open" ON public.asistentes   FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.jornadas     FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.registros    FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.multas_extra FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "open" ON public.config       FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

-- ─── Habilitar Realtime ───
ALTER PUBLICATION supabase_realtime ADD TABLE public.registros;
ALTER PUBLICATION supabase_realtime ADD TABLE public.asistentes;
