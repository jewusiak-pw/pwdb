select cron.schedule(
    'pending-to-failed-orders',
    '*/10 * * * *',
    $$
	update cfr.orders o
	set order_status_id = 4
	where o.order_status_id = 1
	and o.purchase_date < now() - interval '20 minutes';
    $$
);

