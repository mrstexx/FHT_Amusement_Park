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
/** In: l_i_anzahl_naechte_in - Anzahl der N�chte des Aufenhaltes.
/** In: l_v_bezeichnung_in - Bezeichnung der gew�nschten Zimmerkategorie.
/** In: l_v_bezeichnung_form_in - Bezeichnung der gew�nschten Pensionsform.
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
			    IF f_is_room_free(vResult.zimmernummer, TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD'), l_i_anzahl_naechte_in) THEN
                    l_i_zimmernummer := vResult.zimmernummer;
                    EXIT;
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
					COMMIT;
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

--EXEC sp_checkin ('Franz', 'Wadsack','2020-01-22', 3, 'Suite','Vollpension ab 12');


/*********************************************************************
/**
/** Procedure sp_checkin_add_
/** Out: 
/** In: l_v_nachname_in - Nachname des Gastes.
/** In: l_v_vornamen_in - Vorname des Gastes.
/** In: l_d_zeitstempel_in - Ankunftdatum des Gastes.'YYYY-MM-DD'
/** In: l_v_vorname_primary_in - Vorname zu dem der Gast hinzugebucht wird
/** In: l_v_nachname_primary_in - Nachname zu dem der Gast hinzugebucht wird
/** Developer: Alina Poljanc
/** Description: The procedure creates a guest, if it's not existent yet,
/**   					 adds him to a receipt and a room for the given time a the primary guest
/** 						 In case the given name is not found in the person table,
/** 						 there is no bed left in  the room or the person has
/**							 already checked in at another room in the same time, an
/**							 exception is thrown. 
/*********************************************************************/


CREATE OR REPLACE PROCEDURE sp_checkin_add
(l_v_vorname_in IN VARCHAR, l_v_nachname_in IN VARCHAR, l_l_d_zeitstempel_in IN VARCHAR, l_v_vorname_primary_in IN VARCHAR, l_v_nachname_primary_in IN VARCHAR)
AS
-- Cursor for all rooms of an invoice guest
	CURSOR l_rooms_for_invoice_cur
		IS
			SELECT z.zimmernummer
			FROM zimmer z
			JOIN zimmer_rechnung zr
			ON z.zimmernummer = zr.zimmernummer
			WHERE zr.rechnungID = 
				(SELECT r.rechnungID  FROM rechnung r 
				INNER JOIN rechnung_gaeste rg ON rg.rechnungID = r.rechnungID		
				INNER JOIN gaeste g ON g.personID = rg.personID
				INNER JOIN person p ON p.personID = g.personID	
				WHERE p.vorname = l_v_vorname_primary_in
				AND p.nachname = l_v_nachname_primary_in
				AND r.zeitstempel = TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD'))
			ORDER BY z.zimmernummer ASC;
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
	l_i_help_1 INT := 0;
	l_i_bettenanzahl INT := 0;
	l_i_personID person.personID%TYPE := 0;
	l_i_zimmernummer zimmer.zimmernummer%TYPE := 0;
	l_i_rechnungID rechnung.rechnungID%TYPE; 
	l_i_anzahl_naechte INTEGER;
	x_no_checkin_found EXCEPTION;
	x_person_id_not_exists EXCEPTION;
	x_person_id_exists_multiple EXCEPTION;
	x_no_bed_left EXCEPTION;
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

		-- check if primary guest has checked in at given time
		SELECT count(r.rechnungID) INTO l_i_help FROM rechnung r 
		INNER JOIN rechnung_gaeste rg ON rg.rechnungID = r.rechnungID		
		INNER JOIN gaeste g ON g.personID = rg.personID
		INNER JOIN person p ON p.personID = g.personID	
		WHERE p.vorname = l_v_vorname_primary_in
		AND p.nachname = l_v_nachname_primary_in
		AND r.zeitstempel = TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD');
		IF l_i_help <> 1
		THEN
			DBMS_OUTPUT.PUT_LINE('Angegebene Hauptbuchung wurde nicht gefunden!');
			RAISE x_no_checkin_found;
		ELSE	
			SELECT r.rechnungID, r.anzahl_naechte INTO l_i_rechnungID, l_i_anzahl_naechte FROM rechnung r 
			INNER JOIN rechnung_gaeste rg ON rg.rechnungID = r.rechnungID		
			INNER JOIN gaeste g ON g.personID = rg.personID
			INNER JOIN person p ON p.personID = g.personID	
			WHERE p.vorname = l_v_vorname_primary_in
			AND p.nachname = l_v_nachname_primary_in
			AND r.zeitstempel = TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD');
			
			-- check if there is a bed left in the booked room
			FOR vResult IN l_rooms_for_invoice_cur
			LOOP
				SELECT count(rg.personID) INTO l_i_help FROM  rechnung_gaeste rg
				INNER JOIN rechnung r ON rg.rechnungID = r.rechnungID		
				INNER JOIN gaeste g ON g.personID = rg.personID
				INNER JOIN zimmer_rechnung zr ON r.rechnungID = zr.rechnungID	
				INNER JOIN zimmer z ON zr.zimmernummer  = z.zimmernummer
				WHERE z.zimmernummer = vResult.zimmernummer
				AND r.zeitstempel = TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD');
				
				SELECT bettenzahl INTO l_i_help_1 FROM zimmer WHERE zimmernummer = vResult.zimmernummer;
				-- check if checked in guests at a room is smaller than the amount of beds
				DBMS_OUTPUT.PUT_LINE('Zimmer:' || vResult.zimmernummer);
				DBMS_OUTPUT.PUT_LINE('Bettens des Zimmers:' || l_i_help_1);
				
				l_i_bettenanzahl := l_i_bettenanzahl + l_i_help_1;
				DBMS_OUTPUT.PUT_LINE('Bettens Gesamt:' || l_i_bettenanzahl);
				IF(l_i_help < l_i_bettenanzahl)
				THEN
					-- bed is found
					l_i_zimmernummer := vResult.zimmernummer;
					EXIT;
				END IF;
			END LOOP;
			IF l_i_zimmernummer <> 0
			THEN 
				DBMS_OUTPUT.PUT_LINE('Zimmer wurde gefunden!');
				
				-- check if person is already added in guest list
				SELECT count(personID) INTO l_i_help FROM gaeste WHERE personID = l_i_personID;
				-- if not in guest list, add to guest list
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

						SELECT TO_DATE(l_l_d_zeitstempel_in,  'YYYY-MM-DD') + l_i_anzahl_naechte INTO l_d_to_date FROM dual;					
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
				-- create entry in rechnung_gaeste
				INSERT INTO rechnung_gaeste (rechnungID, personID) VALUES (l_i_rechnungID, l_i_personID );
				COMMIT;
			ELSE
				DBMS_OUTPUT.PUT_LINE('Alle Betten der Zimmer der Rechnung sind belegt!');
				RAISE x_no_bed_left;
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
		WHEN x_no_bed_left
		THEN 
			rollback;
			errno := -20466;
			errmsg := 'There is no bed left!';
			raise_application_error(errno,errmsg);
		WHEN x_person_already_checked_in
		THEN 
			rollback;
			errno := -20465;
			errmsg := 'The person entered is already checked in at another room!';
			raise_application_error(errno,errmsg);
		WHEN 	x_no_checkin_found
		THEN
			ROLLBACK;
			errno := -20467;
			errmsg := 'The entered primary guest has not checked in yet!';
			raise_application_error(errno,errmsg);
END;
/

--SELECT * FROM gaeste_view;
--SELECT * FROM person;
--SELECT * FROM zimmer WHERE zimmernummer = 501; -- 6 Betten

-- EXEC sp_checkin_add ('Ivy', 'Koller','2020-01-05', 'Lina', 'Severovic');

/*********************************************************************
/**
/** Procedure sp_checkin_add_room
/** Out: 
/** In: l_d_zeitstempel_in - Ankunftdatum des Gastes.'YYYY-MM-DD'
/** In: l_v_vorname_primary_in - Vorname zu dem das Zimmer hinzugebucht wird
/** In: l_v_nachname_primary_in - Nachname zu dem das Zimmer hinzugebucht wird
/** In: l_v_bezeichnung_in - Bezeichnung der gew�nschten Zimmerkategorie.
/** Developer: Alina Poljanc
/** Description: The procedure adds a room to an existing invoice
/**   					 In case the given name is not found in the person table,
/** 						 there is no room left in the wished category  an
/**							 exception is thrown. 
/*********************************************************************/


CREATE OR REPLACE PROCEDURE sp_checkin_add_room
(l_d_zeitstempel_in IN VARCHAR,l_v_vorname_primary_in IN VARCHAR, l_v_nachname_primary_in IN VARCHAR, l_v_bezeichnung_in IN VARCHAR)
AS
-- Cursor for all rooms of a category
	CURSOR l_room_for_category_cur
		IS
			SELECT zimmernummer
			FROM zimmer
			WHERE zimmerkategorieID = (SELECT zimmerkategorieID FROM zimmerkategorie WHERE bezeichnung = l_v_bezeichnung_in)
			ORDER BY zimmernummer ASC;

	l_i_help INT := 0;
	l_i_anzahl_naechte INT; 	
	l_i_personID person.personID%TYPE := 0;
	l_i_zimmernummer zimmer.zimmernummer%TYPE := 0;
	l_i_rechnungID rechnung.rechnungID%TYPE;
	x_person_id_not_exists EXCEPTION;
	x_person_id_exists_multiple EXCEPTION;
	x_no_room_available EXCEPTION;
  errno INTEGER; 
	errmsg char(200);
BEGIN
-- check if person exists
	SELECT count(personid) INTO l_i_help FROM person WHERE vorname = l_v_vorname_primary_in AND nachname = l_v_nachname_primary_in; 
	
	IF l_i_help = 0
	THEN
		DBMS_OUTPUT.PUT_LINE('Person existiert nicht!');
		RAISE x_person_id_not_exists;
	ELSIF l_i_help = 1
	THEN
		-- get personID  of primary guest
		SELECT personID INTO l_i_personID FROM person WHERE vorname = l_v_vorname_primary_in AND nachname = l_v_nachname_primary_in;
		
		-- get rechnungID of invoice and anzahl_naechte 
		SELECT count(r.rechnungID) INTO l_i_help FROM rechnung r
		INNER JOIN rechnung_gaeste rg ON rg.rechnungID = r.rechnungID
		INNER JOIN gaeste g ON g.personID = rg.personID
		INNER JOIN person p ON p.personID = g.personID
		WHERE p.personID = l_i_personID
		AND r.zeitstempel = TO_DATE(l_d_zeitstempel_in,  'YYYY-MM-DD');
		
		IF l_i_help <> 1
		THEN
			DBMS_OUTPUT.PUT_LINE('Person hat zu dem angegebenen Datum noch nichts gebucht!');
			RAISE x_no_room_available;
		END IF;
		
		SELECT r.rechnungID, r.anzahl_naechte INTO l_i_rechnungID, l_i_anzahl_naechte FROM rechnung r
		INNER JOIN rechnung_gaeste rg ON rg.rechnungID = r.rechnungID
		INNER JOIN gaeste g ON g.personID = rg.personID
		INNER JOIN person p ON p.personID = g.personID
		WHERE p.personID = l_i_personID
		AND r.zeitstempel = TO_DATE(l_d_zeitstempel_in,  'YYYY-MM-DD');
		
		-- check if zimmerkategorie is valid 
		SELECT count(zimmerkategorieID) INTO l_i_help FROM zimmerkategorie WHERE bezeichnung = l_v_bezeichnung_in;
		IF l_i_help <> 1
		THEN
			DBMS_OUTPUT.PUT_LINE('Zimmerkategorie konnte nicht gefunden werden!');
			RAISE x_no_room_available;
		ELSE	
			-- find room in given category
			FOR vResult IN l_room_for_category_cur
			LOOP
                IF f_is_room_free(vResult.zimmernummer, TO_DATE(l_d_zeitstempel_in,  'YYYY-MM-DD'), l_i_anzahl_naechte) THEN
                    l_i_zimmernummer := vResult.zimmernummer;
                    EXIT;
                END IF;
			END LOOP;
			IF l_i_zimmernummer <> 0
			THEN 
				DBMS_OUTPUT.PUT_LINE('Zimmer wurde gefunden!');
				-- create entry in zimmer_rechnung
					INSERT INTO zimmer_rechnung (zimmernummer, rechnungID) VALUES (l_i_zimmernummer,l_i_rechnungID);	
					COMMIT;		
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
END;
/


--SELECT * FROM gaeste_view;
--SELECT * FROM person;
--SELECT * FROM zimmer WHERE zimmernummer = 504; -- 6 Betten

--EXEC sp_checkin_add ('Ivy', 'Koller','2020-01-05', 'Lina', 'Severovic');
--EXEC sp_checkin_add_room ('2020-01-05', 'Lina', 'Severovic', 'Suite');


/
