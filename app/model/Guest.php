<?php

include "../manager/DatabaseManager.php";

class Guest extends DatabaseManager
{

    private function getGuestData()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM gaeste_view_grouped ORDER BY VON DESC');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->firstName = $row['VORNAME'];
                $rowObj->lastName = $row['NACHNAME'];
                $rowObj->dateFrom = $row['VON'];
                $rowObj->dateTo = $row['BIS'];
                $rowObj->pension = $row['PENSIONFORM'];
                $rowObj->roomNumbers = $row['ZIMMERNUMMERN'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    public function showGuestData()
    {
        $data = $this->getGuestData();
        foreach ($data as $row) {
            echo "<tr>";

            echo '<td>' . $row->firstName . '</td>';
            echo '<td>' . $row->lastName . '</td>';
            echo '<td>' . $row->dateFrom . '</td>';
            echo '<td>' . $row->dateTo . '</td>';
            echo '<td>' . $row->pension . '</td>';
            echo '<td>' . $row->roomNumbers . '</td>';

            echo "</tr>";
        }
    }

}