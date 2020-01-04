/*********************************************************************
/**
/** Procedure: sp_room_status
/** In: l_i_roomNr_in
/** Out: l_v_result_ou
/** Developer: Stefan Miljevic
/** Description: A procedure that checks if room with passed room
/**              number is empty. If empty l_v_result_ou is null, otherwise
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

    SELECT DISTINCT anzahl_naechte, zeitstempel
    INTO l_i_num_nights, l_d_timestamp
    FROM zimmer_rechnung
             JOIN rechnung USING (rechnungid)
    WHERE zimmernummer = l_i_roomNr_in
      AND ROWNUM = 1
    ORDER BY anzahl_naechte DESC;

    IF (l_i_num_nights IS NOT NULL) AND (l_d_timestamp IS NOT NULL) THEN
        -- if 0 or positive, room is already empty -> return null
        IF (trunc(sysdate) - (l_d_timestamp + l_i_num_nights)) < 0 THEN
            l_v_result_ou := to_char(l_d_timestamp + l_i_num_nights, 'YYYY-MM-DD HH24:mm');
        END IF;
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