INSERT INTO cfr.payments (
    status_id,
    payment_type_id,
    payment_gateway_id,
    external_id,
    order_id
)
SELECT
    (floor(random() * 5) + 1)::int AS status_id,            -- 1–5
    (floor(random() * 4) + 1)::int AS payment_type_id,      -- 1–4
    (floor(random() * 5) + 1)::int AS payment_gateway_id,   -- 1–5
    (ARRAY['1234'])[1] AS external_id,                      -- single fixed value from your config
    (floor(random() * 613000) + 1)::int AS order_id         -- 1–613000
FROM generate_series(1, 3000000);