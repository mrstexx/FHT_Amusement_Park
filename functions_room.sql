/*********************************************************************
/**
/** Procedure: sp_room_status
/** In: l_i_roomNr_in
/** Out: l_v_result_ou
/** Developer: Stefan Miljevic
/** Description: A procedure that checks if room with passed room
/**              number is empty now. If empty l_v_result_ou is null, otherwise
/**              is set leaving date in form "YYYY-MM-DD".
/**
/*********************************************************************/
CREATE OR REPLACE PROCEDURE sp_room_status(l_i_roomNr_in IN INT, l_v_result_ou OUT VARCHAR2)
    IS
    l_i_check      INT;
    l_i_num_nights INT;
    l_d_timestamp  DATE;

    x_no_room_number EXCEPTION;
BEGIN
    SELECT count(*) INTO l_i_check FROM zimmer WHERE zimmernummer = l_i_roomNr_in;
    IF l_i_check = 0 THEN
        RAISE x_no_room_number;
    END IF;

    SELECT anzahl_naechte, zeitstempel
    INTO l_i_num_nights, l_d_timestamp
    FROM RECHNUNG
             JOIN ZIMMER_RECHNUNG USING (rechnungid)
    WHERE zimmernummer = l_i_roomNr_in
      AND ZEITSTEMPEL + ANZAHL_NAECHTE > SYSDATE
      AND SYSDATE > ZEITSTEMPEL
      AND ROWNUM = 1
    ORDER BY ZEITSTEMPEL;

    IF (l_i_num_nights IS NOT NULL) AND (l_d_timestamp IS NOT NULL) THEN
        l_v_result_ou := to_char(l_d_timestamp + l_i_num_nights, 'YYYY-MM-DD HH24:MI');
    END IF;

EXCEPTION
    WHEN x_no_room_number THEN
        DBMS_OUTPUT.PUT_LINE('Passed room number ' || l_i_roomNr_in || ' does not exist.');
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('No data found error occurred with passed room number: ' || l_i_roomNr_in);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
END;
/

/*********************************************************************
/**
/** Function: f_is_room_free
/** In: l_i_room_number_in - Room number
/** In: l_d_date_in - Checkin date
/** In: l_i_nights_number_in - Number of nights
/** Developer: Stefan Miljevic
/** Returns: True, if room is free, otherwise false
/** Description: A function that returns boolen value based on room status (occupied or free)
/**
/*********************************************************************/
CREATE OR REPLACE FUNCTION f_is_room_free(l_i_room_number_in IN INTEGER, l_d_date_in IN DATE,
                                          l_i_nights_number_in IN INTEGER) RETURN BOOLEAN
    IS
    l_i_check INT;
    CURSOR cur_room_status IS SELECT ANZAHL_NAECHTE, ZEITSTEMPEL
                              FROM RECHNUNG
                                       JOIN ZIMMER_RECHNUNG USING (rechnungid)
                              WHERE ZIMMERNUMMER = l_i_room_number_in;
    x_no_room_number EXCEPTION;

BEGIN
    SELECT count(*) INTO l_i_check FROM zimmer WHERE zimmernummer = l_i_room_number_in;
    IF l_i_check = 0 THEN
        RAISE x_no_room_number;
    END IF;

    FOR cv_entry IN cur_room_status
        LOOP
            -- check if two date ranges overlapping
            IF (cv_entry.ZEITSTEMPEL <= l_d_date_in + l_i_nights_number_in) AND
               (l_d_date_in <= cv_entry.ZEITSTEMPEL + cv_entry.ANZAHL_NAECHTE) THEN
                RETURN FALSE;
            END IF;
        END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN x_no_room_number THEN
        DBMS_OUTPUT.PUT_LINE('Passed room number ' || l_i_room_number_in || ' does not exist.');
        RETURN TRUE;
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('No data found error occurred with passed room number: ' || l_i_room_number_in);
        RETURN TRUE;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        RETURN TRUE;
END;
/