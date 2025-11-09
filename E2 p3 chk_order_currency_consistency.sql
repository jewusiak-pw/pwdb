create or replace function cfr.chk_order_currency_consistency()
returns trigger as $$
declare
    v_order_id integer;
    v_order_currency char(3);
    v_invalid_currency_count integer;
begin
    if tg_table_name = 'orders' then
        v_order_id := new.id;
        v_order_currency := new.currency_id;
    elsif tg_table_name = 'offer_orders' then
        v_order_id := new.order_id;
        select currency_id into v_order_currency from cfr.orders where id = v_order_id;
    else
        return new;
    end if;

    select count(o.id) into v_invalid_currency_count
    from cfr.offer_orders oo
    join cfr.offers o on oo.offer_id = o.id
    where oo.order_id = v_order_id
      and o.currency_id <> v_order_currency;

    if v_invalid_currency_count > 0 then
        raise exception 'order ccy % is incorrect, bc not all linked offers have same ccy', 
		v_order_currency;
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger tr_order_currency_check
before insert or update of currency_id on cfr.orders
for each row
execute function cfr.chk_order_currency_consistency();

create or replace trigger tr_offer_order_currency_check
before insert or update on cfr.offer_orders
for each row
execute function cfr.chk_order_currency_consistency();