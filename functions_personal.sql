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
    l_i_counter                 int               := 0;
    CURSOR cur_personal_details IS SELECT *
                                   FROM person
                                            JOIN personal USING (personid);
-- details
    l_personal_tab_type_details personal_tab_type := PERSONAL_TAB_TYPE();
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
/** Procedure: update_personal_data
/** In: l_i_personID_in
/** In: l_i_abteilungID_in
/** In: l_i_gehaltsstufeID_in
/** In: l_i_attraktionID_in
/** Developer: Stefan Miljevic
/** Description: A procedure that updates personal data.
/**
/*********************************************************************/
