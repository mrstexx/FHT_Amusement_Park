SET serveroutput ON;
/

/*********************************************************************
/**
/** Object-type: PERSONAL_OBJ_TYPE | PERSONAL_TAB_TYPE
/** Developer: Stefan Miljevic
/** Description: generelle Personaluebersicht mit PersonID, Vorname,
/**              Nachname, Geschlecht, AbteilungID, GehaltsstufeID und AttraktionID
/**
/*********************************************************************/
CREATE OR REPLACE TYPE PERSONAL_OBJ_TYPE IS OBJECT
(
    personID       INT,
    vorname        VARCHAR(255),
    nachname       VARCHAR(255),
    geschlecht     VARCHAR(1),
    abteilungID    INT,
    gehaltsstufeID INT,
    attraktionID   INT
);
/

CREATE OR REPLACE TYPE PERSONAL_TAB_TYPE IS TABLE OF PERSONAL_OBJ_TYPE;
/


/*********************************************************************
/**
/** Function: f_getPersonalData_personal_type
/** Developer: Stefan Miljevic
/** Returns: PERSONAL_TAB_TYPE
/** Description: A function that returns data to be visible in the app.
/**
/*********************************************************************/
CREATE OR REPLACE FUNCTION f_getPersonalData_type RETURN PERSONAL_TAB_TYPE
    IS
    l_i_counter                 INT               := 0;
    CURSOR cur_personal_details IS SELECT *
                                   FROM person
                                            JOIN personal USING (personid);
-- details
    l_personal_tab_type_details PERSONAL_TAB_TYPE := PERSONAL_TAB_TYPE();
BEGIN
    FOR cv_record IN cur_personal_details
        LOOP
            -- extend table
            l_personal_tab_type_details.extend;
            l_i_counter := l_i_counter + 1;
            l_personal_tab_type_details(l_i_counter) :=
                    PERSONAL_OBJ_TYPE(cv_record.personid, cv_record.vorname, cv_record.nachname, cv_record.geschlecht,
                                      cv_record.abteilungid, cv_record.gehaltsstufeid, cv_record.attraktionid);
        END LOOP;
    RETURN l_personal_tab_type_details;
END;
/

-- execute with SELECT * FROM TABLE (f_getPersonalData_type);

/*********************************************************************
/**
/** Procedure: sp_updatePersonalData
/** In: l_i_personID_in
/** In: l_i_newAbteilungID_in
/** In: l_i_newGehaltsstufeID_in
/** In: l_i_newAttraktionID_in
/** Developer: Stefan Miljevic
/** Description: A procedure that updates personal data.
/**
/*********************************************************************/
CREATE OR REPLACE PROCEDURE sp_updatePersonalData(l_i_personID_in IN INT,
                                                  l_i_newAbteilungID_in IN INT,
                                                  l_i_newGehaltsstufeID_in IN INT,
                                                  l_i_newAttraktionID_in IN INT)
    IS
    l_i_check INT;
    x_person_id_not_exists EXCEPTION;

BEGIN
    -- save state before update
    SAVEPOINT update_personal_begin;
    -- check for person id
    SELECT count(*) INTO l_i_check FROM personal WHERE personid = l_i_personID_in;
    IF l_i_check = 0 THEN
        RAISE x_person_id_not_exists;
    END IF;
    -- update personal
    UPDATE personal
    SET abteilungid    = l_i_newAbteilungID_in,
        gehaltsstufeid = l_i_newGehaltsstufeID_in,
        attraktionid   = l_i_newAttraktionID_in
    WHERE personid = l_i_personID_in;
    -- commit changes
    COMMIT;
EXCEPTION
    WHEN x_person_id_not_exists THEN
        DBMS_OUTPUT.put_line('Entered PersonID does not exist.');
        ROLLBACK TO update_personal_begin;
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Oracle Error Code: ' || SQLCODE);
        DBMS_OUTPUT.put_line('Oracle Error Message: ' || SQLERRM);
        ROLLBACK TO update_personal_begin;
        RAISE;
END;
/