<?php

include "../model/CheckIn.php";

// TODO: isset needed - form validation
$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];
$date = $_POST['datetime'];
$roomType = $_POST['roomType'];

$ci = new CheckIn();

$retMsg = $ci->checkinAddRoom($firstName, $lastName, $date, $roomType);

if ($retMsg) {
    echo $retMsg;
} else {
    echo true;
}