<?php

include '../manager/DatabaseManager.php';

class Employee
{

    public function showAllEmployees()
    {
        $db = new DatabaseManager();
        $conn = $db->connect();
        if ($conn) {
            echo "It works";
        }
        $db->disconnect();
    }

}