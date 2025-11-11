DELIMITER //

CREATE TRIGGER tr_offer_order_slot_limit
BEFORE INSERT ON cfr.offer_orders
FOR EACH ROW
BEGIN
    -- Deklaracja zmiennych lokalnych
    DECLARE v_max_slots INT;
    DECLARE v_current_orders INT;
    DECLARE v_offer_id INT;
    DECLARE msg VARCHAR(255);

    -- Ustawienie ID oferty z wstawianego wiersza
    SET v_offer_id = NEW.offer_id;

    -- Pobranie maksymalnej liczby slotów
    SELECT max_slots INTO v_max_slots
    FROM cfr.offers
    WHERE id = v_offer_id;

    -- Zliczenie aktualnej liczby zamówień w określonych statusach
    SELECT COUNT(oo.order_id) INTO v_current_orders
    FROM cfr.offer_orders oo
    JOIN cfr.orders o ON oo.order_id = o.id
    WHERE oo.offer_id = v_offer_id
      AND o.order_status_id IN (1, 2, 5);

    -- Sprawdzenie, czy limit został przekroczony
    IF v_current_orders >= v_max_slots THEN
        -- Sformatowanie komunikatu błędu
        SET msg = CONCAT('offer ', v_offer_id, ' is full - limit is ', v_max_slots, ', we have ', v_current_orders, ' in Completed/Pending/Processing status');

        -- Wywołanie wyjątku (błędu)
        SIGNAL SQLSTATE '45000' -- Używa się '45000' dla nieobsłużonych błędów użytkownika
        SET MESSAGE_TEXT = msg;
    END IF;

    -- W MySQL, po prostu kończymy blok BEGIN...END, nie ma potrzeby używania 'RETURN NEW;'
END//

DELIMITER ;