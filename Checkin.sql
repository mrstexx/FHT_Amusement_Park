---------CHECKIN Prozedur begonnen----Nicht fertig!! 

SET serveroutput ON;
/
/*********************************************************************
/**
/** Sequence seq_rechnung
/** Developer: Alina Poljanc
/** Description: Sequence for the primary key for the rechnung table
/*********************************************************************/

DECLARE
    l_i_start INTEGER :=1 ;
    l_i_help INTEGER :=0 ;
BEGIN
	SELECT count(rechnungID) INTO l_i_help FROM rechnung;
	IF l_i_help <> 0
	THEN
  	SELECT max(rechnungID) + 1
  	INTO   l_i_start
  	FROM   rechnung;
	END IF;
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_rechnung
                       START WITH ' || l_i_start ||
                       ' INCREMENT BY 1';
END;
/
--SELECT * FROM rechnung;

/*********************************************************************
/**
/** Procedure sp_checkin
/** Out: 
/** In: l_v_nachname_in - Nachname des Gastes.
/** In: l_v_vornamen_in - Vorname des Gastes.
/** In: l_d_zeitstempel_in - Ankunftdatum des Gastes.'YYYY-MM-DD'
/** In: l_i_anzahl_naechte_in - Anzahl der Nächte des Aufenhaltes.
/** In: l_v_bezeichnung_in - Bezeichnung der gewünschten Zimmerkategorie.
/** In: l_v_bezeichnung_form_in - Bezeichnung der gewünschten Pensionsform.
/** Developer: Josef Wermann + Alina Poljanc
/** Description: The procedure creates a guest, if it's not existent yet,
/**   					 a receipt and reserves a room for the given time, pensionform and category. 
/** 						 In case the given name is not found in the person table,
/** 						 there is no room in the wished category or the person has
/**							 already checked in at another room in the same time, an
/**							 exception is thrown. 
/*********************************************************************/

CREATE OR REPLACE PROCEDURE sp_checkin
(l_v_vorname_in IN VARCHAR, l_v_nachname_in IN VARCHAR, l_l_d_zeitstempel_in IN VARCHAR, l_i_anzahl_naechte_in IN INTEGER, l_v_bezeichnung_in IN VARCHAR, l_v_bezeichnung_form_in IN VARCHAR)
AS
-- Cursor for all rooms of a category
	CURSOR l_room_for_category_cur
		IS
			SELECT zimmernummer
			FROM zimmer
			WHERE zimmerkategorieID = (SELECT zimmerkategorieID FROM zimmerkategorie WHERE bezeichnung = l_v_bezeichnung_in)
			ORDER BY zimmernummer ASC;
-- Cursor for all invoices of one guest
	CURSOR l_room_for_person_cur
		IS
			SELECT *
			FROM rechnung r
			JOIN rechnung_gaeste g
			ON r.rechnungID = g.rechnungID
			WHERE g.personID = (SELECT personID FROM person WHERE vorname = l_v_vorname_in AND nachname = l_v_nachname_in)
			ORDER BY r.rechnungID ASC;
	l_i_help INT := 0;
	l_i_personID person.personID%TYPE := 0;
	l_i_zimmernummer zimmer.zimmernummer%TYPE := 0;
	l_i_rechnungID rechnung.rechnungID%TYPE; 
	l_i_pensionsform INTEGER; 
	l_v_result_room_status VARCHAR2(200); 
	x_person_id_not_exists EXCEPTION;
	x_person_id_exists_multiple EXCEPTION;
	x_no_room_available EXCEPTION;
	x_no_pensionsform_available EXCEPTION;
  x_person_already_checked_in EXCEPTION;
  errno INTEGER; 
	errmsg char(200);
BEGIN
-- check if person exists
	SELECT count(personid) INTO l_i_help FROM person WHERE vorname = l_v_vorname_in AND nachname = l_v_nachname_in; 
	
	IF l_i_help = 0
	THEN
		DBMS_OUTPUT.PUT_LINE('Person existiert nicht!');
		RAISE x_person_id_not_exists;
	ELSIF l_i_help = 1
	THEN
		SELECT personID INTO l_i_personID FROM person WHERE vorname = l_v_vorname_in AND nachname = l_v_nachname_in;
		SELECT count(zimmerkategorieID) INTO l_i_help FROM zimmerkategorie WHERE bezeichnung = l_v_bezeichnung_in;
		IF l_i_help <> 1
		THEN
			DBMS_OUTPUT.PUT_LINE('Zimmerkategorie konnte nicht gefunden werden!');
			RAISE x_no_room_available;
		ELSE	
			FOR vResult IN l_room_for_category_cur
			LOOP
				BEGIN
					sp_room_status(vResult.zimmernummer,l_v_result_room_status);
				END;
				IF l_v_result_room_status IS NULL
				THEN 
					l_i_zimmernummer := vResult.zimmernummer;
					EXIT;
				ELSE
					DECLARE
						l_d_to_date DATE; 
					BEGIN 
						SELECT TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') + l_i_anzahl_naechte_in INTO l_d_to_date FROM dual;
						DBMS_OUTPUT.PUT_LINE(l_l_d_zeitstempel_in);
						DBMS_OUTPUT.PUT_LINE(l_v_result_room_status);
						SELECT count(1) INTO l_i_help
						FROM dual 
						WHERE TO_DATE(l_v_result_room_status, 'YYYY-MM-DD HH24:MI') BETWEEN TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') AND l_d_to_date;			
					END;
					IF l_i_help = 1
					THEN
					-- room is available for the timeframe
						l_i_zimmernummer := vResult.zimmernummer;
						EXIT;
					END IF;
				END IF;
			END LOOP;
			IF l_i_zimmernummer <> 0
			THEN 
				DBMS_OUTPUT.PUT_LINE('Zimmer wurde gefunden!');
				
				-- check if person is already added in guest list
				SELECT count(personID) INTO l_i_help FROM gaeste WHERE personID = l_i_personID;
				-- if not in guest list, add to get list
				IF l_i_help = 0
				THEN
				 INSERT INTO gaeste (personID)VALUES (l_i_personID);
				END IF;
				-- check if guest is aleady checked in for another room in the same timeframe				
				FOR vResult IN l_room_for_person_cur
				LOOP
					DECLARE
						l_d_to_date DATE; 
						l_d_to_date_1 DATE; 
						l_i_start INTEGER ;
						l_i_end INTEGER;
					BEGIN
						l_i_start := 0;
						l_i_end := 0;
						l_i_help := 0;

						SELECT TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') + l_i_anzahl_naechte_in INTO l_d_to_date FROM dual;					
						SELECT count(1) INTO l_i_start 
							FROM dual 
							WHERE vResult.zeitstempel BETWEEN TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') AND l_d_to_date;		

						SELECT vResult.zeitstempel + vResult.anzahl_naechte INTO l_d_to_date_1 FROM dual;					 
						SELECT count(1) INTO l_i_end
							FROM dual 
							WHERE l_d_to_date_1 BETWEEN TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') AND l_d_to_date;	
						l_i_help := l_i_start + l_i_end;
						IF l_i_help <> 0
						THEN
						DBMS_OUTPUT.PUT_LINE('Person ist in demselben Zeitraum schon auf einem anderen Zimmer gebucht!');
						RAISE x_person_already_checked_in;
						EXIT;
						END IF;
					END;
				END LOOP;


				-- check if l_v_bezeichnung_form_in  is null
				IF l_v_bezeichnung_form_in IS NULL
				THEN
				 	-- create entry in rechnung 
				 	SELECT seq_rechnung.NEXTVAL INTO l_i_rechnungID FROM DUAL;
				 	INSERT INTO rechnung (rechnungID,pensionsform_tageskarteID, anzahl_naechte, zeitstempel)
				 	VALUES (l_i_rechnungID, NULL,l_i_anzahl_naechte_in,TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') );
					-- create entry in zimmer_rechnung
					INSERT INTO zimmer_rechnung (zimmernummer, rechnungID) VALUES (l_i_zimmernummer,l_i_rechnungID);
					-- create entry in rechnung_gaeste
					INSERT INTO rechnung_gaeste (rechnungID, personID) VALUES (l_i_rechnungID, l_i_personID );
				ELSE
					-- check if form exists
					SELECT count(pensionsform_tageskarteID) INTO l_i_help FROM pensionsform_tageskarte WHERE bezeichnung = l_v_bezeichnung_form_in;
					
					IF l_i_help = 1
					THEN
						-- if form exists proceed
						SELECT pensionsform_tageskarteID INTO l_i_pensionsform FROM pensionsform_tageskarte WHERE bezeichnung = l_v_bezeichnung_form_in;
						
						-- create entry in rechnung 
				 		SELECT seq_rechnung.NEXTVAL INTO l_i_rechnungID FROM DUAL;
				 		
						INSERT INTO rechnung (rechnungID,pensionsform_tageskarteID, anzahl_naechte, zeitstempel)
				 		VALUES (l_i_rechnungID, l_i_pensionsform,l_i_anzahl_naechte_in,TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') );
						-- create entry in zimmer_rechnung
						INSERT INTO zimmer_rechnung (zimmernummer, rechnungID) VALUES (l_i_zimmernummer,l_i_rechnungID);
						-- create entry in rechnung_gaeste
						INSERT INTO rechnung_gaeste (rechnungID, personID) VALUES (l_i_rechnungID, l_i_personID );
						COMMIT;
					ELSE
						-- else raise exception
						DBMS_OUTPUT.PUT_LINE('Pensionsform konnte nicht gefunden werden!');
						RAISE	x_no_pensionsform_available;
					END IF;
				END IF;
			ELSE
				DBMS_OUTPUT.PUT_LINE('Kein Zimmer in der angegebenenen Kategorie verfuegbar!');
				RAISE x_no_room_available;
			END IF;
		END IF;
	ELSE 
		DBMS_OUTPUT.PUT_LINE('Person existiert mehrmals!');
		RAISE x_person_id_exists_multiple;
	END IF;
	
EXCEPTION
		WHEN x_person_id_not_exists 
		THEN 
			rollback;
			errno := -20461;
			errmsg := 'PersonID does not exists with given firstname and surname!';
			raise_application_error(errno,errmsg);	
		WHEN x_person_id_exists_multiple
		THEN 
			rollback;
			errno := -20462;
			errmsg := 'PersonID exists multiple times with given firstname and surname!';
			raise_application_error(errno,errmsg);
		WHEN x_no_room_available
		THEN 
			rollback;
			errno := -20463;
			errmsg := 'There is no room for the given category or at the given timeframe available!';
			raise_application_error(errno,errmsg);
		WHEN x_no_pensionsform_available
		THEN 
			rollback;
			errno := -20464;
			errmsg := 'The entered pensionform is invalid!';
			raise_application_error(errno,errmsg);
		WHEN x_person_already_checked_in
		THEN 
			rollback;
			errno := -20465;
			errmsg := 'The person entered is already checked in at another room!';
			raise_application_error(errno,errmsg);
END;
/
/*****************************************************************************************
select * from person;
select * from zimmerkategorie;
select * from pensionsform_tageskarte;
select * from rechnung;
/
 
EXEC sp_checkin ('Lina', 'Severovic','2020-01-22', 3, 'Suite','Vollpension ab 12');
/
*****************************************************************************************/



