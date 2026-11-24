-- Fliperamada TI — esquema inicial para Supabase/Postgres.
-- Execute no SQL Editor de um projeto novo. Não contém nenhuma chave secreta.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null default '',
  full_name text not null default '',
  role text not null default 'cashier' check (role in ('admin', 'manager', 'cashier', 'technician')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.employee_details (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  cpf text,
  position text not null default '',
  phone text,
  admitted_at date,
  base_salary numeric(12,2) check (base_salary is null or base_salary >= 0)
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  tax_id text,
  contact text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in ('Fichas', 'Bebidas', 'Snacks')),
  price numeric(12,2) not null check (price >= 0),
  stock_qty integer not null default 0 check (stock_qty >= 0),
  stock_min integer not null default 0 check (stock_min >= 0),
  unit_cost numeric(12,2) not null default 0 check (unit_cost >= 0),
  sku text unique,
  icon_key text not null default 'inventory_2',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.machines (
  id uuid primary key default gen_random_uuid(),
  game_name text not null,
  asset_number text not null unique,
  acquired_at date,
  status text not null default 'active' check (status in ('active', 'maintenance', 'inactive')),
  maintenance_count integer not null default 0 check (maintenance_count >= 0),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.maintenance_records (
  id uuid primary key default gen_random_uuid(),
  machine_id uuid not null references public.machines(id),
  created_by uuid not null references public.profiles(id),
  description text not null,
  parts jsonb not null default '[]'::jsonb,
  occurred_at timestamptz not null default now()
);

create table if not exists public.cash_sessions (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.profiles(id),
  opened_at timestamptz not null default now(),
  opening_float numeric(12,2) not null check (opening_float >= 0),
  closed_at timestamptz,
  expected_by_method jsonb,
  counted_by_method jsonb,
  difference numeric(12,2),
  closing_note text,
  constraint cash_close_pair check ((closed_at is null) = (counted_by_method is null))
);
create unique index if not exists one_open_cash_per_operator
  on public.cash_sessions(operator_id) where closed_at is null;
create index if not exists cash_sessions_opened_idx on public.cash_sessions(opened_at desc);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  cash_session_id uuid not null references public.cash_sessions(id),
  created_by uuid not null references public.profiles(id),
  subtotal numeric(12,2) not null check (subtotal >= 0),
  discount numeric(12,2) not null default 0 check (discount >= 0),
  total numeric(12,2) not null check (total >= 0),
  status text not null default 'completed' check (status in ('completed', 'reversed')),
  created_at timestamptz not null default now()
);
create index if not exists sales_created_at_idx on public.sales(created_at desc);

create table if not exists public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  product_id uuid not null references public.products(id),
  product_name text not null,
  category text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  unit_cost numeric(12,2) not null default 0 check (unit_cost >= 0)
);

create table if not exists public.sale_payments (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  method text not null check (method in ('cash', 'pix', 'debit', 'credit')),
  amount numeric(12,2) not null check (amount > 0),
  amount_received numeric(12,2) not null default 0 check (amount_received >= 0),
  change_amount numeric(12,2) not null default 0 check (change_amount >= 0)
);

create table if not exists public.cash_movements (
  id uuid primary key default gen_random_uuid(),
  cash_session_id uuid not null references public.cash_sessions(id) on delete cascade,
  created_by uuid not null references public.profiles(id),
  movement_type text not null check (movement_type in ('opening_float', 'supply', 'withdrawal', 'sale')),
  amount numeric(12,2) not null check (amount >= 0),
  method text not null default 'cash' check (method in ('cash', 'pix', 'debit', 'credit', 'mixed')),
  justification text,
  sale_id uuid references public.sales(id),
  created_at timestamptz not null default now()
);
create index if not exists cash_movements_session_idx on public.cash_movements(cash_session_id, created_at desc);

create table if not exists public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id),
  operator_id uuid not null references public.profiles(id),
  supplier_id uuid references public.suppliers(id),
  machine_id uuid references public.machines(id),
  movement_type text not null check (movement_type in ('purchase', 'sale', 'maintenance', 'loss', 'reversal', 'adjustment')),
  quantity integer not null check (quantity <> 0),
  unit_cost numeric(12,2) not null default 0 check (unit_cost >= 0),
  note text,
  created_at timestamptz not null default now()
);
create index if not exists inventory_product_time_idx on public.inventory_movements(product_id, created_at desc);

create table if not exists public.work_shifts (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.profiles(id) on delete cascade,
  weekday integer not null check (weekday between 0 and 6),
  shift_name text not null check (shift_name in ('Manhã', 'Tarde', 'Noite/Fim de Semana')),
  start_time time not null,
  end_time time not null,
  created_at timestamptz not null default now(),
  unique (employee_id, weekday, shift_name)
);

create unique index if not exists one_employee_per_shift on public.work_shifts(weekday, shift_name);

create table if not exists public.time_entries (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  note text,
  constraint time_entry_order check (ended_at is null or ended_at >= started_at)
);
create unique index if not exists one_open_time_entry_per_employee
  on public.time_entries(employee_id) where ended_at is null;

-- PostgreSQL numeric admite NaN e Infinity; RPCs usam este predicado antes de calcular/gravar valores.
create or replace function public._is_finite_numeric(p_value numeric)
returns boolean
language sql immutable strict
set search_path = pg_catalog, pg_temp
as $$ select p_value::text not in ('NaN', 'Infinity', '-Infinity') $$;

create or replace function public.current_app_role()
returns text
language sql stable security definer set search_path = public, pg_temp
as $$ select role from public.profiles where id = auth.uid() and is_active limit 1 $$;

create or replace function public.has_app_role(allowed text[])
returns boolean
language sql stable security definer set search_path = public, pg_temp
as $$ select coalesce(public.current_app_role() = any(allowed), false) $$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public, pg_temp
as $$
begin
  insert into public.profiles(id, email, full_name, role, is_active)
  values (new.id, coalesce(new.email, ''), coalesce(new.raw_user_meta_data->>'full_name', ''), 'cashier', true)
  on conflict (id) do update set email = excluded.email, updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users for each row execute procedure public.handle_new_user();
drop trigger if exists on_auth_user_email_updated on auth.users;
create trigger on_auth_user_email_updated
after update of email on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.open_cash(p_opening_float numeric)
returns uuid language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_id uuid;
  v_role text := public.current_app_role();
  v_amount numeric;
begin
  if auth.uid() is null or v_role is null or v_role not in ('admin', 'manager', 'cashier') then
    raise exception 'Perfil inativo ou sem permissão para abrir caixa.';
  end if;
  if p_opening_float is null or not public._is_finite_numeric(p_opening_float) then
    raise exception 'Informe um fundo inicial finito.';
  end if;
  v_amount := round(p_opening_float, 2);
  if v_amount < 0 then raise exception 'Informe um fundo inicial válido.'; end if;
  insert into public.cash_sessions(operator_id, opening_float)
  values (auth.uid(), v_amount) returning id into v_id;
  insert into public.cash_movements(cash_session_id, created_by, movement_type, amount, method, justification)
  values (v_id, auth.uid(), 'opening_float', v_amount, 'cash', 'Fundo de troco');
  return v_id;
end;
$$;

create or replace function public.record_cash_adjustment(p_movement_type text, p_amount numeric, p_justification text)
returns uuid language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_session uuid;
  v_id uuid;
  v_role text := public.current_app_role();
  v_amount numeric;
begin
  if auth.uid() is null or v_role is null or v_role not in ('admin', 'manager', 'cashier') then
    raise exception 'Perfil inativo ou sem permissão para movimentar caixa.';
  end if;
  if p_movement_type is null or p_movement_type not in ('supply', 'withdrawal') then
    raise exception 'Tipo de movimentação inválido.';
  end if;
  if p_amount is null or not public._is_finite_numeric(p_amount) then
    raise exception 'Informe um valor finito.';
  end if;
  v_amount := round(p_amount, 2);
  if v_amount <= 0 then raise exception 'Informe um valor maior que zero.'; end if;
  if length(trim(coalesce(p_justification, ''))) < 3 then raise exception 'A justificativa é obrigatória.'; end if;
  if p_movement_type = 'withdrawal' and v_role not in ('admin', 'manager') then
    raise exception 'Sangria exige perfil Gerente ou Administrador.';
  end if;
  select id into v_session from public.cash_sessions
    where operator_id = auth.uid() and closed_at is null for update;
  if v_session is null then raise exception 'Abra o caixa antes de registrar movimentações.'; end if;
  insert into public.cash_movements(cash_session_id, created_by, movement_type, amount, method, justification)
  values (v_session, auth.uid(), p_movement_type, v_amount, 'cash', trim(p_justification))
  returning id into v_id;
  return v_id;
end;
$$;

create or replace function public.create_sale(p_items jsonb, p_payments jsonb, p_discount numeric default 0)
returns uuid language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_session uuid;
  v_sale uuid;
  v_item jsonb;
  v_pay jsonb;
  v_product public.products%rowtype;
  v_product_id uuid;
  v_qty integer;
  v_qty_numeric numeric;
  v_subtotal numeric := 0;
  v_discount numeric;
  v_total numeric;
  v_paid numeric := 0;
  v_amount numeric;
  v_received numeric;
  v_method text;
  v_role text := public.current_app_role();
  v_item_count bigint;
  v_unique_count bigint;
begin
  if auth.uid() is null or v_role is null or v_role not in ('admin', 'manager', 'cashier') then
    raise exception 'Perfil inativo ou sem permissão para vender.';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' then
    raise exception 'O carrinho está vazio ou inválido.';
  end if;
  if jsonb_array_length(p_items) = 0 then raise exception 'O carrinho está vazio ou inválido.'; end if;
  if jsonb_typeof(p_payments) is distinct from 'array' then
    raise exception 'Informe ao menos uma forma de pagamento.';
  end if;
  if jsonb_array_length(p_payments) = 0 then raise exception 'Informe ao menos uma forma de pagamento.'; end if;
  if p_discount is null or not public._is_finite_numeric(p_discount) then
    raise exception 'Informe um desconto finito.';
  end if;
  v_discount := round(p_discount, 2);
  if v_discount < 0 then raise exception 'O desconto não pode ser negativo.'; end if;
  if v_discount > 0 and v_role not in ('admin', 'manager') then
    raise exception 'Desconto exige perfil Gerente ou Administrador.';
  end if;

  -- Validar os itens e rejeitar IDs repetidos antes de adquirir locks.
  for v_item in select value from jsonb_array_elements(p_items) as entries(value) loop
    if jsonb_typeof(v_item) is distinct from 'object'
       or jsonb_typeof(v_item->'product_id') is distinct from 'string'
       or jsonb_typeof(v_item->'quantity') is distinct from 'number' then
      raise exception 'Item de venda inválido.';
    end if;
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty_numeric := (v_item->>'quantity')::numeric;
    if not public._is_finite_numeric(v_qty_numeric)
       or v_qty_numeric <> trunc(v_qty_numeric)
       or v_qty_numeric <= 0
       or v_qty_numeric > 2147483647 then
      raise exception 'Quantidade de produto inválida.';
    end if;
  end loop;
  select count(*), count(distinct (value->>'product_id')::uuid)
    into v_item_count, v_unique_count from jsonb_array_elements(p_items) as entries(value);
  if v_item_count <> v_unique_count then raise exception 'Não repita produtos no carrinho.'; end if;

  -- Toda venda bloqueia produtos na mesma ordem, reduzindo deadlocks concorrentes.
  for v_item in
    select value from jsonb_array_elements(p_items) as entries(value)
    order by (value->>'product_id')::uuid
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty := ((v_item->>'quantity')::numeric)::integer;
    select * into v_product from public.products where id = v_product_id and is_active for update;
    if not found then raise exception 'Um dos produtos não está disponível.'; end if;
    if v_product.price is null or not public._is_finite_numeric(v_product.price)
       or v_product.price < 0 or v_product.unit_cost is null
       or not public._is_finite_numeric(v_product.unit_cost) or v_product.unit_cost < 0 then
      raise exception 'Produto com preço ou custo inválido: %.', v_product.name;
    end if;
    if v_product.stock_qty < v_qty then raise exception 'Estoque insuficiente para %.', v_product.name; end if;
    v_subtotal := v_subtotal + v_product.price * v_qty;
  end loop;
  if v_discount > 0 and v_discount >= v_subtotal then
    raise exception 'O desconto deve ser menor que o subtotal.';
  end if;
  v_total := round(v_subtotal - v_discount, 2);

  for v_pay in select value from jsonb_array_elements(p_payments) as entries(value) loop
    if jsonb_typeof(v_pay) is distinct from 'object'
       or jsonb_typeof(v_pay->'method') is distinct from 'string'
       or jsonb_typeof(v_pay->'amount') is distinct from 'number' then
      raise exception 'Forma ou valor de pagamento inválido.';
    end if;
    v_method := v_pay->>'method';
    v_amount := round((v_pay->>'amount')::numeric, 2);
    if not public._is_finite_numeric(v_amount) or v_amount <= 0 then
      raise exception 'O pagamento deve ser um valor finito maior que zero.';
    end if;
    if v_pay ? 'amount_received' then
      if jsonb_typeof(v_pay->'amount_received') is distinct from 'number' then
        raise exception 'O valor recebido deve ser numérico e finito.';
      end if;
      v_received := round((v_pay->>'amount_received')::numeric, 2);
    else
      v_received := v_amount;
    end if;
    if not public._is_finite_numeric(v_received) or v_received < 0 then
      raise exception 'O valor recebido deve ser finito e não negativo.';
    end if;
    if v_method is null or v_method not in ('cash', 'pix', 'debit', 'credit') then
      raise exception 'Forma de pagamento inválida.';
    end if;
    if v_method = 'cash' and v_received < v_amount then
      raise exception 'O valor recebido em dinheiro é menor que o pagamento.';
    end if;
    v_paid := v_paid + v_amount;
  end loop;
  if v_paid <> v_total then raise exception 'A soma dos pagamentos não corresponde exatamente ao total da venda.'; end if;

  select id into v_session from public.cash_sessions
    where operator_id = auth.uid() and closed_at is null for update;
  if v_session is null then raise exception 'Abra o caixa antes de vender.'; end if;
  insert into public.sales(cash_session_id, created_by, subtotal, discount, total)
  values (v_session, auth.uid(), round(v_subtotal, 2), v_discount, v_total)
  returning id into v_sale;

  for v_item in select value from jsonb_array_elements(p_items) as entries(value) loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty := ((v_item->>'quantity')::numeric)::integer;
    select * into v_product from public.products where id = v_product_id;
    insert into public.sale_items(sale_id, product_id, product_name, category, quantity, unit_price, unit_cost)
    values (v_sale, v_product.id, v_product.name, v_product.category, v_qty, v_product.price, v_product.unit_cost);
    update public.products set stock_qty = stock_qty - v_qty, updated_at = now() where id = v_product.id;
    insert into public.inventory_movements(product_id, operator_id, movement_type, quantity, unit_cost, note)
    values (v_product.id, auth.uid(), 'sale', -v_qty, v_product.unit_cost, 'Venda ' || left(v_sale::text, 8));
  end loop;

  for v_pay in select value from jsonb_array_elements(p_payments) as entries(value) loop
    v_method := v_pay->>'method';
    v_amount := round((v_pay->>'amount')::numeric, 2);
    if v_pay ? 'amount_received' then
      v_received := round((v_pay->>'amount_received')::numeric, 2);
    else
      v_received := v_amount;
    end if;
    insert into public.sale_payments(sale_id, method, amount, amount_received, change_amount)
    values (v_sale, v_method, v_amount, v_received, greatest(0, v_received - v_amount));
  end loop;
  insert into public.cash_movements(cash_session_id, created_by, movement_type, amount, method, sale_id)
  values (v_session, auth.uid(), 'sale', v_total, 'mixed', v_sale);
  return v_sale;
end;
$$;

create or replace function public.close_cash(p_counted jsonb, p_note text default null)
returns jsonb language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_session public.cash_sessions%rowtype;
  v_expected jsonb := '{}'::jsonb;
  v_counted_normalized jsonb := '{}'::jsonb;
  v_delta numeric := 0;
  v_method text;
  v_expected_amount numeric;
  v_counted numeric;
  v_opening numeric;
  v_adjust numeric;
  v_sales numeric;
  v_role text := public.current_app_role();
  v_has_method_difference boolean := false;
begin
  if auth.uid() is null or v_role is null or v_role not in ('admin', 'manager', 'cashier') then
    raise exception 'Perfil inativo ou sem permissão para fechar caixa.';
  end if;
  if jsonb_typeof(p_counted) is distinct from 'object' then
    raise exception 'Informe os valores contados por forma de pagamento.';
  end if;
  foreach v_method in array array['cash', 'pix', 'debit', 'credit'] loop
    if jsonb_typeof(p_counted->v_method) is distinct from 'number' then
      raise exception 'Informe um valor numérico para %.', v_method;
    end if;
    v_counted := round((p_counted->>v_method)::numeric, 2);
    if not public._is_finite_numeric(v_counted) or v_counted < 0 then
      raise exception 'O valor contado para % deve ser finito e não negativo.', v_method;
    end if;
    v_counted_normalized := v_counted_normalized || jsonb_build_object(v_method, v_counted);
  end loop;

  select * into v_session from public.cash_sessions
    where operator_id = auth.uid() and closed_at is null for update;
  if not found then raise exception 'Não há caixa aberto para fechar.'; end if;

  foreach v_method in array array['cash', 'pix', 'debit', 'credit'] loop
    v_opening := case when v_method = 'cash' then v_session.opening_float else 0 end;
    select coalesce(sum(case when movement_type = 'supply' then amount
                             when movement_type = 'withdrawal' then -amount else 0 end), 0)
      into v_adjust from public.cash_movements
      where cash_session_id = v_session.id and method = v_method;
    select coalesce(sum(p.amount), 0) into v_sales
      from public.sale_payments p join public.sales s on s.id = p.sale_id
      where s.cash_session_id = v_session.id and s.status = 'completed' and p.method = v_method;
    v_expected_amount := round(v_opening + v_adjust + v_sales, 2);
    v_expected := v_expected || jsonb_build_object(v_method, v_expected_amount);
    v_counted := (v_counted_normalized->>v_method)::numeric;
    if v_counted <> v_expected_amount then v_has_method_difference := true; end if;
    v_delta := v_delta + v_counted - v_expected_amount;
  end loop;
  if v_has_method_difference and length(trim(coalesce(p_note, ''))) < 3 then
    raise exception 'Descreva cada diferença por forma de pagamento antes de concluir o fechamento.';
  end if;
  update public.cash_sessions set closed_at = now(), expected_by_method = v_expected,
    counted_by_method = v_counted_normalized, difference = round(v_delta, 2),
    closing_note = nullif(trim(coalesce(p_note, '')), '')
    where id = v_session.id;
  return jsonb_build_object('session_id', v_session.id, 'expected', v_expected,
                            'counted', v_counted_normalized, 'difference', round(v_delta, 2));
end;
$$;

create or replace function public.register_stock_receipt(
  p_supplier_id uuid,
  p_lines jsonb,
  p_note text default null,
  p_occurred_at timestamptz default now()
)
returns integer language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_line jsonb;
  v_product public.products%rowtype;
  v_product_id uuid;
  v_qty integer;
  v_qty_numeric numeric;
  v_cost numeric;
  v_count integer := 0;
  v_role text := public.current_app_role();
  v_item_count bigint;
  v_unique_count bigint;
begin
  if auth.uid() is null or v_role is null or v_role not in ('admin', 'manager') then
    raise exception 'Entrada de estoque exige perfil Gerente ou Administrador ativo.';
  end if;
  if p_occurred_at is null or not isfinite(p_occurred_at) or p_occurred_at > now() then
    raise exception 'A data da entrada deve ser finita e não futura.';
  end if;
  if jsonb_typeof(p_lines) is distinct from 'array' then
    raise exception 'Inclua ao menos um produto na entrada.';
  end if;
  if jsonb_array_length(p_lines) = 0 then
    raise exception 'Inclua ao menos um produto na entrada.';
  end if;
  if p_supplier_id is not null and not exists (
    select 1 from public.suppliers where id = p_supplier_id and is_active
  ) then raise exception 'Fornecedor inativo ou inexistente.'; end if;

  for v_line in select value from jsonb_array_elements(p_lines) as entries(value) loop
    if jsonb_typeof(v_line) is distinct from 'object'
       or jsonb_typeof(v_line->'product_id') is distinct from 'string'
       or jsonb_typeof(v_line->'quantity') is distinct from 'number'
       or jsonb_typeof(v_line->'unit_cost') is distinct from 'number' then
      raise exception 'Linha de entrada de estoque inválida.';
    end if;
    v_product_id := (v_line->>'product_id')::uuid;
    v_qty_numeric := (v_line->>'quantity')::numeric;
    v_cost := round((v_line->>'unit_cost')::numeric, 2);
    if not public._is_finite_numeric(v_qty_numeric)
       or v_qty_numeric <> trunc(v_qty_numeric)
       or v_qty_numeric <= 0
       or v_qty_numeric > 2147483647
       or not public._is_finite_numeric(v_cost)
       or v_cost < 0 then
      raise exception 'Quantidade ou custo inválido na entrada.';
    end if;
  end loop;
  select count(*), count(distinct (value->>'product_id')::uuid)
    into v_item_count, v_unique_count from jsonb_array_elements(p_lines) as entries(value);
  if v_item_count <> v_unique_count then
    raise exception 'Não repita produtos na mesma entrada de estoque.';
  end if;

  -- Entradas concorrentes também adquirem locks de produtos na mesma ordem.
  for v_line in
    select value from jsonb_array_elements(p_lines) as entries(value)
    order by (value->>'product_id')::uuid
  loop
    v_product_id := (v_line->>'product_id')::uuid;
    v_qty := ((v_line->>'quantity')::numeric)::integer;
    v_cost := round((v_line->>'unit_cost')::numeric, 2);
    select * into v_product from public.products
      where id = v_product_id and is_active for update;
    if not found then raise exception 'Produto não encontrado ou inativo.'; end if;
    if v_product.stock_qty > 2147483647 - v_qty then raise exception 'Estoque excede o limite permitido.'; end if;
    update public.products set stock_qty = stock_qty + v_qty, unit_cost = v_cost, updated_at = now()
      where id = v_product.id;
    insert into public.inventory_movements(
      product_id, operator_id, supplier_id, movement_type, quantity, unit_cost, note, created_at
    ) values (
      v_product.id, auth.uid(), p_supplier_id, 'purchase', v_qty, v_cost,
      nullif(trim(coalesce(p_note, '')), ''), p_occurred_at
    );
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;

create or replace function public.register_part_exit(
  p_machine_id uuid, p_product_id uuid, p_quantity integer, p_note text default null
)
returns uuid language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_product public.products%rowtype;
  v_record uuid;
  v_machine public.machines%rowtype;
  v_role text := public.current_app_role();
begin
  if auth.uid() is null or v_role is null or v_role not in ('admin', 'manager', 'technician') then
    raise exception 'Saída de peça exige perfil Técnico, Gerente ou Administrador ativo.';
  end if;
  if p_quantity is null or p_quantity <= 0 then raise exception 'Informe uma quantidade maior que zero.'; end if;
  select * into v_machine from public.machines where id = p_machine_id for update;
  if not found then raise exception 'Máquina vinculada não encontrada.'; end if;
  select * into v_product from public.products where id = p_product_id and is_active for update;
  if not found then raise exception 'Produto ou peça não encontrado no estoque.'; end if;
  if v_product.unit_cost is null or not public._is_finite_numeric(v_product.unit_cost) or v_product.unit_cost < 0 then
    raise exception 'Custo unitário da peça inválido.';
  end if;
  if v_product.stock_qty < p_quantity then raise exception 'Estoque insuficiente para esta saída.'; end if;
  update public.products set stock_qty = stock_qty - p_quantity, updated_at = now() where id = v_product.id;
  insert into public.inventory_movements(product_id, operator_id, machine_id, movement_type, quantity, unit_cost, note)
  values (v_product.id, auth.uid(), v_machine.id, 'maintenance', -p_quantity, v_product.unit_cost,
          nullif(trim(coalesce(p_note, '')), ''));
  insert into public.maintenance_records(machine_id, created_by, description, parts)
  values (v_machine.id, auth.uid(), coalesce(nullif(trim(coalesce(p_note, '')), ''), 'Saída de peça: ' || v_product.name),
          jsonb_build_array(jsonb_build_object('product_id', v_product.id, 'product_name', v_product.name, 'quantity', p_quantity)))
  returning id into v_record;
  update public.machines set maintenance_count = maintenance_count + 1,
    status = case when status = 'active' then 'maintenance' else status end
    where id = v_machine.id;
  return v_record;
end;
$$;

create or replace function public.save_employee_profile(
  p_user_id uuid,
  p_email text,
  p_full_name text,
  p_role text,
  p_active boolean,
  p_cpf text,
  p_position text,
  p_phone text,
  p_salary numeric,
  p_admitted_at date
)
returns uuid language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_actor_role text := public.current_app_role();
  v_target_id uuid;
  v_target_role text;
  v_matches bigint;
begin
  if auth.uid() is null or v_actor_role is null or v_actor_role not in ('admin', 'manager') then
    raise exception 'Somente Administrador ou Gerente ativo pode salvar perfis.';
  end if;
  if p_email is null or length(trim(p_email)) = 0 or p_full_name is null
     or p_role is null or p_role not in ('admin', 'manager', 'cashier', 'technician')
     or p_active is null then
    raise exception 'Dados de perfil obrigatórios inválidos.';
  end if;
  if p_salary is not null and (not public._is_finite_numeric(p_salary) or p_salary < 0) then
    raise exception 'O salário deve ser finito e não negativo.';
  end if;
  if p_user_id is null then
    select count(*) into v_matches from public.profiles where lower(email) = lower(trim(p_email));
    if v_matches = 0 then raise exception 'Convide o usuário no Supabase Auth antes de salvar seu perfil.'; end if;
    if v_matches > 1 then raise exception 'Há mais de um perfil com esse e-mail; informe o UUID do usuário.'; end if;
    select id, role into v_target_id, v_target_role from public.profiles
      where lower(email) = lower(trim(p_email)) for update;
  else
    select id, role into v_target_id, v_target_role from public.profiles where id = p_user_id for update;
    if not found then raise exception 'Perfil inexistente; crie primeiro o usuário no Supabase Auth.'; end if;
  end if;
  if v_target_id is null then raise exception 'Perfil não encontrado; esta função não cria usuários no Auth.'; end if;
  if v_actor_role = 'manager' and (v_target_role in ('admin', 'manager') or p_role in ('admin', 'manager')) then
    raise exception 'Gerente não pode alterar nem atribuir perfil de Administrador ou Gerente.';
  end if;
  if v_target_role in ('admin', 'manager') and v_actor_role <> 'admin' then
    raise exception 'Somente Administrador pode gerenciar perfis privilegiados.';
  end if;
  if p_role in ('admin', 'manager') and v_actor_role <> 'admin' then
    raise exception 'Somente Administrador pode atribuir perfil privilegiado.';
  end if;
  if v_target_id = auth.uid() and v_actor_role = 'admin' and (p_role <> 'admin' or not p_active) then
    raise exception 'Por segurança, Administrador não pode se rebaixar nem desativar a própria conta.';
  end if;

  if not exists (select 1 from auth.users where id = v_target_id and lower(email) = lower(trim(p_email))) then
    raise exception 'Altere o e-mail de login no Supabase Auth, não neste cadastro.';
  end if;
  update public.profiles set email = lower(trim(p_email)), full_name = trim(p_full_name),
    role = p_role, is_active = p_active, updated_at = now()
    where id = v_target_id;
  insert into public.employee_details(user_id, cpf, position, phone, admitted_at, base_salary)
  values (v_target_id, nullif(trim(coalesce(p_cpf, '')), ''), coalesce(trim(p_position), ''),
          nullif(trim(coalesce(p_phone, '')), ''), p_admitted_at,
          case when p_salary is null then null else round(p_salary, 2) end)
  on conflict (user_id) do update set cpf = excluded.cpf, position = excluded.position,
    phone = excluded.phone, admitted_at = excluded.admitted_at, base_salary = excluded.base_salary;
  return v_target_id;
end;
$$;

create or replace function public.end_time_entry(p_entry_id uuid)
returns void language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_employee_id uuid;
  v_ended_at timestamptz;
  v_role text := public.current_app_role();
begin
  if auth.uid() is null or v_role is null then raise exception 'Usuário inativo ou não autenticado.'; end if;
  select employee_id, ended_at into v_employee_id, v_ended_at from public.time_entries
    where id = p_entry_id and employee_id = auth.uid() for update;
  if not found then raise exception 'Registro de ponto não encontrado para o usuário atual.'; end if;
  if v_ended_at is not null then raise exception 'Este registro de ponto já foi encerrado.'; end if;
  update public.time_entries set ended_at = now() where id = p_entry_id and employee_id = auth.uid();
end;
$$;

-- RLS: acesso depende de autenticação e perfil ativo; alterações controladas usam RPC ou grants mínimos.
alter table public.profiles enable row level security;
alter table public.employee_details enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.machines enable row level security;
alter table public.maintenance_records enable row level security;
alter table public.cash_sessions enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.sale_payments enable row level security;
alter table public.cash_movements enable row level security;
alter table public.inventory_movements enable row level security;
alter table public.work_shifts enable row level security;
alter table public.time_entries enable row level security;

-- Policies são recriadas de forma idempotente quando esta migração é reexecutada.
drop policy if exists "profile self or admin read" on public.profiles;
drop policy if exists "profile admin update" on public.profiles;
drop policy if exists "employee details manager read" on public.employee_details;
drop policy if exists "employee details manager write" on public.employee_details;
drop policy if exists "products authenticated read" on public.products;
drop policy if exists "products manager write" on public.products;
drop policy if exists "products manager insert" on public.products;
drop policy if exists "products manager update" on public.products;
drop policy if exists "suppliers authenticated read" on public.suppliers;
drop policy if exists "suppliers manager write" on public.suppliers;
drop policy if exists "suppliers manager update" on public.suppliers;
drop policy if exists "machines authenticated read" on public.machines;
drop policy if exists "machines manager technician write" on public.machines;
drop policy if exists "maintenance authenticated read" on public.maintenance_records;
drop policy if exists "maintenance manager technician write" on public.maintenance_records;
drop policy if exists "cash self or manager read" on public.cash_sessions;
drop policy if exists "cash self insert" on public.cash_sessions;
drop policy if exists "cash self or manager update" on public.cash_sessions;
drop policy if exists "sales own or manager read" on public.sales;
drop policy if exists "sale items own or manager read" on public.sale_items;
drop policy if exists "sale payments own or manager read" on public.sale_payments;
drop policy if exists "cash movements self or manager read" on public.cash_movements;
drop policy if exists "inventory authenticated read" on public.inventory_movements;
drop policy if exists "shifts authenticated read" on public.work_shifts;
drop policy if exists "shifts manager write" on public.work_shifts;
drop policy if exists "shifts manager insert" on public.work_shifts;
drop policy if exists "shifts manager update" on public.work_shifts;
drop policy if exists "shifts manager delete" on public.work_shifts;
drop policy if exists "time self or manager read" on public.time_entries;
drop policy if exists "time self insert" on public.time_entries;
drop policy if exists "time self or manager update" on public.time_entries;

create policy "profile self or admin read" on public.profiles for select to authenticated
  using (public.current_app_role() is not null and (id = auth.uid() or public.has_app_role(array['admin', 'manager'])));
create policy "employee details manager read" on public.employee_details for select to authenticated
  using (public.has_app_role(array['admin', 'manager']));

create policy "products authenticated read" on public.products for select to authenticated
  using (public.current_app_role() is not null);
create policy "products manager insert" on public.products for insert to authenticated
  with check (public.has_app_role(array['admin', 'manager']));
create policy "products manager update" on public.products for update to authenticated
  using (public.has_app_role(array['admin', 'manager']))
  with check (public.has_app_role(array['admin', 'manager']));

create policy "suppliers authenticated read" on public.suppliers for select to authenticated
  using (public.has_app_role(array['admin', 'manager']));
create policy "suppliers manager update" on public.suppliers for update to authenticated
  using (public.has_app_role(array['admin', 'manager']))
  with check (public.has_app_role(array['admin', 'manager']));

create policy "machines authenticated read" on public.machines for select to authenticated
  using (public.current_app_role() is not null);
create policy "maintenance authenticated read" on public.maintenance_records for select to authenticated
  using (public.current_app_role() is not null);

create policy "cash self or manager read" on public.cash_sessions for select to authenticated
  using (public.current_app_role() is not null
         and (operator_id = auth.uid() or public.has_app_role(array['admin', 'manager'])));
create policy "sales own or manager read" on public.sales for select to authenticated
  using (public.current_app_role() is not null
         and (created_by = auth.uid() or public.has_app_role(array['admin', 'manager'])));
create policy "sale items own or manager read" on public.sale_items for select to authenticated
  using (public.current_app_role() is not null and exists (
    select 1 from public.sales s where s.id = sale_id
      and (s.created_by = auth.uid() or public.has_app_role(array['admin', 'manager']))
  ));
create policy "sale payments own or manager read" on public.sale_payments for select to authenticated
  using (public.current_app_role() is not null and exists (
    select 1 from public.sales s where s.id = sale_id
      and (s.created_by = auth.uid() or public.has_app_role(array['admin', 'manager']))
  ));
create policy "cash movements self or manager read" on public.cash_movements for select to authenticated
  using (public.current_app_role() is not null and exists (
    select 1 from public.cash_sessions s where s.id = cash_session_id
      and (s.operator_id = auth.uid() or public.has_app_role(array['admin', 'manager']))
  ));
create policy "inventory authenticated read" on public.inventory_movements for select to authenticated
  using (public.current_app_role() is not null);

create policy "shifts authenticated read" on public.work_shifts for select to authenticated
  using (public.current_app_role() is not null);
create policy "shifts manager insert" on public.work_shifts for insert to authenticated
  with check (public.has_app_role(array['admin', 'manager']) and exists (select 1 from public.profiles p where p.id = employee_id and p.is_active));
create policy "shifts manager update" on public.work_shifts for update to authenticated
  using (public.has_app_role(array['admin', 'manager']))
  with check (public.has_app_role(array['admin', 'manager']) and exists (select 1 from public.profiles p where p.id = employee_id and p.is_active));
create policy "shifts manager delete" on public.work_shifts for delete to authenticated
  using (public.has_app_role(array['admin', 'manager']));

create policy "time self or manager read" on public.time_entries for select to authenticated
  using (public.current_app_role() is not null
         and (employee_id = auth.uid() or public.has_app_role(array['admin', 'manager'])));
create policy "time self insert" on public.time_entries for insert to authenticated
  with check (public.current_app_role() is not null and employee_id = auth.uid());

-- Revoga privilégios padrão antes de conceder apenas o necessário.
revoke all privileges on public.profiles, public.employee_details, public.suppliers, public.products,
  public.machines, public.maintenance_records, public.cash_sessions, public.sales,
  public.sale_items, public.sale_payments, public.cash_movements, public.inventory_movements,
  public.work_shifts, public.time_entries from public, anon, authenticated;
revoke execute on function public.current_app_role(), public.has_app_role(text[]), public.handle_new_user(),
  public._is_finite_numeric(numeric), public.open_cash(numeric), public.record_cash_adjustment(text, numeric, text),
  public.create_sale(jsonb, jsonb, numeric), public.close_cash(jsonb, text),
  public.register_stock_receipt(uuid, jsonb, text, timestamptz), public.register_part_exit(uuid, uuid, integer, text),
  public.save_employee_profile(uuid, text, text, text, boolean, text, text, text, numeric, date),
  public.end_time_entry(uuid) from public, anon, authenticated;
grant usage on schema public to authenticated;
grant select on public.profiles, public.employee_details, public.suppliers, public.products,
  public.machines, public.maintenance_records, public.cash_sessions, public.sales,
  public.sale_items, public.sale_payments, public.cash_movements, public.inventory_movements,
  public.work_shifts, public.time_entries to authenticated;

-- Produtos: gerente/admin pode manter catálogo, mas estoque/custo só mudam por RPC.
grant insert (name, category, price, stock_min, sku, icon_key, is_active)
  on public.products to authenticated;
grant update (name, category, price, stock_min, sku, icon_key, is_active)
  on public.products to authenticated;
-- Fornecedor só pode ser desativado; não há INSERT nem DELETE via API.
grant update (is_active) on public.suppliers to authenticated;
-- Escalas: gerente/admin têm CRUD sujeito às policies; ponto só permite inserir employee_id/note.
grant insert, update, delete on public.work_shifts to authenticated;
grant insert (employee_id, note) on public.time_entries to authenticated;

grant execute on function public.current_app_role() to authenticated;
grant execute on function public.has_app_role(text[]) to authenticated;
grant execute on function public.open_cash(numeric) to authenticated;
grant execute on function public.record_cash_adjustment(text, numeric, text) to authenticated;
grant execute on function public.create_sale(jsonb, jsonb, numeric) to authenticated;
grant execute on function public.close_cash(jsonb, text) to authenticated;
grant execute on function public.register_stock_receipt(uuid, jsonb, text, timestamptz) to authenticated;
grant execute on function public.register_part_exit(uuid, uuid, integer, text) to authenticated;
grant execute on function public.save_employee_profile(uuid, text, text, text, boolean, text, text, text, numeric, date) to authenticated;
grant execute on function public.end_time_entry(uuid) to authenticated;

-- Bootstrap: crie o primeiro usuário em Supabase Auth, copie o UUID dele e execute esta instrução
-- uma única vez no SQL Editor do projeto para torná-lo administrador. Não crie a linha Auth manualmente.
-- update public.profiles set role = 'admin', is_active = true, updated_at = now() where id = '<USER_UUID>'::uuid;
