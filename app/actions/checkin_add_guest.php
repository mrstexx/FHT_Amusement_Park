<?php

include "../model/CheckIn.php";

// TODO: isset needed - form validation
$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];
$primFirstName = $_POST['primFirstName'];
$primLastName = $_POST['primLastName'];
$date = $_POST['datetime'];

$ci = new CheckIn();

$retMsg = $ci->checkinAddGuest($firstName, $lastName, $primFirstName, $primLastName, $date);

if ($retMsg) {
    echo $retMsg;
} else {
    echo true;
}