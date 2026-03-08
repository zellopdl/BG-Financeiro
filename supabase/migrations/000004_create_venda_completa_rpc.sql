-- Criacao atomica de venda com itens e parcelas (contas a receber)
create or replace function public.create_venda_completa(
  p_nf text,
  p_cliente_id uuid,
  p_data date,
  p_parcelas integer,
  p_status text,
  p_tipo_documento_id uuid default null,
  p_tipo_pagamento_id uuid default null,
  p_items jsonb default '[]'::jsonb,
  p_vencimentos jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security invoker
as $$
declare
  v_venda_id uuid;
  v_item jsonb;
  v_vencimento jsonb;
  v_total numeric(12,2);
  v_item_total numeric(12,2);
  v_qtd numeric(12,3);
  v_unit numeric(12,2);
  v_desc text;
  v_valor_parcela numeric(12,2);
  v_data_vencimento date;
  v_data_pagamento date;
  v_index integer := 0;
begin
  if coalesce(trim(p_nf), '') = '' then
    raise exception 'NF e obrigatoria';
  end if;

  if p_cliente_id is null then
    raise exception 'Cliente e obrigatorio';
  end if;

  if p_data is null then
    raise exception 'Data da venda e obrigatoria';
  end if;

  if p_parcelas is null or p_parcelas < 1 then
    raise exception 'Parcelas deve ser >= 1';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Adicione pelo menos um item';
  end if;

  if p_vencimentos is null or jsonb_typeof(p_vencimentos) <> 'array' or jsonb_array_length(p_vencimentos) <> p_parcelas then
    raise exception 'Quantidade de vencimentos deve ser igual ao numero de parcelas';
  end if;

  v_total := 0;
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_desc := coalesce(trim(v_item->>'descricao'), '');
    v_qtd := coalesce((v_item->>'quantidade')::numeric, 0);
    v_unit := coalesce((v_item->>'valor_unitario')::numeric, 0);
    v_item_total := coalesce((v_item->>'valor_total')::numeric, 0);

    if v_desc = '' then
      raise exception 'Item com descricao vazia';
    end if;

    if v_qtd <= 0 then
      raise exception 'Item com quantidade invalida';
    end if;

    if v_unit < 0 then
      raise exception 'Item com valor unitario invalido';
    end if;

    if v_item_total < 0 then
      raise exception 'Item com valor total invalido';
    end if;

    v_total := v_total + v_item_total;
  end loop;

  if v_total <= 0 then
    raise exception 'Total da venda deve ser maior que zero';
  end if;

  insert into public.vendas (
    nf,
    cliente_id,
    data,
    valor,
    parcelas,
    status,
    tipo_documento_id,
    tipo_pagamento_id
  ) values (
    trim(p_nf),
    p_cliente_id,
    p_data,
    v_total,
    p_parcelas,
    coalesce(nullif(trim(p_status), ''), 'Lançada'),
    p_tipo_documento_id,
    p_tipo_pagamento_id
  )
  returning id into v_venda_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    insert into public.itens_venda (
      venda_id,
      descricao,
      quantidade,
      valor_unitario,
      valor_total
    ) values (
      v_venda_id,
      trim(v_item->>'descricao'),
      (v_item->>'quantidade')::numeric,
      (v_item->>'valor_unitario')::numeric,
      (v_item->>'valor_total')::numeric
    );
  end loop;

  for v_vencimento in select * from jsonb_array_elements(p_vencimentos)
  loop
    v_index := v_index + 1;
    v_data_vencimento := (v_vencimento->>'vencimento')::date;
    v_data_pagamento := nullif(v_vencimento->>'data_pagamento', '')::date;
    v_valor_parcela := coalesce((v_vencimento->>'valor')::numeric, 0);

    if v_data_vencimento is null then
      raise exception 'Vencimento da parcela % nao informado', v_index;
    end if;

    if v_valor_parcela <= 0 then
      raise exception 'Valor da parcela % invalido', v_index;
    end if;

    insert into public.contas_receber (
      descricao,
      valor,
      vencimento,
      data_pagamento,
      origem,
      venda_id,
      parcela_numero,
      status,
      tipo_documento_id,
      tipo_pagamento_id
    ) values (
      format('Parcela %s/%s - NF %s', v_index, p_parcelas, trim(p_nf)),
      v_valor_parcela,
      v_data_vencimento,
      v_data_pagamento,
      trim(p_nf),
      v_venda_id,
      v_index,
      'Aberta',
      p_tipo_documento_id,
      p_tipo_pagamento_id
    );
  end loop;

  return v_venda_id;
end;
$$;
