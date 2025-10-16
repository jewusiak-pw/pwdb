-- ================================
-- ORGANIZERS
-- ================================
INSERT INTO cfr.organisers (name, description, tax_id, address_1, address_city, address_zipcode, address_country)
VALUES
('TechPol Sp. z o.o.', 'Organizator konferencji technologicznych w Polsce', 'PL1234567890', 'ul. Piękna 12', 'Warszawa', '00-549', 'PL'),
('EuroScience GmbH', 'Niemiecka firma organizująca wydarzenia naukowe', 'DE9988776655', 'Berliner Str. 44', 'Berlin', '10117', 'DE');

-- ================================
-- CONFERENCES (2 przyszłe, 2 przeszłe)
-- ================================
INSERT INTO cfr.conferences (name, description, start_time, end_time, country, city, organiser_id)
VALUES
('AI Future Summit 2026', 'Konferencja o sztucznej inteligencji i etyce danych', '2026-04-15 09:00:00+02', '2026-04-17 18:00:00+02', 'PL', 'Warszawa', 1),
('GreenTech Europe 2026', 'Zrównoważony rozwój i technologie ekologiczne', '2026-09-10 09:00:00+02', '2026-09-12 17:00:00+02', 'DE', 'Berlin', 2),
('Data Science Week 2024', 'Warsztaty i prelekcje dla analityków danych', '2024-05-20 09:00:00+02', '2024-05-23 17:00:00+02', 'PL', 'Kraków', 1),
('CyberSec Days 2023', 'Bezpieczeństwo IT i ochrona danych', '2023-11-12 09:00:00+01', '2023-11-14 17:00:00+01', 'DE', 'Hamburg', 2);

-- ================================
-- ACCOMMODATION TYPES
-- ================================
INSERT INTO cfr.accomodation_types (type_name)
VALUES ('Hotel'), ('Hostel'), ('Brak akomodacji');

-- ================================
-- ROOM TYPES
-- ================================
INSERT INTO cfr.room_types (type_name)
VALUES ('Pokój 1-osobowy'), ('Pokój 2-osobowy'), ('Apartament');

-- ================================
-- ACCOMMODATION OPTIONS
-- ================================
INSERT INTO cfr.accommodation_options (name, description, accommodation_type_id, surcharge, address_1, address_city, address_zipcode, address_country, total_capacity)
VALUES
('Hotel Warszawianka', '4-gwiazdkowy hotel w centrum Warszawy', 1, 450.00, 'ul. Marszałkowska 22', 'Warszawa', '00-590', 'PL', 100),
('EcoHostel Berlin', 'Hostel przyjazny środowisku', 2, 150.00, 'Alexanderplatz 8', 'Berlin', '10178', 'DE', 50),
('Bez noclegu', 'Uczestnik zapewnia własne zakwaterowanie', 3, 0.00, NULL, NULL, NULL, 'PL', 0);

-- ================================
-- ROOM OPTIONS
-- ================================
INSERT INTO cfr.room_options (name, description, room_type_id, surcharge, max_persons, total_available_rooms, accommodation_option_id)
VALUES
('Pokój jednoosobowy', 'Standardowy pokój z łazienką', 1, 0.00, 1, 40, 1),
('Pokój dwuosobowy', 'Pokój z dwoma łóżkami', 2, 100.00, 2, 30, 1),
('Apartament premium', 'Apartament z widokiem na miasto', 3, 300.00, 2, 10, 1),
('Pokój 4-osobowy', 'Pokój współdzielony w hostelu', 2, 0.00, 4, 25, 2);

-- ================================
-- ACTIVITIES
-- ================================
INSERT INTO cfr.activities (name, description, start_time, end_time, surcharge, location_name, address_city, address_country)
VALUES
('Warsztaty Machine Learning', 'Praktyczne zajęcia z uczenia maszynowego', '2026-04-15 10:00:00+02', '2026-04-15 16:00:00+02', 200.00, 'Sala A', 'Warszawa', 'PL'),
('Panel Etyka AI', 'Dyskusja o etyce i odpowiedzialności AI', '2026-04-16 09:00:00+02', '2026-04-16 11:00:00+02', 0.00, 'Audytorium', 'Warszawa', 'PL'),
('Wycieczka po Berlinie', 'Zwiedzanie miasta z przewodnikiem', '2026-09-11 14:00:00+02', '2026-09-11 18:00:00+02', 120.00, 'Berlin Center', 'Berlin', 'DE'),
('Hackathon GreenTech', 'Konkurs programistyczny w tematyce ekologii', '2026-09-12 09:00:00+02', '2026-09-12 17:00:00+02', 0.00, 'Berlin Arena', 'Berlin', 'DE');

-- ================================
-- OFFERS
-- ================================
INSERT INTO cfr.offers (name, description, price, max_slots, conference_id)
VALUES
('Pakiet Standard AI', 'Udział w konferencji AI Future Summit + panel główny', 800.00, 200, 1),
('Pakiet Premium AI', 'Udział + warsztaty ML + hotel', 1300.00, 100, 1),
('Pakiet Green Basic', 'Udział w GreenTech Europe + hackathon', 900.00, 150, 2),
('Pakiet Green Deluxe', 'Udział + wycieczka + hotel', 1250.00, 100, 2);

-- ================================
-- OFFER → ACTIVITIES
-- ================================
INSERT INTO cfr.offer_activities (offer_id, activity_id)
VALUES
(1, 2),
(2, 1),
(3, 4),
(4, 3);

-- ================================
-- OFFER → ACCOMMODATION OPTIONS
-- ================================
INSERT INTO cfr.offer_accommodation_options (offer_id, accommodation_option_id)
VALUES
(2, 1),
(4, 2);

-- ================================
-- CLIENTS
-- ================================
INSERT INTO cfr.clients (name, surname, email, food_preferrence, special_needs, id_no, phone_number, address_1, address_city, address_zipcode, address_country)
VALUES
('Anna', 'Kowalska', 'anna.kowalska@example.com', 'wegetariańska', NULL, 'ABC12345', '+48 600 111 222', 'ul. Lipowa 8', 'Warszawa', '00-310', 'PL'),
('Jan', 'Nowak', 'jan.nowak@example.com', 'standardowa', 'brak', 'XYZ98765', '+48 601 555 777', 'ul. Długa 15', 'Kraków', '31-001', 'PL'),
('Laura', 'Schmidt', 'laura.schmidt@example.de', 'bezglutenowa', NULL, 'DE445566', '+49 160 998877', 'Friedrichstr. 33', 'Berlin', '10117', 'DE');

-- ================================
-- ORDER STATUSES
-- ================================
INSERT INTO cfr.order_statuses (status_name)
VALUES ('Złożone'), ('Opłacone'), ('Anulowane');

-- ================================
-- ORDERS
-- ================================
INSERT INTO cfr.orders (order_status_id, total, client_id)
VALUES
(2, 1300.00, 1),
(1, 900.00, 2),
(2, 1250.00, 3);

-- ================================
-- OFFER ORDERS
-- ================================
INSERT INTO cfr.offer_orders (offer_id, order_id)
VALUES
(2, 1),
(3, 2),
(4, 3);

-- ================================
-- PAYMENT STATUSES / TYPES / GATEWAYS
-- ================================
INSERT INTO cfr.payment_statuses (status_name)
VALUES ('Zakończona'), ('W toku'), ('Nieudana');

INSERT INTO cfr.payment_types (type_name)
VALUES ('Karta'), ('Przelew'), ('BLIK');

INSERT INTO cfr.payment_gateways (gateway_name)
VALUES ('PayU'), ('Stripe'), ('Przelewy24');

-- ================================
-- PAYMENTS
-- ================================
INSERT INTO cfr.payments (status_id, payment_type_id, payment_gateway_id, external_id, order_id)
VALUES
(1, 1, 1, 'PAYU-001-A', 1),
(2, 2, 3, 'P24-998-B', 2),
(1, 1, 2, 'STRIPE-5566-C', 3);
