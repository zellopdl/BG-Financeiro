-- Extensão necessária para UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

----------------------------------------------------------
-- 1. SISTEMA_CONFIG
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sistema_config (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    chave VARCHAR(255) UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

INSERT INTO public.sistema_config (chave, valor)
VALUES ('senha_mestre', '1234')
ON CONFLICT (chave) DO NOTHING;

ALTER TABLE public.sistema_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.sistema_config FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.sistema_config FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.sistema_config FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.sistema_config FOR DELETE USING (true);


----------------------------------------------------------
-- 2. TIPOS_DOCUMENTO
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tipos_documento (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

INSERT INTO public.tipos_documento (nome) VALUES 
('Boleto'), ('Recibo'), ('Transferência'), ('Pix'), ('Dinheiro') 
ON CONFLICT (nome) DO NOTHING;

ALTER TABLE public.tipos_documento ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.tipos_documento FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.tipos_documento FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.tipos_documento FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.tipos_documento FOR DELETE USING (true);


----------------------------------------------------------
-- 3. PESSOAS (Fornecedores e Clientes)
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.pessoas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('Cliente', 'Fornecedor')),
    documento TEXT,
    cidade TEXT,
    telefone TEXT,
    whatsapp BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.pessoas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.pessoas FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.pessoas FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.pessoas FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.pessoas FOR DELETE USING (true);


----------------------------------------------------------
-- 4. COMPRAS
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.compras (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nf TEXT,
    fornecedor_id UUID REFERENCES public.pessoas(id) ON DELETE SET NULL,
    data DATE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    forma_pagamento TEXT,
    parcelas INTEGER DEFAULT 1,
    status TEXT NOT NULL,
    tipo_documento TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.compras ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.compras FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.compras FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.compras FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.compras FOR DELETE USING (true);


----------------------------------------------------------
-- 5. ITENS_COMPRA
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.itens_compra (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    compra_id UUID REFERENCES public.compras(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.itens_compra ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.itens_compra FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.itens_compra FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.itens_compra FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.itens_compra FOR DELETE USING (true);


----------------------------------------------------------
-- 6. VENDAS
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.vendas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nf TEXT,
    cliente_id UUID REFERENCES public.pessoas(id) ON DELETE SET NULL,
    data DATE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    forma_pagamento TEXT,
    parcelas INTEGER DEFAULT 1,
    status TEXT NOT NULL,
    tipo_documento TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.vendas FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.vendas FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.vendas FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.vendas FOR DELETE USING (true);


----------------------------------------------------------
-- 7. ITENS_VENDA
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.itens_venda (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    venda_id UUID REFERENCES public.vendas(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.itens_venda FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.itens_venda FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.itens_venda FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.itens_venda FOR DELETE USING (true);


----------------------------------------------------------
-- 8. CONTAS_PAGAR
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.contas_pagar (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    vencimento DATE NOT NULL,
    data_pagamento DATE,
    origem TEXT DEFAULT 'Manual',
    status TEXT NOT NULL CHECK (status IN ('Aberta', 'Paga')),
    pessoa_id UUID REFERENCES public.pessoas(id) ON DELETE SET NULL,
    categoria TEXT NOT NULL DEFAULT 'Outros',
    tipo_documento_id UUID REFERENCES public.tipos_documento(id) ON DELETE SET NULL,
    compra_id UUID REFERENCES public.compras(id) ON DELETE CASCADE,
    parcela_numero INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.contas_pagar FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.contas_pagar FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.contas_pagar FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.contas_pagar FOR DELETE USING (true);


----------------------------------------------------------
-- 9. CONTAS_RECEBER
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.contas_receber (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    vencimento DATE NOT NULL,
    data_pagamento DATE,
    origem TEXT DEFAULT 'Manual',
    status TEXT NOT NULL CHECK (status IN ('Aberta', 'Recebida')),
    pessoa_id UUID REFERENCES public.pessoas(id) ON DELETE SET NULL,
    categoria TEXT NOT NULL DEFAULT 'Outros',
    tipo_documento_id UUID REFERENCES public.tipos_documento(id) ON DELETE SET NULL,
    venda_id UUID REFERENCES public.vendas(id) ON DELETE CASCADE,
    parcela_numero INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.contas_receber FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.contas_receber FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.contas_receber FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.contas_receber FOR DELETE USING (true);


----------------------------------------------------------
-- 10. RECORRENCIAS
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.recorrencias (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('Receita', 'Despesa')),
    frequencia TEXT NOT NULL CHECK (frequencia IN ('Mensal', 'Semanal', 'Anual')),
    dia_vencimento INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Inativa')),
    pessoa_id UUID REFERENCES public.pessoas(id) ON DELETE SET NULL,
    categoria TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.recorrencias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow select for everyone" ON public.recorrencias FOR SELECT USING (true);
CREATE POLICY "Allow update for everyone" ON public.recorrencias FOR UPDATE USING (true);
CREATE POLICY "Allow insert for everyone" ON public.recorrencias FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete for everyone" ON public.recorrencias FOR DELETE USING (true);
