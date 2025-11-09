create or replace function cfr.get_or_create_address(
    param_line1 varchar(255),
    param_line2 varchar(255),
    param_city varchar(100),
    param_zipcode varchar(50),
    param_country char(2)
)
returns integer
language plpgsql
as $$
declare
    v_address_id integer;
begin
    select id into v_address_id
    from cfr.addresses
    where line_1 = param_line1
      and city = param_city
      and zipcode = param_zipcode
      and country = param_country
	  and line_2 = param_line2
    limit 1;

    if v_address_id is null then
        insert into cfr.addresses (line_1, line_2, city, zipcode, country)
        values (param_line1, param_line2, param_city, param_zipcode, param_country)
        returning id into v_address_id;
    end if;

    return v_address_id;
end;
$$;