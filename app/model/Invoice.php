<?php

include "../manager/DatabaseManager.php";

class Invoice extends DatabaseManager
{

    private function getGuestNames($invoiceID)
    {
        $connection = $this->connect();
        if ($connection) {
            $ret = "";
            $stmt = oci_parse($connection, 'BEGIN sp_invoice_guest_list(:iID, :ret); END;');
            oci_bind_by_name($stmt, ':iID', $invoiceID);
            oci_bind_by_name($stmt, ':ret', $ret, 255);
            oci_execute($stmt);
            oci_free_statement($stmt);
            if ($ret) {
                return $ret;
            }
        }
        $this->disconnect();
        return null;
    }

    private function getInvoicePrice($invoiceID)
    {
        $conn = $this->connect();
        if ($conn) {
            $ret = "";
            $stmt = oci_parse($conn, 'BEGIN sp_calculate_invoice_price(:iID, :ret); END;');
            oci_bind_by_name($stmt, ':iID', $invoiceID);
            oci_bind_by_name($stmt, ':ret', $ret, 20);
            oci_execute($stmt);
            oci_free_statement($stmt);
            if ($ret) {
                return $ret;
            }
        }
        $this->disconnect();
        return 0;
    }

    private function getInvoiceData()
    {
        $data = array();
        $conn = $this->connect();
        if ($conn) {
            $statement = oci_parse($conn, 'SELECT * FROM rechnung_view ORDER BY RECHNUNGID DESC');
            oci_execute($statement);
            while ($row = oci_fetch_array($statement, OCI_ASSOC + OCI_RETURN_NULLS)) {
                $rowObj = new stdClass();
                $rowObj->id = $row['RECHNUNGID'];
                $rowObj->date = $row['ZEITSTEMPEL'];
                $rowObj->nightsNum = $row['ANZAHL_NAECHTE'];
                $rowObj->pension = $row['BEZEICHNUNG'];
                array_push($data, $rowObj);
            }
            oci_free_statement($statement);
        }
        $this->disconnect();
        return $data;
    }

    private function prepareData($data)
    {
        foreach ($data as $row) {
            $row->price = $this->getInvoicePrice($row->id);
            $row->guestNames = $this->getGuestNames($row->id);
        }
    }

    public function showAllInvoices()
    {
        $data = $this->getInvoiceData();
        $this->prepareData($data);
        foreach ($data as $row) {
            echo '<div class="col-sm-6 invoice-card"><div class="card"><div class="card-body">';
            echo '<h5 class="card-title">Nr-' . sprintf("%06d", $row->id) . '</h5>';
            echo '<div class="card-text">';
            echo 'Arrival Date: ' . $row->date . '<br>';
            echo 'Nights number: ' . $row->nightsNum . '<br>';
            echo 'Pension form: ' . $row->pension . '<br>';
            echo 'Price: <b>' . $row->price . '$</b><br><hr>';
            echo '<i>Guest name(s):</i> ';
            if (isset($row->guestNames)) {
                echo $row->guestNames;
            } else {
                echo 'No data';
            }
            echo '</div>';
            echo '</div></div></div>';
        }
    }
}