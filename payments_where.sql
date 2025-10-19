SELECT * FROM cfr.payments p join cfr.orders o on p.order_id = o.id 
where o.purchase_date between '2025-01-01' and '2025-01-31' and o.total > 500;