-- drop view cfr.v_monthly_order_volume;
create or replace view cfr.v_monthly_order_volume as
select
    to_char(o.purchase_date, 'YYYY-MM') as order_month,
    o.currency_id,
    sum(o.total) as monthly_sales_volume,
    count(o.id) as monthly_order_count
from
    cfr.orders o
group by
    order_month, o.currency_id
order by
    order_month, o.currency_id;
