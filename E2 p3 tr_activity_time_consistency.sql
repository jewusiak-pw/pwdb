create or replace function cfr.chk_activity_time_consistency()
returns trigger as $$
begin
    if new.end_time is not null and new.start_time >= new.end_time then
        raise exception 'activity start_time (%) has to be < end_time (%)', new.start_time, new.end_time;
    end if;
    return new;
end;
$$ language plpgsql;

create or replace trigger tr_activity_time_consistency
before insert or update on cfr.activities
for each row
execute function cfr.chk_activity_time_consistency();