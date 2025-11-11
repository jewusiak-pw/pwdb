DELIMITER //

CREATE TRIGGER tr_conference_time_consistency_INSERT
BEFORE INSERT ON cfr.conferences
FOR EACH ROW
BEGIN
    -- Deklaracja zmiennej do przechowywania komunikatu błędu
    DECLARE error_msg VARCHAR(255); 

    -- Sprawdzenie, czy start_time nie jest późniejsze/równe end_time
    IF NEW.start_time >= NEW.end_time THEN
        
        -- Przypisanie wyrażenia CONCAT do zmiennej
        SET error_msg = CONCAT(
            'start_time (', NEW.start_time, ') has to be < end_time (', NEW.end_time, ')'
        );
        
        -- Wywołanie wyjątku, używając zmiennej
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = error_msg;
    END IF;
END//


CREATE TRIGGER tr_conference_time_consistency_UPDATE
BEFORE UPDATE ON cfr.conferences
FOR EACH ROW
BEGIN
    -- Deklaracja zmiennej do przechowywania komunikatu błędu
    DECLARE error_msg VARCHAR(255); 

    -- Sprawdzenie, czy start_time nie jest późniejsze/równe end_time
    IF NEW.start_time >= NEW.end_time THEN
        
        -- Przypisanie wyrażenia CONCAT do zmiennej
        SET error_msg = CONCAT(
            'start_time (', NEW.start_time, ') has to be < end_time (', NEW.end_time, ')'
        );
        
        -- Wywołanie wyjątku, używając zmiennej
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = error_msg;
    END IF;
END//

DELIMITER ;