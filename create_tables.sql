/*********************************************************************
/**
/** Table create
/** Developer: Josef Wermann
/** Description: Script um alle Tabellen zu erstellen
/**
/*********************************************************************/
--lokale Datenbank verwenden, in der die tabellen-namen noch nicht belegt sind

--create tablespace auskommentieren, wenn dieser schon existiert
CREATE TABLESPACE freizeitpark
  datafile '/usr/lib/oracle/xe/oradata/XE/freizeitpark.dbf'
	SIZE 10 M 
	autoextend ON;
	
/*********************************************************************
/**
/** Table: land
/** Developer: Josef Wermann
/** Description: Laendernamen und LaenderIDs
/**
/*********************************************************************/
CREATE TABLE land(
	landID INT PRIMARY KEY,
	bezeichnung VARCHAR(255) UNIQUE NOT NULL)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: ort
/** Developer: Josef Wermann
/** Description: Ortnamen mit zugehöriger PLZ und Land
/**
/*********************************************************************/
CREATE TABLE ort(
	ortID INT PRIMARY KEY,
	plz INT NOT NULL,
	landID INT REFERENCES land(landID) ON DELETE SET NULL,
	bezeichnung VARCHAR(255))
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: person
/** Developer: Josef Wermann
/** Description: generelle Personenuebersicht mit Vorname,
/**              Nachname, Gebdatum, Geschlecht und Land
/**
/*********************************************************************/
CREATE TABLE person(
	personID INT PRIMARY KEY,
	landID INT REFERENCES land(landID) ON DELETE SET NULL,
	vorname VARCHAR(255) NOT NULL,
	nachname VARCHAR(255) NOT NULL,
	geburtsdatum DATE,
	geschlecht VARCHAR(1))
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: gehaltstufe
/** Developer: Josef Wermann
/** Description: Zuordnung Gehaltsstufen und Monatsgehalt
/**
/*********************************************************************/
CREATE TABLE gehaltsstufe(
	gehaltsstufeID INT PRIMARY KEY,
	monatsgehalt FLOAT)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: attraktion
/** Developer: Josef Wermann
/** Description: Attraktionen mit maximaler gleichzeitiger Personenanzahl
/**
/*********************************************************************/
CREATE TABLE attraktion(
	attraktionID INT PRIMARY KEY,
	bezeichnung VARCHAR(255) NOT NULL,
	personenmaximal INT)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: abteilung
/** Developer: Josef Wermann
/** Description: Abteilungsbezeichnungen
/**
/*********************************************************************/
CREATE TABLE abteilung(
	abteilungID INT PRIMARY KEY,
	bezeichnung VARCHAR(255))
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: personal
/** Developer: Josef Wermann
/** Description: Personalzuordnung zu Ort, Gehalt, eventuell Attraktion
/**              Personalnr, SVNR, Adresse und Abteilung
/**
/*********************************************************************/
CREATE TABLE personal(
	personID INT PRIMARY KEY REFERENCES person(personID) ON DELETE CASCADE,
	ortID INT REFERENCES ort(ortID) ON DELETE SET NULL,
	gehaltsstufeID INT REFERENCES gehaltsstufe(gehaltsstufeID) ON DELETE SET NULL,
	attraktionID INT REFERENCES attraktion(attraktionID) ON DELETE SET NULL,
	personalnr VARCHAR(20) UNIQUE NOT NULL,
	svnr VARCHAR(10) UNIQUE NOT NULL,
	adresse VARCHAR(255),
	abteilungID INT REFERENCES abteilung(abteilungID) ON DELETE SET NULL)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: gaeste
/** Developer: Josef Wermann
/** Description: Definition von Personen als Gaesten
/**
/*********************************************************************/
CREATE TABLE gaeste(
	personID INT PRIMARY KEY REFERENCES person(personID) ON DELETE CASCADE)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: gaeste_kinder
/** Developer: Josef Wermann
/** Description: Hilfstabelle Kinder zu Eltern zuordnen
/**
/*********************************************************************/
CREATE TABLE gaeste_kinder(
	personID_elternteil INT REFERENCES gaeste(personID) ON DELETE CASCADE,
	personID_kind INT REFERENCES gaeste(personID) ON DELETE CASCADE)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: pensionsform_tageskarte
/** Developer: Josef Wermann
/** Description: Bezeichnungen von möglichen Karten und Pensionsformen
/**              inkl. Preis
/**
/*********************************************************************/
CREATE TABLE pensionsform_tageskarte(
	pensionsform_tageskarteID INT PRIMARY KEY,
	bezeichnung VARCHAR(255) NOT NULL,
	preis FLOAT NOT NULL)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: zimmerkategorie
/** Developer: Josef Wermann
/** Description: Bezeichnungen von Zimmerkategorien inkl. Preis
/**
/*********************************************************************/
CREATE TABLE zimmerkategorie(
	zimmerkategorieID INT PRIMARY KEY,
	bezeichnung VARCHAR(255) NOT NULL,
	preis FLOAT NOT NULL)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: zimmer
/** Developer: Josef Wermann
/** Description: Zimmernummern mit Zuordnung zu Kategorie, Stock und
/**              Bettenzahl
/**
/*********************************************************************/
CREATE TABLE zimmer(
	zimmernummer INT PRIMARY KEY,
	zimmerkategorieID INT REFERENCES zimmerkategorie(zimmerkategorieID) ON DELETE SET NULL,
	stock INT NOT NULL,
	bettenzahl INT NOT NULL)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: rechnung
/** Developer: Josef Wermann
/** Description: Gesamtrechnungen mit Karte/Pension, Naechtezahl und
/**              Zeitstempel
/**
/*********************************************************************/
CREATE TABLE rechnung(
	rechnungID INT PRIMARY KEY,
	pensionsform_tageskarteID INT REFERENCES pensionsform_tageskarte(pensionsform_tageskarteID) ON DELETE SET NULL,
	anzahl_naechte INT,
	zeitstempel DATE NOT NULL)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: zimmer_rechnung
/** Developer: Josef Wermann
/** Description: Hilfsstabelle für Rechnung des Zimmers
/**
/*********************************************************************/
CREATE TABLE zimmer_rechnung(
	zimmernummer INT REFERENCES zimmer(zimmernummer) ON DELETE CASCADE,
	rechnungID INT REFERENCES rechnung(rechnungID) ON DELETE CASCADE)
TABLESPACE freizeitpark;

/*********************************************************************
/**
/** Table: rechnung_gaeste
/** Developer: Josef Wermann
/** Description: Hilfsstabelle um Rechnung dem GAst zuzuweisen
/**
/*********************************************************************/
CREATE TABLE rechnung_gaeste(
	rechnungID INT REFERENCES rechnung(rechnungID) ON DELETE CASCADE,
	personID INT REFERENCES gaeste(personID) ON DELETE CASCADE)
TABLESPACE freizeitpark;
