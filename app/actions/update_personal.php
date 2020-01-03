<?php

include "../model/Personal.php";

$newData = NULL;
$error = false;

if (isset($_POST['val'])) {
    $newData = $_POST['val'];
    $personal = new Personal();
    $error = !$personal->updatePersonalData($newData);
}

$retObj = new stdClass();

if ($error) {
    $retObj->error = true;
} else {
    $retObj->error = false;
}

echo json_encode($retObj);