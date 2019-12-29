/*********************************************************************
/**
/** Table create index
/** Developer: Josef Wermann
/** Description: Indizes für Tabellen
/**
/*********************************************************************/

create index ind_person on person (nachname, vorname);
create index ind_person_land on person (landID, ortID);
create index ind_ort on ort (landID);
create index ind_personal on personal (abteilungID, attraktionID, gehaltsstufeID);
create index ind_rechnung on rechnung (pensionsform_tageskarteID);
create index ind_zimmer on zimmer (zimmerkategorieID, zimmernummer);
