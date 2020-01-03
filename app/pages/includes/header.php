<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Amusement Parm Management System</title>

    <!-- Google Font-->
    <link href="https://fonts.googleapis.com/css?family=Raleway&display=swap" rel="stylesheet">
    <!--Font Awesome-->
    <script src="https://kit.fontawesome.com/cdc29819ee.js" crossorigin="anonymous"></script>
    <!--Bootstrap CSS CDN-->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
          integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <!--Own CSS-->
    <link rel="stylesheet" href="../../style/style.css">


    <!--Bootstrap JS CDN-->
    <script src="https://code.jquery.com/jquery-3.4.1.min.js"
            integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
            crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js"
            integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo"
            crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"
            integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6"
            crossorigin="anonymous"></script>
</head>
<body>

<div class="wrapper">
    <!-- Sidebar -->
    <nav id="sidebar">
        <div class="sidebar-header">
            <h3>Amusement Park System</h3>
        </div>

        <ul class="list-unstyled components">
            <!--            <li class="active">-->
            <!--                <a href="#homeSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">Start-->
            <!--                    Page</a>-->
            <!--                <ul class="collapse list-unstyled" id="homeSubmenu">-->
            <!--                    <li>-->
            <!--                        <a href="#">Home 1</a>-->
            <!--                    </li>-->
            <!--                    <li>-->
            <!--                        <a href="#">Home 2</a>-->
            <!--                    </li>-->
            <!--                    <li>-->
            <!--                        <a href="#">Home 3</a>-->
            <!--                    </li>-->
            <!--                </ul>-->
            <!--            </li>-->
            <li class="<?php if (strpos($_SERVER['PHP_SELF'], 'new_ticket.php') != false
                || strpos($_SERVER['PHP_SELF'], 'index.php') != false) {
                echo "active";
            } ?>">
                <a href="<?php echo isset($path) ? $path : ""; ?>new_ticket.php"><i class="fas fa-ticket-alt fa-fw"></i>
                    New
                    Ticket</a>
            </li>
            <li class="<?php if (strpos($_SERVER['PHP_SELF'], 'invoices.php') !== false) {
                echo "active";
            } ?>">
                <a href="<?php echo isset($path) ? $path : ""; ?>invoices.php"><i class="fas fa-receipt fa-fw"></i>
                    Invoices</a>
            </li>
            <li>
                <a href="#"><i class="fas fa-user fa-fw"></i> Guests</a>
            </li>
            <li class="<?php if (strpos($_SERVER['PHP_SELF'], 'rooms.php') !== false) {
                echo "active";
            } ?>">
                <a href="<?php echo isset($path) ? $path : ""; ?>rooms.php"><i class="fas fa-bed fa-fw"></i> Rooms</a>
            </li>
            <li class="<?php if (strpos($_SERVER['PHP_SELF'], 'employees.php') !== false) {
                echo "active";
            } ?>">
                <a href="<?php echo isset($path) ? $path : ""; ?>employees.php"><i class="far fa-id-badge fa-fw"></i>
                    Employees</a>
            </li>
        </ul>
    </nav>