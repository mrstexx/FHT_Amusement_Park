/*********************************************************************
/**
/** Procedure: sp_calculate_invoice_price
/** In: l_i_invoiceID_in
/** Out: l_n_price_ou
/** Developer: Stefan Miljevic
/** Description: A procedure that calculates final price of one invoice
/**              where invoice id is passed. If an error is occurred
/**              null value is returned in out variable.
/**
/*********************************************************************/
CREATE OR REPLACE PROCEDURE sp_calculate_invoice_price(l_i_invoiceID_in IN INT, l_n_price_ou OUT NUMBER)
    IS

    l_i_check         INT;
    l_f_room_price    zimmerkategorie.preis%TYPE := 0;
    l_f_pension_price pensionsform_tageskarte.preis%TYPE;
    l_i_num_of_nights INT;
    CURSOR cur_invoice_room IS SELECT *
                               FROM zimmer_rechnung
                                        JOIN zimmer USING (zimmernummer)
                                        JOIN zimmerkategorie USING (zimmerkategorieID)
                               WHERE rechnungid = l_i_invoiceID_in;

    x_no_invoice_id EXCEPTION;
    x_wrong_value EXCEPTION;

BEGIN

    -- check for invoice id first
    SELECT count(*) INTO l_i_check FROM rechnung WHERE rechnungid = l_i_invoiceID_in;
    IF l_i_check = 0 THEN
        RAISE x_no_invoice_id;
    END IF;
    -- get num of nights
    SELECT anzahl_naechte INTO l_i_num_of_nights FROM rechnung WHERE rechnungid = l_i_invoiceID_in;
    -- get pensionsform price
    SELECT preis
    INTO l_f_pension_price
    FROM rechnung
             JOIN pensionsform_tageskarte USING (pensionsform_tageskarteID)
    WHERE rechnungid = l_i_invoiceID_in;
    -- get room price
    FOR cv_room IN cur_invoice_room
        LOOP
            IF cv_room.preis IS NOT NULL THEN
                l_f_room_price := l_f_room_price + cv_room.preis;
            END IF;
        END LOOP;
    -- check for values
    IF l_f_room_price IS NOT NULL AND l_f_pension_price IS NOT NULL AND l_i_num_of_nights IS NOT NULL THEN
        -- calculate final price
        l_n_price_ou := (l_f_room_price + l_f_pension_price) * l_i_num_of_nights;
    END IF;

EXCEPTION
    WHEN x_no_invoice_id THEN
        DBMS_OUTPUT.PUT_LINE('Passed invoice ID ' || l_i_invoiceID_in || ' does not exist.');
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('No data found error occurred with passed invoice id: ' || l_i_invoiceID_in);
    WHEN x_wrong_value THEN
        DBMS_OUTPUT.PUT_LINE('Getting wrong value: not possible to calculate final price.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        RAISE;
END;
/


/*********************************************************************
/**
/** Procedure: sp_invoice_guest_list
/** In: l_i_invoiceID_in
/** Out: l_v_guestList_ou
/** Developer: Stefan Miljevic
/** Description: A procedure that gets all guest names by passed
/**              invoice id. If not data available, null is returned.
/**
/*********************************************************************/
CREATE OR REPLACE PROCEDURE sp_invoice_guest_list(l_i_invoiceID_in IN INT, l_v_guestList_ou OUT VARCHAR2)
    IS

    l_i_check INT;
    CURSOR cur_invoice_guest IS SELECT vorname, nachname
                                FROM person
                                         JOIN gaeste USING (personID)
                                         JOIN rechnung_gaeste USING (personID)
                                WHERE rechnungid = l_i_invoiceID_in;

    x_no_invoice_id EXCEPTION;

BEGIN
    -- check for invoice id first
    SELECT count(*) INTO l_i_check FROM rechnung WHERE rechnungid = l_i_invoiceID_in;
    IF l_i_check = 0 THEN
        RAISE x_no_invoice_id;
    END IF;
    -- get all names from cursor
    FOR cv_entry IN cur_invoice_guest
        LOOP
            l_v_guestList_ou := l_v_guestList_ou || cv_entry.vorname || ' ' || cv_entry.nachname || '; ';
        END LOOP;

EXCEPTION
    WHEN x_no_invoice_id THEN
        DBMS_OUTPUT.PUT_LINE('Passed invoice ID ' || l_i_invoiceID_in || ' does not exist.');
    WHEN no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('No data found error occurred with passed invoice id: ' || l_i_invoiceID_in);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        RAISE;
END;
/
