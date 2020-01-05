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

/*********************************************************************
/**
/** Table View: gaeste_view
/** Developer: Alina Poljanc
/** Description: This view shows the for the guests relevant data. 
/**
/*********************************************************************/
CREATE OR REPLACE VIEW gaeste_view
AS
	SELECT p.vorname AS vorname, p.nachname AS nachname, z.zimmernummer AS zimmernummer, zk.bezeichnung AS Zimmerkategorie, pt.bezeichnung AS pensionsform, r.zeitstempel AS von, (r.zeitstempel + r.anzahl_naechte) AS bis FROM person p
	INNER JOIN gaeste g ON p.personID = g.personID	
	INNER JOIN rechnung_gaeste rg ON g.personID = rg.personID
	INNER JOIN rechnung r ON rg.rechnungID = r.rechnungID
	INNER JOIN zimmer_rechnung zr ON zr.rechnungID = r.rechnungID
	INNER JOIN zimmer z ON z.zimmernummer  = zr.zimmernummer
	LEFT JOIN zimmerkategorie zk ON zk.zimmerkategorieID  = z.zimmerkategorieID
	LEFT JOIN pensionsform_tageskarte pt ON pt.pensionsform_tageskarteID  = r.pensionsform_tageskarteID;
/
--select * from gaeste_view;

/*********************************************************************
/**
/** Type  + Function : t_varchar2_tab + tab_to_string 
/** Developer: ORACLE 
/** Description: Enables to create the gaeste_view grouped in Oracle 10g 
/**								--> see https://oracle-base.com/articles/misc/string-aggregation-techniques#collect
/*********************************************************************/


CREATE OR REPLACE TYPE t_varchar2_tab AS TABLE OF VARCHAR2(4000);
/

CREATE OR REPLACE FUNCTION tab_to_string (p_varchar2_tab  IN  t_varchar2_tab,
                                          p_delimiter     IN  VARCHAR2 DEFAULT ',') RETURN VARCHAR2 IS
  l_string     VARCHAR2(32767);
BEGIN
  FOR i IN p_varchar2_tab.FIRST .. p_varchar2_tab.LAST LOOP
    IF i != p_varchar2_tab.FIRST THEN
      l_string := l_string || p_delimiter;
    END IF;
    l_string := l_string || p_varchar2_tab(i);
  END LOOP;
  RETURN l_string;
END tab_to_string;
/
/*********************************************************************
/**
/** Table View: gaeste_view_grouped
/** Developer: Alina Poljanc
/** Description: This view shows the for the guests relevant data 
/**              grouped by booking and name 
/**
/*********************************************************************/

CREATE OR REPLACE VIEW gaeste_view_grouped
AS
	SELECT  nachname,vorname, von, bis, max(pensionsform) as pensionform,tab_to_string( CAST(COLLECT (TO_CHAR(zimmernummer)) AS t_varchar2_tab))AS zimmernummern
	FROM gaeste_view
	GROUP BY nachname ,vorname, von, bis
	ORDER BY nachname ,vorname, von, bis;  
/
--select * from gaeste_view_grouped;
