select id, name from cfr.conferences c 
where start_time between '2025-06-01' and '2025-08-31' 
and end_time between '2025-06-01' and '2025-08-31'
and country = 'US';