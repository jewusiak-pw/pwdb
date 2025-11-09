create or replace function cfr.chk_offer_slot_limit()
returns trigger as $$
declare
    v_max_slots integer;
    v_current_orders integer;
    v_offer_id integer;
begin
    v_offer_id := new.offer_id;

    select max_slots into v_max_slots
    from cfr.offers
    where id = v_offer_id;

    select count(oo.order_id) into v_current_orders
    from cfr.offer_orders oo
    join cfr.orders o on oo.order_id = o.id
    where oo.offer_id = v_offer_id
      and o.order_status_id in (1, 2, 5);

    if v_current_orders >= v_max_slots then
        raise exception 'offer % is full - limit is %, we have % in Completed/Pending/Processing status', 
		v_offer_id, v_max_slots, v_current_orders;
    end if;
    
    return new;
end;
$$ language plpgsql;

create or replace trigger tr_offer_order_slot_limit
before insert on cfr.offer_orders
for each row
execute function cfr.chk_offer_slot_limit();
