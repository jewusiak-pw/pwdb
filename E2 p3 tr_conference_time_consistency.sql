create or replace function cfr.chk_conference_time_consistency()
returns trigger as $$
begin
    if new.start_time >= new.end_time then
        raise exception 'start_time (%) has to be < end_time (%)', new.start_time, new.end_time;
    end if;
    return new;
end;
$$ language plpgsql;

create or replace trigger tr_conference_time_consistency
before insert or update on cfr.conferences
for each row
execute function cfr.chk_conference_time_consistency();