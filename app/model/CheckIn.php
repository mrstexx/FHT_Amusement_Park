<?php

include "../manager/DatabaseManager.php";

class CheckIn extends DatabaseManager
{

    private function getRoomTypes()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT BEZEICHNUNG FROM ZIMMERKATEGORIE');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->description = $row['BEZEICHNUNG'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function getPensionTypes()
    {
        // TODO: TOO MANY CODE DUPLICATIONS
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT BEZEICHNUNG FROM PENSIONSFORM_TAGESKARTE');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->description = $row['BEZEICHNUNG'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    public function showRoomTypes()
    {
        $data = $this->getRoomTypes();
        foreach ($data as $row) {
            echo '<option>' . $row->description . '</option>';
        }
    }

    public function showPensionTypes()
    {
        // TODO: TOO MANY CODE DUPLICATIONS
        $data = $this->getPensionTypes();
        foreach ($data as $row) {
            echo '<option>' . $row->description . '</option>';
        }
    }

    public function checkinAdd($firstName, $lastName, $roomType, $pensionType, $dateTime, $numNights)
    {
        $conn = $this->connect();
        if ($conn) {
            $sql = "BEGIN sp_checkin(:fn, :ln, :dt, :num, :rt, :pt); END;";
            $stmt = oci_parse($conn, $sql);
            oci_bind_by_name($stmt, ':fn', $firstName);
            oci_bind_by_name($stmt, ':ln', $lastName);
            oci_bind_by_name($stmt, ':rt', $roomType);
            oci_bind_by_name($stmt, ':pt', $pensionType);
            oci_bind_by_name($stmt, ':dt', $dateTime);
            oci_bind_by_name($stmt, ':num', $numNights);
            $result = oci_execute($stmt, OCI_COMMIT_ON_SUCCESS);
            if (!$result) {
                $err = oci_error($stmt);
                // for now keep only oracle db error message - BAD WAY!
                return $err['message'];
            }
            oci_free_statement($stmt);
        }
        $this->disconnect();
        return null;
    }

    public function checkinAddGuest($firstName, $lastName, $primFirstName, $primLastName, $dateTime)
    {
        $conn = $this->connect();
        if ($conn) {
            $sql = "BEGIN sp_checkin_add(:fn, :ln, :dt, :pfn, :pln); END;";
            $stmt = oci_parse($conn, $sql);
            oci_bind_by_name($stmt, ':fn', $firstName);
            oci_bind_by_name($stmt, ':ln', $lastName);
            oci_bind_by_name($stmt, ':dt', $dateTime);
            oci_bind_by_name($stmt, ':pfn', $primFirstName);
            oci_bind_by_name($stmt, ':pln', $primLastName);
            $result = oci_execute($stmt, OCI_COMMIT_ON_SUCCESS);
            if (!$result) {
                $err = oci_error($stmt);
                // for now keep only oracle db error message - BAD WAY!
                return $err['message'];
            }
            oci_free_statement($stmt);
        }
        $this->disconnect();
        return null;
    }

    public function checkinAddRoom($firstName, $lastName, $dateTime, $roomType)
    {
        $conn = $this->connect();
        if ($conn) {
            $sql = "BEGIN sp_checkin_add_room(:dt, :fn, :ln, :rt); END;";
            $stmt = oci_parse($conn, $sql);
            oci_bind_by_name($stmt, ':fn', $firstName);
            oci_bind_by_name($stmt, ':ln', $lastName);
            oci_bind_by_name($stmt, ':dt', $dateTime);
            oci_bind_by_name($stmt, ':rt', $roomType);
            $result = oci_execute($stmt, OCI_COMMIT_ON_SUCCESS);
            if (!$result) {
                $err = oci_error($stmt);
                // for now keep only oracle db error message - BAD WAY!
                return $err['message'];
            }
            oci_free_statement($stmt);
        }
        $this->disconnect();
        return null;
    }

}