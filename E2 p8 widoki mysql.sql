CREATE OR replace VIEW cfr.v_sales_per_conference_completed AS SELECT
    c.name AS conference_name,
    c.country AS conference_country,
    c.city AS conference_city,
    o.currency,
    SUM(o.total) AS total_sales,
    COUNT(DISTINCT o.id) AS completed_orders_count
FROM
    cfr.conferences c
JOIN
    cfr.offers ofer ON c.id = ofer.conference_id
JOIN
    cfr.offer_orders oo ON ofer.id = oo.offer_id
JOIN
    cfr.orders o ON oo.order_id = o.id
JOIN
    cfr.order_statuses os ON o.order_status_id = os.id
WHERE
    os.status_name = 'Completed'
GROUP BY
    c.name, c.country, c.city, o.currency;

CREATE OR REPLACE VIEW cfr.v_offer_activity_popularity AS
SELECT
    ofer.id AS offer_id,
    ofer.name AS offer_name,
    c.name AS conference_name,
    COUNT(oo.order_id) AS times_ordered
FROM
    cfr.offers ofer
JOIN
    cfr.conferences c ON ofer.conference_id = c.id
LEFT JOIN
    cfr.offer_orders oo ON ofer.id = oo.offer_id
GROUP BY
    ofer.id, ofer.name, c.name
ORDER BY
    times_ordered DESC;


CREATE OR REPLACE VIEW cfr.v_monthly_order_volume AS
SELECT
    DATE_FORMAT(o.purchase_date, '%Y-%m') AS order_month,
    o.currency_id,
    SUM(o.total) AS monthly_sales_volume,
    COUNT(o.id) AS monthly_order_count
FROM
    cfr.orders o
GROUP BY
    DATE_FORMAT(o.purchase_date, '%Y-%m'),
    o.currency_id
ORDER BY
    order_month,
    o.currency_id;
