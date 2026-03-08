-- Drop previous version if exists
DROP TABLE IF EXISTS public.recorrencias CASCADE;

CREATE TABLE public.recorrencias (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2),
    tipo TEXT NOT NULL CHECK (tipo IN ('Pagar', 'Receber')),
    periodicidade TEXT NOT NULL CHECK (periodicidade IN ('Mensal', 'Trimestral', 'Anual')),
    dia_vencimento INTEGER NOT NULL,
    ativa BOOLEAN NOT NULL DEFAULT true,
    pessoa_id UUID REFERENCES public.pessoas(id) ON DELETE SET NULL,
    categoria TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.recorrencias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.recorrencias FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.recorrencias FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.recorrencias FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.recorrencias FOR DELETE USING (true);
