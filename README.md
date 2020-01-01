#### Fachhochschule Technikum Wien - Datenbanksysteme Winter Semester 2019 

Abschlussprojekt: Freizeitpark mit Pension


#### To setup database:
- Open php.ini file and comment out line extension=oci8_12c
- Make sure that "instantclient" is installed
- Check if oci8 is installed (sudo pecl install oci8)
- Rename extension in php.ini to "extension=oci8"

For database login is used username: system AND pw: oralce

