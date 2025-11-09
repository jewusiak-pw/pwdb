create or replace function cfr.update_order_total()
returns trigger as $$
declare
    v_order_id integer;
    v_new_total decimal(19, 2);
begin
    if tg_op = 'DELETE' then
        v_order_id := old.order_id;
    else
        v_order_id := new.order_id;
    end if;

    select coalesce(sum(o.price), 0)
    into v_new_total
    from cfr.offer_orders oo
    join cfr.offers o on oo.offer_id = o.id
    where oo.order_id = v_order_id;
    
    update cfr.orders
    set total = v_new_total
    where id = v_order_id;

    return new;
end;
$$ language plpgsql;

create or replace trigger tr_offer_orders_update_total
after insert or delete or update on cfr.offer_orders
for each row
execute function cfr.update_order_total();

