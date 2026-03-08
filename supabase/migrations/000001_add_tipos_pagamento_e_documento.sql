----------------------------------------------------------
-- 1. TIPOS_PAGAMENTO
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tipos_pagamento (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

INSERT INTO public.tipos_pagamento (nome) VALUES 
('Dinheiro'), ('Cheque'), ('Cartão de Crédito'), ('Débito'), ('Pix') 
ON CONFLICT (nome) DO NOTHING;

ALTER TABLE public.tipos_pagamento ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.tipos_pagamento FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.tipos_pagamento FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.tipos_pagamento FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.tipos_pagamento FOR DELETE USING (true);

----------------------------------------------------------
-- 2. ALTERAÇÕES NAS TABELAS DE LANÇAMENTOS
----------------------------------------------------------
-- Adicionando tipo_documento_id nas tabelas compras e vendas, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='compras' AND column_name='tipo_documento_id') THEN
        ALTER TABLE public.compras ADD COLUMN tipo_documento_id UUID REFERENCES public.tipos_documento(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendas' AND column_name='tipo_documento_id') THEN
        ALTER TABLE public.vendas ADD COLUMN tipo_documento_id UUID REFERENCES public.tipos_documento(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Adicionando tipo_pagamento_id nas tabelas compras, vendas, contas_pagar, contas_receber
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='compras' AND column_name='tipo_pagamento_id') THEN
        ALTER TABLE public.compras ADD COLUMN tipo_pagamento_id UUID REFERENCES public.tipos_pagamento(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendas' AND column_name='tipo_pagamento_id') THEN
        ALTER TABLE public.vendas ADD COLUMN tipo_pagamento_id UUID REFERENCES public.tipos_pagamento(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_pagar' AND column_name='tipo_pagamento_id') THEN
        ALTER TABLE public.contas_pagar ADD COLUMN tipo_pagamento_id UUID REFERENCES public.tipos_pagamento(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='tipo_pagamento_id') THEN
        ALTER TABLE public.contas_receber ADD COLUMN tipo_pagamento_id UUID REFERENCES public.tipos_pagamento(id) ON DELETE SET NULL;
    END IF;
END $$;
