/*********************************************************************
/**
/** Table View: personal_view
/** Developer: Josef Wermann
/** Description: Der View zeigt alle Personalmitglieder mit Personalnummer,
/**							 Nachname, Vorname, Alter, Geschlecht, Gehalt, 
/**              Abteilungsbezeichnung und falls vorhanden zugewiesener
/** 						 Attraktion an.
/**
/*********************************************************************/

CREATE OR REPLACE VIEW personal_view
AS
					SELECT personalnr, nachname, vorname,
								 (TRUNC(MONTHS_BETWEEN(SYSDATE, geburtsdatum)/12)) AS "ALTER",
								 geschlecht, monatsgehalt, abteilung.bezeichnung AS abteilung,
								 attraktion.bezeichnung AS attraktion
					FROM person JOIN personal USING(personID)
											JOIN gehaltsstufe USING(gehaltsstufeID)
											JOIN abteilung USING(abteilungID)
											LEFT JOIN attraktion USING(attraktionID);

--SELECT * FROM personal_view;

/*********************************************************************
/**
/** Table View: kinder_view
/** Developer: Josef Wermann
/** Description: Der View zeigt bei Gaesten zu allen Kindern die	
/**              dazugeh�rigen Eltern an (bzw, falls nur ein 
/**              Elternteil bekannt ist, nur dieses.)
/**
/*********************************************************************/

CREATE OR REPLACE VIEW kinder_view
AS

	WITH kind AS (SELECT vorname || ' ' || nachname AS name_kind, personID_kind, personID_elternteil
		  			    FROM gaeste_kinder JOIN gaeste ON(personID_kind = personID)
			  											     JOIN person USING(personID)),

     mutter AS (SELECT vorname || ' ' || nachname AS name_mutter, personID_kind, personID_elternteil
				  	    FROM gaeste_kinder JOIN gaeste ON(personID_elternteil = personID)
					  									     JOIN person USING(personID)
					  		WHERE geschlecht = 'w'),

     vater AS (SELECT vorname || ' ' || nachname AS name_vater, personID_kind, personID_elternteil
				  	    FROM gaeste_kinder JOIN gaeste ON(personID_elternteil = personID)
					  									     JOIN person USING(personID)
					  		WHERE geschlecht = 'm')
/**
--OLD
SELECT name_kind, name_mutter, name_vater
FROM kind LEFT JOIN mutter USING(personID_kind, personID_elternteil)
          LEFT JOIN vater USING(personID_kind, personID_elternteil)
ORDER BY name_kind;
**/

--NEW
SELECT DISTINCT name_kind, name_mutter, name_vater
FROM kind LEFT JOIN mutter USING(personID_kind)
          LEFT JOIN vater USING(personID_kind)
ORDER BY name_kind;

--SELECT * FROM kinder_view;

/


/*********************************************************************
/**
/** Table View: zimmer_view
/** Developer: Stefan Miljevic
/** Description: Der View zeigt die Zimmerinformationen
/**              (nummer, bezeichnung und preise)
/**
/*********************************************************************/
CREATE OR REPLACE VIEW zimmer_view AS
SELECT zimmernummer, bezeichnung, preis
FROM zimmer
         JOIN zimmerkategorie USING (zimmerkategorieid)
ORDER BY zimmernummer;

-- SELECT * FROM zimmer_view;


/*********************************************************************
/**
/** Table View: rechnung_view
/** Developer: Stefan Miljevic
/** Description: Der View zeigt die basis Rechnungsinformationen
/**             (rechnungsID, zeitstempel, anzahl der naechte und
/**              pensionsform bezeichnung). Dieser View wird fuer
/**              darstellung der Rechnungsdaten verwendet.
/**
/*********************************************************************/
CREATE OR REPLACE VIEW rechnung_view
AS
SELECT rechnungid,
       zeitstempel,
       anzahl_naechte,
       bezeichnung
FROM rechnung
         JOIN pensionsform_tageskarte USING (pensionsform_tageskarteID);
/
-- SELECT * FROM rechnung_view;