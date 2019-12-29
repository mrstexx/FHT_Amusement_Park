---------CHECKIN Prozedur begonnen----Nicht fertig!! 

SET serveroutput ON;
/

/*********************************************************************
/**
/** Procedure sp_checkin
/** Out: 
/** In: l_v_nachname_in - Nachname des Gastes.
/** In: l_v_vornamen_in - Vorname des Gastes.
/** Developer: Josef Wermann
/** Description: Description of PL/SQL procedure
/**
/*********************************************************************/

CREATE OR REPLACE PROCEDURE sp_checkin(l_v_vorname_in IN VARCHAR, l_v_nachname_in IN VARCHAR)
AS
	l_i_help INT := 0;
	l_i_maxid INT := 0;

BEGIN

	SELECT MAX(personid) INTO l_i_maxid FROM person; --search max personID
	--check if name + Adress already exists.
	SELECT COUNT(*) INTO l_i_help FROM person RIGHT JOIN gaeste USING(personID) WHERE vorname = l_v_vorname_in AND nachname = l_v_nachname_in; 
		IF l_i_help = 0 THEN
			DBMS_OUTPUT.PUT_LINE('gibts noch nicht');
		ELSE
			DBMS_OUTPUT.PUT_LINE('gibts schon');
		END IF;
		DBMS_OUTPUT.PUT_LINE(l_i_maxid);
END;
/

select * from person;
/
EXEC sp_checkin('Lina', 'Severovic');
/
