DELIMITER //

CREATE TRIGGER tr_activity_time_consistency_INSERT
BEFORE INSERT ON cfr.activities
FOR EACH ROW
BEGIN
    -- Deklaracja zmiennej do przechowywania komunikatu błędu
    DECLARE error_msg VARCHAR(255); 

    IF NEW.end_time IS NOT NULL AND NEW.start_time >= NEW.end_time THEN
        
        -- Przypisanie wyrażenia CONCAT do zmiennej
        SET error_msg = CONCAT(
            'activity start_time (', NEW.start_time, ') has to be < end_time (', NEW.end_time, ')'
        );
        
        -- Wywołanie wyjątku, używając zmiennej
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = error_msg;
    END IF;
END//


CREATE TRIGGER tr_activity_time_consistency_UPDATE
BEFORE UPDATE ON cfr.activities
FOR EACH ROW
BEGIN
    -- Deklaracja zmiennej do przechowywania komunikatu błędu
    DECLARE error_msg VARCHAR(255); 

    IF NEW.end_time IS NOT NULL AND NEW.start_time >= NEW.end_time THEN
        
        -- Przypisanie wyrażenia CONCAT do zmiennej
        SET error_msg = CONCAT(
            'activity start_time (', NEW.start_time, ') has to be < end_time (', NEW.end_time, ')'
        );
        
        -- Wywołanie wyjątku, używając zmiennej
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = error_msg;
    END IF;
END//

DELIMITER ;