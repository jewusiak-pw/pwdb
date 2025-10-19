-- Ustawienie strefy czasowej dla sesji
SET TIME ZONE 'Europe/Warsaw';

-- Użycie bloku DO $$...END $$ dla deklaracji zmiennych i logiki transakcyjnej
DO $$
DECLARE
    -- Zmienne dla ID słownikowych (niezmienione)
    ac_type_hotel_id INT;
    ac_type_hostel_id INT;
    ac_type_apartment_id INT;
    room_type_single_id INT;
    room_type_twin_id INT;
    room_type_hostel_id INT;
    room_type_suite_id INT;
    os_completed_id INT;
    os_pending_id INT;
    os_failed_id INT;
    ps_paid_id INT;
    ps_pending_id INT;
    ps_failed_id INT;
    pt_cc_id INT;
    pt_bt_id INT;
    pt_pp_id INT;
    pg_stripe_id INT;
    pg_payu_id INT;
    pg_adyen_id INT;

    -- Zmienne dla logiki zamówień
    client_id_var INT;
    offer_id_var INT;
    order_id_var INT;
    order_price DECIMAL(19,2);
    i INT;
    random_i_var INT;
    
    -- ID popularnych ofert
    popular_offers INT[] := ARRAY[1, 5, 13, 15, 25, 26, 37, 39, 12, 28, 41];
    -- Ceny powiązane z ID ofert
    offer_prices HSTORE := hstore(ARRAY[
        '1', '1299.00', '5', '399.00', '13', '1500.00', '15', '550.00',
        '25', '799.00', '26', '99.00', '37', '3500.00', '39', '950.00',
        '12', '999.00', '28', '1499.00', '41', '2200.00'
    ]);
    
    order_status_id_var INT;
    payment_status_id_var INT;
    payment_type_id_var INT;
    payment_gateway_id_var INT;
    
    -- Nowe zmienne do zarządzania walutami i datami
    conf_start_dates HSTORE;
    conf_currencies HSTORE;
    conf_id_var INT;
    start_time_conf timestamptz;
    random_purchase_time timestamptz;
    order_currency VARCHAR(3);
    
BEGIN

    -- --------------------------------------------------
    -- -- 1. Wypełnianie Danych Słownikowych
    -- --------------------------------------------------

    -- INSERT INTO cfr.accomodation_types (type_name) VALUES
    -- ('Hotel'), ('Hostel'), ('Apartment'), ('Guesthouse'), ('Other');

    -- INSERT INTO cfr.room_types (type_name) VALUES
    -- ('single'), ('double'), ('twin'), ('suite'), ('hostel_bed'), ('hostel_bed_female'), ('hostel_bed_male'), ('other');

    -- INSERT INTO cfr.order_statuses (status_name) VALUES
    -- ('Pending'), ('Completed'), ('Cancelled'), ('Failed'), ('Processing');

    -- INSERT INTO cfr.payment_statuses (status_name) VALUES
    -- ('New'), ('Paid'), ('Refunded'), ('Failed'), ('Pending');

    -- INSERT INTO cfr.payment_types (type_name) VALUES
    -- ('Credit Card'), ('Bank Transfer'), ('PayPal'), ('Cash');

    -- INSERT INTO cfr.payment_gateways (gateway_name) VALUES
    -- ('Stripe'), ('PayU'), ('Adyen'), ('Przelewy24'), ('Manual');

    -- Pobranie i przypisanie ID słownikowych
    SELECT id FROM cfr.accomodation_types WHERE type_name = 'Hotel' INTO ac_type_hotel_id;
    SELECT id FROM cfr.accomodation_types WHERE type_name = 'Hostel' INTO ac_type_hostel_id;
    SELECT id FROM cfr.accomodation_types WHERE type_name = 'Apartment' INTO ac_type_apartment_id;
    SELECT id FROM cfr.room_types WHERE type_name = 'single' INTO room_type_single_id;
    SELECT id FROM cfr.room_types WHERE type_name = 'twin' INTO room_type_twin_id;
    SELECT id FROM cfr.room_types WHERE type_name = 'hostel_bed' INTO room_type_hostel_id;
    SELECT id FROM cfr.room_types WHERE type_name = 'suite' INTO room_type_suite_id;
    SELECT id FROM cfr.order_statuses WHERE status_name = 'Completed' INTO os_completed_id;
    SELECT id FROM cfr.order_statuses WHERE status_name = 'Pending' INTO os_pending_id;
    SELECT id FROM cfr.order_statuses WHERE status_name = 'Failed' INTO os_failed_id;
    SELECT id FROM cfr.payment_statuses WHERE status_name = 'Paid' INTO ps_paid_id;
    SELECT id FROM cfr.payment_statuses WHERE status_name = 'Pending' INTO ps_pending_id;
    SELECT id FROM cfr.payment_statuses WHERE status_name = 'Failed' INTO ps_failed_id;
    SELECT id FROM cfr.payment_types WHERE type_name = 'Credit Card' INTO pt_cc_id;
    SELECT id FROM cfr.payment_types WHERE type_name = 'Bank Transfer' INTO pt_bt_id;
    SELECT id FROM cfr.payment_types WHERE type_name = 'PayPal' INTO pt_pp_id;
    SELECT id FROM cfr.payment_gateways WHERE gateway_name = 'Stripe' INTO pg_stripe_id;
    SELECT id FROM cfr.payment_gateways WHERE gateway_name = 'PayU' INTO pg_payu_id;
    SELECT id FROM cfr.payment_gateways WHERE gateway_name = 'Adyen' INTO pg_adyen_id;

    -- --------------------------------------------------
    -- -- 2. Wypełnianie Danych Bazowych
    -- --------------------------------------------------

    -- -- Organisers (4 rekordy)
    -- INSERT INTO cfr.organisers (name, description, tax_id, address_1, address_city, address_zipcode, address_country) VALUES
    -- ('TechEvents Sp. z o.o.', 'Organizator konferencji IT i nowych technologii', 'PL5272658145', 'ul. Prosta 51', 'Warszawa', '00-838', 'PL'),
    -- ('ScienceWorld Ltd.', 'Międzynarodowe wydarzenia naukowe i medyczne', 'GB123456789', '20 Fenchurch St', 'Londyn', 'EC3M 3BD', 'GB'),
    -- ('Marketing Masters', 'Specjaliści od konferencji marketingowych i digitalu', 'DE987654321', 'Unter den Linden 77', 'Berlin', '10117', 'DE'),
    -- ('Global BizMeet', 'Spotkania i fora dla liderów biznesu i ekonomii', 'US112233445', '1 World Trade Center', 'Nowy Jork', '10007', 'US');

    -- -- Clients (100 rekordów)
    -- FOR i IN 1..100 LOOP
    --     INSERT INTO cfr.clients (name, surname, email, food_preferrence, special_needs, id_no, phone_number, address_1, address_city, address_zipcode, address_country)
    --     VALUES (
    --         'Imię' || i,
    --         'Nazwisko' || i,
    --         'client' || i || '@example.com',
    --         CASE (i % 5) WHEN 0 THEN 'Wegetariańska' WHEN 1 THEN 'Wegańska' WHEN 2 THEN 'Bezglutenowa' ELSE 'Brak' END,
    --         CASE (i % 20) WHEN 0 THEN 'Wymaga dostępu dla wózka' WHEN 1 THEN 'Tłumacz języka migowego' ELSE NULL END,
    --         'ID' || LPAD(i::text, 4, '0'),
    --         '+48 123 456 ' || LPAD(i::text, 3, '0'),
    --         'ul. Przykładowa ' || (i * 3),
    --         CASE (i % 4) WHEN 0 THEN 'Warszawa' WHEN 1 THEN 'Kraków' WHEN 2 THEN 'Poznań' ELSE 'Wrocław' END,
    --         '00-00' || (i % 9 + 1),
    --         CASE (i % 5) WHEN 0 THEN 'PL' WHEN 1 THEN 'DE' ELSE 'GB' END
    --     );
    -- END LOOP;

    -- -- Conferences (4 rekordy)
    -- INSERT INTO cfr.conferences (name, description, start_time, end_time, country, city, organiser_id) VALUES
    -- ('Future of IT 2025', 'Najnowsze trendy w technologii, AI, Cloud i Security', '2025-05-10 09:00:00+02', '2025-05-12 18:00:00+02', 'PL', 'Warszawa', 1), -- ID 1
    -- ('BioScience Summit', 'Przełomy w biologii, genetyce i medycynie, innowacje w labolatoriach', '2025-09-05 10:00:00+01', '2025-09-07 17:00:00+01', 'GB', 'Londyn', 2), -- ID 2
    -- ('Digital Marketing Expo', 'Strategie marketingowe na 2026, SEO, Social Media, Content', '2026-03-20 08:30:00+01', '2026-03-21 16:30:00+01', 'DE', 'Berlin', 3), -- ID 3
    -- ('Global Economic Forum', 'Dyskusje o przyszłości globalnej ekonomii, rynkach wschodzących i finansach', '2026-11-15 09:30:00-05', '2026-11-17 19:00:00-05', 'US', 'Nowy Jork', 4); -- ID 4
    
    -- Przygotowanie map walut i dat rozpoczęcia konferencji
    SELECT hstore(ARRAY_AGG(id::TEXT), ARRAY_AGG(start_time::TEXT))
    FROM cfr.conferences
    INTO conf_start_dates;

    -- Mapowanie country_code -> currency
    SELECT hstore(ARRAY_AGG(id::TEXT), ARRAY_AGG(CASE 
        WHEN country = 'PL' THEN 'PLN' 
        WHEN country = 'GB' THEN 'GBP' 
        WHEN country = 'DE' THEN 'EUR' 
        WHEN country = 'US' THEN 'USD' 
        ELSE 'EUR' END))
    FROM cfr.conferences
    INTO conf_currencies;

    -- -- Offers (48 rekordów) - DODANO currency
    -- INSERT INTO cfr.offers (name, description, price, currency, max_slots, conference_id) VALUES
    -- -- Conference 1 (ID: 1, PLN)
    -- ('Standard Pass - 3 dni', 'Pełen dostęp do wszystkich sesji głównych', 1299.00, 'PLN', 500, 1),
    -- ('VIP Pass - 3 dni', 'Dostęp VIP, catering, spotkania z prelegentami', 2499.00, 'PLN', 50, 1),
    -- ('Day 1 Ticket', 'Dostęp tylko na pierwszy dzień konferencji', 499.00, 'PLN', 200, 1),
    -- ('Student Pass', 'Zniżka dla studentów (wymaga weryfikacji legitymacji)', 499.00, 'PLN', 100, 1),
    -- ('Online Access', 'Dostęp do nagrań i streamingu wszystkich paneli', 399.00, 'PLN', 1000, 1),
    -- ('Workshop: AI Basics', 'Warsztat wprowadzający do uczenia maszynowego', 350.00, 'PLN', 30, 1),
    -- ('Workshop: Cloud Security', 'Praktyczny warsztat z bezpieczeństwa chmury AWS/Azure', 450.00, 'PLN', 25, 1),
    -- ('Standard + Nocleg', 'Standard Pass + 2 noce w hotelu', 1999.00, 'PLN', 150, 1),
    -- ('Ekspozycja Srebrna', 'Miejsce dla wystawcy (małe stoisko) - 3 dni', 5000.00, 'PLN', 10, 1),
    -- ('Ekspozycja Złota', 'Miejsce dla wystawcy (duże stoisko) - 3 dni', 9000.00, 'PLN', 5, 1),
    -- ('Lunch Add-on', 'Dodatkowy lunch premium w dniu 3', 80.00, 'PLN', 100, 1),
    -- ('Early Bird Standard', 'Standard Pass w niższej cenie (wyprzedane)', 999.00, 'PLN', 100, 1),
    -- -- Conference 2 (ID: 2, GBP)
    -- ('Standard Delegate', 'Pełen dostęp, 3 dni, materiały konferencyjne', 1500.00, 'GBP', 400, 2),
    -- ('Poster Presentation', 'Standard Delegate + miejsce na poster badawczy', 1650.00, 'GBP', 100, 2),
    -- ('Virtual Ticket', 'Tylko sesje online, dostęp do Q&A', 550.00, 'GBP', 800, 2),
    -- ('Gala Dinner Ticket', 'Bilet na uroczystą kolację galową', 180.00, 'GBP', 200, 2),
    -- ('Student Delegate', 'Zniżka dla studentów / doktorantów', 650.00, 'GBP', 150, 2),
    -- ('Lab Tour Add-on', 'Wycieczka do lokalnego laboratorium badawczego', 250.00, 'GBP', 50, 2),
    -- ('Full Delegate + Hotel', 'Standard Delegate + 2 noce w Hotelu A', 2200.00, 'GBP', 120, 2),
    -- ('Day 2 Pass', 'Dostęp tylko na drugi dzień, w tym sesje plenarne', 600.00, 'GBP', 150, 2),
    -- ('Exhibitor Stand Basic', 'Małe stoisko wystawowe dla startupów', 4000.00, 'GBP', 8, 2),
    -- ('Exhibitor Stand Premium', 'Duże stoisko wystawowe w głównej hali', 7500.00, 'GBP', 4, 2),
    -- ('Networking Lunch', 'Lunch w specjalnej strefie networkingowej z zaproszonymi gośćmi', 100.00, 'GBP', 100, 2),
    -- ('Proceedings Book', 'Książka z materiałami z konferencji (twarda oprawa)', 50.00, 'GBP', 500, 2),
    -- -- Conference 3 (ID: 3, EUR)
    -- ('2-Day Full Access', 'Pełen dostęp do paneli, masterclass i targów', 799.00, 'EUR', 700, 3),
    -- ('Expo Only Pass', 'Tylko strefa targowa (2 dni), bez dostępu do prelekcji', 99.00, 'EUR', 2000, 3),
    -- ('Masterclass: SEO 2026', 'Zaawansowany Masterclass SEO (cały dzień)', 599.00, 'EUR', 40, 3),
    -- ('VIP Networking Ticket', 'Dostęp do spotkań B2B i strefy VIP z cateringiem', 1499.00, 'EUR', 80, 3),
    -- ('Masterclass: Social Media Ads', 'Zaawansowany Masterclass Social Media Ads', 499.00, 'EUR', 50, 3),
    -- ('Full Access + Accommodation', '2-Day Full Access + 1 noc w Hostelu City', 999.00, 'EUR', 100, 3),
    -- ('Virtual Masterclass Bundle', 'Dostęp do nagrań wszystkich Masterclass z 3 konferencji', 650.00, 'EUR', 500, 3),
    -- ('1-Day Ticket (Day 1)', 'Dostęp tylko na pierwszy dzień (piątek)', 450.00, 'EUR', 300, 3),
    -- ('Exhibitor Silver', 'Średnie stoisko wystawowe, pakiet marketingowy', 3500.00, 'EUR', 15, 3),
    -- ('Exhibitor Bronze', 'Małe stoisko wystawowe, podstawowy pakiet', 1500.00, 'EUR', 20, 3),
    -- ('Coffee Break Sponsorship', 'Sponsorowanie jednej przerwy kawowej z brandingiem', 2500.00, 'EUR', 2, 3),
    -- ('Post-Expo Cocktail', 'Bilet na imprezę kończącą targi i networking', 120.00, 'EUR', 150, 3),
    -- -- Conference 4 (ID: 4, USD)
    -- ('Executive Pass', 'Pełen dostęp, ekskluzywne sesje, prywatny lunch', 3500.00, 'USD', 300, 4),
    -- ('Academic Pass', 'Dla pracowników naukowych zniżka 50%', 1800.00, 'USD', 100, 4),
    -- ('Virtual Forum Access', 'Dostęp do streamingu wszystkich sesji, materiały cyfrowe', 950.00, 'USD', 1000, 4),
    -- ('Keynote Speaker Dinner', 'Kolacja z głównymi mówcami, tylko dla zaproszonych', 450.00, 'USD', 100, 4),
    -- ('Emerging Leader Ticket', 'Dla młodych liderów (do 30 roku życia) z mentorem', 2200.00, 'USD', 50, 4),
    -- ('Executive + Hotel Suite', 'Executive Pass + 2 noce w apartamencie w NY Grand Hotel', 5500.00, 'USD', 30, 4),
    -- ('Panel Luncheon', 'Lunch w trakcie panelu dyskusyjnego o globalnej ekonomii', 150.00, 'USD', 200, 4),
    -- ('Press Pass', 'Dla akredytowanych dziennikarzy i mediów', 0.00, 'USD', 50, 4),
    -- ('Sponsor Platinum', 'Najwyższy poziom sponsoringu, logo na głównej scenie', 25000.00, 'USD', 3, 4),
    -- ('Sponsor Gold', 'Złoty poziom sponsoringu, stoisko premium', 15000.00, 'USD', 5, 4),
    -- ('Day 3 Only Pass', 'Dostęp tylko na trzeci dzień forum', 1500.00, 'USD', 100, 4),
    -- ('Exclusive Report Access', 'Dostęp do raportu podsumowującego i prognoz', 299.00, 'USD', 500, 4);

    -- -- Activities (6 rekordów) - DODANO currency
    -- INSERT INTO cfr.activities (name, description, start_time, end_time, surcharge, currency, location_name, address_1, address_city, address_zipcode, address_country) VALUES
    -- ('City Tour - Old Town', 'Wycieczka z przewodnikiem po Starym Mieście w Warszawie, w cenie przekąski', '2025-05-11 19:00:00+02', '2025-05-11 22:00:00+02', 50.00, 'PLN', 'Zbiórka przy PKiN', 'Plac Defilad 1', 'Warszawa', '00-901', 'PL'),
    -- ('Networking Mixer', 'Luźne spotkanie networkingowe przy piwie rzemieślniczym i winie', '2025-09-06 18:30:00+01', '2025-09-06 21:00:00+01', 30.00, 'GBP', 'The Pub Loft', '42 Whitechapel High St', 'Londyn', 'E1 7PL', 'GB'),
    -- ('Berlin History Walk', 'Spacer historyczny po Berlinie, mur Berliński i Brama Brandenburska', '2026-03-20 17:00:00+01', '2026-03-20 19:00:00+01', 0.00, 'EUR', 'Brama Brandenburska', 'Pariser Platz', 'Berlin', '10117', 'DE'),
    -- ('Jazz Night in NYC', 'Występ jazzowy w słynnym klubie na Manhattanie, w cenie drink powitalny', '2026-11-16 20:00:00-05', '2026-11-16 23:00:00-05', 100.00, 'USD', 'Blue Note Club', '131 W 3rd St', 'Nowy Jork', '10012', 'US'),
    -- ('Yoga Morning Session', 'Sesja jogi przed konferencją, dla wszystkich poziomów zaawansowania', '2025-05-11 07:00:00+02', '2025-05-11 08:00:00+02', 20.00, 'PLN', 'Sala A', 'ul. Konferencyjna 10', 'Warszawa', '00-001', 'PL'),
    -- ('Science Museum Visit', 'Zwiedzanie Muzeum Nauki w Londynie po godzinach zamknięcia', '2025-09-07 18:00:00+01', '2025-09-07 21:00:00+01', 45.00, 'GBP', 'Science Museum', 'Exhibition Rd', 'Londyn', 'SW7 2DD', 'GB');

    -- -- Accommodations Options (6 rekordów) - DODANO currency
    -- INSERT INTO cfr.accommodation_options (name, description, accommodation_type_id, surcharge, currency, address_1, address_city, address_zipcode, address_country, total_capacity) VALUES
    -- ('Hotel Centrum', '4-gwiazdkowy hotel blisko centrum konferencyjnego (Warszawa)', ac_type_hotel_id, 50.00, 'PLN', 'Al. Jerozolimskie 100', 'Warszawa', '00-801', 'PL', 300),
    -- ('Hostel City', 'Tani hostel z pokojami wieloosobowymi (Warszawa)', ac_type_hostel_id, 0.00, 'PLN', 'ul. Marszałkowska 58', 'Warszawa', '00-545', 'PL', 150),
    -- ('Hotel A', 'Luksusowy hotel w centrum Londynu, widok na Tamizę', ac_type_hotel_id, 120.00, 'GBP', 'Riverbank House', 'Londyn', 'SE1 9PT', 'GB', 200),
    -- ('Pension Schmidt', 'Prywatny pensjonat, blisko metra (Berlin)', ac_type_hotel_id, 20.00, 'EUR', 'Friedrichstraße 200', 'Berlin', '10117', 'DE', 80),
    -- ('NY Grand Hotel', '5-gwiazdkowy hotel na Manhattanie, obok Central Parku', ac_type_hotel_id, 250.00, 'USD', '5th Ave & 59th St', 'Nowy Jork', '10019', 'US', 400),
    -- ('Brooklyn Budget Stay', 'Tani nocleg na Brooklynie, łatwy dojazd do Manhattanu', ac_type_hostel_id, 0.00, 'USD', '120 Dekalb Ave', 'Nowy Jork', '11201', 'US', 100);

    -- -- Room Options (12 rekordów) - DODANO currency
    -- INSERT INTO cfr.room_options (name, description, room_type_id, surcharge, currency, max_persons, total_available_rooms, accommodation_option_id) VALUES
    -- ('Pokój Jednoosobowy', 'Standardowy pokój jednoosobowy z łazienką', room_type_single_id, 0.00, 'PLN', 1, 100, 1),
    -- ('Pokój Dwuosobowy', 'Pokój z dwoma oddzielnymi łóżkami i biurkiem', room_type_twin_id, 50.00, 'PLN', 2, 80, 1),
    -- ('Wielosobowy', 'Łóżko w pokoju wieloosobowym (mieszany)', room_type_hostel_id, 0.00, 'PLN', 4, 30, 2),
    -- ('Dormitorium Kobiece', 'Łóżko w pokoju wieloosobowym tylko dla kobiet', room_type_hostel_id, 0.00, 'PLN', 6, 20, 2),
    -- ('Single Executive', 'Luksusowy pokój jednoosobowy z widokiem', room_type_single_id, 100.00, 'GBP', 1, 50, 3),
    -- ('Double Standard', 'Pokój z łóżkiem małżeńskim (King Size)', room_type_twin_id, 80.00, 'GBP', 2, 70, 3),
    -- ('Small Double', 'Mały pokój dwuosobowy z podstawowym wyposażeniem', room_type_twin_id, 0.00, 'EUR', 2, 30, 4),
    -- ('Apartament', 'Duży pokój z aneksem kuchennym i salonem', room_type_suite_id, 150.00, 'EUR', 3, 15, 4),
    -- ('Executive Suite', 'Luksusowy apartament z widokiem na miasto i obsługą concierge', room_type_suite_id, 400.00, 'USD', 2, 20, 5),
    -- ('Standard King', 'Pokój z łóżkiem typu King-Size i strefą wypoczynkową', room_type_twin_id, 150.00, 'USD', 2, 100, 5),
    -- ('Standard Single', 'Mały pokój jednoosobowy, ekonomiczny', room_type_single_id, 0.00, 'USD', 1, 40, 6),
    -- ('Double Economy', 'Pokój dwuosobowy w niższej cenie, na parterze', room_type_twin_id, 0.00, 'USD', 2, 30, 6);

    -- INSERT INTO cfr.offer_activities (offer_id, activity_id) VALUES
    -- (1, 1), (2, 4), (14, 2), (14, 6), (25, 3), (37, 4), (12, 5);

    -- INSERT INTO cfr.offer_accommodation_options (offer_id, accommodation_option_id) VALUES
    -- (8, 1), (19, 3), (30, 2), (42, 5);

    --------------------------------------------------
    -- 3. Generowanie Danych dla Orders i Payments (1500 zamówień)
    --------------------------------------------------

    FOR i IN 1..500000 LOOP
		select trunc(random() * 1000 + 1) into random_i_var;
        -- Losowy klient (1-100)
        client_id_var := (random_i_var % 100) + 1;

        -- Losowa popularna oferta i jej cena
        offer_id_var := popular_offers[1 + (random_i_var % array_length(popular_offers, 1))];
        order_price := (offer_prices -> offer_id_var::TEXT)::DECIMAL(19,2);

        -- Wyszukanie ID konferencji na podstawie ID oferty
        SELECT conference_id FROM cfr.offers WHERE id = offer_id_var INTO conf_id_var;
        
        -- Pobranie daty rozpoczęcia konferencji i WALUTY
        start_time_conf := (conf_start_dates -> conf_id_var::TEXT)::timestamptz;
        order_currency := (conf_currencies -> conf_id_var::TEXT)::VARCHAR(3);
        
        -- Generowanie purchase_date: losowa data między [start_time_conf - 120 dni] a [start_time_conf - 1 dzień]
        random_purchase_time := start_time_conf - (INTERVAL '1 day' * (FLOOR(random() * 120) + 1));

        -- Logika statusów
        IF (random_i_var % 10) < 7 THEN
            order_status_id_var := os_completed_id;
            payment_status_id_var := ps_paid_id;
        ELSIF (random_i_var % 10) < 9 THEN
            order_status_id_var := os_pending_id;
            payment_status_id_var := ps_pending_id;
        ELSE
            order_status_id_var := os_failed_id;
            payment_status_id_var := ps_failed_id;
        END IF;

        -- Losowe typy płatności i bramki
        payment_type_id_var := CASE (random_i_var % 3)
            WHEN 0 THEN pt_cc_id
            WHEN 1 THEN pt_bt_id
            ELSE pt_pp_id
        END;
        payment_gateway_id_var := CASE (random_i_var % 3)
            WHEN 0 THEN pg_stripe_id
            WHEN 1 THEN pg_payu_id
            ELSE pg_adyen_id
        END;

        -- Wstawienie Orders Z UWZGLĘDNIENIEM currency
        INSERT INTO cfr.orders (order_status_id, total, client_id, purchase_date, currency)
        VALUES (order_status_id_var, order_price, client_id_var, random_purchase_time, order_currency)
        RETURNING id INTO order_id_var;

        -- Wstawienie Offer-Orders
        INSERT INTO cfr.offer_orders (offer_id, order_id)
        VALUES (offer_id_var, order_id_var);

        -- Wstawienie Payments
        INSERT INTO cfr.payments (status_id, payment_type_id, payment_gateway_id, external_id, order_id)
        VALUES (payment_status_id_var, payment_type_id_var, payment_gateway_id_var, 'EXT' || order_id_var::TEXT || 'TSK' || i::TEXT, order_id_var);

    END LOOP;
END $$;