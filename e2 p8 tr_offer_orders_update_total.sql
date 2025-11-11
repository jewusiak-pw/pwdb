DELIMITER //

CREATE TRIGGER tr_offer_orders_insert_update_total
AFTER INSERT ON cfr.offer_orders
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(19, 2);
    
    -- ID zamówienia, które ma zostać zaktualizowane, to NEW.order_id
    
    -- Oblicz nową sumę
    SELECT COALESCE(SUM(o.price), 0)
    INTO v_new_total
    FROM cfr.offer_orders oo
    JOIN cfr.offers o ON oo.offer_id = o.id
    WHERE oo.order_id = NEW.order_id;
    
    -- Zaktualizuj sumę w tabeli orders
    UPDATE cfr.orders
    SET total = v_new_total
    WHERE id = NEW.order_id;
END//

CREATE TRIGGER tr_offer_orders_delete_update_total
AFTER DELETE ON cfr.offer_orders
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(19, 2);
    
    -- ID zamówienia, które ma zostać zaktualizowane, to OLD.order_id
    
    -- Oblicz nową sumę
    SELECT COALESCE(SUM(o.price), 0)
    INTO v_new_total
    FROM cfr.offer_orders oo
    JOIN cfr.offers o ON oo.offer_id = o.id
    WHERE oo.order_id = OLD.order_id;
    
    -- Zaktualizuj sumę w tabeli orders
    UPDATE cfr.orders
    SET total = v_new_total
    WHERE id = OLD.order_id;
END//

CREATE TRIGGER tr_offer_orders_update_update_total
AFTER UPDATE ON cfr.offer_orders
FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(19, 2);
    DECLARE v_old_total DECIMAL(19, 2);

    -- 1. Zaktualizuj stare zamówienie (jeśli order_id się zmieniło)
    IF OLD.order_id <> NEW.order_id THEN
        -- Oblicz sumę dla starego zamówienia
        SELECT COALESCE(SUM(o.price), 0)
        INTO v_old_total
        FROM cfr.offer_orders oo
        JOIN cfr.offers o ON oo.offer_id = o.id
        WHERE oo.order_id = OLD.order_id;

        -- Zaktualizuj stare zamówienie
        UPDATE cfr.orders
        SET total = v_old_total
        WHERE id = OLD.order_id;
    END IF;

    -- 2. Zawsze zaktualizuj nowe zamówienie
    -- Oblicz sumę dla nowego (lub niezmienionego) zamówienia
    SELECT COALESCE(SUM(o.price), 0)
    INTO v_new_total
    FROM cfr.offer_orders oo
    JOIN cfr.offers o ON oo.offer_id = o.id
    WHERE oo.order_id = NEW.order_id;

    -- Zaktualizuj nowe zamówienie
    UPDATE cfr.orders
    SET total = v_new_total
    WHERE id = NEW.order_id;
END//

DELIMITER ;