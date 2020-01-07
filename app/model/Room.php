<?php

include "../manager/DatabaseManager.php";

class Room extends DatabaseManager
{
    private function getRoomData()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM zimmer_view');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->number = $row['ZIMMERNUMMER'];
                $rowObj->description = $row['BEZEICHNUNG'];
                $rowObj->price = $row['PREIS'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function preparedRoomData($data)
    {
        $conn = $this->connect();
        if ($conn) {
            foreach ($data as $row) {
                $ret = "";
                $stmt = oci_parse($conn, 'BEGIN sp_room_status(:nr, :ret); END;');
                oci_bind_by_name($stmt, ':nr', $row->number);
                oci_bind_by_name($stmt, ':ret', $ret, 20);
                oci_execute($stmt);
                $row->status = $ret;
                oci_free_statement($stmt);
            }
        }
        $this->disconnect();
    }

    public function showRoomData()
    {
        $data = $this->getRoomData();
        $this->preparedRoomData($data);
        $counter = 1;
        foreach ($data as $row) {
            echo "<tr>";

            echo '<th scope="row">' . $counter . '</th>';

            echo '<td>' . $row->number . '</td>';
            echo '<td>' . $row->description . '</td>';
            echo '<td>' . $row->price . '</td>';

            if ($row->status) {
                echo '<td class="room-status-2">Leaving: ' . $row->status . '</td>';
            } else {
                echo '<td class="room-status-1">Free</td>';
            }
            echo "</tr>";
            $counter++;
        }
    }
}