set serveroutput on;

/*********************************************************************
/**
/** Table Trigger: age_trigger
/** Kind of trigger: Before insert
/** Developer: Marius Hochwald
/** Description: Überprüft beim eintragen der Person, ob dieser
/**				 eh nicht in der Zukunft auf die Welt kam(kommt).
/** Table & Attributes: person
/**
/*********************************************************************/

CREATE OR REPLACE TRIGGER age_trigger
before insert on person
for each row
declare
	INVALID_DATE EXCEPTION; 
	v_today_timestamp timestamp;
	v_entry_timestamp timestamp;
begin
	select systimestamp into v_today_timestamp from dual;
	IF systimestamp < :new.geburtsdatum THEN
	RAISE INVALID_DATE;
	END IF;
EXCEPTION
	WHEN INVALID_DATE THEN
	BEGIN
	RAISE_APPLICATION_ERROR(-20001,'YOU CANNOT BE BORN IN THE FUTURE');
END;
	
END;
/

/*********************************************************************
/**
/** Table Trigger: zimmerk_preischeck_trigger
/** Kind of trigger: Before insert
/** Developer: Marius Hochwald
/** Description: Überprüft beim eintragen eines Preises, dass dieser nicht
/**				 irrtümlich negativ eingetragen wurde.
/** Table & Attributes: zimmerkategorie
/**
/*********************************************************************/

CREATE OR REPLACE TRIGGER zimmerk_preischeck_trigger 
before insert on zimmerkategorie
for each row
declare
	INVALID_PRICE EXCEPTION;
begin
  IF :new.preis < 0 THEN
  RAISE INVALID_PRICE;
  END IF;
EXCEPTION
	WHEN INVALID_PRICE THEN
	BEGIN
	RAISE_APPLICATION_ERROR(-20002,'THE PARK SHOULD AT LEAST EARN A PENNY');
END;
end;
/

/*********************************************************************
/**
/** Table Trigger: CheckInLog_trigger
/** Kind of trigger: After insert
/** Developer: Marius Hochwald
/** Description: Loggt alle Checkins, die durch die Prozedur durchgeführt
/** werden.
/** Table & Attributes: rechnung_gaeste, person
/**
/*********************************************************************/

create table CheckInLog (
	id integer primary key,
	rechnungID integer,
	vorname varchar(255),
	nachname varchar(255),
	personID integer,
	zeitstempel timestamp
);

create sequence seq_CheckInLog;

create or replace procedure write_CheckInLog(
	i_rechnungID IN int,
	i_personID IN int)
as
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_systimestamp timestamp;
  v_cur_seq_CheckInLog integer;
  v_person person%rowtype;
begin
	select systimestamp into v_systimestamp from dual;
  select seq_CheckInLog.nextval into v_cur_seq_CheckInLog from dual;
  select * into v_person from person where personID = i_personID;
  insert into CheckInLog values(v_cur_seq_CheckInLog, i_rechnungID, v_person.vorname, v_person.nachname, i_personID, v_systimestamp);
  dbms_output.put_line('neuer Eintrag im CheckInLog: PersonenID' || i_personID ||' '|| v_systimestamp );
  commit;
end;
/

create or replace trigger CheckInLog_trigger
after insert on rechnung_gaeste
for each row
begin
	write_CheckInLog(:new.rechnungID, :new.personID);
END;
/

/*********************************************************************
/**
/** Table Trigger: ZimmerLog_trigger
/** Kind of trigger: After insert
/** Developer: Marius Hochwald
/** Description: Erhöht einen Counter jedesmal, wenn ein Zimmer gebucht wurde.
/** 			 Damit lässt sich feststellen,
/**			 	 welche Zimmer am beliebtesten sind.
/** Table & Attributes: zimmer_rechnung
/**
/*********************************************************************/

create table ZimmerLog (
	zimmernummerID integer primary key,
	counter integer DEFAULT 0
);

insert into ZimmerLog (zimmernummerID) select zimmernummer from zimmer;

create or replace procedure write_ZimmerLog(
	i_zimmernummer int)
as
  v_counter int;
begin
  select counter into v_counter from ZimmerLog where zimmernummerID = i_zimmernummer;
  v_counter := v_counter + 1;
  Update ZimmerLog Set counter = v_counter where zimmernummerID = i_zimmernummer;
end;
/

create or replace trigger ZimmerLog_trigger
after insert on zimmer_rechnung
for each row
begin
	write_ZimmerLog(:new.zimmernummer);
END;
/