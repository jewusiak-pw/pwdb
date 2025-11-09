select p.id as payment_id, o.id as order_id, p.external_id, p.payment_gateway_id, ps.status_name as payment_status, os.status_name as order_status 
from cfr.payments p join cfr.orders o on p.order_id = o.id 
join cfr.order_statuses os on os.id = o.order_status_id 
join cfr.payment_statuses ps on ps.id = p.status_id 
-- nie w statusie completed lub paid (2 i 2)
where p.status_id != 2 and o.order_status_id != 2;
