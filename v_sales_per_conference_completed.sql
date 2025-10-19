
select
    c.name as conference_name,
    c.country as conference_country,
    c.city as conference_city,
    o.currency,
    sum(o.total) as total_sales,
    count(distinct o.id) as completed_orders_count
from
    cfr.conferences c
join
    cfr.offers of on c.id = of.conference_id
join
    cfr.offer_orders oo on of.id = oo.offer_id
join
    cfr.orders o on oo.order_id = o.id
join
    cfr.order_statuses os on o.order_status_id = os.id
where
    os.status_name = 'Completed'
group by
    c.name, c.country, c.city, o.currency;