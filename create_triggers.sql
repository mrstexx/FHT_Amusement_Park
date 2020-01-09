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
/** Table Trigger: attraktion_trigger
/** Kind of trigger: Before delete
/** Developer: Marius Hochwald
/** Description: Loggt alle Attraktionen, die abgerissen wurden.
/** Table & Attributes: attraktion and all attraktion attributes
/**
/*********************************************************************/

create table attraktionslog (
	id integer primary key,
	bezeichnung VARCHAR(255),
	zeitstempel timestamp
);


create sequence seq_attraktionslog;

create or replace procedure write_attraktionslog(
	i_bezeichnung char)
as
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_systimestamp timestamp;
  v_cur_seq_attraktionslog integer;
  v_attraktion attraktion%rowtype;
begin
  select systimestamp into v_systimestamp from dual;
  select seq_attraktionslog.nextval into v_cur_seq_attraktionslog from dual;
  select * into v_attraktion from attraktion where bezeichnung = i_bezeichnung;
  insert into attraktionslog values(v_cur_seq_attraktionslog, v_attraktion.bezeichnung, v_systimestamp);
  dbms_output.put_line('neuer Eintrag in Attraktionslog: id=' ||i_bezeichnung||' '||v_systimestamp );
  commit;
end;
/

create or replace trigger attraktionslog_trigger
before delete on attraktion
for each row
begin
	write_attraktionslog(:old.bezeichnung, 'Delete');
END;
/

/*********************************************************************
/**
/** Table Trigger: zimmerkategorie_preischeck_trigger
/** Kind of trigger: Before insert
/** Developer: Marius Hochwald
/** Description: Überprüft beim eintragen eines Preises, dass dieser nicht
/**				 irrtümlich negativ eingetragen wurde.
/** Table & Attributes: zimmerkategorie
/**
/*********************************************************************/

CREATE OR REPLACE TRIGGER zimmerkategorie_preischeck_trigger 
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
/** Table Trigger: pensionsform_preischeck_trigger
/** Kind of trigger: Before insert
/** Developer: Marius Hochwald
/** Description: Überprüft beim Löschen eines Landes,
/**				 dass auch die Orte dementsprechend entfernt werden
/** Table & Attributes: land, ort
/**
/*********************************************************************/

CREATE OR REPLACE TRIGGER pension_preischeck_trigger 
before insert on pensionsform_tageskarte
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