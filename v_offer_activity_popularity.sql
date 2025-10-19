create or replace view cfr.v_offer_activity_popularity as
select
    of.id as offer_id,
    of.name as offer_name,
    c.name as conference_name,
    count(oo.order_id) as times_ordered
from
    cfr.offers of
join
    cfr.conferences c on of.conference_id = c.id
left join
    cfr.offer_orders oo on of.id = oo.offer_id
group by
    of.id, of.name, c.name
order by
    times_ordered desc;