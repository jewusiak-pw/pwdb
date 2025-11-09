create or replace function cfr.calculate_total_acc_opt_capacity(acc_opt_id integer)
returns integer
language plpgsql
as $$
declare
    tot_cap integer;
begin
    select coalesce(sum(ro.max_persons * ro.total_available_rooms), 0)
    into tot_cap
    from cfr.room_options ro
    where ro.accommodation_option_id = acc_opt_id;

    return tot_cap;
end;
$$;