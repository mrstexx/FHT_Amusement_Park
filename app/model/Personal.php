<?php

include '../manager/DatabaseManager.php';

class Personal extends DatabaseManager
{
    private function getPersonalData()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM TABLE (f_getPersonalData_type)');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->personID = $row['PERSONID'];
                $rowObj->firstName = $row['VORNAME'];
                $rowObj->lastName = $row['NACHNAME'];
                $rowObj->gender = $row['GESCHLECHT'];
                $rowObj->departID = $row['ABTEILUNGID'];
                $rowObj->salaryID = $row['GEHALTSSTUFEID'];
                $rowObj->attractionID = $row['ATTRAKTIONID'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function getDepartments()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM ABTEILUNG');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->id = $row['ABTEILUNGID'];
                $rowObj->value = $row['BEZEICHNUNG'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function getSalaryRanges()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM GEHALTSSTUFE');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->id = $row['GEHALTSSTUFEID'];
                $rowObj->value = $row['MONATSGEHALT'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function getAttractions()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM ATTRAKTION');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->id = $row['ATTRAKTIONID'];
                $rowObj->value = $row['BEZEICHNUNG'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function getAssignedValue($data, $id)
    {
        foreach ($data as $dataObj) {
            if ($dataObj->id === $id) {
                return $dataObj->value;
            }
        }
        return "";
    }

    private function getPreparedData($data)
    {
        $preparedData = array();
        $attractions = $this->getAttractions();
        $departments = $this->getDepartments();
        $salaryRanges = $this->getSalaryRanges();
        foreach ($data as $dataObj) {
            $preparedDataObj = new stdClass();
            $preparedDataObj->personID = $dataObj->personID !== null ? "el-" . htmlentities($dataObj->personID, ENT_QUOTES) : "&nbsp;";
            $preparedDataObj->firstName = $dataObj->firstName !== null ? htmlentities($dataObj->firstName, ENT_QUOTES) : "&nbsp;";
            $preparedDataObj->lastName = $dataObj->lastName !== null ? htmlentities($dataObj->lastName, ENT_QUOTES) : "&nbsp;";
            $preparedDataObj->gender = $dataObj->gender !== null ? htmlentities($dataObj->gender, ENT_QUOTES) : "&nbsp;";
            $preparedDataObj->departmentVal = $this->getAssignedValue($departments, $dataObj->departID);
            $preparedDataObj->departments = $departments;
            $preparedDataObj->salaryRanges = $salaryRanges;
            $preparedDataObj->salaryVal = $this->getAssignedValue($salaryRanges, $dataObj->salaryID);
            $preparedDataObj->attractionVal = $this->getAssignedValue($attractions, $dataObj->attractionID);
            $preparedDataObj->attractions = $attractions;
            array_push($preparedData, $preparedDataObj);
        }
        return $preparedData;
    }

    public function showPersonalData()
    {
        $data = $this->getPersonalData();
        $preparedData = $this->getPreparedData($data);
        $counter = 1;
        // ext data is for null value
        $ext = new stdClass();
        $ext->id = 0;
        $ext->value = "";
        foreach ($preparedData as $row) {
            echo "<tr>";

            // client id
            echo '<th scope="row" id="' . $row->personID . '">' . $counter . '</th>';

            // first name
            echo '<td>' . $row->firstName . '</td>';

            // last name
            echo '<td>' . $row->lastName . '</td>';

            // gender
            echo '<td>' . $row->gender . '</td>';

            // department
            array_push($row->departments, $ext);
            echo '<td><div class="form-group"><select class="form-control">';
            foreach ($row->departments as $option) {
                $selected = $option->value === $row->departmentVal ? 'selected' : '';
                echo '<option id="el-' . $option->id . '" ' . $selected . '>' . $option->value . '</option>';
            }
            echo '</select></div></td>';

            // salary
            array_push($row->salaryRanges, $ext);
            echo '<td><div class="form-group"><select class="form-control">';
            foreach ($row->salaryRanges as $option) {
                $selected = $option->value === $row->salaryVal ? 'selected' : '';
                echo '<option id="el-' . $option->id . '" ' . $selected . '>' . $option->value . '</option>';
            }
            echo '</select></div></td>';

            // attraction
            array_push($row->attractions, $ext);
            echo '<td><div class="form-group"><select class="form-control">';
            foreach ($row->attractions as $option) {
                $selected = $option->value === $row->attractionVal ? 'selected' : '';
                echo '<option id="el-' . $option->id . '" ' . $selected . '>' . $option->value . '</option>';
            }
            echo '</select></div></td>';
            echo "</tr>";
            $counter++;
        }
    }

    public function updatePersonalData($newData)
    {
        $conn = $this->connect();
        $noError = true;
        if ($conn) {
            foreach ($newData as $entry) {
                $personID = $entry['personID'];
                $newDepID = $entry['newDepartmentID'] === "0" ? null : $entry['newDepartmentID'];
                $newSalaryID = $entry['newSalaryID'] === "0" ? null : $entry['newSalaryID'];
                $newAttrID = $entry['newAttractionID'] === "0" ? null : $entry['newAttractionID'];

                // update data
                $sql = "BEGIN sp_updatePersonalData(:personID, :depID, :salaryID, :attrID); END;";
                $stmt = oci_parse($conn, $sql);
                oci_bind_by_name($stmt, ':personID', $personID);
                oci_bind_by_name($stmt, ':depID', $newDepID);
                oci_bind_by_name($stmt, ':salaryID', $newSalaryID);
                oci_bind_by_name($stmt, ':attrID', $newAttrID);
                $result = oci_execute($stmt, OCI_COMMIT_ON_SUCCESS);
                if (!$result) {
                    $noError = false;
                    echo oci_error();
                }
                oci_free_statement($stmt);
            }
        }
        $this->disconnect();
        return $noError;
    }
}