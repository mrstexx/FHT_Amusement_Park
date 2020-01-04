<?php

include "../manager/DatabaseManager.php";

class Invoice extends DatabaseManager
{

    private function getGuestNames($invoiceID)
    {
        // execute here PL/SQL procedure to get guests names
        // expected varchar of all guests
    }

    private function getInvoicePrice($invoiceID)
    {
        // execute here PL/SQL procedure to get price of invoice ID
    }

    private function getInvoiceData()
    {
        // get data from rechnung_view;
    }

    private function getData()
    {
        $data = array();
        return $data;
    }

    private function prepareData($data)
    {
        // match all data here and create final array of data
    }

    public function showAllInvoices()
    {
        $data = $this->getData();
        $this->prepareData($data);

        foreach ($data as $row) {

        }

    }

}