create or replace procedure cfr.add_new_conference_quick(
    param_conf_name varchar(255),
    param_conf_desc varchar(2000),
    param_start_time timestamptz,
    param_end_time timestamptz,
    param_country char(2),
    param_city varchar(100),
    param_org_name varchar(255),
    param_org_tax_id varchar(30),
    param_addr_line1 varchar(255),
    param_addr_line2 varchar(255),
    param_addr_city varchar(100),
    param_addr_zipcode varchar(50),
    param_addr_country char(2)
)
language plpgsql
as $$
declare
    v_address_id integer;
    v_organiser_id integer;
    v_conference_id integer;
begin
	if param_start_time >= param_end_time then
        raise exception 'start_time (%) has to be before end_time (%)', param_start_time, param_end_time;
    end if;
    insert into cfr.addresses (line_1, line_2, city, zipcode, country)
    values (param_addr_line1, param_addr_line2, param_addr_city, param_addr_zipcode, param_addr_country)
    on conflict do nothing returning id into v_address_id;

    if v_address_id is null then
        select id into v_address_id
        from cfr.addresses
        where line_1 = param_addr_line1 and city = param_addr_city and zipcode = param_addr_zipcode
          and country = param_addr_country limit 1;
    end if;

    select id into v_organiser_id
    from cfr.organisers where tax_id = param_org_tax_id -- jeśli istnieje po taxID
    limit 1;

    if v_organiser_id is null then
        insert into cfr.organisers (name, tax_id, address_id)
        values (param_org_name, param_org_tax_id, v_address_id) returning id into v_organiser_id;
    end if;

    insert into cfr.conferences (name, description, start_time, end_time, country, city, organiser_id)
    values (param_conf_name, param_conf_desc, param_start_time, param_end_time, param_country, param_city, v_organiser_id)
    returning id into v_conference_id;

    raise notice 'added new conference (id: %) organised by org with id: %', v_conference_id, v_organiser_id;

end;
$$;