create or replace function cfr.chk_currency_consistency()
returns trigger as $$
declare
    v_offer_currency char(3);
    v_invalid_currency_count integer;
    v_offer_id integer;
begin
    v_offer_id := coalesce(new.offer_id, old.offer_id);

    select currency_id into v_offer_currency
    from cfr.offers
    where id = v_offer_id;
    
    select count(a.id) into v_invalid_currency_count
    from cfr.offer_activities oa
    join cfr.activities a on oa.activity_id = a.id
    where oa.offer_id = v_offer_id
      and a.currency_id <> v_offer_currency;
      
    if v_invalid_currency_count > 0 then
        raise exception 'offer % uses %, but % activities have a different currency', 
		v_offer_id, v_offer_currency, v_invalid_currency_count;
    end if;

    select count(ao.id) into v_invalid_currency_count
    from cfr.offer_accommodation_options oao
    join cfr.accommodation_options ao on oao.accommodation_option_id = ao.id
    where oao.offer_id = v_offer_id
      and ao.currency_id <> v_offer_currency;

    if v_invalid_currency_count > 0 then
        raise exception 'offer % uses %, but % accommodation options have a different currency', 
		v_offer_id, v_offer_currency, v_invalid_currency_count;
    end if;

    select count(ro.id) into v_invalid_currency_count
    from cfr.offer_accommodation_options oao
    join cfr.accommodation_options ao on oao.accommodation_option_id = ao.id
	join cfr.room_options ro on ro.accommodation_option_id = ao.id
    where oao.offer_id = v_offer_id
      and ro.currency_id <> v_offer_currency;

    if v_invalid_currency_count > 0 then
        raise exception 'offer % uses %, but % room options have a different currency', 
		v_offer_id, v_offer_currency, v_invalid_currency_count;
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger tr_offer_activity_currency
before insert or update on cfr.offer_activities
for each row
execute function cfr.chk_currency_consistency();

create or replace trigger tr_offer_accommodation_currency
before insert or update on cfr.offer_accommodation_options
for each row
execute function cfr.chk_currency_consistency();

create or replace trigger tr_offer_accommodation_room_options_currency
before insert or update on cfr.room_options
for each row
execute function cfr.chk_currency_consistency();