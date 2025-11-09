create or replace procedure cfr.complete_payment_from_ext(
    param_external_id varchar,
    param_payment_gateway_id integer
)
language plpgsql
as $$
declare
    v_order_id integer;
    v_order_status integer;
    v_pmt_status integer;
begin
    select p.order_id, o.order_status_id, p.status_id
    into v_order_id, v_order_status, v_pmt_status
    from cfr.payments p join cfr.orders o on p.order_id = o.id
    where p.external_id = param_external_id
      and p.payment_gateway_id = param_payment_gateway_id;

    if v_order_id is null then
        raise exception 'could not find payment with external id % and gateway id %!', param_external_id, param_payment_gateway_id;
    end if;

	if v_order_status != 1 or v_pmt_status != 1 and v_pmt_status != 5 then
		raise exception 'invalid status for payment % (expected 1 = pending) or order % (expected 1 = new or 5 = pending)', v_pmt_status, v_order_status;
	end if;

    update cfr.payments
    set status_id = 2 -- 2 = paid
    where external_id = param_external_id
      and payment_gateway_id = param_payment_gateway_id;

    update cfr.orders
    set order_status_id = 2 -- 2 = complete
    where id = v_order_id;

    raise notice 'update ok for payment % (gateway %) and order %', param_external_id, param_payment_gateway_id, v_order_id;

exception
    when others then
        raise notice 'error while running procedure %, transaction rolled back!', sqlerrm;
end;
$$;