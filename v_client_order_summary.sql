CREATE OR REPLACE VIEW cfr.v_client_order_summary AS
SELECT
    cl.id AS client_id,
    cl.email,
    cl.name,
    cl.surname,
    COUNT(o.id) AS total_orders_placed,
    SUM(CASE WHEN os.status_name = 'Completed' THEN o.total ELSE 0 END) AS total_sales_completed,
    ARRAY_AGG(DISTINCT o.currency) AS transaction_currencies
FROM
    cfr.clients cl
JOIN
    cfr.orders o ON cl.id = o.client_id
JOIN
    cfr.order_statuses os ON o.order_status_id = os.id
GROUP BY
    cl.id, cl.email, cl.name, cl.surname
ORDER BY
    total_sales_completed DESC;