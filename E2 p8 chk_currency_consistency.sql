DELIMITER //

CREATE PROCEDURE check_offer_currency_consistency (IN p_offer_id INT)
BEGIN
    DECLARE v_offer_currency CHAR(3);
    DECLARE v_invalid_currency_count INT;
    DECLARE msg VARCHAR(512);

    -- 1. Pobierz walutę oferty
    SELECT currency_id INTO v_offer_currency
    FROM cfr.offers
    WHERE id = p_offer_id;

    -- Upewnij się, że waluta oferty została znaleziona
    IF v_offer_currency IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Offer not found or missing currency_id.';
    END IF;

    -- 2. Sprawdź niespójności walut w DZIAŁANIACH (Activities)
    SELECT COUNT(a.id) INTO v_invalid_currency_count
    FROM cfr.offer_activities oa
    JOIN cfr.activities a ON oa.activity_id = a.id
    WHERE oa.offer_id = p_offer_id
      AND a.currency_id <> v_offer_currency;
    
    IF v_invalid_currency_count > 0 THEN
        SET msg = CONCAT('offer ', p_offer_id, ' uses ', v_offer_currency, ', but ', v_invalid_currency_count, ' activities have a different currency');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

    -- 3. Sprawdź niespójności walut w OPCJACH ZAKWATEROWANIA (Accommodation Options)
    SELECT COUNT(ao.id) INTO v_invalid_currency_count
    FROM cfr.offer_accommodation_options oao
    JOIN cfr.accommodation_options ao ON oao.accommodation_option_id = ao.id
    WHERE oao.offer_id = p_offer_id
      AND ao.currency_id <> v_offer_currency;

    IF v_invalid_currency_count > 0 THEN
        SET msg = CONCAT('offer ', p_offer_id, ' uses ', v_offer_currency, ', but ', v_invalid_currency_count, ' accommodation options have a different currency');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

    -- 4. Sprawdź niespójności walut w OPCJACH POKOI (Room Options)
    SELECT COUNT(ro.id) INTO v_invalid_currency_count
    FROM cfr.offer_accommodation_options oao
    JOIN cfr.accommodation_options ao ON oao.accommodation_option_id = ao.id
    JOIN cfr.room_options ro ON ro.accommodation_option_id = ao.id
    WHERE oao.offer_id = p_offer_id
      AND ro.currency_id <> v_offer_currency;

    IF v_invalid_currency_count > 0 THEN
        SET msg = CONCAT('offer ', p_offer_id, ' uses ', v_offer_currency, ', but ', v_invalid_currency_count, ' room options have a different currency');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

END//


CREATE TRIGGER tr_offer_activity_currency_INSERT
BEFORE INSERT ON cfr.offer_activities
FOR EACH ROW
BEGIN
    -- Używamy NEW.offer_id, ponieważ OLD.offer_id nie istnieje przy INSERT
    CALL check_offer_currency_consistency(NEW.offer_id);
END//

CREATE TRIGGER tr_offer_activity_currency_UPDATE
BEFORE UPDATE ON cfr.offer_activities
FOR EACH ROW
BEGIN
    -- Używamy IFNULL(NEW.offer_id, OLD.offer_id) - choć przy UPDATE obie wartości istnieją,
    -- to jest to bezpieczne na wypadek, gdyby pole offer_id nie było aktualizowane.
    DECLARE v_offer_id INT;
    SET v_offer_id = IFNULL(NEW.offer_id, OLD.offer_id);
    
    CALL check_offer_currency_consistency(v_offer_id);
END//


CREATE TRIGGER tr_offer_accommodation_currency_INSERT
BEFORE INSERT ON cfr.offer_accommodation_options
FOR EACH ROW
BEGIN
    -- Przy INSERT używamy NEW.offer_id
    CALL check_offer_currency_consistency(NEW.offer_id);
END//


CREATE TRIGGER tr_offer_accommodation_currency_UPDATE
BEFORE UPDATE ON cfr.offer_accommodation_options
FOR EACH ROW
BEGIN
    -- Używamy IFNULL na wypadek, gdyby oferta nie była aktualizowana (wtedy wciąż sprawdzamy starą/nową)
    DECLARE v_offer_id INT;
    SET v_offer_id = IFNULL(NEW.offer_id, OLD.offer_id);
    
    CALL check_offer_currency_consistency(v_offer_id);
END//


CREATE TRIGGER tr_offer_accommodation_room_options_currency_INSERT
BEFORE INSERT ON cfr.room_options
FOR EACH ROW
BEGIN
    DECLARE v_offer_id INT;
    
    -- Znajdź ID oferty powiązane z nową opcją zakwaterowania
    SELECT oao.offer_id INTO v_offer_id
    FROM cfr.offer_accommodation_options oao
    WHERE oao.accommodation_option_id = NEW.accommodation_option_id
    LIMIT 1;

    -- Jeśli znaleziono ofertę, sprawdź spójność
    IF v_offer_id IS NOT NULL THEN
        CALL check_offer_currency_consistency(v_offer_id);
    END IF;
END//

CREATE TRIGGER tr_offer_accommodation_room_options_currency_UPDATE
BEFORE UPDATE ON cfr.room_options
FOR EACH ROW
BEGIN
    DECLARE v_offer_id INT;
    DECLARE v_acc_opt_id INT;
    
    -- Określ ID opcji zakwaterowania (może się zmienić przy UPDATE)
    SET v_acc_opt_id = IFNULL(NEW.accommodation_option_id, OLD.accommodation_option_id);
    
    -- Znajdź ID oferty powiązane z tą opcją zakwaterowania
    SELECT oao.offer_id INTO v_offer_id
    FROM cfr.offer_accommodation_options oao
    WHERE oao.accommodation_option_id = v_acc_opt_id
    LIMIT 1;

    -- Jeśli znaleziono ofertę, sprawdź spójność
    IF v_offer_id IS NOT NULL THEN
        CALL check_offer_currency_consistency(v_offer_id);
    END IF;
END//

DELIMITER ;
