<?php

include "../model/CheckIn.php";

$firstName = $_POST['firstName'];
$lastName = $_POST['lastName'];
$roomType = $_POST['roomType'];
$pensionType = $_POST['pensionType'];
$dateTime = $_POST['datetime'];
$numNights = (int)$_POST['nights'];

$ci = new CheckIn();

$retMsg = $ci->checkinAdd($firstName, $lastName, $roomType, $pensionType, $dateTime, $numNights);

if ($retMsg) {
    echo $retMsg;
} else {
    echo true;
}