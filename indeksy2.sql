
CREATE INDEX idx_conferences_country_city 
    ON cfr.conferences (country, city);

drop index idx_conferences_start_end;
CREATE INDEX idx_conferences_start_end 
    ON cfr.conferences (country, start_time, end_time, id, name);

CREATE INDEX  
    ON cfr.conferences (country);
	
CREATE INDEX  
    ON cfr.conferences (start_time);

CREATE INDEX  
    ON cfr.conferences (end_time);




CREATE INDEX idx_offers_conference_id 
    ON cfr.offers (conference_id);

CREATE INDEX idx_offers_price_currency 
    ON cfr.offers (currency, price);





CREATE INDEX idx_acc_city_country 
    ON cfr.accommodation_options (address_city, address_country);

CREATE INDEX idx_acc_type_currency 
    ON cfr.accommodation_options (accommodation_type_id, currency);




CREATE INDEX idx_room_acc_id 
    ON cfr.room_options (accommodation_option_id);




CREATE INDEX idx_activities_start_end_city 
    ON cfr.activities (start_time, end_time, address_city);




CREATE INDEX idx_orders_client 
    ON cfr.orders (client_id);

CREATE INDEX ON cfr.orders (purchase_date);




CREATE INDEX idx_payments_order 
    ON cfr.payments (order_id);

CREATE INDEX idx_payments_status_type 
    ON cfr.payments (status_id, payment_type_id);


CREATE INDEX ON cfr.order_statuses (status_name);

CREATE INDEX ON cfr.offer_orders (order_id);


CREATE INDEX ON cfr.offers (conference_id);
