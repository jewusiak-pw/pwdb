CREATE ROLE cfr_admin WITH LOGIN PASSWORD 'testpass';

CREATE ROLE cfr_sys_sales WITH LOGIN PASSWORD 'testpass';

CREATE ROLE cfr_stats WITH LOGIN PASSWORD 'testpass';

GRANT USAGE ON SCHEMA cfr TO cfr_admin, cfr_sys_sales, cfr_stats;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA cfr TO cfr_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA cfr TO cfr_sys_sales;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cfr TO cfr_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON
    cfr.orders,
    cfr.payments,
    cfr.clients,
    cfr.offer_orders
TO cfr_sys_sales;

GRANT SELECT ON
    cfr.conferences,
    cfr.organisers,
    cfr.activities,
    cfr.offers,
    cfr.offer_activities,
    cfr.offer_accommodation_options,
    cfr.payment_types,
    cfr.order_statuses,
    cfr.payment_statuses,
    cfr.payment_gateways
TO cfr_sys_sales;