DELIMITER //

CREATE PROCEDURE check_order_currency_consistency (IN p_order_id INT, IN p_order_currency CHAR(3))
BEGIN
    DECLARE v_invalid_currency_count INT;
    DECLARE msg VARCHAR(255);

    -- Sprawdzenie, czy wszystkie oferty powiązane z zamówieniem mają tę samą walutę
    SELECT COUNT(o.id) INTO v_invalid_currency_count
    FROM cfr.offer_orders oo
    JOIN cfr.offers o ON oo.offer_id = o.id
    WHERE oo.order_id = p_order_id
      AND o.currency_id <> p_order_currency;

    IF v_invalid_currency_count > 0 THEN
        -- Wygenerowanie błędu, jeśli waluta zamówienia jest niespójna z walutami ofert
        SET msg = CONCAT('order ccy ', p_order_currency, ' is incorrect, bc not all linked offers have same ccy');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END//


-- Trigger 1: Przed INSERT na cfr.orders
CREATE TRIGGER tr_order_currency_check_INSERT
BEFORE INSERT ON cfr.orders
FOR EACH ROW
BEGIN
    -- Waluta i ID są dostępne w NEW
    CALL check_order_currency_consistency(NEW.id, NEW.currency_id);
END//

-- Trigger 2: Przed UPDATE kolumny currency_id na cfr.orders
CREATE TRIGGER tr_order_currency_check_UPDATE
BEFORE UPDATE ON cfr.orders
FOR EACH ROW
BEGIN
    -- Sprawdzamy tylko, jeśli waluta faktycznie się zmienia
    IF OLD.currency_id <> NEW.currency_id THEN
        -- Waluta i ID są dostępne w NEW
        CALL check_order_currency_consistency(NEW.id, NEW.currency_id);
    END IF;
END//


-- Trigger 3: Przed INSERT na cfr.offer_orders
CREATE TRIGGER tr_offer_order_currency_check_INSERT
BEFORE INSERT ON cfr.offer_orders
FOR EACH ROW
BEGIN
    DECLARE v_order_currency CHAR(3);
    
    -- Pobierz walutę zamówienia
    SELECT currency_id INTO v_order_currency
    FROM cfr.orders 
    WHERE id = NEW.order_id;
    
    CALL check_order_currency_consistency(NEW.order_id, v_order_currency);
END//

-- Trigger 4: Przed UPDATE na cfr.offer_orders
CREATE TRIGGER tr_offer_order_currency_check_UPDATE
BEFORE UPDATE ON cfr.offer_orders
FOR EACH ROW
BEGIN
    DECLARE v_order_currency CHAR(3);
    DECLARE v_order_id INT;

    -- Ustal, które zamówienie ma być sprawdzone (zwykle nowe ID, ale jeśli order_id się zmieniło, to też stare)
    SET v_order_id = NEW.order_id;
    
    -- Pobierz walutę zamówienia
    SELECT currency_id INTO v_order_currency
    FROM cfr.orders 
    WHERE id = v_order_id;
    
    CALL check_order_currency_consistency(v_order_id, v_order_currency);

    -- Dodatkowe sprawdzenie, jeśli order_id uległo zmianie (musi być obsłużone osobno)
    IF OLD.order_id <> NEW.order_id THEN
        -- Sprawdzenie dla starego ID zamówienia
        SELECT currency_id INTO v_order_currency
        FROM cfr.orders 
        WHERE id = OLD.order_id;

        CALL check_order_currency_consistency(OLD.order_id, v_order_currency);
    END IF;
END//

DELIMITER ;